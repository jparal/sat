# -*- shell-script -*-
#
# Copyright (c) 2004-2005 The Trustees of Indiana University and Indiana
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

# SAT_LOAD_PLATFORM()
# --------------------
AC_DEFUN([AC_LOAD_PLATFORM], [
    AC_ARG_WITH([platform],
      [AC_HELP_STRING([--with-platform@<:@=FILE@:>@],
          [Load options for build from FILE.  Options on the
            command line not in FILE are used.  Options on the
            command line and in FILE are replaced by what is
            in FILE.])])
      if test "$with_platform" = "" ; then
	if test -r "${srcdir}/mk/platform/`hostname -s`" ; then
          with_platform="`hostname -s`"
        fi
      fi
      if test "$with_platform" = "yes" ; then
        AC_MSG_ERROR([--with-platform argument must include FILE option])
      elif test "$with_platform" = "no" ; then
	AC_MSG_NOTICE([Avoiding to load platform config file])
       # AC_MSG_ERROR([--without-platform is not a valid argument])
      elif test "$with_platform" != "" ; then
        # if no path part, check in contrib/platform
        if test "`basename $with_platform`" = "$with_platform" ; then
          if test -r "${srcdir}/mk/platform/$with_platform" ; then
            with_platform="${srcdir}/mk/platform/$with_platform"
          fi
        fi

        # make sure file exists
        if test ! -r "$with_platform" ; then
          AC_MSG_ERROR([platform file $with_platform not found])
        fi

        # eval into environment
        AC_MSG_WARN([Loading environment file $with_platform])
#         SAT_LOG_FILE([$with_platform])
        . "$with_platform"

        # see if they left us a name
        if test "$SAT_PLATFORM_LOADED" != "" ; then
          platform_loaded="$SAT_PLATFORM_LOADED"
        else
          platform_loaded="$with_platform"
        fi
      fi
    ])
