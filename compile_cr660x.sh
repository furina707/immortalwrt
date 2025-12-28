#!/bin/bash

# Xiaomi CR660x Compilation Script for Debian 11
# Run this script on your remote server (as root)

set -e

# Bypass root check for certain tools
export FORCE_UNSAFE_CONFIGURE=1

# 1. Check for Root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo ">>> Fixing Debian 11 Sources..."
cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
EOF

echo ">>> Updating System and Installing Dependencies..."
apt update
apt install -y build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev \
libncursesw5-dev libssl-dev python3 python3-distutils python3-setuptools \
python3-dev rsync subversion swig time xsltproc zlib1g-dev unzip wget \
qemu-utils

# 2. Setup Swap (Critical for 2GB RAM)
if [ ! -f /swapfile ]; then
    echo ">>> Creating 4GB Swap File..."
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "Swap created."
else
    echo "Swap file already exists."
fi

# 3. Clone Source Code
if [ ! -d "immortalwrt" ]; then
    echo ">>> Cloning ImmortalWrt Source..."
    git clone -b master --single-branch https://github.com/immortalwrt/immortalwrt.git
fi

cd immortalwrt

# 4. Update Feeds
echo ">>> Updating Feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 5. Configure for Xiaomi CR660x (CR6608 default)
echo ">>> Configuring for Xiaomi CR660x..."
# Reset config
rm -f .config

# Write target config
cat > .config <<EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_xiaomi_mi-router-cr6608=y
# CONFIG_TARGET_ramips_mt7621_DEVICE_xiaomi_mi-router-cr6606 is not set
# CONFIG_TARGET_ramips_mt7621_DEVICE_xiaomi_mi-router-cr6609 is not set
CONFIG_LUCI_LANG_zh_Hans=y
CONFIG_PACKAGE_luci=y
EOF

# Expand to full configuration
make defconfig

# 6. Download Sources
echo ">>> Downloading Sources (this may take a while)..."
make download -j8

# 7. Compile
echo ">>> Starting Compilation..."
echo "Use 'screen' or 'tmux' if you are afraid of SSH disconnects."
# Using -j2 to be safe on 2GB RAM + Swap. -j$(nproc) might OOM.
make -j2 || make -j1 V=s

echo ">>> Compilation Complete!"
echo "Firmware should be in bin/targets/ramips/mt7621/"
