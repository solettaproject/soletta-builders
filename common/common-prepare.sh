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

if [ -z "$PREPARE_DIR" ]; then
    echo "Prepare script need to set PREPARE_DIR before including ${BASH_SOURCE[0]}"
    exit 1
fi

PLATFORM_NAME=$(echo "$(basename $PREPARE_DIR)" | sed -e 's/platform-//')
COMPILE_DIR=$PREPARE_DIR/../out/platform-$PLATFORM_NAME

if [ -n "$PARALLEL_JOBS" ]; then
    PARALLEL_JOBS=8
fi

trap '
    ret=$?;
    set +e;
    if [[ $ret -ne 0 ]]; then
	echo FAILED TO PREPARE >&2
    fi
    exit $ret;
    ' EXIT

trap 'exit 1;' SIGINT

rm -rf $COMPILE_DIR
mkdir -p $COMPILE_DIR
cd $COMPILE_DIR

if [[ -z "$SOLETTA_TARGET_REPO" ]]; then
    export SOLETTA_TARGET_REPO="https://github.com/solettaproject/soletta.git"
    export SOLETTA_TARGET_BRANCH="master"
fi

if [[ -z "$SOLETTA_HOST_REPO" ]]; then
    export SOLETTA_HOST_REPO="https://github.com/solettaproject/soletta.git"
    export SOLETTA_HOST_BRANCH="master"
fi

git clone "$SOLETTA_HOST_REPO" soletta-host
if [ $? -ne 0 ]; then
    exit 1
fi

pushd soletta-host

make alldefconfig
if [ $? -ne 0 ]; then
    exit 1
fi

make -j $PARALLEL_JOBS build/soletta_sysroot/usr/bin/sol-fbp-generator
if [ $? -ne 0 ]; then
    exit 1
fi

popd
