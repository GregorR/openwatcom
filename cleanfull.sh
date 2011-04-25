#!/bin/bash
cd `dirname "$0"`

die() {
    echo "$1"
    exit 1
}

rmobj() {
    find . -name '*.obj' -o -name '*.lo1' -o -name '*.log' |
    xargs rm -f 2> /dev/null
}

. setvars.sh
cd bld

builder clean
rm -f build/binl/{builder,wcc386,wcl,wlink,wpp,wpp386,wstrip,wtouch}
find . -name prebuild | xargs rm -rf
find . -name bootstrp | xargs rm -rf
rmobj

cd ../contrib
rmobj
