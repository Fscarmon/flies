#!/bin/bash
nez_ver="v0.18.12"
nezboard_ver="v0.18.2"
XRAY_VERSION="v1.8.23"

# Check and install necessary tools
check_install() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 could not be found, installing..."
        sudo apt-get update && sudo apt-get install -y $1
    else
        echo "$1 is already installed."
    fi
}

check_install curl
check_install unzip
check_install upx

# Create download directory
mkdir -p download
cd download

# Define versions and platforms
PLATFORMS=("linux-amd64" "linux-arm64" "freebsd-amd64")
PLATFORM=("linux_amd64" "linux_arm64" "freebsd_amd64")

# Download and extract Nezha panel and client
for platform in "${PLATFORMS[@]}"; do
    echo "Processing Nezha panel for $platform..."

    wget -q -O "nezha-panel-$platform.zip" "https://github.com/naiba/nezha/releases/download/${nezboard_ver}/dashboard-$platform.zip"
    unzip -o "nezha-panel-$platform.zip" -d "nezha-panel-$platform"
    mv "./nezha-panel-$platform/dist/dashboard-$platform" "./board-$platform"
    rm -rf "./nezha-panel-$platform" "nezha-panel-$platform.zip"
done

for platfor in "${PLATFORM[@]}"; do
    echo "Processing Nezha agent for $platfor..."

    wget -q -O "nezha-agent-$platfor.zip" "https://github.com/nezhahq/agent/releases/download/${nez_ver}/nezha-agent_$platfor.zip"
    unzip -j "nezha-agent-$platfor.zip" "nezha-agent" -d "."
    mv "nezha-agent" "agent-$platfor"
    rm "nezha-agent-$platfor.zip"
done
echo "nezha-agent-${nez_ver}" > nezha-agent-${nez_ver}.log

# Download Xray
echo "Downloading Xray..."
if [ -n "$XRAY_VERSION" ]; then
    for platform in "${PLATFORMS[@]}"; do
        case $platform in
            "linux-amd64") XRAY_PLATFORM="linux-64";;
            "linux-arm64") XRAY_PLATFORM="linux-arm64-v8a";;
            "freebsd-amd64") XRAY_PLATFORM="freebsd-64";;
        esac
        wget -q -O "Xray-$platform.zip" "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-$XRAY_PLATFORM.zip"
        unzip -j "Xray-$platform.zip" "xray" -d "."
        mv "xray" "web-$platform"
        rm "Xray-$platform.zip"
    done
    echo "Xray-${XRAY_VERSION}" > "Xray-${XRAY_VERSION}.log"
else
    echo "Failed to get Xray version, skipping Xray download."
fi

# Download Cloudflare
echo "Downloading Cloudflare..."
for platform in "${PLATFORMS[@]}"; do
    case $platform in
        "linux-amd64") CF_PLATFORM="amd64";;
        "linux-arm64") CF_PLATFORM="arm64";;
        "freebsd-amd64") CF_PLATFORM="amd64";;
    esac
    wget -q -O "cff-$platform" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${platform%-*}-$CF_PLATFORM"
    chmod +x "cff-$platform"
done

# Compress binaries with UPX
echo "Compressing binaries with UPX..."
for file in board-* agent-* web-* cff-*; do
    upx -3 "$file" -o "${file}-up3"
done

# Delete all non-executable files but keep .log files
find . -type f ! -executable ! -name "*.log" -delete

echo "Done. All executable files and .log files are in the 'download' directory."
