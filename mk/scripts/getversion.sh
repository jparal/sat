#!/bin/sh
#
# getversion.sh is created from version.m4 and version.m4sh.
#
# Copyright (c) 2004-2006 The Trustees of Indiana University and Indiana
#                         University Research and Technology
#                         Corporation.  All rights reserved.
# Copyright (c) 2004-2005 The University of Tennessee and The University
#                         of Tennessee Research Foundation.  All rights
#                         reserved.
# Copyright (c) 2004-2005 High Performance Computing Center Stuttgart,
#                         University of Stuttgart.  All rights reserved.
# Copyright (c) 2004-2005 The Regents of the University of California.
#                         All rights reserved.
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#



# AC_GET_VERSION(version_file, variable_prefix)
# -----------------------------------------------
# parse version_file for version information, setting
# the following shell variables:
#
#  prefix_VERSION
#  prefix_VERSION_BASE
#  prefix_VERSION_MAJOR
#  prefix_VERSION_MINOR
#  prefix_VERSION_MICRO
#  prefix_VERSION_GREEK
#  prefix_VERSION_PATCH
#  prefix_WANT_REVISION



srcfile="$1"
option="$2"

case "$option" in
    # svnversion can take a while to run.  If we don't need it, don't run it.
    --major|--minor|--micro|--greek|--base|--help)
        sat_ver_need_svn=0
        ;;
    *)
        sat_ver_need_svn=1
esac


if test -z "$srcfile"; then
    option="--help"
else

    : ${ac_ver_need_svn=1}
    : ${srcdir=.}
    : ${svnversion_result=-1}

        if test -f "$srcfile"; then
      SAT_VERSION_MAJOR="`sed '/^major=*/!d; s///;q' < \"\$srcfile\"`"
      SAT_VERSION_MINOR="`sed '/^minor=*/!d; s///;q' < \"\$srcfile\"`"
      SAT_VERSION_MICRO="`sed '/^micro=*/!d; s///;q' < \"\$srcfile\"`"
      SAT_VERSION_GREEK="`sed '/^greek=*/!d; s///;q' < \"\$srcfile\"`"
      SAT_WANT_REVISION="`sed '/^revision=*/!d; s///;q' < \"\$srcfile\"`"
      SAT_VERSION_PATCH="`sed '/^patch=*/!d; s///;q' < \"\$srcfile\"`"

#         # Only print release version if it isn't 0
#         if test "$SAT_VERSION_RELEASE" -ne 0 ; then
      SAT_VERSION="$SAT_VERSION_MAJOR.$SAT_VERSION_MINOR.$SAT_VERSION_MICRO"
#         else
#             SAT_VERSION="$SAT_VERSION_MAJOR.$SAT_VERSION_MINOR"
#         fi
      if test "$SAT_VERSION_GREEK" != "" ; then
        SAT_VERSION="${SAT_VERSION}~${SAT_VERSION_GREEK}"
      fi
      SAT_VERSION_BASE=$SAT_VERSION

      # When nothing is specified as 'revision=' ...
      if test -z "$SAT_WANT_REVISION"; then SAT_WANT_REVISION=0; fi
      if test "$SAT_WANT_REVISION" -eq 1 && test "$ac_ver_need_svn" -eq 1 ; then
        if test "$svnversion_result" != "-1" ; then
          SAT_VERSION_PATCH=$svnversion_result
        fi
        if test "$SAT_VERSION_PATCH" = "-1" ; then

          if test -d "$srcdir/.svn" -a -n "`which svnversion`"; then
            SAT_VERSION_PATCH=r`svnversion "$srcdir" | tr ':' '.'`
                    # make sure svnversion worked
            if test $? -ne 0 ; then
              SAT_VERSION_PATCH=`date '+%Y%m%d'`
            fi
            svnversion_result="$SAT_VERSION_PATCH"
          elif test -z "`git status > /dev/null`" -a "$?" -eq 1; then
            SAT_VERSION_PATCH=`git branch -v | sed -n 's/\* .* \([a-f0-9]*\) .*/\1/p'`
	  else
            SAT_VERSION_PATCH=`date '+%Y%m%d'`
          fi

        fi
        SAT_VERSION="${SAT_VERSION}_${SAT_VERSION_PATCH}"
      else
	SAT_VERSION_PATCH=""
      fi
    fi


    if test "$option" = ""; then
	option="--full"
    fi
fi

case "$option" in
    --full|-v|--version)
	echo $SAT_VERSION
	;;
    --major)
	echo $SAT_VERSION_MAJOR
	;;
    --minor)
	echo $SAT_VERSINO_MINOR
	;;
    --micro)
	echo $SAT_VERSION_MICRO
	;;
    --greek)
	echo $SAT_VERSION_GREEK
	;;
    --patch)
	echo $SAT_VERSION_PATCH
	;;
    --base)
        echo $SAT_VERSION_BASE
        ;;
    --all)
        echo ${SAT_VERSION} ${SAT_VERSION_MAJOR} ${SAT_VERSION_MINOR} ${SAT_VERSION_MICRO} ${SAT_VERSION_GREEK} ${SAT_VERSION_PATCH}
        ;;
    -h|--help)
	cat <<EOF
$0 <srcfile> <option>

<srcfile> - Text version file
<option>  - One of:
    --full    - Full version number
    --major   - Major version number
    --minor   - Minor version number
    --micro   - Micro version number
    --greek   - Greek (alpha, beta, etc) version number
    --patch   - Subversion/GIT revision number or date
    --all     - Show all version numbers, separated by :
    --base    - Show base version number (no patch number)
    --help    - This message
EOF
        ;;
    *)
        echo "Unrecognized option $option.  Run $0 --help for options"
        ;;
esac

# All done

exit 0
