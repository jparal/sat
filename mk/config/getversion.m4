dnl -*- shell-script -*-
dnl
dnl Copyright (c) 2004-2006 The Trustees of Indiana University and Indiana
dnl                         University Research and Technology
dnl                         Corporation.  All rights reserved.
dnl Copyright (c) 2004-2005 The University of Tennessee and The University
dnl                         of Tennessee Research Foundation.  All rights
dnl                         reserved.
dnl Copyright (c) 2004-2005 High Performance Computing Center Stuttgart,
dnl                         University of Stuttgart.  All rights reserved.
dnl Copyright (c) 2004-2005 The Regents of the University of California.
dnl                         All rights reserved.
dnl $COPYRIGHT$
dnl
dnl Additional copyrights may follow
dnl
dnl $HEADER$
dnl

dnl
dnl This file is also used as input to getversion.sh.
dnl

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
m4_define([AC_GET_VERSION],[
    : ${ac_ver_need_svn=1}
    : ${srcdir=.}
    : ${svnversion_result=-1}

    dnl quote eval to suppress macro expansion with non-GNU m4
    if test -f "$1"; then
      $2_VERSION_MAJOR="`sed '/^major=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_MINOR="`sed '/^minor=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_MICRO="`sed '/^micro=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_GREEK="`sed '/^greek=*/!d; s///;q' < \"\$1\"`"
      $2_WANT_REVISION="`sed '/^revision=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_PATCH="`sed '/^patch=*/!d; s///;q' < \"\$1\"`"

#         # Only print release version if it isn't 0
#         if test "$$2_VERSION_RELEASE" -ne 0 ; then
      $2_VERSION="$$2_VERSION_MAJOR.$$2_VERSION_MINOR.$$2_VERSION_MICRO"
#         else
#             $2_VERSION="$$2_VERSION_MAJOR.$$2_VERSION_MINOR"
#         fi
      if test "$$2_VERSION_GREEK" != "" ; then
        $2_VERSION="${$2_VERSION}-${$2_VERSION_GREEK}"
      fi
      $2_VERSION_BASE=$$2_VERSION

      if test "$$2_WANT_REVISION" -eq 1 && test "$ac_ver_need_svn" -eq 1 ; then
        if test "$svnversion_result" != "-1" ; then
          $2_VERSION_PATCH=$svnversion_result
        fi
        if test "$$2_VERSION_PATCH" = "-1" ; then
          m4_ifdef([AC_MSG_CHECKING],
            [AC_MSG_CHECKING([for SVN version])])
          if test -d "$srcdir/.svn" -a -n "`which svnversion`"; then
            $2_VERSION_PATCH=r`svnversion "$srcdir" | tr ':' '.'`
                    # make sure svnversion worked
            if test $? -ne 0 ; then
              $2_VERSION_PATCH=`date '+%Y%m%d'`
            fi
            svnversion_result="$$2_VERSION_PATCH"
          elif test -z "`git status > /dev/null`" -a "$?" -eq 1; then
            $2_VERSION_PATCH=`git branch -v | grep '^* ' | cut -d ' ' -f 3`
	  else
            $2_VERSION_PATCH=`date '+%Y%m%d'`
          fi
          m4_ifdef([AC_MSG_RESULT],
            [AC_MSG_RESULT([done])])
        fi
        $2_VERSION="${$2_VERSION}_${$2_VERSION_PATCH}"
      fi
    fi
  ])
