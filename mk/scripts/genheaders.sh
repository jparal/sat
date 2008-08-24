#!/bin/sh

libname=$1
shift

libfile="../sat${libname}.h"
rm -f "$libfile"

echo "#ifndef __sat_sat${libname}_h__" >> "$libfile"
echo "#define __sat_sat${libname}_h__" >> "$libfile"
echo "" >> $libfile
echo "#include \"satsysdef.h\"" >> $libfile

while [ x"$1" != x ]
do
    # Modules goes to library file
    if ! echo "$1" | grep / > /dev/null; then
	echo "#include \"$libname/$1\"" >> "$libfile"
	shift
	continue
    fi

    # Assume that all header files from one module are after each other
    dir=`echo "$1" | sed 's|/.*||g'`
    modfile="sat$dir.h"

    rm -f "$modfile"
    echo "#ifndef __sat_${libname}_sat${dir}_h__" >> "$modfile"
    echo "#define __sat_${libname}_sat${dir}_h__" >> "$modfile"
    echo ""  >> "$modfile"
    echo "#include \"satsysdef.h\"" >> "$modfile"

    locdir=$dir
    while [ "$locdir" = "$dir" ]
    do
 	echo "#include \"${libname}/$1\"" >> "$modfile"
	shift
 	locdir=`echo "$1" | sed 's|/.*||g'`
    done

    echo ""  >> "$modfile"
    echo "#endif /* __sat_${libname}_sat${dir}_h__ */" >> "$modfile"

done

echo "" >> $libfile
echo "#endif /* __sat_sat${libname}_h__ */" >> $libfile
