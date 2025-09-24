#!/bin/bash

# Variables
BURP_DIR="/usr/share/burpsuitepro"
BURP_SCRIPT="burpsuitepro"
DOWNLOAD="https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar&version=&"
navegador="$HOME/BurpSuite-Pro/Linux/navegador.sh"

print_status() {
    echo -e "\e[1;34m$1\e[0m"
}

upgrad_burpsuite() {
    print_status 'Upgrading Burp Suite Professional... :)'
    bash $navegador $DOWNLOAD . >/dev/null 2>&1
    mv *.jar burpsuite_pro.jar && sudo mv burpsuite_pro.jar $BURP_DIR
    print_status "Burp Suite successfully updated :D"
}

execute_burpsuite() {
    print_status 'Executing Burp Suite Professional...'
    "$BURP_SCRIPT" > /dev/null 2>&1 & disown || { echo "Failed to launch Burp Suite!"; exit 1; }
}

main() {
    upgrad_burpsuite
    execute_burpsuite
}

main "$@"
