#! /bin/sh

if test ! -f configure.ac ; then
  echo "*** Please invoke this script from directory containing configure.ac."
  exit 1
fi

MACROFILE=acinclude.m4
MACRODIR=mk/config

rm -f $MACROFILE
for i in $MACRODIR/*.m4 ; do
  cat $i >> $MACROFILE
done

autom4te --prepend-include=$MACRODIR --language=m4sh mk/config/getversion.m4sh -o mk/scripts/getversion.sh

# aclocal
# automake --add-missing --foreign --force-missing --copy
autoreconf -B mk/config/ -I mk/config/ --install

rm -f aclocal.m4
rm -rf autom4te.cache

# exit $rc
