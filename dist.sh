#!/bin/bash
cd `dirname "$0"`

OW=openwatcom-1.9.0
CMD="owar owcc owranlib wasaxp wasm wasmps wasppc wbind wcc wcc386 wccaxp wcl wcl386 wclaxp wclmps wd wdis wdump wfc wfc386 wfl wfl386 whc whelp wipfc wlib wlink wmake wpp wpp386 wprof wrc wsample wstrip wtouch"

die() {
    echo "$1"
    exit 1
}

DESTDIR=.
if [ "$1" ]
then
    DESTDIR="$1"
fi

# make the root
mkdir "$DESTDIR"/usr || die 'Failed to mkdir usr'

# we'll put rel2 under usr/lib/openwatcom...
mkdir -p "$DESTDIR"/usr/lib &&
cp -af rel2 "$DESTDIR"/usr/lib/$OW ||
die 'Failed to copy rel2 to usr/lib'

# now make a wrapper script for all the commands
mkwrapper() {
    wname="$1"
    scr="$2"
    include="$3"
    echo '#!/bin/bash
WATCOM=`dirname "$0"`/../lib/'$OW'
export WATCOM
'"$scr"'

PATH="$WATCOM/binl:$PATH"
export PATH
if [ ! "$INCLUDE" ]
then
    '"$include"'
    export INCLUDE
fi

exec $WATCOM/binl/$SCR "$@"' > "$DESTDIR"/usr/lib/$OW/$wname || die 'Failed to install '$wname
    chmod 0755 "$DESTDIR"/usr/lib/$OW/$wname || die 'Failed to make '$wname' +x'
}

mkwrapper wrapper 'SCR=`basename "$0"`' 'INCLUDE="$WATCOM/lh"'
mkwrapper dos-wrapper 'SCR=`basename "$0"`; SCR=${SCR/dos-}' 'INCLUDE="$WATCOM/h"'

# now install the individual wrappers
mkdir -p "$DESTDIR"/usr/bin
for i in $CMD
do
    ln -s ../lib/$OW/wrapper "$DESTDIR"/usr/bin/$i || die 'Failed to install '$i
    ln -s ../lib/$OW/dos-wrapper "$DESTDIR"/usr/bin/dos-$i || die 'Failed to install dos-'$i
done
