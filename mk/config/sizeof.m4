
AC_DEFUN([AC_CHECK_SIZESOF], [
    AC_CHECK_SIZEOF(int)
    AC_CHECK_SIZEOF(char)
    AC_CHECK_SIZEOF(short)
    AC_CHECK_SIZEOF(int)
    AC_CHECK_SIZEOF(long)
    AC_CHECK_SIZEOF(long long)

    AC_CHECK_SIZEOF(float)
    AC_CHECK_SIZEOF(double)

    AC_CHECK_SIZEOF(void *)
  ])
