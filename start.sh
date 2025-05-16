#!/bin/bash
nez_ver="v0.15.5"
nezboard_ver="v0.17.8"
XRAY_VERSION="v25.3.6"
SB_VERSION="1.10.7"
gost_ver="3.0.0-rc10"
caddy="2.9.1"
FRP_VERSION="0.62.1"
ND_VERSION="1.2.1"
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
check_install wget
check_install unzip
#check_install upx
check_install openssl
# Create download directory
mkdir -p download
cd download
openssl ecparam -genkey -name prime256v1 -out "./private.key"
openssl req -new -x509 -days 3650 -key "./private.key" -out "./cert.pem" -subj "/CN=bing.com"
# Define versions and platforms
PLATFORMS=("linux-amd64" "linux-arm64" "freebsd-amd64")
PLATFORM=("linux_amd64" "linux_arm64" "freebsd_amd64")
# Download and extract Nezha panel and client
for platform in "${PLATFORMS[@]}"; do
    wget https://github.com/fmnx/cftun/releases/download/v2.1.0/cftun-$platform.tar.gz
    tar zxvf cftun-$platform.tar.gz
    rm -rf "./cftun-$platform.tar.gz"
    echo "Processing Nezha panel for $platform..."
    curl -sLo "sb-$platform.tar.gz" "https://github.com/SagerNet/sing-box/releases/download/v${SB_VERSION}/sing-box-${SB_VERSION}-${platform}.tar.gz"
    tar -xzvf "sb-$platform.tar.gz" -C "./"
    mv "./sing-box-${SB_VERSION}-$platform/sing-box" "./sb-$platform"
    rm -rf "sb-$platform.tar.gz"
    rm -rf "./sing-box-${SB_VERSION}-$platform"
    
    wget -q -O "nezha-panel-$platform.zip" "https://github.com/naiba/nezha/releases/download/${nezboard_ver}/dashboard-$platform.zip"
    unzip -o "nezha-panel-$platform.zip" -d "nezha-panel-$platform"
    mv "./nezha-panel-$platform/dist/dashboard-$platform" "./board-$platform"
    rm -rf "./nezha-panel-$platform" "nezha-panel-$platform.zip"
    rm -rf "./nezha-panel-$platform"
done
echo "board-${nezboard_ver}" > board-${nezboard_ver}.log
echo "sb-${SB_VERSION}" > sb-${SB_VERSION}.log
for platfor in "${PLATFORM[@]}"; do
     curl -sLo "nodepass_${ND_VERSION}_$platfor.tar.gz" "https://github.com/yosebyte/nodepass/releases/download/v${ND_VERSION}/nodepass_${ND_VERSION}_$platfor.tar.gz"
   tar -xzvf "nodepass_${ND_VERSION}_$platfor.tar.gz"
    mv "nodepass" "nodepass-$platfor"
    rm "nodepass_${ND_VERSION}_$platfor.tar.gz"
 echo "Processing Nezha agent for $platfor..."
    curl -sLo "gost-$platfor.tar.gz" "https://github.com/go-gost/gost/releases/download/v${gost_ver}/gost_${gost_ver}_$platfor.tar.gz"
    tar -xzvf "gost-$platfor.tar.gz"
    mv "gost" "gost-$platfor"
    rm "gost-$platfor.tar.gz"
    wget -q -O "nezha-agent-$platfor.zip" "https://github.com/nezhahq/agent/releases/download/${nez_ver}/nezha-agent_$platfor.zip"
    unzip -j "nezha-agent-$platfor.zip" "nezha-agent" -d "."
    mv "nezha-agent" "agent-$platfor"
    rm "nezha-agent-$platfor.zip"
    curl -sLo "caddy-$platfor.tar.gz" "https://github.com/caddyserver/caddy/releases/download/v${caddy}/caddy_${caddy}_$platfor.tar.gz"
    tar -xzvf "caddy-$platfor.tar.gz"
    mv "caddy" "caddy-$platfor"
    rm -rf "caddy-$platfor.tar.gz"
    wget -q -O "frp_${FRP_VERSION}_$platfor.tar.gz" "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_$platfor.tar.gz"
    tar -xf frp_${FRP_VERSION}_$platfor.tar.gz
    mv frp_${FRP_VERSION}_$platfor/frps ./frps-$platfor
    mv frp_${FRP_VERSION}_$platfor/frpc ./frpc-$platfor
    rm -rf frp_${FRP_VERSION}_$platfor*
    rm -rf LICENSE
    rm -rf README*.*
done
echo "agent-${nez_ver}" > agent-${nez_ver}.log
echo "frp-${FRP_VERSION}" > frp-${FRP_VERSION}.log
echo "gost-${gost_ver}" > gost-${gost_ver}
#curl -sLo "cff-freebsd-amd64" "https://eooce.2go.us.kg/bot"
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
        rm -rf "Xray-$platform.zip"
    done
    echo "Xray-${XRAY_VERSION}" > "web-${XRAY_VERSION}.log"
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
curl -sLo "cff-freebsd-amd64" "https://github.com/eooce/test/releases/download/freebsd/bot"
curl -sLo "sb-freebsd-amd64" "https://github.com/eooce/test/releases/download/freebsd/sb"
files=(
          "agent-freebsd_amd64"
          "agent-linux_amd64"
          "agent-linux_arm64"
          "cff-linux-amd64"
          "cff-linux-arm64"
          "cff-freebsd-amd64"
          "web-freebsd-amd64"
          "web-linux-amd64"
          "web-linux-arm64"
          "sb-linux-amd64"
          "sb-linux-arm64"
          "sb-freebsd-amd64"
          "board-linux-amd64"
          "board-linux-arm64"
          "gost-linux_amd64"
          "gost-linux_arm64"
          "frps-linux_amd64"
          "frps-linux_arm64"
          "frps-freebsd_amd64"
)

# 循环检查每个文件
for file_path in "${files[@]}"; do
    if [ -f "$file_path" ]; then
        if [ ! -s "$file_path" ]; then
            rm "$file_path"
            echo "文件 '$file_path' 已删除，因为它是空的。"
        else
            echo "文件 '$file_path' 存在且不为空。"
        fi
    else
        echo "文件 '$file_path' 不存在。"
    fi
done

# Compress binaries with UPX
#echo "Compressing binaries with UPX..."
#for file in board-* sb-* agent-* web-* cff-*; do
  #  upx -3 "$file" -o "${file}-up3"
#done

# Delete all non-executable files but keep .log files
#find . -type f ! -executable ! -name "*.log" ! -name "*.pem" ! -name "*.key" -delete

echo "Done. All executable files and .log files are in the 'download' directory."
