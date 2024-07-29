#!/bin/bash
nez_ver ="v0.18.2"
XRAY_VERSION="v1.8.23"
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
PLATFORMS=("linux-amd64" "linux-arm64" "freebsd-amd64")
PLATFORM=("linux_amd64" "linux_arm64" "freebsd_amd64")
# 下载并解压哪吒面板和客户端
for platform in "${PLATFORMS[@]}"; do
    echo "Processing Nezha for $platform..."

    wget -q -O "nezha-panel-$platform.zip" "https://github.com/naiba/nezha/releases/latest/download/dashboard-$platform.zip"
       
    # 解压缩并处理 dist 文件夹中的文件
    unzip -o "nezha-panel-$platform.zip" -d "nezha-panel-$platform"
    mv "./nezha-panel-$platform/dist/dashboard-$platform" "./board-$platform"
    rm -rf "./nezha-panel-$platform"
    rm -rf  "nezha-panel-$platform.zip"
    
done
for platfor in "${PLATFORM[@]}"; do
    echo "Processing Nezha for $platfor..."

    wget -q -O "nezha-agent-$platfor.zip" "https://github.com/nezhahq/agent/releases/download/${nez_ver}/nezha-agent_$platfor.zip"
    
    # 解压缩并处理 dist 文件夹中的文件

    unzip -j "nezha-agent-$platfor.zip" "nezha-agent" -d "."
    mv "nezha-agent" "agent-$platfor"
    rm "nezha-agent-$platfor.zip"
    
done
touch "nezha-agent-${nez_ver}"
# 下载 Xray
echo "Downloading Xray..."
if [ -n "$XRAY_VERSION" ]; then
    for platform in "${PLATFORMS[@]}"; do
        case $platform in
            "linux-amd64" | "linux_amd64") XRAY_PLATFORM="linux-64";;
            "linux-arm64" | "linux_arm64") XRAY_PLATFORM="linux-arm64-v8a";;
            "freebsd-amd64" | "freebsd_amd64") XRAY_PLATFORM="freebsd-64";;
        esac
        wget -q -O "Xray-$platform.zip" "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-$XRAY_PLATFORM.zip"
        unzip -j "Xray-$platform.zip" "xray" -d "."
        mv "xray" "web-$platform"
        rm "Xray-$platform.zip"
    done
    touch "Xray-${nez_ver}"
else
    echo "Failed to get Xray version, skipping Xray download."
fi

# 下载 Cloudflare
echo "Downloading Cloudflare..."
for platform in "${PLATFORMS[@]}"; do
    case $platform in
        "linux-amd64" | "linux_amd64") CF_PLATFORM="amd64";;
        "linux-arm64" | "linux_arm64") CF_PLATFORM="arm64";;
        "freebsd-amd64" | "freebsd_amd64") CF_PLATFORM="amd64";;
        "freebsd-arm64" | "freebsd_arm64") CF_PLATFORM="arm64";;
    esac
    wget -q -O "cff-$platform" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${platform%-*}-$CF_PLATFORM"
    chmod +x "cff-$platform"
done

# 删除所有非执行文件
find . -type f ! -executable -delete

echo "Done. All executable files are in the 'download' directory."
