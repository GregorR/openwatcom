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

pushd w32loadr && builder clean ; popd
pushd dip && builder clean ; popd
pushd mad && builder clean ; popd
builder clean
rm -f build/binl/{builder,wcc386,wcl,wlink,wpp,wpp386,wstrip,wstub.exe,wtouch}
rm -f re2c/linux386/re2c.{exe,sym}
rm -f yacc/linux386/yacc.{exe,sym}
find . -name prebuild | xargs rm -rf
find . -name bootstrp | xargs rm -rf
rmobj

cd ../contrib
rm -f wattcp/lib/wattcpwl.lib
rmobj
