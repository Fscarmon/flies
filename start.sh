#!/bin/bash

# 检查并安装必要的工具
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

# 创建下载目录
mkdir -p download
cd download

# 定义版本和平台
PLATFORMS=("linux-amd64" "linux-arm64" "freebsd-amd64" "freebsd-arm64")

# 下载并解压哪吒面板和客户端
for platform in "${PLATFORMS[@]}"; do
    echo "Processing Nezha for $platform..."
    
    wget -q -O "nezha-panel-$platform.tar.gz" "https://github.com/naiba/nezha/releases/latest/download/nezha-panel-$platform.tar.gz"
    wget -q -O "nezha-agent-$platform.tar.gz" "https://github.com/naiba/nezha/releases/latest/download/nezha-agent-$platform.tar.gz"
    
    tar -xzf "nezha-panel-$platform.tar.gz"
    tar -xzf "nezha-agent-$platform.tar.gz"
    
    rm "nezha-panel-$platform.tar.gz" "nezha-agent-$platform.tar.gz"
    
    for file in nezha-{panel,agent,dashboard}; do
        if [ -f "$file" ]; then
            mv "$file" "${file}-${platform}"
        fi
    done
done

# 下载 Xray
echo "Downloading Xray..."
XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f 4)
if [ -n "$XRAY_VERSION" ]; then
    for platform in "${PLATFORMS[@]}"; do
        case $platform in
            "linux-amd64") XRAY_PLATFORM="linux-64";;
            "linux-arm64") XRAY_PLATFORM="linux-arm64-v8a";;
            "freebsd-amd64") XRAY_PLATFORM="freebsd-64";;
            "freebsd-arm64") XRAY_PLATFORM="freebsd-arm64";;
        esac
        wget -q -O "Xray-$platform.zip" "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-$XRAY_PLATFORM.zip"
        unzip -j "Xray-$platform.zip" "xray" -d "."
        mv "xray" "xray-$platform"
        rm "Xray-$platform.zip"
    done
else
    echo "Failed to get Xray version, skipping Xray download."
fi

# 下载 Cloudflare
echo "Downloading Cloudflare..."
for platform in "${PLATFORMS[@]}"; do
    case $platform in
        "linux-amd64") CF_PLATFORM="amd64";;
        "linux-arm64") CF_PLATFORM="arm64";;
        "freebsd-amd64") CF_PLATFORM="amd64";;
        "freebsd-arm64") CF_PLATFORM="arm64";;
    esac
    wget -q -O "cloudflared-$platform" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${platform%-*}-$CF_PLATFORM"
    chmod +x "cloudflared-$platform"
done

# 删除所有非执行文件
find . -type f ! -executable -delete

echo "Done. All executable files are in the 'download' directory."
