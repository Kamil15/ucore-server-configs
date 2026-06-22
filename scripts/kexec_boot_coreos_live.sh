#!/bin/bash
# 1. Get current stable version
VER=$(curl -s https://builds.coreos.fedoraproject.org/streams/stable.json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); \
    print(d['architectures']['x86_64']['artifacts']['metal']['release'])")

BASE="https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${VER}/x86_64"

# 2. Download all three artifacts
curl -O "${BASE}/fedora-coreos-${VER}-live-kernel-x86_64"
curl -O "${BASE}/fedora-coreos-${VER}-live-initramfs.x86_64.img"
curl -O "${BASE}/fedora-coreos-${VER}-live-rootfs.x86_64.img"

# 3. Combine initramfs + rootfs
cat fedora-coreos-${VER}-live-initramfs.x86_64.img \
    fedora-coreos-${VER}-live-rootfs.x86_64.img \
    > combined.img

# 4. Load and execute
kexec -l fedora-coreos-${VER}-live-kernel-x86_64 \
  --initrd=combined.img \
  --append="ip=dhcp rd.neednet=1 ignition.platform.id=metal"

sync && kexec -e