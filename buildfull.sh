#!/bin/bash
cd `dirname "$0"`

die() {
    echo "$1"
    exit 1
}

builderd() {
    pushd "$1"
    shift
    builder "$@" || die 'Failed to build '"$1"
    popd
}

buildd() {
    DIR="$1"
    shift
    builderd "$DIR" rel2 "$@"
}

export PATH="$PWD/rel2/binl:$PATH"
export WATCOM="$PWD/rel2"
export INCLUDE="$PWD/rel2/lh"

# First do the bootstrap build
if [ ! -e rel2/binl/owcc ]
then
    bbuild="bash build.sh"
    if linux32 true
    then
        bbuild="linux32 bash build.sh"
    fi
    $bbuild || ( rm -rf rel2 ; die 'Failed to build bootstrap' )
fi

. setvars.sh
cd bld

builder clean
find . -name prebuild | xargs rm -rf
find . -name bootstrp | xargs rm -rf
find . -name '*.obj' | xargs rm -f

# Circular dependencies are hell, just use the host wlib
for i in wlib wcl386 wasm wrc
do
    cp -f ../rel2/binl/$i build/binl/b$i
done

# Force the C library and its dependencies first
buildd builder
buildd hdr
buildd os2api
buildd w16api
buildd w32api
buildd clib
buildd mathlib
buildd emu

# Then C++lib/rtdll
buildd dwarf
buildd cfloat
buildd cg
buildd owl
pushd yacc/linux386 && ( wmake || die 'Failed to build yacc' ) && cp yacc.exe ../../build/binl/byacc && popd
pushd re2c/linux386 && ( wmake || die 'Failed to build re2c' ) && cp re2c.exe ../../build/binl/re2c && popd
pushd sdk/rc && builder rel2 ; popd # No error-check here
buildd as
buildd plusplus/cpplib
buildd rtdll

# Other stuff
buildd emu86
pushd ../contrib/wattcp/src && ( wmake || die 'Failed to build wattcp' ) && popd

# Then build everything else
builder rel2 || die 'Failed to build world'

# Including the stuff we had to prevent it from building before
buildd w32loadr
buildd dip
buildd mad

cd ..

# Then make a use script for convenience
echo '#!/bin/bash
ORIGDIR=`pwd`
cd `dirname "$BASH_SOURCE"`
WATCOM=`pwd`
export WATCOM
cd "$ORIGDIR"
unset ORIGDIR
PATH="$WATCOM/binl:$PATH"
export PATH
INCLUDE="$WATCOM/lh"
export INCLUDE' > rel2/use.sh

echo '#!/bin/bash
ORIGDIR=`pwd`
cd `dirname "$BASH_SOURCE"`
WATCOM=`pwd`
export WATCOM
cd "$ORIGDIR"
unset ORIGDIR
PATH="$WATCOM/binl:$PATH"
export PATH
INCLUDE="$WATCOM/h"
export INCLUDE' > rel2/usedos.sh
