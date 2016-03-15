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

trap 'exit 1;' SIGINT

SCRIPT_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

function die() {
    echo "ERROR: $*" >&2
    exit 1
}

usage() {
    echo "
Usage:  ./$(basename $0) [OPTIONS]

OPTIONS
     -t             soletta target repo.
     -b             soletta target branch.
     -h             soletta host repo.
     -r             soletta host branch.
     -s             skip testing the `sol` tool and builds.
     -p             show this help.

     Host and target repos default to this soletta repo, e.g. ../, while
     host and target branches default to the current checked out branch.
" 1>&$1
}

OPT_SKIP_SOL_BUILDS=0

while getopts "t:b:h:r:p" o; do
    case "${o}" in
        t)
            export SOLETTA_TARGET_REPO="$OPTARG";;
        b)
            export SOLETTA_TARGET_BRANCH="$OPTARG";;
        h)
            export SOLETTA_HOST_REPO="$OPTARG";;
        r)
            export SOLETTA_HOST_BRANCH="$OPTARG";;
	s)
	    export OPT_TEST_SOL_BUILDS=1;;
        p)
            usage 1; exit 0;;
        \?)
            usage 2; exit 1;;
    esac
done

if [[ -z "$SOLETTA_TARGET_REPO" ]]; then
    export SOLETTA_TARGET_REPO="$SCRIPT_DIR/.."
fi

if [[ -z "$SOLETTA_HOST_REPO" ]]; then
    export SOLETTA_HOST_REPO="$SCRIPT_DIR/.."
fi

if [ $OPT_SKIP_SOL_BUILDS -eq 0 ]; then
    command -v go > /dev/null
    if [ $? -eq 1 ]; then
	die "Couldn't find go to build 'sol' tool. You can skip this by running with '-s' option."
    fi

    pushd $SCRIPT_DIR/sol > /dev/null
    go build
    if [ $? -eq 1 ]; then
	die "Failed to build 'sol' tool."
    fi

    go test
    if [ $? -eq 1 ]; then
	die "Failed to run 'sol' tests."
    fi
    popd > /dev/null
fi

for dir in $SCRIPT_DIR/platform-*/; do
    if [[ $dir =~ platform-[^galileo] ]]; then
	$dir/prepare
    fi

    if [ $? -ne 0 ]; then
	die "Failed to prepare $dir"
    fi
done

if [ $OPT_SKIP_SOL_BUILDS -eq 1 ]; then
    echo "Skipped building 'sol' tool and using it to build the test programs."
    exit
fi

# Use an alternative port to avoid conflict with any other manually
# ran sol server.
SOL_TOOL="$SCRIPT_DIR/sol/sol -addr=localhost:2223"

SERVER_OUTPUT=$(mktemp)

echo
echo "=== Running build server, output in: $SERVER_OUTPUT"
echo

pushd $SCRIPT_DIR/out > /dev/null
$SOL_TOOL -run-as-server 2>&1 > $SERVER_OUTPUT &

SERVER_PID=$!
popd > /dev/null

trap 'kill $SERVER_PID' EXIT

# Skip the platform-test since it always fail to compile, it's goal is
# to show the environment things would be compiled.

PLATFORMS=$($SOL_TOOL | grep -v 'platform-test')
echo $PLATFORMS | tr ' ' '\n'

for test in $SCRIPT_DIR/tests/*; do
    pushd $test > /dev/null
    for plat in $PLATFORMS; do
	echo
	echo "=== Using 'sol' tool to build '$test' for '$plat'"
	echo
	$SOL_TOOL $plat
	if [ $? -eq 1 ]; then
	    die "Failed building '$test' for '$plat'"
	fi
	# TODO: Check the actual build product!
    done
    popd > /dev/null
done

echo
echo OK!
echo
