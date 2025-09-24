#!/bin/bash

# Variables
BURP_DIR="/usr/share/burpsuitepro"
BURP_SCRIPT="/usr/local/bin/burpsuitepro"

print_status() {
    echo -e "\e[1;34m$1\e[0m"
}

remove_old_files() {
    print_status 'Removing Old Files...'
    sudo rm -f "$BURP_DIR"/*.jar || { echo "Failed to remove old JAR files!"; exit 1; }
    sudo rm -f "$BURP_SCRIPT" || { echo "Failed to remove old script!"; exit 1; }
}

main () {
    remove_old_files
    print_status "Uninstallation complete!"
}

main "$@"
