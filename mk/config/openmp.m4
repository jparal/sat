
AC_DEFUN([AC_COMPILERS_ENABLE_OPENMP],[

    ac_openmp=no
    AC_MSG_CHECKING([whether to enable C/C++ OpenMP compilation flags])
    AC_ARG_ENABLE(openmp,
      AS_HELP_STRING([--enable-openmp],[enable C/C++ OpenMP compilation flags]),[
	if test "$enableval" = yes; then
	  if test "$CXXFLAGS_OMP" != ""; then
	    AC_MSG_RESULT([yes])
	    ac_openmp=yes
	    CXXFLAGS="$CXXFLAGS_OMP $CXXFLAGS"
	    LDFLAGS="$CXXFLAGS_OMP $LDFLAGS"
	    AC_DEFINE(HAVE_OPENMP,1,[define if we want support for OpenMP])
	  else
	    AC_MSG_RESULT([yes])
	    AC_MSG_WARN([This compiler doesnt support OpenMP])
	  fi
	fi
	],[AC_MSG_RESULT([no])])

  ])

AC_SUBST(ac_openmp)
