#!/bin/bash

# Variables
BURP_DIR="/usr/share/burpsuitepro"
BURP_SCRIPT="/usr/local/bin/burpsuitepro"
BURP_RELEASES_URL="https://portswigger.net/burp/releases/data?pageSize=10"
ACTUAL_VERSION=$(< version.txt)

print_status() {
    echo -e "\e[1;34m$1\e[0m"
}

error_status() {
    echo -e "\e[1;31m$1\e[0m"
    exit 1
}

upgrad_burpsuite() {
    print_status 'Checking if there is a new version  ;'
    local html version download_link
    html=$(curl -s "$BURP_RELEASES_URL")
    version=$(echo "$html" | jq -r '[.ResultSet.Results[] | select(.releaseChannels[] == "Stable" and (.categories | index("DAST") | not))] | first | .version')
    [[ -n "$version" && "$version" != "null" ]] || error_status "No se pudo obtener la versión desde la API"
    if [[ "$ACTUAL_VERSION" == "$version" ]]; then
        print_status 'BurpSuitePro in its latest version.';  exit 0;
    else 
        print_status 'Upgrading Burp Suite Professional...'
        print_status "Please wait while we complete the process :)"
        download_link="https://portswigger.net/burp/releases/download?product=desktop&version=$version&type=Jar"
        echo "$version" > version.txt
        sudo curl -L --fail --progress-bar  "$download_link" -o "$BURP_DIR/burpsuite_pro.jar"  || error_status "Download failed!"
        print_status "Burp Suite successfully updated :D"
    fi       
}

execute_burpsuite() {
    print_status 'Executing Burp Suite Professional...'
    "$BURP_SCRIPT" > /dev/null 2>&1 & disown || { error_status "Failed to launch Burp Suite!"; exit 1; }
}

check_dependencies() {
    for cmd in jq curl java; do
        if ! command -v "$cmd" &> /dev/null; then
            error_status "Required dependency '$cmd' not found. Install it first."
        fi
    done
}

main() {
    check_dependencies
    upgrad_burpsuite
    execute_burpsuite
}

main "$@"
