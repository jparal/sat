
#
# set following variables:    ZLIB_LIBS, with_zlib
# generate config file value: HAVE_ZLIB
# Conditional for Automake:   ZLIB
#

AC_DEFUN([AC_PATH_ZLIB],[

    AC_ARG_WITH(zlib, AC_HELP_STRING([--without-zlib], [Compile without zlib support (STW output)]))

    if test "x$with_zlib" != "xno"; then
      AC_CHECK_LIB(z, gzopen, [
          AC_CHECK_HEADERS(zlib.h, [
              AC_DEFINE(HAVE_ZLIB, 1, [define if you want compressed logs])
              AC_SUBST(ZLIB_LIBS)
              ZLIB_LIBS="-lz"
              with_zlib=yes
            ])
        ])
    fi

    AM_CONDITIONAL(ZLIB, test x$with_zlib = xyes)
])
