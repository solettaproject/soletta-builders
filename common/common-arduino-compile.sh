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

if [ -z "$COMPILE_DIR" ]; then
    echo "Prepare script need to set COMPILE_DIR before including ${BASH_SOURCE[0]}"
    exit 1
fi

rm -rf $COMPILE_DIR/RIOT/examples/soletta_app
cp -r $COMPILE_DIR/RIOT/examples/soletta_app_base $COMPILE_DIR/RIOT/examples/soletta_app

# TODO: better support for subdirectories in the build itself, the current code
# might have conflicts (plat-riot/info.c and plat-arm/info.c).
cp * */* $COMPILE_DIR/RIOT/examples/soletta_app/

make WERROR=0 -C $COMPILE_DIR/RIOT/examples/soletta_app

if [ $? -ne 0 ]; then
    exit 1
fi

mkdir $PLATFORM_NAME
