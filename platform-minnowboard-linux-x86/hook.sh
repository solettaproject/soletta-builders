#!/bin/bash

# This file is part of the Soletta Project
#
# Copyright (C) 2015 Intel Corporation. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

pacman --root=$ROOTFS --noconfirm -S \
       icu

cp -r soletta-target/build/soletta_sysroot/* $ROOTFS/

if [[ -n $DRONE_PACKAGES_URL ]]; then
    wget "$DRONE_PACKAGES_URL/linux-minnow-drone-4.1.4-1-x86_64.pkg.tar.xz"
    wget "$DRONE_PACKAGES_URL/low-speed-spidev-minnow-drone-git-r15.2d52b1d-3-x86_64.pkg.tar.xz"
else
    echo "Could not download kernel and low-speed-spidev module. Please, set DRONE_PACKAGES_URL variable."
    exit 1
fi

pacman --root=$ROOTFS --noconfirm -U linux-minnow-drone-4.1.4-1-x86_64.pkg.tar.xz
pacman --root=$ROOTFS --noconfirm -U low-speed-spidev-minnow-drone-git-r15.2d52b1d-3-x86_64.pkg.tar.xz

cat > $ROOTFS/boot/loader/loader.conf <<EOF
default minnow-drone*
EOF

cat > $ROOTFS/boot/loader/entries/minnow-drone.conf <<EOF
title      Arch Linux
options    console=ttyS0,115200 console=tty0 rw quiet
linux      /vmlinuz-linux-minnow-drone
initrd     /initramfs-linux-minnow-drone.img
EOF

cat > $ROOTFS/etc/systemd/system/app.service <<EOF
[Unit]
Description=app

[Service]
ExecStart=/usr/bin/app

[Install]
WantedBy=multi-user.target
EOF

systemctl --root=$ROOTFS enable app.service
