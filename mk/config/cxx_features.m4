
AC_DEFUN([AC_CHECK_CXX_FEATURES],[

# AC_MSG_NOTICE([
# C++ compiler ($CXX $CXXFLAGS $LDFLAGS) characteristics
# ])

OS=`uname -a`
AC_SUBST(OS)
DATE=`date`
AC_SUBST(DATE)

AH_TOP([
/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/

])

# AC_DEFINE_UNQUOTED([],["$CXX"],[CXX])
# AC_DEFINE_UNQUOTED([],["$CXXFLAGS"],[CXXFLAGS])
AC_DEFINE_UNQUOTED([CONFIGURE_UNAME],["$OS"],[uname -a])
AC_DEFINE_UNQUOTED([CONFIGURE_DATE],["$DATE"],[date])
AC_DEFINE_UNQUOTED([CONFIGURE_TARGET],["$target"],[target])

AC_CXX_GENERAL
AC_CXX_KEYWORDS
AC_CXX_TYPE_CASTS
AC_CXX_TEMPLATES_FEATURES
AC_CXX_STANDARD_LIBRARY

]))
