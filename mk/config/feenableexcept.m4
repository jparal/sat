


AC_DEFUN([AC_CXX_HAVE_FEENABLEEXCEPT],
  [AC_CACHE_CHECK(whether the compiler has feenableexcept() function,
      ac_cv_cxx_have_feenableexcept,
      [AC_LANG_SAVE
        AC_LANG_CPLUSPLUS
        AC_TRY_COMPILE([#include <fenv.h>],[
            feenableexcept (FE_OVERFLOW | FE_INVALID); return 0;],
          ac_cv_cxx_have_feenableexcept=yes, ac_cv_cxx_have_feenableexcept=no)
        AC_LANG_RESTORE
        ])
    if test "$ac_cv_cxx_have_feenableexcept" = yes; then
      AC_DEFINE(HAVE_FEENABLEEXCEPT,1,[define if the compiler has feenableexcept() function])
    fi
    ])
