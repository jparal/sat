#
# Check for headers which doesn't fit anywhere else ...
#
AC_DEFUN([AC_CHECK_SAT_HEADERS],
  [
    save_CPPFLAGS=$CPPFLAGS
    CPPFLAGS="$CPPFLAGS $CFLAGS_MPI"

    AC_CHECK_HEADER([lam_config.h],[AC_DEFINE([HAVE_LAM_CONFIG_H],[1],
	  [Define to 1 if you have the <lam_config.h> header file.])])
    AC_CHECK_HEADER([cxxabi.h],[AC_DEFINE([HAVE_ABI_CXA_DEMANGLE_H],[1],
	  [Define to 1 if you have the <cxxabi.h> header file.])])
    AC_CHECK_HEADER([execinfo.h],[AC_DEFINE([HAVE_EXECINFO_H],[1],
	  [Define to 1 if you have the <execinfo.h> header file.])])
    AC_CHECK_HEADER(
      [valgrind/callgrind.h], [AC_DEFINE([HAVE_VALGRIND_CALLGRIND_H],[1],
	  [Define to 1 if you have the <valgrind/callgrind.h> header file.])])

    CPPFLASG=$save_CPPFLASG
  ])
