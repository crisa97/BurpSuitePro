#!/bin/bash

# Variables
BURP_DIR="/usr/share/burpsuitepro"
BURP_SCRIPT="/usr/local/bin/burpsuitepro"
BURP_RELEASES_URL="https://portswigger.net/burp/releases/data?pageSize=10"
LOADER_JAR_URL="https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/BurpLoaderKeyGen.jar"

print_status() {
    echo -e "\e[1;34m$1\e[0m"
}

error_status() {
    echo -e "\e[1;31m$1\e[0m"
    exit 1
}

download_burpsuite() {
    print_status "Downloading the latest Burp Suite Professional..."
    print_status "Please wait while we complete the process :)"
    local html version download_link
    sudo mkdir -p "$BURP_DIR" || error_status "Failed to make directory '$BURP_DIR'"
    html=$(curl -s "$BURP_RELEASES_URL")
    version=$(echo "$html" | jq -r '[.ResultSet.Results[] | select(.releaseChannels[] == "Stable" and (.categories | index("DAST") | not))] | first | .version')
    [[ -n "$version" && "$version" != "null" ]] || error_status "No se pudo obtener la versión desde la API"
    download_link="https://portswigger.net/burp/releases/download?product=desktop&version=$version&type=Jar"
    echo "$version" > version.txt
    sudo curl -L --fail --progress-bar  "$download_link" -o "$BURP_DIR/burpsuite_pro.jar"  || error_status "Download failed!"
    print_status "Downloaded Burp Suite Version: $version" 
}

download_loader_jar() {
    print_status "Downloading the latest Burp Loader Key Generator..."
    sudo wget "$LOADER_JAR_URL" -O "$BURP_DIR/BurpLoaderKeyGen.jar" -q --progress=bar:force || error_status "Failed to download BurpLoaderKeyGen.jar!"
}

generate_script() {
    print_status "Generating executable script for Burp Suite Professional..."
    sudo tee "$BURP_SCRIPT" > /dev/null << EOF
#!/bin/bash
java \\
  --add-opens=java.desktop/javax.swing=ALL-UNNAMED \\
  --add-opens=java.base/java.lang=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \\
  -javaagent:$BURP_DIR/BurpLoaderKeyGen.jar \\
  -noverify \\
  -jar $BURP_DIR/burpsuite_pro.jar &
EOF

    sudo chmod +x "$BURP_SCRIPT" || error_status "Failed to make the script executable!"
    print_status "Script generated at $BURP_SCRIPT"
}

launch_burpsuite() {
    print_status "Launching Burp Suite Professional..."
    "$BURP_SCRIPT" > /dev/null 2>&1 &
    local pid=$!
    sleep 10s
    kill -0 "$pid" 2>/dev/null || error_status "Failed to launch Burp Suite!"
}

start_key_generator() {
    print_status "Starting Key Generator..."
    java -jar "$BURP_DIR/BurpLoaderKeyGen.jar" > /dev/null 2>&1 & disown || { error_status "Failed to start the Key Generator!"; exit 1; }
    print_status "Key Generator process has started. Follow the instructions to generate the key."
}

check_installed() {
    if [[ -f "$BURP_DIR/burpsuite_pro.jar" ]]; then
        print_status "Burp Suite Professional ya está instalado (versión $(cat version.txt 2>/dev/null || cat "$BURP_DIR/version.txt" 2>/dev/null || echo "desconocida"))."
        read -rp "¿Reinstalar? (s/N): " confirm
        [[ "$confirm" =~ ^[sS]$ ]] || { print_status "Cancelado."; exit 0; }
    fi
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
    check_installed
    download_burpsuite
    download_loader_jar
    generate_script
    launch_burpsuite
    start_key_generator
}

main "$@"
