#!/bin/bash

#
# TODO: Add parsing and adding output transfer into log file
#

MACHINE=$1
TOPSRCDIR=$2
TARGZFILE=$3

. $TOPSRCDIR/mk/integrate/common

FILEDIR=`echo $TARGZFILE | sed 's/\.tar\.gz//'`
TARFILE="$FILEDIR.tar"


LOGFILE="output.log"
RESULTS="`date +%y%m%d_%H%M%S`_$MACHINE"
GATHER="$GATHER $LOGFILE"
TMPDIR="TMP.$$"
COMP=`eval echo "\\${$MACHINE}"`

function runcmd()
{
    ssh "$COMP" "$1"
}

function download()
{
    scp "$COMP:~/$TMPDIR/$FILEDIR/$1" . >/dev/null
}

CMD=""
while read LINE; do
    CMD="$CMD $LINE >> $LOGFILE 2>&1;"
done < $TOPSRCDIR/mk/integrate/$MACHINE

CDDIR="cd ~/; cd $TMPDIR; cd $FILEDIR;"
scp "$TARGZFILE" "$COMP:" > /dev/null

CMD="rm -rf $TMPDIR; mkdir $TMPDIR; mv $TARGZFILE $TMPDIR; cd $TMPDIR; gzip -d $TARGZFILE; tar xf $TARFILE; cd $FILEDIR; $CMD tar cf $RESULTS.tar $GATHER"

runcmd "$CMD"

download "$RESULTS.tar"
runcmd "rm -rf $TMPDIR"
