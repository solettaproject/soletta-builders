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

usage() {
    echo "Usage: sudo ./$(basename $0) <device to be flashed, e.g., /dev/ttyACM0>" 1>&$1;
}

if [ -z "$1" ]; then
    echo "No device supplied, aborting..."
    usage 1
    exit 1
fi

if [ `uname` = "Linux" ]; then
    stty -F $1 raw ispeed 1200 ospeed 1200 cs8 -cstopb ignpar eol 255 eof 255
    ./bossac  -R -e -w -v -b ./*.hex
elif [ `uname` = "Darwin" ]; then
    stty -f $1 raw ispeed 1200 ospeed 1200 cs8 -cstopb ignpar eol 255 eof 255
    ./bossac_osx -R -e -w -v -b ./*.hex
else
    echo "CAUTION: No flash tool for your host system found!"
fi
