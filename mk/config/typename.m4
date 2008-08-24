dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_typename.html
dnl

AC_DEFUN([AC_CXX_TYPENAME],
  [AC_CACHE_CHECK(for typename keyword,
      ac_cv_cxx_typename,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([template<typename T>class X {public:X(){}};],
	  [X<float> z; return 0;],
	  ac_cv_cxx_typename=yes, ac_cv_cxx_typename=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_typename" = yes; then
      AC_DEFINE(HAVE_TYPENAME,1,[define if the compiler recognizes typename])
    fi
  ])
