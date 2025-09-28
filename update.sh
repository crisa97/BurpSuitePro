#!/bin/bash

# Variables
BURP_DIR="/usr/share/burpsuitepro"
BURP_SCRIPT="burpsuitepro"
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
    version=$(echo "$html" | jq '.ResultSet.Results[] | select(.releaseChannels[] == "Stable") | .builds[] | select(.ProductId == "pro" and .ProductPlatform == "Linux")' | grep '"Version"' | awk -F'"' '{print $4}' | head -n1)
    if [[ "$ACTUAL_VERSION" == "$version" ]]; then
        print_status 'BurpSuitePro in its latest version.';  exit 1;
    else 
        print_status 'Upgrading Burp Suite Professional...'
        print_status "Please wait while we complete the process :)"
        download_link="https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar&version=$version&"
        echo "$version" > version.txt
        sudo wget "$download_link" -O "$BURP_DIR/burpsuite_pro.jar" -q --progress=bar:force || error_status "Download failed!"
        print_status "Burp Suite successfully updated :D"
    fi       
}

execute_burpsuite() {
    print_status 'Executing Burp Suite Professional...'
    "$BURP_SCRIPT" > /dev/null 2>&1 & disown || { error_status "Failed to launch Burp Suite!"; exit 1; }
}

main() {
    upgrad_burpsuite
    execute_burpsuite
}

main "$@"