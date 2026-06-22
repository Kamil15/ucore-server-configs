#!/bin/bash

# Get URLs from JSON
read KERNEL INITRAMFS ROOTFS < <(curl -s https://builds.coreos.fedoraproject.org/streams/stable.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
pxe = d['architectures']['x86_64']['artifacts']['metal']['formats']['pxe']
print(pxe['kernel']['location'], pxe['initramfs']['location'], pxe['rootfs']['location'])
")

# Download
curl -O "$KERNEL"
curl -O "$INITRAMFS"
curl -O "$ROOTFS"

# Combine
cat fedora-coreos-*-live-initramfs.x86_64.img \
    fedora-coreos-*-live-rootfs.x86_64.img \
    > combined.img

# kexec
# kexec -l fedora-coreos-*-live-kernel.x86_64 \
#   --initrd=combined.img \
#   --append="ip=dhcp rd.neednet=1 ignition.platform.id=metal \
#     ignition.config.data=$(base64 -w0 live.ign)"

# sync && kexec -e