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

# SAT_SAVE_VERSION(project_short, version_file])
# ----------------------------------------------
# creates version information for project from version_file, using
# SAT_GET_VERSION().  Information is AC_SUBSTed and put in
# header_file.
AC_DEFUN([SAT_SAVE_VERSION], [
    AC_GET_VERSION([$2], [$1])

    AC_SUBST($1[_VERSION_MAJOR])
    AC_SUBST($1[_VERSION_MINOR])
    AC_SUBST($1[_VERSION_MICRO])
    AC_SUBST($1[_VERSION_BASE])
    AC_SUBST($1[_VERSION_GREEK])
    AC_SUBST($1[_WANT_SVN])
    AC_SUBST($1[_VERSION_PATCH])
    AC_SUBST($1[_VERSION])

    AC_MSG_CHECKING([$1 version])
    AC_MSG_RESULT([$]$1[_VERSION])
    AC_MSG_CHECKING([$1 patch repository version])
    AC_MSG_RESULT([$]$1[_VERSION_PATCH])

    AC_DEFINE_UNQUOTED($1[_VERSION_MAJOR], [$]$1[_VERSION_MAJOR],
        [Major release number of ]$1)
    AC_DEFINE_UNQUOTED($1[_VERSION_MINOR], [$]$1[_VERSION_MINOR],
        [Minor release number of ]$1)
    AC_DEFINE_UNQUOTED($1[_VERSION_MICRO], [$]$1[_VERSION_MICRO],
        [Micro release number of ]$1)
    AC_DEFINE_UNQUOTED($1[_VERSION_BASE], [$]$1[_VERSION_BASE],
        [Standard version number of ]$1)
    AC_DEFINE_UNQUOTED($1[_VERSION_GREEK], ["$]$1[_VERSION_GREEK"],
        [Greek - alpha, beta, etc - release number of ]$1)
    AC_DEFINE_UNQUOTED($1[_WANT_SVN], [$]$1[_WANT_SVN],
        [Do we consider patch revision as a part of version tag?])
    AC_DEFINE_UNQUOTED($1[_VERSION_PATCH], ["$]$1[_VERSION_PATCH"],
        [Patch revision number of ]$1)
    AC_DEFINE_UNQUOTED($1[_VERSION], ["$]$1[_VERSION"],
        [Complete release number of ]$1)

])dnl
