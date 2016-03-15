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

if [ -z "$1" -o -z "$2" ]; then
    exit 1
fi

if [ ! -d "$2" ]; then
    exit 1
fi

DEV=$(losetup -f --show "$1")

echo $DEV

trap '
    ret=$?;
    set +e;
    umount $ROOTFS
    losetup -d $DEV
    if [[ $ret -ne 0 ]]; then
        echo FAILED TO COPY >&2
    fi
    exit $ret;
    ' EXIT

# clean up after ourselves no matter how we die.
trap 'exit 1;' SIGINT

ROOT=${DEV##*/}

SYSTEM_PART=/dev/${ROOT}p2

ROOTFS="/run/installer-$ROOT/system"
mkdir -p $ROOTFS

mount $SYSTEM_PART $ROOTFS

cp -r $2/* $ROOTFS/

