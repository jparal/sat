
AC_DEFUN([AC_CXX_CHECK_BUILTINS],[
# see if the C++ compiler supports __builtin_expect
    AC_LANG_PUSH(C++)
    AC_CACHE_CHECK([if $CXX supports __builtin_expect],
      [ac_cv_cxx_supports___builtin_expect],
      [AC_TRY_LINK([],
	  [void *ptr = (void*) 0;
	    if (__builtin_expect (ptr != (void*) 0, 1)) return 0;],
	  [ac_cv_cxx_supports___builtin_expect="yes"],
	  [ac_cv_cxx_supports___builtin_expect="no"])])
    if test "$ac_cv_cxx_supports___builtin_expect" = "yes" ; then
      AC_DEFINE_UNQUOTED([HAVE_BUILTIN_EXPECT],1,
	[Whether C++ compiler supports __builtin_expect])
    fi
    AC_LANG_POP(C++)

  # see if the C compiler supports __builtin_prefetch
    AC_LANG_PUSH(C++)
    AC_CACHE_CHECK([if $CXX supports __builtin_prefetch],
      [ac_cv_cxx_supports___builtin_prefetch],
      [AC_TRY_LINK([],
          [int ptr;
	    __builtin_prefetch(&ptr,0,0);],
          [ac_cv_cxx_supports___builtin_prefetch="yes"],
          [ac_cv_cxx_supports___builtin_prefetch="no"])])
    if test "$ac_cv_cxx_supports___builtin_prefetch" = "yes" ; then
      AC_DEFINE_UNQUOTED([HAVE_BUILTIN_PREFETCH],1,
	[Whether C++ compiler supports __builtin_prefetch])
    fi
    AC_LANG_POP(C++)
  ])
