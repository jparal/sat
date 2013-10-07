
AC_DEFUN([AC_CMP_FLAGS_64BITS],[
    AC_REQUIRE([AC_CHECK_PLATFORM])
    ac_64bit=false
    AC_MSG_CHECKING([whether to enable C/C++ 64-bit compilation flags])
    AC_ARG_ENABLE(64bit,
      AS_HELP_STRING([--enable-64bit],[Enable C/C++ 64-bit compilation flags]),[
	if test "$enableval" = yes; then
	  AC_MSG_RESULT([yes])
	  ac_64bit=true
	fi
	],[AC_MSG_RESULT([no])])

    ac_bits=32

    if test "$ac_64bit" = true; then
      case "$ac_host_os" in
	AIX)
	  case "$CXX" in
	    *xlC*)
	      FLAGS64="-q64"
#			ARFLAGS64="-cruX64"
	      LDFLAGS64="-b64"
	      ;;
	    *KCC)
	      FLAGS64="-q64"
	      ARFLAGS64="-q64"
	      LDFLAGS64="-b64"
	      ;;
	    *g++*)
	      FLAGS64="-maix64"
	      ARFLAGS64="-cruX64"
	      LDFLAGS64="-Wl,-b64"
	      ;;
	  esac

	  case "$F77" in
	    *xlf*)
	      FFLAGS64="-q64 $FFLAGS"
	      ;;
	  esac

	  case "$FC" in
	    *xlf90*)
	      FCFLAGS64="-q64 $FCFLAGS"
	      ;;
	  esac
	  ;;

	Irix)
	  case "$CXX" in
	    *KCC)
	      FLAGS64="-64"
	      LDFLAGS64="-64"
	      ARFLAGS64="-64"
	      ;;
	    *CC*)
	      FLAGS64="-64"
	      LDFLAGS64="-64"
	      ARFLAGS64="-64"
	      ;;
	    *g++*) dnl clang++ and g++
	      FLAGS64="-m64"
#			LDFLAGS64="-Wl,-64"
	      ;;
	  esac

	  case "$F77" in
	    *f77*)
	      FFLAGS64="-64 $FFLAGS"
	      ;;
	  esac

	  case "$FC" in
	    *f90*)
	      FCFLAGS64="-64 $FCFLAGS"
	      ;;
	  esac 
	  ;;

	Linux)
	  case "$CXX" in
	    *pgCC)
	      FLAGS64="-tp x64"
	      LDFLAGS64="-tp x64"
	      ;;
	    *CC*)
	      FLAGS64="-64"
	      LDFLAGS64="-64"
	      ARFLAGS64="-64"
	      ;;
	    *g++*)
	      FLAGS64="-m64"
#			LDFLAGS64="-Wl,-m64"
	      ;;
	  esac
	  ;;
      esac

      if test x"$FLAGS64" = x; then
	AC_MSG_WARN([Unable to find appropriate 64bit flags for OS: $ac_host_os CXX: $CXX])
      else
	ac_bits=64
      fi

    fi # "$ac_64bit" = true

    AC_SUBST(ac_bits)

    if test -n "$FLAGS64"; then
      CXXFLAGS="$FLAGS64 $CXXFLAGS"
      CFLAGS="$FLAGS64 $CFLAGS"
    fi
    if test -n "$LDFLAGS64"; then
      LDFLAGS="$LDFLAGS64 $LDFLAGS"
    fi
    if test -n "$ARFLAGS64"; then
      ARFLAGS="$ARFLAGS64 $ARFLAGS"
    fi
  ])
# -*- shell-script -*-
#
# Copyright (c) 2004-2007 The Trustees of Indiana University and Indiana
#                         University Research and Technology
#                         Corporation.  All rights reserved.
# Copyright (c) 2004-2005 The University of Tennessee and The University
#                         of Tennessee Research Foundation.  All rights
#                         reserved.
# Copyright (c) 2004-2007 High Performance Computing Center Stuttgart,
#                         University of Stuttgart.  All rights reserved.
# Copyright (c) 2004-2005 The Regents of the University of California.
#                         All rights reserved.
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#

#
# Search the generated warnings for 
# keywords regarding skipping or ignoring certain attributes
#   Intel: ignore
#   Sun C++: skip
#
AC_DEFUN([_AC_ATTRIBUTE_FAIL_SEARCH],[
    # AC_REQUIRE([AC_PROG_GREP]) # Requires autoconf-2.61
    if test -s conftest.err ; then
      for i in ignore skip ; do
        grep -iq $i conftest.err
        if test "$?" = "0" ; then
          ac_cv___attribute__[$1]=0
          break;
        fi
      done
    fi
  ])

#
# Check for one specific attribute by compiling with C and C++
# and possibly using a cross-check.
#
# If the cross-check is defined, a static function "usage" should be
# defined, which is to be called from main (to circumvent warnings
# regarding unused function in main file)
#       static int usage (int * argument);
#
# The last argument is for specific CFLAGS, that need to be set 
# for the compiler to generate a warning on the cross-check.
# This may need adaption for future compilers / CFLAG-settings.
#
AC_DEFUN([_AC_CHECK_SPECIFIC_ATTRIBUTE], [
    AC_MSG_CHECKING([for __attribute__([$1])])
    AC_CACHE_VAL(ac_cv___attribute__[$1], [
        #
        # Try to compile using the C compiler, then C++
        #
        AC_TRY_COMPILE([$2],[],
          [
                        #
                        # In case we did succeed: Fine, but was this due to the
                        # attribute being ignored/skipped? Grep for IgNoRe/skip in conftest.err
                        # and if found, reset the ac_cv__attribute__var=0
                        #
            ac_cv___attribute__[$1]=1
            _AC_ATTRIBUTE_FAIL_SEARCH([$1])
            ],
          [ac_cv___attribute__[$1]=0])
        if test "$ac_cv___attribute__[$1]" = "1" ; then
          AC_LANG_PUSH(C++)
          AC_TRY_COMPILE([
              extern "C" {
                $2
                }],[],
            [
              ac_cv___attribute__[$1]=1
              _AC_ATTRIBUTE_FAIL_SEARCH([$1])
              ],[ac_cv___attribute__[$1]=0])
          AC_LANG_POP(C++)
        fi
        
        #
        # If the attribute is supported by both compilers,
        # try to recompile a *cross-check*, IFF defined.
        #
        if test '(' "$ac_cv___attribute__[$1]" = "1" -a "[$3]" != "" ')' ; then
          ac_c_werror_flag_safe=$ac_c_werror_flag
          ac_c_werror_flag="yes"
          CFLAGS_safe=$CFLAGS
          CFLAGS="$CFLAGS [$4]"

          AC_TRY_COMPILE([$3],
            [
              int i=4711;
              i=usage(&i);
              ],
            [ac_cv___attribute__[$1]=0],
            [
                 #
                 # In case we did NOT succeed: Fine, but was this due to the
                 # attribute being ignored? Grep for IgNoRe in conftest.err
                 # and if found, reset the ac_cv__attribute__var=0
                 #
              ac_cv___attribute__[$1]=1
              _AC_ATTRIBUTE_FAIL_SEARCH([$1])
            ])

          ac_c_werror_flag=$ac_c_werror_flag_safe
          CFLAGS=$CFLAGS_safe
        fi
      ])

    if test "$ac_cv___attribute__[$1]" = "1" ; then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
    fi
  ])


#
# Test the availability of __attribute__ and with the help
# of _AC_CHECK_SPECIFIC_ATTRIBUTE for the support of
# particular attributes. Compilers, that do not support an
# attribute most often fail with a warning (when the warning
# level is set).
# The compilers output is parsed in _AC_ATTRIBUTE_FAIL_SEARCH
# 
# To add a new attributes __NAME__ add the
#   ac_cv___attribute__NAME
# add a new check with _AC_CHECK_SPECIFIC_ATTRIBUTE (possibly with a cross-check)
#   _AC_CHECK_SPECIFIC_ATTRIBUTE([name], [int foo (int arg) __attribute__ ((__name__));], [], [])
# and define the corresponding
#   AC_DEFINE_UNQUOTED(AC_HAVE_ATTRIBUTE_NAME, [$ac_cv___attribute__NAME],
#                      [Whether your compiler has __attribute__ NAME or not])
# and decide on a correct macro (in opal/include/opal_config_bottom.h):
#  #  define __opal_attribute_NAME(x)  __attribute__(__NAME__)
#
# Please use the "__"-notation of the attribute in order not to
# clash with predefined names or macros (e.g. const, which some compilers
# do not like..)
#


AC_DEFUN([AC_CMP_ATTRIBUTES], [
    AC_MSG_CHECKING(for __attribute__)

    AC_CACHE_VAL(ac_cv___attribute__, [
	AC_TRY_COMPILE(
	  [#include <stdlib.h>
	    /* Check for the longest available __attribute__ (since gcc-2.3) */
	    struct foo {
              char a;
              int x[2] __attribute__ ((__packed__));
            };
	    ],
	  [],
	  [ac_cv___attribute__=1],
	  [ac_cv___attribute__=0],
	  )

	if test "$ac_cv___attribute__" = "1" ; then
          AC_TRY_COMPILE(
            [#include <stdlib.h>
              /* Check for the longest available __attribute__ (since gcc-2.3) */
              struct foo {
		char a;
		int x[2] __attribute__ ((__packed__));
              };
              ],
            [],
            [ac_cv___attribute__=1],
            [ac_cv___attribute__=0],
            )
	fi
      ])

    test "$ac_cv___attribute__" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE,1,
      [Whether your compiler has __attribute__ or not])

#
# Now that we know the compiler support __attribute__ let's check which kind of
# attributed are supported.
#
    if test "$ac_cv___attribute__" = "0" ; then
      AC_MSG_RESULT([no])
      ac_cv___attribute__aligned=0
      ac_cv___attribute__flatten=0
      ac_cv___attribute__always_inline=0
      ac_cv___attribute__const=0
      ac_cv___attribute__deprecated=0
      ac_cv___attribute__format=0
      ac_cv___attribute__malloc=0
      ac_cv___attribute__may_alias=0
      ac_cv___attribute__no_instrument_function=0
      ac_cv___attribute__nonnull=0
      ac_cv___attribute__noreturn=0
      ac_cv___attribute__pure=0
      ac_cv___attribute__packed=0
      ac_cv___attribute__unused=0
      ac_cv___attribute__sentinel=0
      ac_cv___attribute__visibility=0
      ac_cv___attribute__warn_unused_result=0
      ac_cv___attribute__weak_alias=0
    else
      AC_MSG_RESULT([yes])

      _AC_CHECK_SPECIFIC_ATTRIBUTE([aligned],
        [struct foo { char text[4]; }  __attribute__ ((__aligned__(8)));],
        [], [])

      _AC_CHECK_SPECIFIC_ATTRIBUTE([flatten],
        [int  foo (int arg) __attribute__ ((__flatten__));],
        [], [])

    #
    # Ignored by PGI-6.2.5; -- recognized by output-parser
    #
      _AC_CHECK_SPECIFIC_ATTRIBUTE([always_inline],
        [int foo (int arg) __attribute__ ((__always_inline__));
	  static int usage () { return foo (1); }
	  ],
        [], [])


      _AC_CHECK_SPECIFIC_ATTRIBUTE([const],
        [
          int foo(int arg1, int arg2) __attribute__ ((__const__));
          int foo(int arg1, int arg2) { return arg1 * arg2 + arg1; }
          ],
        [], [])


      _AC_CHECK_SPECIFIC_ATTRIBUTE([deprecated],
        [
          int foo(int arg1, int arg2) __attribute__ ((__deprecated__));
          int foo(int arg1, int arg2) { return arg1 * arg2 + arg1; }
          ],
        [], [])


      ATTRIBUTE_CFLAGS=
      case "$CXXVENDOR" in
        GNU)
          ATTRIBUTE_CFLAGS="-Wall"
          ;;
        Intel)
            # we want specifically the warning on format string conversion
          ATTRIBUTE_CFLAGS="-we181"
          ;;
      esac
      _AC_CHECK_SPECIFIC_ATTRIBUTE([format],
        [
          int this_printf (void *my_object, const char *my_format, ...) __attribute__ ((__format__ (__printf__, 2, 3)));
          ],
        [
          static int usage (int * argument);
          extern int this_printf (int arg1, const char *my_format, ...) __attribute__ ((__format__ (__printf__, 2, 3)));

          static int usage (int * argument) {
            return this_printf (*argument, "%d", argument); /* This should produce a format warning */
          }
          /* The autoconf-generated main-function is int main(), which produces a warning by itself */
          int main(void);
          ],
        [$ATTRIBUTE_CFLAGS])


      _AC_CHECK_SPECIFIC_ATTRIBUTE([malloc],
        [
#ifdef HAVE_STDLIB_H
#  include <stdlib.h>
#endif
          int * foo(int arg1) __attribute__ ((__malloc__));
          int * foo(int arg1) { return (int*) malloc(arg1); }
          ],
        [], [])


    #
    # Attribute may_alias: No suitable cross-check available, that works for non-supporting compilers
    # Ignored by intel-9.1.045 -- turn off with -wd1292
    # Ignored by PGI-6.2.5; ignore not detected due to missing cross-check
    #
      _AC_CHECK_SPECIFIC_ATTRIBUTE([may_alias],
        [int * p_value __attribute__ ((__may_alias__));],
        [], [])


      _AC_CHECK_SPECIFIC_ATTRIBUTE([no_instrument_function],
        [int * foo(int arg1) __attribute__ ((__no_instrument_function__));],
        [], [])


    #
    # Attribute nonnull:
    # Ignored by intel-compiler 9.1.045 -- recognized by cross-check
    # Ignored by PGI-6.2.5 (pgCC) -- recognized by cross-check
    #
      ATTRIBUTE_CFLAGS=
      case "$CXXVENDOR" in
        GNU)
          ATTRIBUTE_CFLAGS="-Wall"
          ;;
        Intel)
            # we do not want to get ignored attributes warnings, but rather real warnings
          ATTRIBUTE_CFLAGS="-wd1292"
          ;;
      esac
      _AC_CHECK_SPECIFIC_ATTRIBUTE([nonnull],
        [
          int square(int *arg) __attribute__ ((__nonnull__));
          int square(int *arg) { return *arg; }
          ],
        [
          static int usage(int * argument);
          int square(int * argument) __attribute__ ((__nonnull__));
          int square(int * argument) { return (*argument) * (*argument); }

          static int usage(int * argument) {
            return square( ((void*)0) );    /* This should produce an argument must be nonnull warning */
          }
          /* The autoconf-generated main-function is int main(), which produces a warning by itself */
          int main(void);
          ],
        [$ATTRIBUTE_CFLAGS])


      _AC_CHECK_SPECIFIC_ATTRIBUTE([noreturn],
        [
#ifdef HAVE_UNISTD_H
#  include <unistd.h>
#endif
#ifdef HAVE_STDLIB_H
#  include <stdlib.h>
#endif
          void fatal(int arg1) __attribute__ ((__noreturn__));
          void fatal(int arg1) { exit(arg1); }
          ],
        [], [])

      _AC_CHECK_SPECIFIC_ATTRIBUTE([packed],
        [
          struct foo {
            char a;
            int x[2] __attribute__ ((__packed__));
          };
          ],
        [], [])

      _AC_CHECK_SPECIFIC_ATTRIBUTE([pure],
        [
          int square(int arg) __attribute__ ((__pure__));
          int square(int arg) { return arg * arg; }
          ],
        [], [])

    #
    # Attribute sentinel:
    # Ignored by the intel-9.1.045 -- recognized by cross-check
    #                intel-10.0beta works fine
    # Ignored by PGI-6.2.5 (pgCC) -- recognized by output-parser and cross-check
    # Ignored by pathcc-2.2.1 -- recognized by cross-check (through grep ignore)
    #
      ATTRIBUTE_CFLAGS=
      case "$CXXVENDOR" in
        GNU)
          ATTRIBUTE_CFLAGS="-Wall"
          ;;
        Intel)
            # we do not want to get ignored attributes warnings
          ATTRIBUTE_CFLAGS="-wd1292"
          ;;
      esac
      _AC_CHECK_SPECIFIC_ATTRIBUTE([sentinel],
        [
          int my_execlp(const char * file, const char *arg, ...) __attribute__ ((__sentinel__));
          ],
        [
          static int usage(int * argument);
          int my_execlp(const char * file, const char *arg, ...) __attribute__ ((__sentinel__));

          static int usage(int * argument) {
            void * last_arg_should_be_null = argument;
            return my_execlp ("lala", "/home/there", last_arg_should_be_null);   /* This should produce a warning */
          }
          /* The autoconf-generated main-function is int main(), which produces a warning by itself */
          int main(void);
          ],
        [$ATTRIBUTE_CFLAGS])

      _AC_CHECK_SPECIFIC_ATTRIBUTE([unused],
        [
          int square(int arg1 __attribute__ ((__unused__)), int arg2);
          int square(int arg1, int arg2) { return arg2; }
          ],
        [], [])


    #
    # Ignored by PGI-6.2.5 (pgCC) -- recognized by the output-parser
    #
      _AC_CHECK_SPECIFIC_ATTRIBUTE([visibility],
        [ int square(int arg1) __attribute__ ((__visibility__("hidden"))); ],
        [], [])


    #
    # Attribute warn_unused_result:
    # Ignored by the intel-compiler 9.1.045 -- recognized by cross-check
    # Ignored by pathcc-2.2.1 -- recognized by cross-check (through grep ignore)
    #
      ATTRIBUTE_CFLAGS=
      case "$CXXVENDOR" in
        GNU)
          ATTRIBUTE_CFLAGS="-Wall"
          ;;
        Intel)
            # we do not want to get ignored attributes warnings
          ATTRIBUTE_CFLAGS="-wd1292"
          ;;
      esac
      _AC_CHECK_SPECIFIC_ATTRIBUTE([warn_unused_result],
        [
          int foo(int arg) __attribute__ ((__warn_unused_result__));
          int foo(int arg) { return arg + 3; }
          ],
        [
          static int usage(int * argument);
          int foo(int arg) __attribute__ ((__warn_unused_result__));

          int foo(int arg) { return arg + 3; }
          static int usage(int * argument) {
            foo (*argument);        /* Should produce an unused result warning */
            return 0;
          }

          /* The autoconf-generated main-function is int main(), which produces a warning by itself */
          int main(void);
          ],
        [$ATTRIBUTE_CFLAGS])


      _AC_CHECK_SPECIFIC_ATTRIBUTE([weak_alias],
        [
          int foo(int arg);
          int foo(int arg) { return arg + 3; }
          int foo2(int arg) __attribute__ ((__weak__, __alias__("foo")));
          ],
        [], [])

    fi

  # Now that all the values are set, define them

    test "$ac_cv___attribute__aligned" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_ALIGNED,1,
      [Whether your compiler has __attribute__ aligned or not])

    test "$ac_cv___attribute__flatten" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_FLATTEN,1,
      [Whether your compiler has __attribute__ flatten or not])

    test "$ac_cv___attribute__always_inline" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_ALWAYS_INLINE,1,
      [Whether your compiler has __attribute__ always_inline or not])

    test "$ac_cv___attribute__const" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_CONST,1,
      [Whether your compiler has __attribute__ const or not])

    test "$ac_cv___attribute__deprecated" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_DEPRECATED,1,
      [Whether your compiler has __attribute__ deprecated or not])

    test "$ac_cv___attribute__format" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_FORMAT,1,
      [Whether your compiler has __attribute__ format or not])

    test "$ac_cv___attribute__malloc" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_MALLOC,1,
      [Whether your compiler has __attribute__ malloc or not])

    test "$ac_cv___attribute__may_alias" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_MAY_ALIAS,1,
      [Whether your compiler has __attribute__ may_alias or not])

    test "$ac_cv___attribute__no_instrument_function" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_NO_INSTRUMENT_FUNCTION,1,
      [Whether your compiler has __attribute__ no_instrument_function or not])

    test "$ac_cv___attribute__nonnull" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_NONNULL,1,
      [Whether your compiler has __attribute__ nonnull or not])

    test "$ac_cv___attribute__noreturn" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_NORETURN,1,
      [Whether your compiler has __attribute__ noreturn or not])

    test "$ac_cv___attribute__packed" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_PACKED,1,
      [Whether your compiler has __attribute__ packed or not])

    test "$ac_cv___attribute__pure" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_PURE,1,
      [Whether your compiler has __attribute__ pure or not])

    test "$ac_cv___attribute__sentinel" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_SENTINEL,1,
      [Whether your compiler has __attribute__ sentinel or not])

    test "$ac_cv___attribute__unused" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_UNUSED,1,
      [Whether your compiler has __attribute__ unused or not])

    test "$ac_cv___attribute__visibility" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_VISIBILITY,1,
      [Whether your compiler has __attribute__ visibility or not])

    test "$ac_cv___attribute__warn_unused_result" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_WARN_UNUSED_RESULT,1,
      [Whether your compiler has __attribute__ warn unused result or not])

    test "$ac_cv___attribute__weak_alias" -eq 0 || \
      AC_DEFINE_UNQUOTED(HAVE_ATTRIBUTE_WEAK_ALIAS,1,
      [Whether your compiler has __attribute__ weak alias or not])
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_bool.html
dnl

AC_DEFUN([AC_CXX_BOOL],
  [AC_CACHE_CHECK(for bool as a built-in type,
      ac_cv_cxx_bool,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    int f(int  x){return 1;}
	    int f(char x){return 1;}
	    int f(bool x){return 1;}
	    ],[bool b = true; return f(b);],
	  ac_cv_cxx_bool=yes, ac_cv_cxx_bool=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_bool" = yes; then
      AC_DEFINE(HAVE_BOOL,1,[define if bool is a built-in type])
    fi
      ])

AC_DEFUN([AC_CMP_BUILTINS],[
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
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_complex.html
dnl

AC_DEFUN([AC_CXX_HAVE_COMPLEX],
  [AC_CACHE_CHECK(whether the compiler has complex<T>,
      ac_cv_cxx_have_complex,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <complex>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[complex<float> a; complex<double> b; return 0;],
	    ac_cv_cxx_have_complex=yes, ac_cv_cxx_have_complex=no)
	  AC_LANG_RESTORE
	])
      if test "$ac_cv_cxx_have_complex" = yes; then
	AC_DEFINE(HAVE_COMPLEX,1,[define if the compiler has complex<T>])
      fi
    ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_complex_math1.html
dnl

AC_DEFUN([AC_CXX_HAVE_COMPLEX_MATH1],
  [AC_CACHE_CHECK(whether the compiler has complex math functions,
      ac_cv_cxx_have_complex_math1,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	ac_save_LIBS="$LIBS"
	LIBS="$LIBS -lm"
	AC_TRY_LINK([#include <complex>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[complex<double> x(1.0, 1.0), y(1.0, 1.0);
	    cos(x); cosh(x); exp(x); log(x); pow(x,1); pow(x,double(2.0));
	    pow(x, y); pow(double(2.0), x); sin(x); sinh(x); sqrt(x); tan(x); tanh(x);
	    return 0;],
	  ac_cv_cxx_have_complex_math1=yes, ac_cv_cxx_have_complex_math1=no)
	LIBS="$ac_save_LIBS"
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_complex_math1" = yes; then
      AC_DEFINE(HAVE_COMPLEX_MATH1,1,[define if the compiler has complex math functions])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_complex_math2.html
dnl

AC_DEFUN([AC_CXX_HAVE_COMPLEX_MATH2],
  [AC_CACHE_CHECK(whether the compiler has more complex math functions,
      ac_cv_cxx_have_complex_math2,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	ac_save_LIBS="$LIBS"
	LIBS="$LIBS -lm"
	AC_TRY_LINK([#include <complex>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[complex<double> x(1.0, 1.0), y(1.0, 1.0);
	    acos(x); asin(x); atan(x); atan2(x,y); atan2(x, double(3.0));
	    atan2(double(3.0), x); log10(x); return 0;],
	  ac_cv_cxx_have_complex_math2=yes, ac_cv_cxx_have_complex_math2=no)
	LIBS="$ac_save_LIBS"
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_complex_math2" = yes; then
      AC_DEFINE(HAVE_COMPLEX_MATH2,1,[define if the compiler has more complex math functions])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_complex_math_in_namespace_std.html
dnl

AC_DEFUN([AC_CXX_COMPLEX_MATH_IN_NAMESPACE_STD],
  [AC_CACHE_CHECK(whether complex math functions are in namespace std,
      ac_cv_cxx_complex_math_in_namespace_std,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <complex>
	    namespace S { using namespace std;
              complex<float> pow(complex<float> x, complex<float> y)
              { return std::pow(x,y); }
            };
	    ],[using namespace S; complex<float> x = 1.0, y = 1.0; S::pow(x,y); return 0;],
	  ac_cv_cxx_complex_math_in_namespace_std=yes, ac_cv_cxx_complex_math_in_namespace_std=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_complex_math_in_namespace_std" = yes; then
      AC_DEFINE(HAVE_COMPLEX_MATH_IN_NAMESPACE_STD,1,
        [define if complex math functions are in namespace std])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_const_cast.html
dnl

AC_DEFUN([AC_CXX_CONST_CAST],
  [AC_CACHE_CHECK(for the const_cast<>,
      ac_cv_cxx_const_cast,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE(,[int x = 0;const int& y = x;int& z = const_cast<int&>(y);return z;],
	  ac_cv_cxx_const_cast=yes, ac_cv_cxx_const_cast=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_const_cast" = yes; then
      AC_DEFINE(HAVE_CONST_CAST,1,[define if the compiler supports const_cast<>])
    fi
  ])

AC_DEFUN([AC_CMP_CXX_FEATURES],[

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


AC_DEFUN([AC_CXX_GENERAL],[

AC_MSG_NOTICE([

**************************************************************************
****    Checking major C++ language features                          ****
**************************************************************************
])

AC_CXX_NAMESPACES
AC_CXX_EXCEPTIONS
AC_CXX_RTTI
AC_CXX_MEMBER_CONSTANTS
AC_CXX_OLD_FOR_SCOPING])

AC_DEFUN([AC_ENABLE_DEBUG],[

    AC_ARG_ENABLE([debug],
      AS_HELP_STRING([--enable-debug@<:@=LIST@:>@],
	[build with debugging information (default yes);
	  same as --enable-mode=debug. The LIST is an optional comma separated
	  list, where allowed values are:
	  'valgrind'... valgrind tool support;
	  'reftrack'... reference tracking in smart pointers;
	  'memtrack'... memory tracking during allocation;
	  'memdebug'... extensive memomory debugging]),
      [
        # Defaults:
	sat_debug=$enableval

	ifs_save="$IFS"
	IFS="$IFS,"
	for item in $enableval; do
	  case "$item" in
	    valgrind)
	      AC_DEFINE_UNQUOTED(SAT_DEBUG_VALGRIND,1,
		[Whether to turn on valgrind support.]) ;;
	    reftrack)
	      AC_DEFINE_UNQUOTED(SAT_DEBUG_REF_TRACKER,1,
		[Whether to turn on reference tracking in smart pointers]) ;;
	    memtrack)
	      AC_DEFINE_UNQUOTED(SAT_MEMORY_TRACKER,1,
		[Whether to turn on memory tracking during allocation]) ;;
	    memdebug)
	      AC_DEFINE_UNQUOTED(SAT_EXTENSIVE_MEMDEBUG,1,
		[Whether to turn on extensive memory debugging]) ;;
	    yes)
	      sat_debug=yes ;;
	    no)
	      sat_debug=no ;;
	    *) AC_MSG_ERROR([bad value $item for --enable-debug]) ;;
	  esac
	done
	IFS="$ifs_save"

	],[sat_debug=no])

    test x$sat_debug != xno && ac_build_mode=debug

  ])

AC_DEFUN([AC_ENABLE_DEBUG_LEVEL],[
    AC_ARG_ENABLE([dbglevel],
      AS_HELP_STRING([--enable-dbglevel=@<:@0|1|2|3@:>@],
	[Set the verbosity of the output @<:@default: 1@:>@]),
      [debug_level=1
	case "$enableval" in
	  0|1|2|3) debug_level=$enableval ;;
	  *) AC_MSG_ERROR([bad value for --enable-dbglevel]) ;;
	esac
	],
      [debug_level=1])

    AC_DEFINE_UNQUOTED(DEBUG_LEVEL, $debug_level, [Debug level of output])

  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_default_template_parameters.html
dnl

AC_DEFUN([AC_CXX_DEFAULT_TEMPLATE_PARAMETERS],
  [AC_CACHE_CHECK(for the default template parameters,
      ac_cv_cxx_default_template_parameters,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T = double, int N = 10> class A {public: int f() {return 0;}};
	    ],[A<float> a; return a.f();],
	  ac_cv_cxx_default_template_parameters=yes, ac_cv_cxx_default_template_parameters=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_default_template_parameters" = yes; then
      AC_DEFINE(HAVE_DEFAULT_TEMPLATE_PARAMETERS,1,
        [define if the compiler supports default template parameters])
    fi
  ])
# This file is part of Autoconf.                       -*- Autoconf -*-

# Copyright (C) 2004 Oren Ben-Kiki
# This file is distributed under the same terms as the Autoconf macro files.

# Generate automatic documentation using Doxygen. Works in concert with the
# aminclude.m4 file and a compatible doxygen configuration file. Defines the
# following public macros:
#
# DX_???_FEATURE(ON|OFF) - control the default setting fo a Doxygen feature.
# Supported features are 'DOXYGEN' itself, 'DOT' for generating graphics,
# 'HTML' for plain HTML, 'CHM' for compressed HTML help (for MS users), 'CHI'
# for generating a seperate .chi file by the .chm file, and 'MAN', 'RTF',
# 'XML', 'PDF' and 'PS' for the appropriate output formats. The environment
# variable DOXYGEN_PAPER_SIZE may be specified to override the default 'a4wide'
# paper size.
#
# By default, HTML, PDF and PS documentation is generated as this seems to be
# the most popular and portable combination. MAN pages created by Doxygen are
# usually problematic, though by picking an appropriate subset and doing some
# massaging they might be better than nothing. CHM and RTF are specific for MS
# (note that you can't generate both HTML and CHM at the same time). The XML is
# rather useless unless you apply specialized post-processing to it.
#
# The macro mainly controls the default state of the feature. The use can
# override the default by specifying --enable or --disable. The macros ensure
# that contradictory flags are not given (e.g., --enable-doxygen-html and
# --enable-doxygen-chm, --enable-doxygen-anything with --disable-doxygen, etc.)
# Finally, each feature will be automatically disabled (with a warning) if the
# required programs are missing.
#
# Once all the feature defaults have been specified, call DX_INIT_DOXYGEN with
# the following parameters: a one-word name for the project for use as a
# filename base etc., an optional configuration file name (the default is
# 'Doxyfile', the same as Doxygen's default), and an optional output directory
# name (the default is 'doxygen-doc').

## ----------##
## Defaults. ##
## ----------##

DX_ENV=""
AC_DEFUN([DX_FEATURE_doc],  ON)
AC_DEFUN([DX_FEATURE_dot],  ON)
AC_DEFUN([DX_FEATURE_man],  ON)
AC_DEFUN([DX_FEATURE_html], ON)
AC_DEFUN([DX_FEATURE_chm],  OFF)
AC_DEFUN([DX_FEATURE_chi],  OFF)
AC_DEFUN([DX_FEATURE_rtf],  OFF)
AC_DEFUN([DX_FEATURE_xml],  OFF)
AC_DEFUN([DX_FEATURE_pdf],  OFF)
AC_DEFUN([DX_FEATURE_ps],   OFF)

## --------------- ##
## Private macros. ##
## --------------- ##

# DX_ENV_APPEND(VARIABLE, VALUE)
# ------------------------------
# Append VARIABLE="VALUE" to DX_ENV for invoking doxygen.
AC_DEFUN([DX_ENV_APPEND], [AC_SUBST([DX_ENV], ["$DX_ENV $1='$2'"])])

# DX_DIRNAME_EXPR
# ---------------
# Expand into a shell expression prints the directory part of a path.
AC_DEFUN([DX_DIRNAME_EXPR],
         [[expr ".$1" : '\(\.\)[^/]*$' \| "x$1" : 'x\(.*\)/[^/]*$']])

# DX_IF_FEATURE(FEATURE, IF-ON, IF-OFF)
# -------------------------------------
# Expands according to the M4 (static) status of the feature.
AC_DEFUN([DX_IF_FEATURE], [ifelse(DX_FEATURE_$1, ON, [$2], [$3])])

# DX_REQUIRE_PROG(VARIABLE, PROGRAM)
# ----------------------------------
# Require the specified program to be found for the DX_CURRENT_FEATURE to work.
AC_DEFUN([DX_REQUIRE_PROG], [
AC_PATH_TOOL([$1], [$2])
if test "$DX_FLAG_DX_CURRENT_FEATURE$$1" = 1; then
    AC_MSG_WARN([$2 not found - will not DX_CURRENT_DESCRIPTION])
    AC_SUBST([DX_FLAG_DX_CURRENT_FEATURE], 0)
fi
])

# DX_TEST_FEATURE(FEATURE)
# ------------------------
# Expand to a shell expression testing whether the feature is active.
AC_DEFUN([DX_TEST_FEATURE], [test "$DX_FLAG_$1" = 1])

# DX_CHECK_DEPEND(REQUIRED_FEATURE, REQUIRED_STATE)
# -------------------------------------------------
# Verify that a required features has the right state before trying to turn on
# the DX_CURRENT_FEATURE.
AC_DEFUN([DX_CHECK_DEPEND], [
test "$DX_FLAG_$1" = "$2" \
|| AC_MSG_ERROR([doxygen-DX_CURRENT_FEATURE ifelse([$2], 1,
                            requires, contradicts) doxygen-DX_CURRENT_FEATURE])
])

# DX_CLEAR_DEPEND(FEATURE, REQUIRED_FEATURE, REQUIRED_STATE)
# ----------------------------------------------------------
# Turn off the DX_CURRENT_FEATURE if the required feature is off.
AC_DEFUN([DX_CLEAR_DEPEND], [
test "$DX_FLAG_$1" = "$2" || AC_SUBST([DX_FLAG_DX_CURRENT_FEATURE], 0)
])

# DX_FEATURE_ARG(FEATURE, DESCRIPTION,
#                CHECK_DEPEND, CLEAR_DEPEND,
#                REQUIRE, DO-IF-ON, DO-IF-OFF)
# --------------------------------------------
# Parse the command-line option controlling a feature. CHECK_DEPEND is called
# if the user explicitly turns the feature on (and invokes DX_CHECK_DEPEND),
# otherwise CLEAR_DEPEND is called to turn off the default state if a required
# feature is disabled (using DX_CLEAR_DEPEND). REQUIRE performs additional
# requirement tests (DX_REQUIRE_PROG). Finally, an automake flag is set and
# DO-IF-ON or DO-IF-OFF are called according to the final state of the feature.
AC_DEFUN([DX_ARG_ABLE], [
    AC_DEFUN([DX_CURRENT_FEATURE], [$1])
    AC_DEFUN([DX_CURRENT_DESCRIPTION], [$2])
    AC_ARG_ENABLE(doxygen-$1,
                  [AS_HELP_STRING(DX_IF_FEATURE([$1], [--disable-doxygen-$1],
                                                      [--enable-doxygen-$1]),
                                  DX_IF_FEATURE([$1], [don't $2], [$2]))],
                  [
case "$enableval" in
#(
y|Y|yes|Yes|YES)
    AC_SUBST([DX_FLAG_$1], 1)
    $3
;; #(
n|N|no|No|NO)
    AC_SUBST([DX_FLAG_$1], 0)
;; #(
*)
    AC_MSG_ERROR([invalid value '$enableval' given to doxygen-$1])
;;
esac
], [
AC_SUBST([DX_FLAG_$1], [DX_IF_FEATURE([$1], 1, 0)])
$4
])
if DX_TEST_FEATURE([$1]); then
    $5
    :
fi
if DX_TEST_FEATURE([$1]); then
    AM_CONDITIONAL(DX_COND_$1, :)
    $6
    :
else
    AM_CONDITIONAL(DX_COND_$1, false)
    $7
    :
fi
])

## -------------- ##
## Public macros. ##
## -------------- ##

# DX_XXX_FEATURE(DEFAULT_STATE)
# -----------------------------
AC_DEFUN([DX_DOXYGEN_FEATURE], [AC_DEFUN([DX_FEATURE_doc],  [$1])])
AC_DEFUN([DX_MAN_FEATURE],     [AC_DEFUN([DX_FEATURE_man],  [$1])])
AC_DEFUN([DX_HTML_FEATURE],    [AC_DEFUN([DX_FEATURE_html], [$1])])
AC_DEFUN([DX_CHM_FEATURE],     [AC_DEFUN([DX_FEATURE_chm],  [$1])])
AC_DEFUN([DX_CHI_FEATURE],     [AC_DEFUN([DX_FEATURE_chi],  [$1])])
AC_DEFUN([DX_RTF_FEATURE],     [AC_DEFUN([DX_FEATURE_rtf],  [$1])])
AC_DEFUN([DX_XML_FEATURE],     [AC_DEFUN([DX_FEATURE_xml],  [$1])])
AC_DEFUN([DX_XML_FEATURE],     [AC_DEFUN([DX_FEATURE_xml],  [$1])])
AC_DEFUN([DX_PDF_FEATURE],     [AC_DEFUN([DX_FEATURE_pdf],  [$1])])
AC_DEFUN([DX_PS_FEATURE],      [AC_DEFUN([DX_FEATURE_ps],   [$1])])

# DX_INIT_DOXYGEN(PROJECT, [CONFIG-FILE], [OUTPUT-DOC-DIR])
# ---------------------------------------------------------
# PROJECT also serves as the base name for the documentation files.
# The default CONFIG-FILE is "Doxyfile" and OUTPUT-DOC-DIR is "doxygen-doc".
AC_DEFUN([DX_INIT_DOXYGEN], [

# Files:
AC_SUBST([DX_PROJECT], [$1])
AC_SUBST([DX_CONFIG], [ifelse([$2], [], Doxyfile, [$2])])
AC_SUBST([DX_DOCDIR], [ifelse([$3], [], doxygen-doc, [$3])])

# Environment variables used inside doxygen.cfg:
DX_ENV_APPEND(SRCDIR, $srcdir)
DX_ENV_APPEND(PROJECT, $DX_PROJECT)
DX_ENV_APPEND(DOCDIR, $DX_DOCDIR)
DX_ENV_APPEND(VERSION, $SAT_VERSION)
DX_ENV_APPEND(MAINTAINERS, `cat $srcdir/docs/MAINTAINERS`)

# Doxygen itself:
DX_ARG_ABLE(doc, [generate any doxygen documentation],
            [],
            [],
            [DX_REQUIRE_PROG([DX_DOXYGEN], doxygen)
             DX_REQUIRE_PROG([DX_PERL], perl)],
            [DX_ENV_APPEND(PERL_PATH, $DX_PERL)])

# Dot for graphics:
DX_ARG_ABLE(dot, [generate graphics for doxygen documentation],
            [DX_CHECK_DEPEND(doc, 1)],
            [DX_CLEAR_DEPEND(doc, 1)],
            [DX_REQUIRE_PROG([DX_DOT], dot)],
            [DX_ENV_APPEND(HAVE_DOT, YES)
             DX_ENV_APPEND(DOT_PATH, [`DX_DIRNAME_EXPR($DX_DOT)`])],
            [DX_ENV_APPEND(HAVE_DOT, NO)])

dnl # Plain HTML pages generation:
dnl DX_ARG_ABLE(html, [generate doxygen plain HTML documentation],
dnl             [DX_CHECK_DEPEND(doc, 1) DX_CHECK_DEPEND(chm, 0)],
dnl             [DX_CLEAR_DEPEND(doc, 1) DX_CLEAR_DEPEND(chm, 0)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_HTML, YES)],
dnl             [DX_TEST_FEATURE(chm) || DX_ENV_APPEND(GENERATE_HTML, NO)])

dnl # Man pages generation:
dnl DX_ARG_ABLE(man, [generate doxygen manual pages],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_MAN, YES)],
dnl             [DX_ENV_APPEND(GENERATE_MAN, NO)])

dnl # RTF file generation:
dnl DX_ARG_ABLE(rtf, [generate doxygen RTF documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_RTF, YES)],
dnl             [DX_ENV_APPEND(GENERATE_RTF, NO)])

dnl # XML file generation:
dnl DX_ARG_ABLE(xml, [generate doxygen XML documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_XML, YES)],
dnl             [DX_ENV_APPEND(GENERATE_XML, NO)])

dnl # (Compressed) HTML help generation:
dnl DX_ARG_ABLE(chm, [generate doxygen compressed HTML help documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [DX_REQUIRE_PROG([DX_HHC], hhc)],
dnl             [DX_ENV_APPEND(HHC_PATH, $DX_HHC)
dnl              DX_ENV_APPEND(GENERATE_HTML, YES)
dnl              DX_ENV_APPEND(GENERATE_HTMLHELP, YES)],
dnl             [DX_ENV_APPEND(GENERATE_HTMLHELP, NO)])

dnl # Seperate CHI file generation.
dnl DX_ARG_ABLE(chi, [generate doxygen seperate compressed HTML help index file],
dnl             [DX_CHECK_DEPEND(chm, 1)],
dnl             [DX_CLEAR_DEPEND(chm, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_CHI, YES)],
dnl             [DX_ENV_APPEND(GENERATE_CHI, NO)])

dnl # PostScript file generation:
dnl DX_ARG_ABLE(ps, [generate doxygen PostScript documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [DX_REQUIRE_PROG([DX_LATEX], latex)
dnl              DX_REQUIRE_PROG([DX_MAKEINDEX], makeindex)
dnl              DX_REQUIRE_PROG([DX_DVIPS], dvips)
dnl              DX_REQUIRE_PROG([DX_EGREP], egrep)])

dnl # PDF file generation:
dnl DX_ARG_ABLE(pdf, [generate doxygen PDF documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [DX_REQUIRE_PROG([DX_PDFLATEX], pdflatex)
dnl              DX_REQUIRE_PROG([DX_MAKEINDEX], makeindex)
dnl              DX_REQUIRE_PROG([DX_EGREP], egrep)])

dnl # LaTeX generation for PS and/or PDF:
dnl if DX_TEST_FEATURE(ps) || DX_TEST_FEATURE(pdf); then
dnl     AM_CONDITIONAL(DX_COND_latex, :)
dnl     DX_ENV_APPEND(GENERATE_LATEX, YES)
dnl else
dnl     AM_CONDITIONAL(DX_COND_latex, false)
dnl     DX_ENV_APPEND(GENERATE_LATEX, NO)
dnl fi

dnl # Paper size for PS and/or PDF:
dnl AC_ARG_VAR(DOXYGEN_PAPER_SIZE,
dnl            [a4wide (default), a4, letter, legal or executive])
dnl case "$DOXYGEN_PAPER_SIZE" in
dnl #(
dnl "")
dnl     AC_SUBST(DOXYGEN_PAPER_SIZE, "")
dnl ;; #(
dnl a4wide|a4|letter|legal|executive)
dnl     DX_ENV_APPEND(PAPER_SIZE, $DOXYGEN_PAPER_SIZE)
dnl ;; #(
dnl *)
dnl     AC_MSG_ERROR([unknown DOXYGEN_PAPER_SIZE='$DOXYGEN_PAPER_SIZE'])
dnl ;;
dnl esac

#For debugging:
#echo DX_FLAG_doc=$DX_FLAG_doc
#echo DX_FLAG_dot=$DX_FLAG_dot
#echo DX_FLAG_man=$DX_FLAG_man
#echo DX_FLAG_html=$DX_FLAG_html
#echo DX_FLAG_chm=$DX_FLAG_chm
#echo DX_FLAG_chi=$DX_FLAG_chi
#echo DX_FLAG_rtf=$DX_FLAG_rtf
#echo DX_FLAG_xml=$DX_FLAG_xml
#echo DX_FLAG_pdf=$DX_FLAG_pdf
#echo DX_FLAG_ps=$DX_FLAG_ps
#echo DX_ENV=$DX_ENV
])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_dynamic_cast.html
dnl

AC_DEFUN([AC_CXX_DYNAMIC_CAST],
  [AC_CACHE_CHECK(for the dynamic_cast<>,
      ac_cv_cxx_dynamic_cast,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <typeinfo>
	    class Base { public : Base () {} virtual void f () = 0;};
	    class Derived : public Base { public : Derived () {} virtual void f () {} };],[
	    Derived d; Base& b=d; return dynamic_cast<Derived*>(&b) ? 0 : 1;],
	  ac_cv_cxx_dynamic_cast=yes, ac_cv_cxx_dynamic_cast=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_dynamic_cast" = yes; then
      AC_DEFINE(HAVE_DYNAMIC_CAST,1,[define if the compiler supports dynamic_cast<>])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_enum_computations.html
dnl

AC_DEFUN([AC_CXX_ENUM_COMPUTATIONS],
  [AC_CACHE_CHECK(for dupport of handling computations inside an enum,
      ac_cv_cxx_enum_computations,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    struct A { enum { a = 5, b = 7, c = 2 }; };
	    struct B { enum { a = 1, b = 6, c = 9 }; };
	    template<class T1, class T2> struct Z
	    { enum { a = (T1::a > T2::a) ? T1::a : T2::b,
		b = T1::b + T2::b,
		c = (T1::c * T2::c + T2::a + T1::a)
	      };
	    };],[
	    return (((int)Z<A,B>::a == 5)
	      && ((int)Z<A,B>::b == 13)
	      && ((int)Z<A,B>::c == 24)) ? 0 : 1;],
	  ac_cv_cxx_enum_computations=yes, ac_cv_cxx_enum_computations=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_enum_computations" = yes; then
      AC_DEFINE(HAVE_ENUM_COMPUTATIONS,1,
        [define if the compiler handle computations inside an enum])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_enum_computations_with_cast.html
dnl

AC_DEFUN([AC_CXX_ENUM_COMPUTATIONS_WITH_CAST],
  [AC_CACHE_CHECK(for the handles (int) casts in enum computations,
      ac_cv_cxx_enum_computations_with_cast,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    struct A { enum { a = 5, b = 7, c = 2 }; };
	    struct B { enum { a = 1, b = 6, c = 9 }; };
	    template<class T1, class T2> struct Z
	    { enum { a = ((int)T1::a > (int)T2::a) ? (int)T1::a : (int)T2::b,
		b = (int)T1::b + (int)T2::b,
		c = ((int)T1::c * (int)T2::c + (int)T2::a + (int)T1::a)
	      };
	    };],[
	    return (((int)Z<A,B>::a == 5)
	      && ((int)Z<A,B>::b == 13)
	      && ((int)Z<A,B>::c == 24)) ? 0 : 1;],
	  ac_cv_cxx_enum_computations_with_cast=yes, ac_cv_cxx_enum_computations_with_cast=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_enum_computations_with_cast" = yes; then
      AC_DEFINE(HAVE_ENUM_COMPUTATIONS_WITH_CAST,1,
        [define if the compiler handles (int) casts in enum computations])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_exceptions.html
dnl

AC_DEFUN([AC_CXX_EXCEPTIONS],
  [AC_CACHE_CHECK(support for exceptions,
      ac_cv_cxx_exceptions,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE(,[try { throw  1; } catch (int i) { return i; }],
	  ac_cv_cxx_exceptions=yes, ac_cv_cxx_exceptions=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_exceptions" = yes; then
      AC_DEFINE(HAVE_EXCEPTIONS,1,[define if the compiler supports exceptions])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_explicit.html
dnl

AC_DEFUN([AC_CXX_EXPLICIT],
  [AC_CACHE_CHECK(for the explicit keyword,
      ac_cv_cxx_explicit,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([class A{public:explicit A(double){}};],
	  [double c = 5.0;A x(c);return 0;],
	  ac_cv_cxx_explicit=yes, ac_cv_cxx_explicit=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_explicit" = yes; then
      AC_DEFINE(HAVE_EXPLICIT,1,[define if the compiler supports the explicit keyword])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_explicit_template_function_qualification.html
dnl

AC_DEFUN([AC_CXX_EXPLICIT_TEMPLATE_FUNCTION_QUALIFICATION],
  [AC_CACHE_CHECK(for the explicit template function qualification,
      ac_cv_cxx_explicit_template_function_qualification,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class Z> class A { public : A() {} };
	    template<class X, class Y> A<X> to (const A<Y>&) { return A<X>(); }
	    ],[A<float> x; A<double> y = to<double>(x); return 0;],
	  ac_cv_cxx_explicit_template_function_qualification=yes, ac_cv_cxx_explicit_template_function_qualification=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_explicit_template_function_qualification" = yes; then
      AC_DEFINE(HAVE_EXPLICIT_TEMPLATE_FUNCTION_QUALIFICATION,1,
        [define if the compiler supports explicit template function qualification])
    fi
  ])



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

dnl Compiler flags preset
AC_DEFUN([AC_CMP_FLAGS],[
    
    AC_REQUIRE([AC_CHECK_PLATFORM])

    dnl Declare variables which we want substituted in the Makefile.ins

    dnl AC_SUBST(CXXFLAGS)
    AC_SUBST(CXXFLAGS_OPT)
    AC_SUBST(CXXFLAGS_DBG)
    AC_SUBST(CXXFLAGS_PRF)
    AC_SUBST(CFLAGS_OPT)
    AC_SUBST(CFLAGS_DBG)
    AC_SUBST(CFLAGS_PRF)
    AC_SUBST(CXX_LIBS)
    AC_SUBST(AR)
    AC_SUBST(ARFLAGS)
    AC_SUBST(LDFLAGS)
    AC_SUBST(LDFLAGS_DBG)
    AC_SUBST(LDFLAGS_OPT)
    AC_SUBST(LDFLAGS_PRF)
    AC_SUBST(RANLIB)

    dnl Set default values
    AC_PROG_RANLIB
    AR=ar
    ARFLAGS="-cru"
    LDFLAGS=

    AC_MSG_CHECKING([whether using $CXX preset flags])
    AC_ARG_ENABLE(cxxflags,
      AS_HELP_STRING([--enable-cxxflags],
	[Enable C++ compiler flags preset @<:@default yes@:>@]),[],[enableval='yes'])

    if test "$enableval" = yes ; then

      ac_cxx_flags_preset=yes

      case "$CXX" in
	*xlc++*|*xlC*) dnl IBM Visual Age C++   http://www.ibm.com/
	  CC_tmp=xlc
	  CXXVENDOR="IBM"
	  CFLAGS=""
	  CXXFLAGS="-qrtti"
	  CXXFLAGS_OPT="-O3 -qstrict -qstrict_induction -qinline -qmaxmem=8192 -qansialias -qhot -qunroll=yes"
	  CXXFLAGS_DBG="-g -qcheck=all"
	  CXXFLAGS_PRF="-pg"
	  FLAGS_OMP="-qthreaded -qsmp=noauto:noopt:omp"
	  CXX_V=`xlC -qversion 2>&1`
	  CXXVERSION_MAJOR=`echo $CXX_V | sed -n '1 s/.*V\([[0-9]]*\)\.\([[0-9]]*\).*/\1/p'`
	  CXXVERSION_MINOR=`echo $CXX_V | sed -n '1 s/.*V\([[0-9]]*\)\.\([[0-9]]*\).*/\2/p'`
	  CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
	  ARFLAGS="-X32_64 cru"
	  ;;
	*icpc*|*icc*) dnl Intel icc http://www.intel.com/
	  CC_tmp=icc
	  CXXVENDOR="Intel"
	  CFLAGS=""
	  CXXFLAGS="" dnl -strict_ansi flag causes trouble
	  CXXFLAGS_OPT="-O3 -Zp16 -ip -ansi_alias -funroll-loops"
	  CXXFLAGS_DBG="-g -O0 -C"
	  CXXFLAGS_PRF="-pg"
	  FLAGS_OMP="-openmp -openmp-report0"
	  CXX_V=`icpc -v 2>&1`
	  CXXVERSION_MAJOR=`echo $CXX_V | sed -n '1 s/Version \([[0-9]]*\)\.\([[0-9]]\).*/\1/p'`
	  CXXVERSION_MINOR=`echo $CXX_V | sed -n '1 s/Version \([[0-9]]*\)\.\([[0-9]]\).*/\2/p'`
	  CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
	  ;;
	*cxx*)  dnl Compaq C++  http://www.compaq.com/
	  CC_tmp=cc
	  CXXVENDOR="Compaq"
	  CXX_V=`cxx -V 2>&1`
	  CXXVERSION_MAJOR=`expr "$CXX_V" : '.*\(@<:@0-9@:>@\)\..*'`
	  CXXVERSION_MINOR=`expr "$CXX_V" : '.*@<:@0-9@:>@\.\(@<:@0-9@:>@\).*'`
	  CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
	  CFLAGS=""
	  if test $CXXVERSION_MAJOR -eq "6" -a $CXXVERSION_MINOR -lt "3" ; then
	    CXXFLAGS=""
	  else
	    CXXFLAGS=""
	  fi
	  CXXFLAGS_OPT=""
	  CXXFLAGS_DBG=""
	  CXXFLAGS_PRF=""
	  AR="ar"
	  ARFLAGS="-rv"
	  RANLIB="ar ts"
	  ;;
	*clang++*)  dnl clang C++ http://clang.llvm.org/
	  CC_tmp=gcc
	  CXXVENDOR="CLANG"
	  GCC_V=`$CXX --version`
	  CXXVERSION_MAJOR=`expr "$GCC_V" : '.* \(@<:@0-9@:>@\)\..*'`
	  CXXVERSION_MINOR=`expr "$GCC_V" : '.* @<:@0-9@:>@\.\(@<:@0-9@:>@\).*'`
	  CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
          CFLAGS=""
          CXXFLAGS=""
	  CXXFLAGS_OPT="-O3"
	  CXXFLAGS_DBG="-g -O0"
	  CXXFLAGS_PRF="-pg"
          ;;
	*g++*|*c++*)  dnl GCC C++ http://gcc.gnu.org/
	  CC_tmp=gcc
	  CXXVENDOR="GCC"
	  GCC_V=`$CXX --version`
	  CXXVERSION_MAJOR=`expr "$GCC_V" : '.* \(@<:@0-9@:>@\)\..*'`
	  CXXVERSION_MINOR=`expr "$GCC_V" : '.* @<:@0-9@:>@\.\(@<:@0-9@:>@\).*'`
	  CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
	  CFLAGS="-Wno-long-long"
	  if test $CXXVERSION_MAJOR -lt "3" ; then
	    CXXFLAGS="-ftemplate-depth-40"
	    CXXFLAGS_OPT="-O2 -funroll-loops -fno-gcse"
	  else
	    CXXFLAGS="-Wno-long-long"
	    CXXFLAGS_OPT="-O3 -funroll-loops" #  -fomit-frame-pointer -ffast-math (no performance gain and NOT STABLE!!)
	  fi
	  CXXFLAGS_DBG="-g"  #long-long is required for older mpich versions
	  CXXFLAGS_PRF="-pg"
	  if test $CXXVERSION_MAJOR -ge "4" -a $CXXVERSION_MAJOR -ge "2" ; then
	    FLAGS_OMP="-fopenmp"
	  fi
	  ;;
	*KCC*)  dnl KAI C++  http://www.kai.com/
	  CC_tmp=kcc
	  CXXVENDOR="KAI"
	  CFLAGS=""
	  CXXFLAGS="--restrict"
	  CXXFLAGS_OPT="+K3"
	  CXXFLAGS_DBG="+K0 -g"
	  AR="$CXX"
	  ARFLAGS="-o"
	  case "$target" in
	    Irix) dnl SGI C backend compiler
	      CXXFLAGS_OPT="$CXXFLAGS_OPT --backend -Ofast"
	      ;;
	    AIX) dnl IBM xlC backend compiler
	      CXXFLAGS_OPT="$CXXFLAGS_OPT -O5 --backend -qstrict --backend -qstrict_induction"
	      ;;
	    *) dnl other C backend compiler
	      CXXFLAGS_OPT="$CXXFLAGS_OPT -O"
	      ;;
	  esac
	  ;;
	*aCC*)  dnl HP aCC http://www.hp.com/go/c++
	  CC_tmp=acc
	  CXXVENDOR="HP"
	  CFLAGS=""
	  CXXFLAGS="-AA"
	  CXXFLAGS_OPT="+O2"
	  CXXFLAGS_DBG="-g"
	  CXXFLAGS_PRF="+pal"
	  ;;
	*FCC*)  dnl Fujitsu C++
	  CC_tmp=fcc
	  CXXVENDOR="Fujitsu"
	  CFLAGS=""
	  CXXFLAGS="-D__FUJITSU"
	  CXXFLAGS_OPT="-K fast"
	  CXXFLAGS_DBG="-g"
	  ;;
	*pgCC*) dnl Portland Group   http://www.pgroup.com
	  CC_tmp=pgcc
	  CXXVENDOR="PGI"
	  CFLAGS=""
	  CXXFLAGS="--exceptions"
	  CXXFLAGS_OPT="-O4 -Mnoframe -Mnodepchk -Minline=levels:25 -Munroll"
	  CXXFLAGS_DBG="-g -O0"
	  CXXFLAGS_PRF="-pg"
	  FLAGS_OMP="-mp"
	  CXX_V=`pgCC -V 2>&1`
	  CXXVERSION_MAJOR=`echo $CXX_V | sed -n '1 s/.*pgCC.* \([[0-9]]*\)\.\([[0-9]]\).*/\1/p'`
	  CXXVERSION_MINOR=`echo $CXX_V | sed -n '1 s/.*pgCC.* \([[0-9]]*\)\.\([[0-9]]\).*/\2/p'`
	  CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
	  ;;
	*pathCC*) dnl Pathscale pathCC compiler   http://www.pathscale.com
	  CC_tmp=pathcc
	  CXXVENDOR="pathCC"
	  CFLAGS=""
	  CXXFLAGS="-D__PATHSCALE -ansi"
	  CXXFLAGS_OPT="-O3 -fstrict-aliasing -finline-functions"
	  CXXFLAGS_DBG="-g"
	  CXXFLAGS_PRF="-pg"
	  AR="$CXX"
	  ARFLAGS="-ar -o"
	  ;;
	*CC*) 
	  CC_tmp=cc
	  case "$ac_host_os" in
	    Irix) dnl SGI C++  http://www.sgi.com
	      CXXVENDOR="SGI"
	      CFLAGS=""
	      CXXFLAGS="-LANG:std -LANG:restrict -no_auto_include" #-c99
	      CXXFLAGS_OPT="-O3 -IPA -OPT:Olimit=0:alias=typed:swp=ON"
	      CXXFLAGS_DBG="-g"
	      FLAGS_OMP="-mp"
	      CXX_V=`CC -v 2>&1`
	      CXXVERSION_MAJOR=`echo $CXX_V | sed -n '1 s/.*Version \([[0-9]]*\)\.\([[0-9]]\).*/\1/p'`
	      CXXVERSION_MINOR=`echo $CXX_V | sed -n '1 s/.*Version \([[0-9]]*\)\.\([[0-9]]\).*/\2/p'`
	      CXXVERSION="$CXXVERSION_MAJOR.$CXXVERSION_MINOR"
	      AR="$CXX"
	      ARFLAGS="-ar -o"
	      ;;
	    Solaris) dnl SunPRO C++ http://www.sun.com
	      CXXVENDOR="SUN"
	      CFLAGS=""
	      CXXFLAGS="-features=tmplife -library=stlport4"
	      CXXFLAGS_OPT="-O3"
	      CXXFLAGS_DBG="-g"
	      ;;
	    UnicOS) dnl Cray C++
	      CXXVENDOR="Cray"
	      CFLAGS=""
	      CXXFLAGS="-h instantiate=used"
	      CXXFLAGS_OPT="-O3 -hpipeline3 -hunroll -haggress -hscalar2"
	      CXXFLAGS_DBG="-g"
	      ;;
	  esac
	  ;;
	*) 
	  ac_cxx_flags_preset=no
	  ;;
      esac

      CXXFLAGS_DBG="$CXXFLAGS_DBG -DSAT_DEBUG"
      CFLAGS_OPT="$CXXFLAGS_OPT"
      CFLAGS_DBG="$CXXFLAGS_DBG"
      CFLAGS_PRF="$CXXFLAGS_PRF"

      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
    fi

    AC_ARG_WITH([flags],
      AC_HELP_STRING([--with-flags],
        [add extra flags to CFLAGS and CXXFLAGS]),
      [CXXFLAGS="$CXXFLAGS $withval" CFLAGS="$CFLAGS $withval"])

    AC_ARG_WITH([cflags],
      AC_HELP_STRING([--with-cflags],
        [add extra flags to CFLAGS]),
      [CFLAGS="$CFLAGS $withval"])

    AC_ARG_WITH([cxxflags],
      AC_HELP_STRING([--with-cxxflags],
        [add extra flags to CXXFLAGS]),
      [CXXFLAGS="$CXXFLAGS $withval"])

    AC_ARG_WITH([cxxflags-opt],
      AC_HELP_STRING([--with-cxxflags-opt],
        [add extra optimization flags to CXXFLAGS]),
      [CXXFLAGS_OPT="$CXXFLAGS_OPT $withval"])

    AC_ARG_WITH([cxxflags-dbg],
      AC_HELP_STRING([--with-cxxflags-dbg],
        [add extra debug CXXFLAGS]),
      [CXXFLAGS_DBG="$CXXFLAGS_DBG $withval"])

    AC_ARG_WITH([cxxflags-prf],
      AC_HELP_STRING([--with-cxxflags-prf],
        [add extra profile CXXFLAGS]),
      [CXXFLAGS_PRF="$CXXFLAGS_PRF $withval"])

    AC_ARG_WITH([arflags],
      AC_HELP_STRING([--with-arflags],
        [overwrite ARFLAGS]),
      [ARFLAGS="$withval"])

    AC_ARG_WITH([ldflags],
      AC_HELP_STRING([--with-ldflags],
        [add extra flags to LDFLAGS]),
      [LDFLAGS="$withval $LDFLAGS"])

    AC_ARG_WITH([ldflags-opt],
      AC_HELP_STRING([--with-ldflags-opt],
        [add extra optimization flags to LDFLAGS]),
      [LDFLAGS_OPT="$withval $LDFLAGS_OPT"])

    AC_ARG_WITH([ldflags-dbg],
      AC_HELP_STRING([--with-ldflags-dbg],
        [add extra debug LDFLAGS]),
      [LDFLAGS_DBG="$withval $LDFLAGS_DBG"])

    AC_ARG_WITH([ldflags-prf],
      AC_HELP_STRING([--with-ldflags-prf],
        [add extra profile LDFLAGS]),
      [LDFLAGS_PRF="$withval $LDFLAGS_PRF"])

    if test "$ac_cxx_flags_preset" = yes ; then
      AC_MSG_NOTICE([Setting compiler flags for $CXXVENDOR $CXX])
    else
      AC_MSG_NOTICE([No flags preset found for $CXX])
    fi
    AC_PROG_CC($CC_tmp)
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_full_specialization_syntax.html
dnl

AC_DEFUN([AC_CXX_FULL_SPECIALIZATION_SYNTAX],
  [AC_CACHE_CHECK(for the full specialization syntax,
      ac_cv_cxx_full_specialization_syntax,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T> class A        { public : int f () const { return 1; } };
	    template<>        class A<float> { public:  int f () const { return 0; } };],[
	    A<float> a; return a.f();],
	  ac_cv_cxx_full_specialization_syntax=yes, ac_cv_cxx_full_specialization_syntax=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_full_specialization_syntax" = yes; then
      AC_DEFINE(HAVE_FULL_SPECIALIZATION_SYNTAX,1,
        [define if the compiler recognizes the full specialization syntax])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_function_nontype_parameters.html
dnl

AC_DEFUN([AC_CXX_FUNCTION_NONTYPE_PARAMETERS],
  [AC_CACHE_CHECK(for the function templates with non-type parameters,
      ac_cv_cxx_function_nontype_parameters,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T, int N> class A {};
	    template<class T, int N> int f(const A<T,N>& x) { return 0; }
	    ],[A<double, 17> z; return f(z);],
	  ac_cv_cxx_function_nontype_parameters=yes, ac_cv_cxx_function_nontype_parameters=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_function_nontype_parameters" = yes; then
      AC_DEFINE(HAVE_FUNCTION_NONTYPE_PARAMETERS,1,
        [define if the compiler supports function templates with non-type parameters])
    fi
  ])
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

dnl
dnl This file is also used as input to getversion.sh.
dnl

# AC_GET_VERSION(version_file, variable_prefix)
# -----------------------------------------------
# parse version_file for version information, setting
# the following shell variables:
#
#  prefix_VERSION
#  prefix_VERSION_BASE
#  prefix_VERSION_MAJOR
#  prefix_VERSION_MINOR
#  prefix_VERSION_MICRO
#  prefix_VERSION_GREEK
#  prefix_VERSION_PATCH
#  prefix_WANT_REVISION
m4_define([AC_GET_VERSION],[
    : ${ac_ver_need_svn=1}
    : ${srcdir=.}
    : ${svnversion_result=-1}

    dnl quote eval to suppress macro expansion with non-GNU m4
    if test -f "$1"; then
      $2_VERSION_MAJOR="`sed '/^major=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_MINOR="`sed '/^minor=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_MICRO="`sed '/^micro=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_GREEK="`sed '/^greek=*/!d; s///;q' < \"\$1\"`"
      $2_WANT_REVISION="`sed '/^revision=*/!d; s///;q' < \"\$1\"`"
      $2_VERSION_PATCH="`sed '/^patch=*/!d; s///;q' < \"\$1\"`"

#         # Only print release version if it isn't 0
#         if test "$$2_VERSION_RELEASE" -ne 0 ; then
      $2_VERSION="$$2_VERSION_MAJOR.$$2_VERSION_MINOR.$$2_VERSION_MICRO"
#         else
#             $2_VERSION="$$2_VERSION_MAJOR.$$2_VERSION_MINOR"
#         fi
      if test "$$2_VERSION_GREEK" != "" ; then
        $2_VERSION="${$2_VERSION}-${$2_VERSION_GREEK}"
      fi
      $2_VERSION_BASE=$$2_VERSION

      # When nothing is specified as 'revision=' ...
      if test -z "$$2_WANT_REVISION"; then $2_WANT_REVISION=0; fi
      if test "$$2_WANT_REVISION" -eq 1 && test "$ac_ver_need_svn" -eq 1 ; then
        if test "$svnversion_result" != "-1" ; then
          $2_VERSION_PATCH=$svnversion_result
        fi
        if test "$$2_VERSION_PATCH" = "-1" ; then
          m4_ifdef([AC_MSG_CHECKING],
            [AC_MSG_CHECKING([for SVN version])])
          if test -d "$srcdir/.svn" -a -n "`which svnversion`"; then
            $2_VERSION_PATCH=r`svnversion "$srcdir" | tr ':' '.'`
                    # make sure svnversion worked
            if test $? -ne 0 ; then
              $2_VERSION_PATCH=`date '+%Y%m%d'`
            fi
            svnversion_result="$$2_VERSION_PATCH"
          elif test -z "`git status > /dev/null`" -a "$?" -eq 1; then
            $2_VERSION_PATCH=`git branch -v | sed -n 's/\* .* \([[a-f0-9]]*\) .*/\1/p'`
	  else
            $2_VERSION_PATCH=`date '+%Y%m%d'`
          fi
          m4_ifdef([AC_MSG_RESULT],
            [AC_MSG_RESULT([done])])
        fi
        $2_VERSION="${$2_VERSION}_${$2_VERSION_PATCH}"
      else
	$2_VERSION_PATCH=""
      fi
    fi
  ])
# Configure path for the GNU Scientific Library
# Christopher R. Gabriel <cgabriel@linux.it>, April 2000


AC_DEFUN([AC_LIB_GSL],
  [
    AC_ARG_WITH(gsl-prefix,[  --with-gsl-prefix=PFX   Prefix where GSL is installed (optional)],
      gsl_prefix="$withval", gsl_prefix="")
    AC_ARG_WITH(gsl-exec-prefix,[  --with-gsl-exec-prefix=PFX Exec prefix where GSL is installed (optional)],
      gsl_exec_prefix="$withval", gsl_exec_prefix="")
    AC_ARG_ENABLE(gsltest, [  --disable-gsltest       Do not try to compile and run a test GSL program],
      , enable_gsltest=yes)
    AC_ARG_ENABLE(gsl, [  --disable-gsl           Do not compile GSL support],
      , enable_gsl=yes, enable_gsl=no)

    if test "x${GSL_CONFIG+set}" != xset ; then
      if test "x$gsl_prefix" != x ; then
        GSL_CONFIG="$gsl_prefix/bin/gsl-config"
      fi
      if test "x$gsl_exec_prefix" != x ; then
        GSL_CONFIG="$gsl_exec_prefix/bin/gsl-config"
      fi
    fi

    AC_PATH_PROG(GSL_CONFIG, gsl-config, no)
    min_gsl_version=ifelse([$1], ,0.2.5,$1)
    AC_MSG_CHECKING(for GSL - version >= $min_gsl_version)
    no_gsl=""
    if test "$GSL_CONFIG" = "no" -o "$enable_gsl" = "no"; then
      no_gsl=yes
    else
      GSL_CFLAGS=`$GSL_CONFIG --cflags`
      GSL_LIBS=`$GSL_CONFIG --libs`

      gsl_major_version=`$GSL_CONFIG --version | \
        sed 's/^\([[0-9]]*\).*/\1/'`
      if test "x${gsl_major_version}" = "x" ; then
	gsl_major_version=0
      fi

      gsl_minor_version=`$GSL_CONFIG --version | \
        sed 's/^\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\).*/\2/'`
      if test "x${gsl_minor_version}" = "x" ; then
	gsl_minor_version=0
      fi

      gsl_micro_version=`$GSL_CONFIG --version | \
        sed 's/^\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\).*/\3/'`
      if test "x${gsl_micro_version}" = "x" ; then
	gsl_micro_version=0
      fi

      if test "x$enable_gsltest" = "xyes" ; then
	ac_save_CFLAGS="$CFLAGS"
	ac_save_LIBS="$LIBS"
	CFLAGS="$CFLAGS $GSL_CFLAGS"
	LIBS="$LIBS $GSL_LIBS"

	rm -f conf.gsltest
	AC_TRY_RUN([
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

	    char* my_strdup (const char *str);

	    char*
	    my_strdup (const char *str)
	    {
	      char *new_str;
	      
	      if (str)
		{
		  new_str = (char *)malloc ((strlen (str) + 1) * sizeof(char));
		  strcpy (new_str, str);
		}
	      else
		new_str = NULL;
		
		return new_str;
	    }

	    int main (void)
	    {
	      int major = 0, minor = 0, micro = 0;
	      int n;
	      char *tmp_version;

	      system ("touch conf.gsltest");

	      /* HP/UX 9 (%@#!) writes to sscanf strings */
	      tmp_version = my_strdup("$min_gsl_version");

	      n = sscanf(tmp_version, "%d.%d.%d", &major, &minor, &micro) ;

	      if (n != 2 && n != 3) {
		  printf("%s, bad version string\n", "$min_gsl_version");
		  exit(1);
		}

		if (($gsl_major_version > major) ||
		    (($gsl_major_version == major) && ($gsl_minor_version > minor)) ||
		    (($gsl_major_version == major) && ($gsl_minor_version == minor) && ($gsl_micro_version >= micro)))
		  {
		    exit(0);
		  }
		else
		  {
		    printf("\n*** 'gsl-config --version' returned %d.%d.%d, but the minimum version\n", $gsl_major_version, $gsl_minor_version, $gsl_micro_version);
		    printf("*** of GSL required is %d.%d.%d. If gsl-config is correct, then it is\n", major, minor, micro);
		    printf("*** best to upgrade to the required version.\n");
		    printf("*** If gsl-config was wrong, set the environment variable GSL_CONFIG\n");
		    printf("*** to point to the correct copy of gsl-config, and remove the file\n");
		    printf("*** config.cache before re-running configure\n");
		    exit(1);
		  }
	    }

	    ],, no_gsl=yes,[echo $ac_n "cross compiling; assumed OK... $ac_c"])
	CFLAGS="$ac_save_CFLAGS"
	LIBS="$ac_save_LIBS"
      fi
    fi
    with_gsl="no"
    if test "x$no_gsl" = x ; then
      with_gsl="yes"
      AC_MSG_RESULT(yes)
      ifelse([$2], , :, [$2])     
    else
      AC_MSG_RESULT(no)
      if test "$GSL_CONFIG" = "no" ; then
	echo "*** The gsl-config script installed by GSL could not be found"
	echo "*** If GSL was installed in PREFIX, make sure PREFIX/bin is in"
	echo "*** your path, or set the GSL_CONFIG environment variable to the"
	echo "*** full path to gsl-config."
      else
	if test -f conf.gsltest ; then
          :
	else
          echo "*** Could not run GSL test program, checking why..."
          CFLAGS="$CFLAGS $GSL_CFLAGS"
          LIBS="$LIBS $GSL_LIBS"
          AC_TRY_LINK([
#include <stdio.h>
	      ],      [ return 0; ],
            [ echo "*** The test program compiled, but did not run. This usually means"
              echo "*** that the run-time linker is not finding GSL or finding the wrong"
              echo "*** version of GSL. If it is not finding GSL, you'll need to set your"
              echo "*** LD_LIBRARY_PATH environment variable, or edit /etc/ld.so.conf to point"
              echo "*** to the installed location  Also, make sure you have run ldconfig if that"
              echo "*** is required on your system"
	      echo "***"
              echo "*** If you have an old version installed, it is best to remove it, although"
              echo "*** you may also be able to get things to work by modifying LD_LIBRARY_PATH"],
            [ echo "*** The test program failed to compile or link. See the file config.log for the"
              echo "*** exact error that occured. This usually means GSL was incorrectly installed"
              echo "*** or that you have moved GSL since it was installed. In the latter case, you"
              echo "*** may want to edit the gsl-config script: $GSL_CONFIG" ])
          CFLAGS="$ac_save_CFLAGS"
          LIBS="$ac_save_LIBS"
	fi
      fi
#     GSL_CFLAGS=""
#     GSL_LIBS=""
      ifelse([$3], , :, [$3])
    fi
    AC_SUBST(GSL_CFLAGS)
    AC_SUBST(GSL_LIBS)
    AM_CONDITIONAL([HAVE_GSL], [test -n "$GSL_LIBS"])
    rm -f conf.gsltest
  ])
# searches for H5PART-stuff

#
# set following variables:    H5PART_CPPFLAGS, H5PART_LDFLAGS, H5PART_LIBS,
#                             with_h5part
# generate config file value: HAVE_H5PART
# Conditional for Automake:   HAVE_H5PART
#

AC_DEFUN([AC_LIB_H5PART],[
    AC_REQUIRE([AC_PROG_CC])
    AC_REQUIRE([AC_LIB_HDF5])

    AC_ARG_WITH(h5part,
      AC_HELP_STRING([--with-h5part=PATH],[directory with H5PART inside]),
    # expand tilde / other stuff
      eval with_h5part=$with_h5part
      )
    
    AC_ARG_WITH(h5part-libs,
      [AC_HELP_STRING([--with-h5part-libs=LIBS],[additional libraries needed to link h5part programs. Those might be needed if your h5part library is static. Possible values are: -lz or -lz -lsz.])],[])

 # store values
    ac_save_CFLAGS="$CFLAGS"
    ac_save_CPPFLAGS="$CPPFLAGS"
    ac_save_LDFLAGS="$LDFLAGS"
    ac_save_LIBS="$LIBS"
    LIBS=""

 # start building variables

 # use special H5PART-lib-path if it's set
    if test x$with_h5part != x ; then
   #  extract absolute path
      if test -d $with_h5part; then
	eval with_h5part=`cd $with_h5part ; pwd`
      else
	AC_MSG_ERROR([H5PART-directory $with_h5part does not exist])
      fi
      LDFLAGS="$LDFLAGS -L$with_h5part/lib"
      H5PART_LDFLAGS="$LDFLAGS"
      CPPFLAGS="$CPPFLAGS -I$with_h5part/include"
    fi

 # test if we are parallel
    # AC_CHECK_DECL(H5PART_HAVE_PARALLEL, [dnl
    #     LIBS="$LIBS $LIBS_MPI"
    #     LDFLAGS="$LDFLAGS $LDFLAGS_MPI"
    #     CPPFLAGS="$CPPFLAGS $CXXFLAGS_MPI"
    #     AC_DEFINE(HAVE_H5PART_PARALLEL,1, [Define to 1 if h5part support parallel access])
    #     with_h5part_parallel=yes],[
    #     with_h5part_parallel=no],
    #   [#include"H5pubconf.h"])

 # test for an arbitrary header
    AC_CHECK_HEADER([H5Part.h], 
      [HAVE_H5PART=1]
      H5PART_CPPFLAGS="$CPPFLAGS",
      [HAVE_H5PART=0])
    
 # test for lib
    if test x$HAVE_H5PART = x1 ; then
      AC_CHECK_LIB(H5Part, H5PartOpenFile,
        [H5PART_LIBS="-lH5Part $HDF5_LIBS $with_h5part_libs"],
	[HAVE_H5PART=0], [$HDF5_LIBS "$with_h5part_libs"])
    fi

 # pre-set variable for summary
    with_h5part="no"

 # did we succeed?
    if test x$HAVE_H5PART = x1 ; then
      AC_SUBST(H5PART_CPPFLAGS, $H5PART_CPPFLAGS)
      AC_SUBST(H5PART_LDFLAGS, $H5PART_LDFLAGS)
      AC_SUBST(H5PART_LIBS, $H5PART_LIBS)
      AC_DEFINE(HAVE_H5PART,1, [Define to 1 if H5Part was found])

   # proudly show in summary
      with_h5part="yes"
    fi

 # also tell automake
    AM_CONDITIONAL(HAVE_H5PART, test x$HAVE_H5PART = x1)

 # reset values					    
    CFLAGS="$ac_save_CFLAGS"
    LIBS="$ac_save_LIBS"
    LDFLAGS="$ac_save_LDFLAGS"
    CPPFLAGS="$ac_save_CPPFLAGS"

  ])


AC_DEFUN([AC_CXX_HAVE_CLIMITS],
  [AC_CACHE_CHECK(whether the compiler has <climits> header,
      ac_cv_cxx_have_climits,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <climits>],[int i = INT_MIN; return 0;],
	  ac_cv_cxx_have_climits=yes, ac_cv_cxx_have_climits=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_climits" = yes; then
      AC_DEFINE(HAVE_CLIMITS,1,[define if the compiler has <climits> header])
    fi
  ])





AC_DEFUN([AC_CXX_HAVE_COMPLEX_FCNS],
  [AC_CACHE_CHECK(whether the compiler has standard complex<T> functions,
      ac_cv_cxx_have_complex_fcns,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <complex>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[complex<double> x(1.0, 1.0);
	    real(x); imag(x); abs(x); arg(x); norm(x); conj(x); polar(1.0,1.0);
	    return 0;],
	  ac_cv_cxx_have_complex_fcns=yes, ac_cv_cxx_have_complex_fcns=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_complex_fcns" = yes; then
      AC_DEFINE(HAVE_COMPLEX_FCNS,1,[define if the compiler has standard complex<T> functions])
    fi
  ])


# searches for HDF5-stuff
# Adopted from DUNE project (http://www.dune-project.org/)

#
# set following variables:    HDF5_CPPFLAGS, HDF5_LDFLAGS, HDF5_LIBS, with_hdf5
# generate config file value: HAVE_HDF5
# Conditional for Automake:   HAVE_HDF5
#

AC_DEFUN([AC_LIB_HDF5],[
    AC_REQUIRE([AC_PROG_CC])

    AC_ARG_WITH(hdf5,
      AC_HELP_STRING([--with-hdf5=PATH],[directory with HDF5 inside]),
    # expand tilde / other stuff
      eval with_hdf5=$with_hdf5
      )
    
    AC_ARG_WITH(hdf5-libs,
      [AC_HELP_STRING([--with-hdf5-libs=LIBS],[additional libraries needed to link hdf5 programs. Those might be needed if your hdf5 library is static. Possible values are: -lz or -lz -lsz.])],[])

 # store values
    ac_save_CFLAGS="$CFLAGS"
    ac_save_CPPFLAGS="$CPPFLAGS"
    ac_save_LDFLAGS="$LDFLAGS"
    ac_save_LIBS="$LIBS"
    LIBS=""

 # start building variables

 # use special HDF5-lib-path if it's set
    if test x$with_hdf5 != x ; then
   #  extract absolute path
      if test -d $with_hdf5; then
	eval with_hdf5=`cd $with_hdf5 ; pwd`
      else
	AC_MSG_ERROR([HDF5-directory $with_hdf5 does not exist])
      fi
      LDFLAGS="$LDFLAGS -L$with_hdf5/lib"
      HDF5_LDFLAGS="$LDFLAGS"
      CPPFLAGS="$CPPFLAGS -I$with_hdf5/include"
    fi

 # test if we are parallel
    AC_CHECK_DECL(H5_HAVE_PARALLEL, [dnl
	LIBS="$LIBS $LIBS_MPI"
	LDFLAGS="$LDFLAGS $LDFLAGS_MPI"
	CPPFLAGS="$CPPFLAGS $CXXFLAGS_MPI"
	AC_DEFINE(HAVE_HDF5_PARALLEL,1, [Define to 1 if hdf5 support parallel access])
	with_hdf5_parallel=yes],[
	with_hdf5_parallel=no],
      [#include"H5pubconf.h"])

 # test for an arbitrary header
    AC_CHECK_HEADER([hdf5.h], 
      [HAVE_HDF5=1]
      HDF5_CPPFLAGS="$CPPFLAGS",
      [HAVE_HDF5=0])
    
 # test for lib
    if test x$HAVE_HDF5 = x1 ; then
      AC_CHECK_LIB(hdf5, H5open,[HDF5_LIBS="-lhdf5 $with_hdf5_libs"],
	[HAVE_HDF5=0], ["$with_hdf5_libs"])
    fi

 # pre-set variable for summary
    with_hdf5="no"

 # did we succeed?
    if test x$HAVE_HDF5 = x1 ; then
      AC_SUBST(HDF5_CPPFLAGS, $HDF5_CPPFLAGS)
      AC_SUBST(HDF5_LDFLAGS, $HDF5_LDFLAGS)
      AC_SUBST(HDF5_LIBS, $HDF5_LIBS)
      AC_DEFINE(HAVE_HDF5,1, [Define to 1 if hdf5 was found])

   # proudly show in summary
      with_hdf5="yes"
    fi

 # also tell automake
    AM_CONDITIONAL(HAVE_HDF5, test x$HAVE_HDF5 = x1)

 # reset values					    
    CFLAGS="$ac_save_CFLAGS"
    LIBS="$ac_save_LIBS"
    LDFLAGS="$ac_save_LDFLAGS"
    CPPFLAGS="$ac_save_CPPFLAGS"

  ])
#
# Check for headers which doesn't fit anywhere else ...
#
AC_DEFUN([AC_CHECK_SAT_HEADERS],
  [
    save_CPPFLAGS=$CPPFLAGS
    CPPFLAGS="$CPPFLAGS $CFLAGS_MPI"

    AC_CHECK_HEADER([signal.h],[AC_DEFINE([HAVE_SIGNAL_H],[1],
          [Define to 1 if you have the <signal.h> header file.])])
    AC_CHECK_HEADER([fenv.h],[AC_DEFINE([HAVE_FENV_H],[1],
          [Define to 1 if you have the <fenv.h> header file.])])
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
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_ieee_math.html
dnl

AC_DEFUN([AC_CXX_HAVE_IEEE_MATH],
  [AC_CACHE_CHECK(whether the compiler supports IEEE math library,
      ac_cv_cxx_have_ieee_math,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	ac_save_LIBS="$LIBS"
	LIBS="$LIBS -lm"
	AC_TRY_LINK([
#ifndef _ALL_SOURCE
 #define _ALL_SOURCE
#endif
#ifndef _XOPEN_SOURCE
 #define _XOPEN_SOURCE
#endif
#ifndef _XOPEN_SOURCE_EXTENDED
 #define _XOPEN_SOURCE_EXTENDED 1
#endif
#include <math.h>],[double x = 1.0; double y = 1.0; int i = 1;
	    acosh(x); asinh(x); atanh(x); cbrt(x); expm1(x); erf(x); erfc(x); isnan(x);
	    j0(x); j1(x); jn(i,x); ilogb(x); logb(x); log1p(x); rint(x); 
	    y0(x); y1(x); yn(i,x);
#ifdef _THREAD_SAFE
	    gamma_r(x,&i); 
	    lgamma_r(x,&i); 
#else
	    gamma(x); 
	    lgamma(x); 
#endif
	    hypot(x,y); nextafter(x,y); remainder(x,y); scalb(x,y);
	    return 0;],
	  ac_cv_cxx_have_ieee_math=yes, ac_cv_cxx_have_ieee_math=no)
	LIBS="$ac_save_LIBS"
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_ieee_math" = yes; then
      AC_DEFINE(HAVE_IEEE_MATH,1,[define if the compiler supports IEEE math library])
    fi
  ])

AC_DEFUN([AC_CXX_ISNAN_IN_NAMESPACE_STD],
  [AC_CACHE_CHECK(whether the compiler has isnan function in namespace std,
      ac_cv_cxx_isnan_std,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <cmath>
	    namespace blitz { int isnan(float x){ return std::isnan(x); } };],[
	    using namespace blitz; float x = 1.0; blitz::isnan(x); return 0;],
	  ac_cv_cxx_isnan_std=yes, ac_cv_cxx_isnan_std=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_isnan_std" = yes; then
      AC_DEFINE(ISNAN_IN_NAMESPACE_STD,1,[define if the compiler has isnan function in namespace std])
    fi
  ])


AC_DEFUN([AC_CXX_KEYWORDS],[
AC_MSG_NOTICE([

**************************************************************************
****    Checking for some of the new keywords                         ****
**************************************************************************
])

AC_CXX_EXPLICIT
AC_CXX_MUTABLE
AC_CXX_TYPENAME
AC_CXX_NCEG_RESTRICT
AC_CXX_NCEG_RESTRICT_EGCS
AC_CXX_BOOL])

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
	if test -r "${srcdir}/mk/platform/`hostname -s`.in" ; then
          with_platform="`hostname -s`.in"
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

AC_DEFUN([AC_CXX_MATH_FN_IN_NAMESPACE_STD],
  [AC_CACHE_CHECK(whether the compiler has C math functions in namespace std,
      ac_cv_cxx_mathfn_std,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <cmath>
	    namespace blitz { double pow(double x, double y){ return std::pow(x,y); } };],[
	    using namespace blitz; double x = 1.0, y = 1.0; blitz::pow(x,y); return 0;],
	  ac_cv_cxx_mathfn_std=yes, ac_cv_cxx_mathfn_std=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_mathfn_std" = yes; then
      AC_DEFINE(MATH_FN_IN_NAMESPACE_STD,1,[define if the compiler has C math functions in namespace std])
    fi
  ])



dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_member_constants.html
dnl

AC_DEFUN([AC_CXX_MEMBER_CONSTANTS],
  [AC_CACHE_CHECK(for the member constants,
      ac_cv_cxx_member_constants,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([class C {public: static const int i = 0;}; const int C::i;],
	  [return C::i;],
	  ac_cv_cxx_member_constants=yes, ac_cv_cxx_member_constants=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_member_constants" = yes; then
      AC_DEFINE(HAVE_MEMBER_CONSTANTS,1,[define if the compiler supports member constants])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_member_templates.html
dnl

AC_DEFUN([AC_CXX_MEMBER_TEMPLATES],
  [AC_CACHE_CHECK(for the member templates,
      ac_cv_cxx_member_templates,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T, int N> class A
	    { public:
	      template<int N2> A<T,N> operator=(const A<T,N2>& z) { return A<T,N>(); }
	    };],[A<double,4> x; A<double,7> y; x = y; return 0;],
	  ac_cv_cxx_member_templates=yes, ac_cv_cxx_member_templates=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_member_templates" = yes; then
      AC_DEFINE(HAVE_MEMBER_TEMPLATES,1,[define if the compiler supports member templates])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_member_templates_outside_class.html
dnl

AC_DEFUN([AC_CXX_MEMBER_TEMPLATES_OUTSIDE_CLASS],
  [AC_CACHE_CHECK(for the member templates outside of class declaration,
      ac_cv_cxx_member_templates_outside_class,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T, int N> class A
	    { public :
	      template<int N2> A<T,N> operator=(const A<T,N2>& z);
	    };
	    template<class T, int N> template<int N2>
	    A<T,N> A<T,N>::operator=(const A<T,N2>& z){ return A<T,N>(); }],[
	    A<double,4> x; A<double,7> y; x = y; return 0;],
	  ac_cv_cxx_member_templates_outside_class=yes, ac_cv_cxx_member_templates_outside_class=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_member_templates_outside_class" = yes; then
      AC_DEFINE(HAVE_MEMBER_TEMPLATES_OUTSIDE_CLASS,1,
        [define if the compiler supports member templates outside the class declaration])
    fi
  ])

AC_DEFUN([AC_CMP_MODE],[

    AC_ENABLE_OPTIMIZE
    AC_ENABLE_PROFILE
    AC_ENABLE_DEBUG
    AC_ENABLE_DEBUG_LEVEL

    AC_ARG_ENABLE([mode], [AC_HELP_STRING([--enable-mode=mode],
	  [set build mode; recognized modes are `optimize', `debug', `profile'
	    (default OPTIMIZE)])],
      [case $enableval in
	optimize|debug|profile) ac_build_mode=$enableval ;;
	*) AC_MSG_ERROR([m4_text_wrap(
	      [unrecognized mode --enable-mode=$enableval;
		use `optimize', `debug', or `profile'], [    ], [[]], [60])]) ;;
	  esac
      ])

    AC_MSG_CHECKING([build mode])
    AS_VAR_SET_IF([ac_build_mode], [], [ac_build_mode=debug])
    AC_MSG_RESULT([$ac_build_mode])

    case $ac_build_mode in
      optimize)
        AC_DEFINE_UNQUOTED([SAT_MODE_OPTIMIZE],1,[Compilation mode is optimize])
	CXXFLAGS="$CXXFLAGS $CXXFLAGS_OPT"
	LDFLAGS="$LDFLAGS $LDFLAGS_OPT"
	CFLAGS="$CFLAGS $CFLAGS_OPT"
	;;
      debug)
        AC_DEFINE_UNQUOTED([SAT_MODE_DEBUG],1,[Compilation mode is debug])
	CXXFLAGS="$CXXFLAGS $CXXFLAGS_DBG"
	LDFLAGS="$LDFLAGS $LDFLAGS_DBG"
	CFLAGS="$CFLAGS $CFLAGS_DBG"
	;;
      profile)
        AC_DEFINE_UNQUOTED([SAT_MODE_PROFILE],1,[Compilation mode is profile])
	CXXFLAGS="$CXXFLAGS $CXXFLAGS_PRF"
	LDFLAGS="$LDFLAGS $LDFLAGS_PRF"
	CFLAGS="$CFLAGS $CFLAGS_PRF"
	;;
    esac

    AC_DEFINE_UNQUOTED([SAT_MODE], ["$ac_build_mode"],[Compilation mode])
    AC_DEFINE_UNQUOTED([SAT_CXXFLAGS], ["$CXXFLAGS"],[Compilation flags (i.e. CXXFLAGS)])

    AM_CONDITIONAL([DEBUG],    [test $ac_build_mode = debug])
    AM_CONDITIONAL([PROFILE],  [test $ac_build_mode = profile])
    AM_CONDITIONAL([OPTIMIZE], [test $ac_build_mode = optimize])
  ])

AC_DEFUN([AC_LIB_MPI],[

    ac_mpi=no
    AC_MSG_CHECKING([whether to enable MPI])
    AC_ARG_ENABLE(mpi, AS_HELP_STRING([--enable-mpi],
        [enable Message Passing Interface (MPI) support]),
      [
	if test "$enableval" = yes; then
	  AC_MSG_RESULT([yes])
          AC_DEFINE_UNQUOTED(HAVE_MPI, 1,
            [Whether we have <mpi.h> header file and we are willing to use it])
	  ac_mpi=yes
	  AC_FIND_MPI
	fi
	], [AC_MSG_RESULT([no])])
  ])

dnl ********************************************************************
dnl * AC_PROG_MPICC searches the PATH for an available MPI C compiler
dnl * wraparound.  It assigns the name to MPICC.
dnl ********************************************************************

AC_DEFUN([AC_PROG_MPICC],
[
   AC_CHECK_PROGS(MPICC, mpcc mpicc tmcc hcc)
   test -z "$MPICC" && AC_MSG_ERROR([no acceptable mpicc found in \$PATH])
])dnl


dnl ********************************************************************
dnl * AC_PROG_MPICXX searches the PATH for an available MPI C++ 
dnl * compiler wraparound.  It assigns the name to MPICXX.
dnl ********************************************************************

AC_DEFUN([AC_PROG_MPICXX],
[
   AC_CHECK_PROGS(MPICXX, mpKCC mpCC mpig++ mpicxx mpiCC hcp)
   test -z "$MPICXX" && AC_MSG_ERROR([no acceptable mpic++ found in \$PATH])
])dnl


dnl **********************************************************************
dnl * AC_PROG_MPIF77 searches the PATH for an available MPI Fortran 77 
dnl * compiler wraparound.  It assigns the name to MPIF77.
dnl **********************************************************************

AC_DEFUN([AC_PROG_MPIF77],
[
   AC_CHECK_PROGS(MPIF77, mpf77 mpxlf mpif77 mpixlf tmf77 hf77)
   test -z "$MPIF77" && AC_MSG_ERROR([no acceptable mpif77 found in \$PATH])
])dnl


dnl ***********************************************************************
dnl * AC_CHECK_MPIF77_PP checks whether the preprocessor needs to
dnl * be called before calling the compiler for Fortran files with
dnl * preprocessor directives and MPI function calls.  If the preprocessor
dnl * is necessary, MPIF77NEEDSPP is set to "yes", otherwise it is set to
dnl * "no"
dnl ***********************************************************************

AC_DEFUN([AC_CHECK_MPIF77_PP],
[
   AC_REQUIRE([AC_PROG_MPIF77])

   rm -f testppmp.o

   AC_MSG_CHECKING(whether $FPP needs to be called before $MPIF77)

   # This follows the same procedur as AC_CHECK_F77_PP, except it tests
   # $MPIF77 using a test program that includes MPI functions.

   cat > testppmp.F <<EOF
#define FOO 3
	program testppmp
	include 'mpif.h'
	integer rank,size,mpierr,sum
	call MPI_INIT(mpierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD,size,mpierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD,rank,mpierr)
#ifdef FORTRAN_NO_UNDERSCORE
        sum = rank + size
#else
        sum = rank + rank
#endif
        call MPI_FINALIZE(mpierr)
        end 
EOF

   $MPIF77 -DBAR -c testppmp.F 
   if test -f testppmp.o; then 
      MPIF77NEEDSPP=no 
   else 
      MPIF77NEEDSPP=yes 
   fi

   echo $MPIF77NEEDSPP
   rm -f testppmp.o testppmp.F
   AC_SUBST(MPIF77NEEDSPP)
])dnl


dnl *********************************************************************
dnl * AC_CHECK_MPI sets up the needed MPI library and directory flags.   
dnl * The location of the file mpi.h is put into the variable MPIINCLUDE
dnl * as a -I flag.  The -l flags that specify the needed libraries and
dnl * the -L flags that specify the paths of those libraries are placed in
dnl * the variables MPILIBS and MPILIBDIRS, respectively.  To set the MPI
dnl * libraries and directories manually, use the --with-mpi-include,
dnl * --with-mpi-libs, and --with-mpi-libdir command-line options when
dnl * invoking configure.  Only one directory should be specified with
dnl * --with-mpi-include, while any number of directories can be specified
dnl * by --with-mpi-libdir.  Any number of libraries can be specified
dnl * with --with-mpi-libs, and the libraries must be referred to by their 
dnl * base names, so libmpi.a is just mpi.  It is adviseable to use all 
dnl * three --with flags whenever one is used, because it is likely that
dnl * when one is chosen it will mess up the automatic choices for the
dnl * other two.  If the architecture is unknown, or if the needed MPI
dnl * settings for the current architecture are not known, then the naive
dnl * settings of MPILIBS="-lmpi" and MPILIBDIRS="-L/usr/local/mpi/lib"
dnl * are tested, and if they exist they are used, otherwise the MPILIB*
dnl * variables are left blank.  In the case of rs6000, the variable
dnl * MPIFLAGS is also set. 
dnl **********************************************************************
 
AC_DEFUN([AC_CHECK_MPI],
[

   dnl * If called from within AC_FIND_MPI, then the configure-line
   dnl * options will already exist.  This ifdef creates them otherwise.
   ifdef([AC_FIND_MPI], ,
       [AC_ARG_WITH(mpi-include,
	       [AC_HELP_STRING([--with-mpi-include=DIR],
		       [the DIR where mpi.h is resides])],
               ac_mpi_include_dir=$withval)

      AC_ARG_WITH(mpi-libs, 
	  [AC_HELP_STRING([--with-mpi-libs=LIBS],
		  [LIBS is space-separated list of library names
                      needed for MPI, e.g. "nsl socket mpi"])],
                  ac_mpi_libs=$withval)

      AC_ARG_WITH(mpi-libdir,
	  [AC_HELP_STRING([--with-mpi-libdir=DIRS],
                  [DIRS is space-separated list of directories
                      containing the libraries specified by
                      e.g "/usr/lib /usr/local/mpi/lib"])],
          ac_mpi_lib_dirs=$withval)]
       )

   if test -z "$ac_mpi_libs"; then
#      AC_REQUIRE([AC_GUESS_ARCH])
      AC_REQUIRE([AC_CHECK_PLATFORM])

      dnl * Set everything to known values
      case $ac_host_os in

        Solaris)
            case $F77 in
               *g77)
                   if test -z "$ac_mpi_include_dir"; then
                      ac_mpi_include_dir=/usr/local/mpi/lam/h
                   fi
                   
                   if test -z "$ac_mpi_lib_dirs"; then
                      ac_mpi_lib_dirs="/usr/local/mpi/lam/lib"
                   fi

                   ac_mpi_libs="socket mpi trillium args tstdio t";;

               *)

                  if test -z "$ac_mpi_include_dir"; then
                     MPIINCLUDE="-I/usr/local/mpi/mpich/include \
                                 -I/usr/local/mpi/mpich/lib/solaris/ch_p4"
                  fi

                  if test -z "$ac_mpi_lib_dirs"; then
                     ac_mpi_lib_dirs="/usr/local/mpi/mpich/lib/solaris/ch_p4 \
                                       /usr/lib"
                  fi
            
               ac_mpi_libs="nsl socket mpi";;
               esac

            if test -z "$MPIINCLUDE"; then
               AC_CHECK_HEADER($ac_mpi_include_dir/mpi.h,
                               MPIINCLUDE="-I$ac_mpi_include_dir")
            fi
         ;;

         alpha)
            if test -z "$ac_mpi_include_dir"; then
               ac_mpi_include_dir=/usr/local/mpi/include
            fi
            AC_CHECK_HEADER($ac_mpi_include_dir/mpi.h,
                               MPIINCLUDE="-I$ac_mpi_include_dir")

            if test -z "$ac_mpi_lib_dirs"; then
               ac_mpi_lib_dirs="/usr/local/mpi/lib/alpha/ch_shmem \
                                  /usr/local/lib"
            fi

            ac_mpi_libs="mpich gs";;

         AIX) 

dnl            if test -z "$ac_mpi_include_dir"; then
dnl               ac_mpi_include_dir=/usr/lpp/ppe.poe/include
dnl            fi
dnl            AC_CHECK_HEADER($ac_mpi_include_dir/mpi.h,
dnl                               MPIINCLUDE="-I$ac_mpi_include_dir")

dnl            if test -z "$ac_mpi_lib_dirs"; then
dnl               ac_mpi_lib_dirs=/usr/lpp/ppe.poe/lib
dnl            fi

            ac_mpi_libs=mpi

#            MPIFLAGS="-binitfini:poe_remote_main";;
	     ;;
         Irix) 
            if test -z "$ac_mpi_include_dir"; then
               ac_mpi_include_dir=/usr/include
            fi
            AC_CHECK_HEADER($ac_mpi_include_dir/mpi.h,
                               MPIINCLUDE="-I$ac_mpi_include_dir")

            if test -z "$ac_mpi_lib_dirs"; then
               ac_mpi_lib_dirs=/usr/lib$ac_bits/
            fi

            ac_mpi_libs=mpi;; 
        
         *)
AC_MSG_WARN([trying naive MPI settings - can use --with flags to change])
            if test -z "$ac_mpi_include_dir"; then
               ac_mpi_include_dir=/usr/local/mpi/include
            fi
            AC_CHECK_HEADER($ac_mpi_include_dir/mpi.h,
                               MPIINCLUDE="-I$ac_mpi_include_dir")

            if test -z "$ac_mpi_lib_dirs"; then
               ac_mpi_lib_dirs=/usr/local/mpi/lib
            fi
            ac_mpi_libs=mpi ;;
      esac

#      for ac_lib in $ac_mpi_libs; do
# TODO: (from SAMRAI)
#         AC_ADD_LIB($ac_lib, main, $ac_mpi_lib_dirs, MPI)
#      done

   else
      if test -n "$ac_mpi_include_dir"; then
         MPIINCLUDE="-I$ac_mpi_include_dir"
      else
         MPIINCLUDE=
      fi

      if test -n "$ac_mpi_lib_dirs"; then
         for ac_lib_dir in $ac_mpi_lib_dirs; do
            MPILIBDIRS="-L$ac_lib_dir $MPILIBDIRS"
         done
      else
         MPILIBDIRS=
      fi

      for ac_lib in $ac_mpi_libs; do
         MPILIBS="$MPILIBS -l$ac_lib"
      done
   fi
])dnl


dnl ********************************************************************
dnl * AC_FIND_MPI will determine the libraries, directories, and other
dnl * flags needed to compile and link programs with MPI function calls.
dnl * This macro runs tests on the script found by the AC_PROG_MPICC
dnl * macro.  If there is no such mpicc-type script in the PATH and
dnl * MPICC is not set manually, then this macro will not work.
dnl *
dnl * One may question why these settings would need to be determined if
dnl * there already is mpicc available, and that is a valid question.  I
dnl * can think of a couple of reasons one may want to use these settings 
dnl * rather than using mpicc directly.  First, these settings allow you
dnl * to choose the C compiler you wish to use rather than using whatever
dnl * compiler is written into mpicc.  Also, the settings determined by
dnl * this macro should also work with C++ and Fortran compilers, so you
dnl * won't need to have mpiCC and mpif77 alongside mpicc.  This is
dnl * especially helpful on systems that don't have mpiCC.  The advantage
dnl * of this macro over AC_CHECK_MPI is that this one doesn't require
dnl * a test of the machine type and thus will hopefully work on unknown
dnl * architectures.  The main disadvantage is that it relies on mpicc.
dnl *
dnl * --with-mpi-include, --with-mpi-libs, and --with-mpi-libdir can be
dnl * used to manually override the automatic test, just as with
dnl * AC_CHECK_MPI.  If any one of these three options are used, the
dnl * automatic test will not be run, so it is best to call all three
dnl * whenever one is called.  In addition, the option --with-mpi-flags is
dnl * available here to set any other flags that may be needed, but it
dnl * does not override the automatic test.  Flags set by --with-mpi-flags
dnl * will be added to the variable MPIFLAGS.  This way, if the macro, for
dnl * whatever reason, leaves off a necessary flag, the flag can be added 
dnl * to MPIFLAGS without eliminating anything else.  The other variables
dnl * set are MPIINCLUDE, MPILIBS, and MPILIBDIRS, just as in 
dnl * AC_CHECK_MPI.  This macro also incorporates AC_CHECK_MPI as a backup
dnl * plan, where if there is no mpicc, it will use the settings
dnl * determined by architecture name in AC_CHECK_MPI
dnl ********************************************************************

AC_DEFUN([AC_FIND_MPI],
[

  ac_find_mpi_cache_used=yes

  AC_CACHE_VAL(ac_cv_mpi_include, ac_find_mpi_cache_used=no)
  AC_CACHE_VAL(ac_cv_mpi_libs, ac_find_mpi_cache_used=no)
  AC_CACHE_VAL(ac_cv_mpi_lib_dirs, ac_find_mpi_cache_used=no)
  AC_CACHE_VAL(ac_cv_mpi_flags, ac_find_mpi_cache_used=no)

  if test "$ac_find_mpi_cache_used" = "yes"; then
    AC_MSG_CHECKING(for location of mpi.h)
    MPIINCLUDE=$ac_cv_mpi_include
    AC_MSG_RESULT("\(cached\) $MPIINCLUDE")

    AC_MSG_CHECKING(for MPI library directories)
    MPILIBDIRS=$ac_cv_mpi_lib_dirs
    AC_MSG_RESULT("\(cached\) $MPILIBDIRS")

    AC_MSG_CHECKING(for MPI libraries)
    MPILIBS=$ac_cv_mpi_libs
    AC_MSG_RESULT("\(cached\) $MPILIBS")

    AC_MSG_CHECKING(for other MPI-related flags)
    MPIFLAGS=$ac_cv_mpi_flags
    AC_MSG_RESULT("\(cached\) $MPIFLAGS")
  else
   

    dnl * Set up user options.  If user uses any of the fist three options,
    dnl * then automatic tests are not run.

    ac_user_chose_mpi=no
    AC_ARG_WITH(mpi-include,
      [AC_HELP_STRING([--with-mpi-include=DIR], [the DIR where mpi.h desides])],
      for mpi_dir in $withval; do
        MPIINCLUDE="$MPIINCLUDE -I$withval"
      done; ac_user_chose_mpi=yes)

    AC_ARG_WITH(mpi-libs,
      [AC_HELP_STRING([--with-mpi-libs=LIBS],[LIBS is space-separated list of library names 
            needed for MPI, e.g. "nsl socket mpi"])],
      for mpi_lib in $withval; do
        MPILIBS="$MPILIBS -l$mpi_lib"
      done; ac_user_chose_mpi=yes)

    AC_ARG_WITH(mpi-libdir,
      [AC_HELP_STRING([--with-mpi-libdir=DIRS],
          [DIRS is space-separated list of directories
            containing the libraries specified by e.g "/usr/lib /usr/local/mpi/lib"])],
      for mpi_lib_dir in $withval; do
        MPILIBDIRS="-L$mpi_lib_dir $MPILIBDIRS"
      done; ac_user_chose_mpi=yes)

    dnl * --with-mpi-flags only adds to automatic selections, 
    dnl * does not override

    AC_ARG_WITH(mpi-flags,
      [AC_HELP_STRING([--with-mpi-flags=FLAGS],
          [FLAGS is space-separated list of whatever flags other
            than -l and -L are needed to link with mpi libraries])],
      MPIFLAGS=$withval)

    if test "$ac_user_chose_mpi" = "no"; then

      dnl * Find an MPICC.  If there is none, call AC_CHECK_MPI to choose MPI
      dnl * settings based on architecture name.  If AC_CHECK_MPI fails,
      dnl * print warning message.  Manual MPI settings must be used.

      AC_ARG_WITH(mpicc,
        [AC_HELP_STRING([--with-mpicc=ARG],[ARG is mpicc or similar MPI C compiling tool])],
        MPICC=$withval,
        [AC_CHECK_PROGS(MPICC, mpcc mpicc tmcc hcc)])

      if test -z "$MPICC"; then
        AC_MSG_WARN([no acceptable mpicc found in \$PATH])
          AC_CHECK_MPI
          if test -z "$MPILIBS"; then
            AC_MSG_WARN([MPI not found - must set manually using --with flags])
          fi

          dnl * When $MPICC is there, run the automatic test
          dnl * here begins the hairy stuff

      else      
 
        dnl changequote(, )dnl
        dnl * Create a minimal MPI program.  It will be compiled using
        dnl * $MPICC with verbose output.
        cat > mpconftest.c << EOF
#include "mpi.h"

main(int argc, char **argv)
{
   int rank, size;
   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &size);
   MPI_Comm_rank(MPI_COMM_WORLD, &rank);
   MPI_Finalize();
   return 0;
}
EOF

        ac_mplibs=
        ac_mplibdirs=
        ac_flags=
        ac_lmpi_exists=no

        dnl * These are various ways to produce verbose output from $MPICC
        dnl * All of their outputs are stuffed into variable
        dnl * $ac_mpoutput

        for ac_command in "$MPICC -show"\
                                "$MPICC -v"\
                                "$MPICC -#"\
                                "$MPICC"; do

          ac_this_output=`$ac_command mpconftest.c -o mpconftest 2>&1`

          dnl * If $MPICC uses xlc, then commas must be removed from output
          xlc_p=`echo $ac_this_output | grep xlcentry`
          if test -n "$xlc_p"; then
            ac_this_output=`echo $ac_this_output | sed 's/,/ /g'`
          fi

          dnl * Turn on flag once -lmpi is found in output
          lmpi_p=`echo $ac_this_output | grep "\-lmpi"`
          if test -n "$lmpi_p"; then
            ac_lmpi_exists=yes
          fi

               ac_mpoutput="$ac_mpoutput $ac_this_output"
               ac_this_output=

            done

            rm -rf mpconftest*

            dnl * little test to identify $CC as IBM's xlc
            echo "main() {}" > cc_conftest.c
            cc_output=`${CC-cc} -v -o cc_conftest cc_conftest.c 2>&1`
            xlc_p=`echo $cc_output | grep xlcentry`
            if test -n "$xlc_p"; then
               ac_compiler_is_xlc=yes
            fi 
            rm -rf cc_conftest*

            dnl * $MPICC might not produce '-lmpi', but we still need it.
            dnl * Add -lmpi to $ac_mplibs if it was never found
            if test "$ac_lmpi_exists" = "no"; then
               ac_mplibs="-lmpi"
            else
               ac_mplibs=
            fi

            ac_want_arg=

            dnl * Loop through every word in output to find possible flags.
            dnl * If the word is the absolute path of a library, it is added
            dnl * to $ac_flags.  Any "-llib", "-L/dir", "-R/dir" and
            dnl * "-I/dir" is kept.  If '-l', '-L', '-R', '-I', '-u', or '-Y'
            dnl * appears alone, then the next word is checked.  If the next
            dnl * word is another flag beginning with '-', then the first
            dnl * word is discarded.  If the next word is anything else, then
            dnl * the two words are coupled in the $ac_arg variable.
            dnl * "-binitfini:poe_remote_main" is a flag needed especially
            dnl * for IBM MPI, and it is always kept if it is found.
            dnl * Any other word is discarded.  Also, after a word is found
            dnl * and kept once, it is discarded if it appears again

            for ac_arg in $ac_mpoutput; do
 
               ac_old_want_arg=$ac_want_arg
               ac_want_arg=  

               if test -n "$ac_old_want_arg"; then
                  case "$ac_arg" in
                  [-*)]
                     ac_old_want_arg=
                  ;;
                  esac
               fi

               case "$ac_old_want_arg" in
               ['')]
                  case $ac_arg in
                  [/*.a)]
                     exists=false
                     for f in $ac_flags; do
                        if test x$ac_arg = x$f; then
                           exists=true
                        fi
                     done
                     if $exists; then
                        ac_arg=
                     else
                        ac_flags="$ac_flags $ac_arg"
                     fi
                  ;;
#                   [-binitfini:poe_remote_main)]
#                      exists=false
#                      for f in $ac_flags; do
#                         if test x$ac_arg = x$f; then
#                            exists=true
#                         fi
#                      done
#                      if $exists; then
#                         ac_arg=
#                      else
#                         ac_flags="$ac_flags $ac_arg"
#                      fi
#                   ;;
                  [-lang*)]
                     ac_arg=
                  ;;
                  [-[lLR])]
                     ac_want_arg=$ac_arg
                     ac_arg=
                  ;;
                  [-[lLR]*)]
                     exists=false
                     for f in $ac_flags; do
                        if test x$ac_arg = x$f; then
                           exists=true
                        fi
                     done
                     if $exists; then
                        ac_arg=
                     else
                       ac_flags="$ac_flags $ac_arg"
                     fi
                  ;;
                 [-u)]
                     ac_want_arg=$ac_arg
                     ac_arg=
                  ;;
                  [-Y)]
                     ac_want_arg=$ac_arg
                     ac_arg=
                  ;;
                  [-I)]
                     ac_want_arg=$ac_arg
                     ac_arg=
                  ;;
                  [-I*)]
                     exists=false
                     for f in $ac_flags; do
                        if test x$ac_arg = x$f; then
                           exists=true
                        fi
                     done
                     if $exists; then
                        ac_arg=
                     else
                        ac_flags="$ac_flags $ac_arg"
                     fi
                  ;;
                  [*)]
                     ac_arg=
                  ;;
                  esac

               ;;
               [-[lLRI])]
                  ac_arg="ac_old_want_arg $ac_arg"
               ;;
               [-u)]
                  ac_arg="-u $ac_arg"
               ;;
               [-Y)]
                  ac_arg=`echo $ac_arg | sed -e 's%^P,%%'`
                  SAVE_IFS=$IFS
                  IFS=:
                  ac_list=
                  for ac_elt in $ac_arg; do
                     ac_list="$ac_list -L$ac_elt"
                  done
                  IFS=$SAVE_IFS
                  ac_arg="$ac_list"
               ;;
               esac

               dnl * Still inside the big for loop, we separate each flag
               dnl * into includes, libdirs, libs, flags
               if test -n "$ac_arg"; then
                  case $ac_arg in
                  [-I*)]

                     dnl * if the directory given in this flag contains mpi.h
                     dnl * then the flag is assigned to $MPIINCLUDE
                     if test -z "$MPIINCLUDE"; then
                        ac_cppflags="$ac_cppflags $ac_arg"
                        ac_include_dir=`echo "$ac_arg" | sed 's/-I//g'` 

                        SAVE_CPPFLAGS="$CPPFLAGS"
                        CPPFLAGS="$ac_cppflags"
                        dnl changequote([, ])dnl

                        unset ac_cv_header_mpi_h
                        AC_CHECK_HEADER(mpi.h,
                                        MPIINCLUDE="$ac_cppflags")

                        dnl changequote(, )dnl
                        CPPFLAGS="$SAVE_CPPFLAGS"

                     else
                        ac_arg=
                     fi
                  ;;
                  [-[LR]*)]

                     dnl * These are the lib directory flags
                     ac_mplibdirs="$ac_mplibdirs $ac_arg"
                  ;;
                  [-l* | /*)]

                     dnl * These are the libraries
                     ac_mplibs="$ac_mplibs $ac_arg"
                  ;;
#                   [-binitfini:poe_remote_main)]
#                      if test "$ac_compiler_is_xlc" = "yes"; then
#                         ac_mpflags="$ac_mpflags $ac_arg"
#                      fi
#                   ;;
                  [*)]
                     dnl * any other flag that has been kept goes here
                     ac_mpflags="$ac_mpflags $ac_arg"
                  ;;
                  esac

                  dnl * Upcoming test needs $LIBS to contain the flags 
                  dnl * we've found
                  LIBS_SAVE=$LIBS
                  LIBS="$MPIINCLUDE $ac_mpflags $ac_mplibdirs $ac_mplibs"

                  if test -n "`echo $LIBS | grep '\-R/'`"; then
                     LIBS=`echo $LIBS | sed 's/-R\//-R \//'`
                  fi

                  dnl changequote([, ])dnl


                  dnl * Test to see if flags found up to this point are
                  dnl * sufficient to compile and link test program.  If not,
                  dnl * the loop keeps going to the next word
                  AC_LANG_PUSH(C)
                  AC_TRY_LINK(
dnl                     ifelse(AC_LANG, [C++],

dnl [#ifdef __cplusplus
dnl extern "C"
dnl #endif
dnl ])dnl
[#include "mpi.h"
], [int rank, size;
   int argc;
   char **argv;
   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &size);
   MPI_Comm_rank(MPI_COMM_WORLD, &rank);
   MPI_Finalize();
],
                     ac_result=yes)
                  AC_LANG_POP(C)
                  LIBS=$LIBS_SAVE

                  if test "$ac_result" = yes; then
                     ac_result=
                     break
                  fi
               fi
            done

            dnl * After loop is done, set variables to be substituted
            MPILIBS=$ac_mplibs
            MPILIBDIRS=$ac_mplibdirs
            MPIFLAGS="$MPIFLAGS $ac_mpflags"

            dnl * IBM MPI uses /usr/lpp/ppe.poe/libc.a instead of /lib/libc.a
            dnl * so we need to make sure that -L/lib is not part of the 
            dnl * linking line when we use IBM MPI.  This only appears in
            dnl * configure when AC_FIND_MPI is called first.
	    dnl            ifdef([AC_PROVIDE_AC_FIND_F77LIBS], 
            dnl               if test -n "`echo $F77LIBFLAGS | grep '\-L/lib '`"; then
            dnl                  if test -n "`echo $F77LIBFLAGS | grep xlf`"; then
            dnl                     F77LIBFLAGS=`echo $F77LIBFLAGS | sed 's/-L\/lib //g'`
            dnl                  fi
            dnl               fi
            dnl            )

            if test -n "`echo $MPILIBS | grep pmpich`" &&
               test -z "`echo $MPILIBS | grep pthread`"; then
                  LIBS_SAVE=$LIBS
                  LIBS="$MPIINCLUDE $MPIFLAGS $MPILIBDIRS $MPILIBS -lpthread"
                  AC_LANG_PUSH(C)
                  AC_TRY_LINK(
dnl                     ifelse(AC_LANG, [C++],

dnl [#ifdef __cplusplus
dnl extern "C"
dnl #endif
dnl ])dnl
[#include "mpi.h"
], [int rank, size;
   int argc;
   char **argv;
   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &size);
   MPI_Comm_rank(MPI_COMM_WORLD, &rank);
   MPI_Finalize();
],
                     MPILIBS="$MPILIBS -lpthread")
                  AC_LANG_POP(C)
                  LIBS=$LIBS_SAVE
            fi

            AC_MSG_CHECKING(for MPI include directories)
            AC_MSG_RESULT($MPIINCLUDE)
            AC_MSG_CHECKING(for MPI library directories)
            AC_MSG_RESULT($MPILIBDIRS)
            AC_MSG_CHECKING(for MPI libraries)
            AC_MSG_RESULT($MPILIBS)
            AC_MSG_CHECKING(for other MPI-related flags)
            AC_MSG_RESULT($MPIFLAGS)
         fi
      fi

      AC_CACHE_VAL(ac_cv_mpi_include, ac_cv_mpi_include=$MPIINCLUDE)
      AC_CACHE_VAL(ac_cv_mpi_lib_dirs, ac_cv_mpi_lib_dirs=$MPILIBDIRS)
      AC_CACHE_VAL(ac_cv_mpi_libs, ac_cv_mpi_libs=$MPILIBS)
      AC_CACHE_VAL(ac_cv_mpi_flags, ac_cv_mpi_flags=$MPIFLAGS)
   fi

   AC_ARG_WITH(mpi-bootcmd, [AC_HELP_STRING([--with-mpi-bootcmd=CMD],
         [how to boot MPI (usualy mpiboot) environment])], MPIBOOT=$withval)
   AC_ARG_WITH(mpi-runcmd,
     [AC_HELP_STRING([--with-mpi-runcmd=CMD],
         [how to run MPI (default: mpirun -np @NP @PROG @ARGS) programs])],
     MPIRUN=$withval)
   AC_ARG_WITH(mpi-haltcmd, [AC_HELP_STRING([--with-mpi-haltcmd=CMD],
         [how to halt MPI environment])], MPIHALT=$withval)

   AC_SUBST(MPIBOOT)
   AC_SUBST(MPIRUN)
   AC_SUBST(MPIHALT)

   CFLAGS_MPI="$MPIFLAGS $MPIINCLUDE"
   CXXFLAGS_MPI="$MPIFLAGS $MPIINCLUDE"
   LDFLAGS_MPI="$MPIFLAGS $MPILIBDIRS $MPILIBS"
   AC_SUBST(CFLAGS_MPI)
   AC_SUBST(CXXFLAGS_MPI)
   AC_SUBST(LDFLAGS_MPI)

])dnl

dnl ********************************************************************
dnl * AC_FIND_MPI_ALPHA is a special case of AC_FIND_MPI for the
dnl * compass cluster.  The original AC_FIND_MPI looks for existence 
dnl * of mpCC and mpiCC.  If the former is found it uses native (proprietary) 
dnl * mpi and if the latter is found, it uses mpich.  The DECs are a 
dnl * special case because mpCC does not exist and mpiCC does, but we want
dnl * to use the native version by default.  Therefore, the original macro 
dnl * did not work for this case so I added this one to deal with it.
dnl * AMW 9/00
dnl ********************************************************************

AC_DEFUN([AC_FIND_MPI_ALPHA],
[

   ac_find_mpi_cache_used=yes

   AC_CACHE_VAL(ac_cv_mpi_include, ac_find_mpi_cache_used=no)
   AC_CACHE_VAL(ac_cv_mpi_libs, ac_find_mpi_cache_used=no)
   AC_CACHE_VAL(ac_cv_mpi_lib_dirs, ac_find_mpi_cache_used=no)
   AC_CACHE_VAL(ac_cv_mpi_flags, ac_find_mpi_cache_used=no)

   if test "$ac_find_mpi_cache_used" = "yes"; then
      AC_MSG_CHECKING(for location of mpi.h)
      MPIINCLUDE=$ac_cv_mpi_include
      AC_MSG_RESULT("\(cached\) $MPIINCLUDE")

      AC_MSG_CHECKING(for MPI library directories)
      MPILIBDIRS=$ac_cv_mpi_lib_dirs
      AC_MSG_RESULT("\(cached\) $MPILIBDIRS")

      AC_MSG_CHECKING(for MPI libraries)
      MPILIBS=$ac_cv_mpi_libs
      AC_MSG_RESULT("\(cached\) $MPILIBS")

      AC_MSG_CHECKING(for other MPI-related flags)
      MPIFLAGS=$ac_cv_mpi_flags
      AC_MSG_RESULT("\(cached\) $MPIFLAGS")
   else
   

      dnl * Set up user options.  If user uses any of the fist three options,
      dnl * then automatic tests are not run.

      ac_user_chose_mpi=no
      AC_ARG_WITH(mpi-include,
          [AC_HELP_STRING([--with-mpi-include=DIR],
                          [the DIR where mpi.h is located])],
                  for mpi_dir in $withval; do
                     MPIINCLUDE="$MPIINCLUDE -I$withval"
                  done; ac_user_chose_mpi=yes)

      AC_ARG_WITH(mpi-libs,
[  --with-mpi-libs=LIBS    LIBS is space-separated list of library names 
                          needed for MPI, e.g. "nsl socket mpi"],  
                  for mpi_lib in $withval; do
                     MPILIBS="$MPILIBS -l$mpi_lib"
                  done; ac_user_chose_mpi=yes)


      AC_ARG_WITH(mpi-lib-dirs,
[  --with-mpi-libdir=DIRS
                          DIRS is space-separated list of directories
                          containing the libraries specified by
                          e.g. "/usr/lib /usr/local/mpi/lib"],
                  for mpi_lib_dir in $withval; do
                     MPILIBDIRS="-L$mpi_lib_dir $MPILIBDIRS"
                  done; ac_user_chose_mpi=yes)

      dnl * --with-mpi-flags only adds to automatic selections, 
      dnl * does not override

      AC_ARG_WITH(mpi-flags,
[  --with-mpi-flags=FLAGS  FLAGS is space-separated list of whatever flags other
                          than -l and -L are needed to link with mpi libraries],
                          MPIFLAGS=$withval)


      if test "$ac_user_chose_mpi" = "no"; then
 
         dnl * Set defaults for Compass cluster here.  This is the point where
         dnl * we call AC_CHECK_MPI in AC_FIND_MPI macro. 
 
         ac_mpi_include_dir=
         ac_mpi_lib_dirs=
         ac_mpi_libs="mpi rt rpc gs pthread"

         for ac_incl_dir in $ac_mpi_include_dir; do
            MPIINCLUDE="-I$ac_incl_dir $MPIINCLUDE"
         done
         for ac_lib_dir in $ac_mpi_lib_dirs; do
            MPILIBDIRS="-L$ac_lib_dir $MPILIBDIRS"
         done
         for ac_lib in $ac_mpi_libs; do
            MPILIBS="$MPILIBS -l$ac_lib"
         done
      fi


      AC_MSG_CHECKING(for MPI include directories)
      AC_MSG_RESULT($MPIINCLUDE)
      AC_MSG_CHECKING(for MPI library directories)
      AC_MSG_RESULT($MPILIBDIRS)
      AC_MSG_CHECKING(for MPI libraries)
      AC_MSG_RESULT($MPILIBS)
      AC_MSG_CHECKING(for other MPI-related flags)
      AC_MSG_RESULT($MPIFLAGS)

   fi

])dnl
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_mutable.html
dnl

AC_DEFUN([AC_CXX_MUTABLE],
  [AC_CACHE_CHECK(for the mutable keyword,
      ac_cv_cxx_mutable,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    class A { mutable int i;
              public:
              int f (int n) const { i = n; return i; }
            };
	    ],[A a; return a.f (1);],
	  ac_cv_cxx_mutable=yes, ac_cv_cxx_mutable=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_mutable" = yes; then
      AC_DEFINE(HAVE_MUTABLE,1,[define if the compiler supports the mutable keyword])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_namespaces.html
dnl

AC_DEFUN([AC_CXX_NAMESPACES],
  [AC_CACHE_CHECK(implementation of namespaces,
      ac_cv_cxx_namespaces,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([namespace Outer { namespace Inner { int i = 0; }}],
          [using namespace Outer::Inner; return i;],
	  ac_cv_cxx_namespaces=yes, ac_cv_cxx_namespaces=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_namespaces" = yes; then
      AC_DEFINE(HAVE_NAMESPACES,1,[define if the compiler implements namespaces])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_nceg_restrict.html
dnl

AC_DEFUN([AC_CXX_NCEG_RESTRICT],
  [AC_CACHE_CHECK(for the Numerical C Extensions Group restrict keyword,
      ac_cv_cxx_nceg_restrict,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    void add(int length, double * restrict a,
              const double * restrict b, const double * restrict c)
	    { for (int i=0; i < length; ++i) a[i] = b[i] + c[i]; }
	    ],[double a[10], b[10], c[10];
	    for (int i=0; i < 10; ++i) { a[i] = 0.0; b[i] = 0.0; c[i] = 0.0; }
	    add(10,a,b,c);
	    return 0;],
	  ac_cv_cxx_nceg_restrict=yes, ac_cv_cxx_nceg_restrict=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_nceg_restrict" = yes; then
      AC_DEFINE(HAVE_NCEG_RESTRICT,1,
        [define if the compiler supports the Numerical C Extensions Group restrict keyword])
    fi
  ])


AC_DEFUN([AC_CXX_NCEG_RESTRICT_EGCS],
  [AC_CACHE_CHECK(if compiler recognizes the '__restrict__' keyword,
      ac_cv_cxx_nceg_restrict_egcs,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    void add(int length, double * __restrict__ a, 
              const double * __restrict__ b, const double * __restrict__ c)
	    { for (int i=0; i < length; ++i) a[i] = b[i] + c[i]; }
	    ],[double a[10], b[10], c[10];
	    for (int i=0; i < 10; ++i) { a[i] = 0.0; b[i] = 0.0; c[i] = 0.0; }
	    add(10,a,b,c);
	    return 0;],
	  ac_cv_cxx_nceg_restrict_egcs=yes, ac_cv_cxx_nceg_restrict_egcs=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_nceg_restrict_egcs" = yes; then
      AC_DEFINE(HAVE_NCEG_RESTRICT_EGCS,1,
        [define if the compiler supports the __restrict__ keyword])
    fi
  ])


# searches for libNOVA-stuff

#
# set following variables:    NOVA_CPPFLAGS, NOVA_LDFLAGS, NOVA_LIBS, with_NOVA
# generate config file value: HAVE_NOVA
# Conditional for Automake:   NAHE_NOVA
#

AC_DEFUN([AC_LIB_NOVA],[
    AC_REQUIRE([AC_PROG_CC])

    AC_ARG_WITH(nova,
      AC_HELP_STRING([--with-nova=PATH],[directory with NOVA inside]),
    # expand tilde / other stuff
      eval with_nova=$with_nova
      )
    
    # AC_ARG_WITH(nova-libs,
    #   [AC_HELP_STRING([--with-nova-libs=LIBS],[additional libraries needed to link nova programs. Those might be needed if your nova library is static. Possible values are: -lz or -lz -lsz.])],[])

 # store values
    ac_save_CFLAGS="$CFLAGS"
    ac_save_CPPFLAGS="$CPPFLAGS"
    ac_save_LDFLAGS="$LDFLAGS"
    ac_save_LIBS="$LIBS"
    LIBS=""

 # start building variables

 # use special NOVA-lib-path if it's set
    if test x$with_nova != x ; then
   #  extract absolute path
      if test -d $with_nova; then
	eval with_nova=`cd $with_nova ; pwd`
      else
	AC_MSG_ERROR([NOVA-directory $with_nova does not exist])
      fi
      LDFLAGS="$LDFLAGS -L$with_nova/lib"
      NOVA_LDFLAGS="$LDFLAGS"
      CPPFLAGS="$CPPFLAGS -I$with_nova/include"
    fi

 # test for an arbitrary header
    AC_CHECK_HEADER([libnova/mercury.h], 
      [HAVE_NOVA=1]
      NOVA_CPPFLAGS="$CPPFLAGS",
      [HAVE_NOVA=0])
    
 # test for lib
    if test x$HAVE_NOVA = x1 ; then
      AC_CHECK_LIB(nova, ln_get_mercury_solar_dist,
        [NOVA_LIBS="-lnova $with_nova_libs"],
	[HAVE_NOVA=0], ["$with_nova_libs"])
    fi

 # pre-set variable for summary
    with_nova="no"

 # did we succeed?
    if test x$HAVE_NOVA = x1 ; then
      AC_SUBST(NOVA_CPPFLAGS, $NOVA_CPPFLAGS)
      AC_SUBST(NOVA_LDFLAGS, $NOVA_LDFLAGS)
      AC_SUBST(NOVA_LIBS, $NOVA_LIBS)
      AC_DEFINE(HAVE_NOVA,1, [Define to 1 if libnova was found])

   # proudly show in summary
      with_nova="yes"
    fi

 # also tell automake
    AM_CONDITIONAL(HAVE_NOVA, test x$HAVE_NOVA = x1)

 # reset values					    
    CFLAGS="$ac_save_CFLAGS"
    LIBS="$ac_save_LIBS"
    LDFLAGS="$ac_save_LDFLAGS"
    CPPFLAGS="$ac_save_CPPFLAGS"

  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_numeric_limits.html
dnl

AC_DEFUN([AC_CXX_HAVE_NUMERIC_LIMITS],
  [AC_CACHE_CHECK(whether the compiler has numeric_limits<T>,
      ac_cv_cxx_have_numeric_limits,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <limits>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[double e = numeric_limits<double>::epsilon(); return 0;],
	    ac_cv_cxx_have_numeric_limits=yes, ac_cv_cxx_have_numeric_limits=no)
	  AC_LANG_RESTORE
	])
      if test "$ac_cv_cxx_have_numeric_limits" = yes; then
	AC_DEFINE(HAVE_NUMERIC_LIMITS,1,[define if the compiler has numeric_limits<T>])
      fi
    ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_use_numtrait.html
dnl

AC_DEFUN([AC_CXX_USE_NUMTRAIT],
  [AC_CACHE_CHECK(for the numeric traits promotions,
      ac_cv_cxx_use_numtrait,
      [AC_REQUIRE([AC_CXX_TYPENAME])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
#ifndef HAVE_TYPENAME
 #define typename
#endif
	    template<class T_numtype> class SumType       { public : typedef T_numtype T_sumtype;   };
	    template<>                class SumType<char> { public : typedef int T_sumtype; };
	    template<class T> class A {};
	    template<class T> A<typename SumType<T>::T_sumtype> sum(A<T>)
	    { return A<typename SumType<T>::T_sumtype>(); }
	    ],[A<float> x; sum(x); return 0;],
	  ac_cv_cxx_use_numtrait=yes, ac_cv_cxx_use_numtrait=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_use_numtrait" = yes; then
      AC_DEFINE(HAVE_USE_NUMTRAIT,1,[define if the compiler supports numeric traits promotions])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_old_for_scoping.html
dnl

AC_DEFUN([AC_CXX_OLD_FOR_SCOPING],
  [AC_CACHE_CHECK(acceptance of the old for scoping rules,
      ac_cv_cxx_old_for_scoping,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE(,[int z;for (int i=0; i < 10; ++i)z=z+i;z=i;return z;],
	  ac_cv_cxx_old_for_scoping=yes, ac_cv_cxx_old_for_scoping=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_old_for_scoping" = yes; then
      AC_DEFINE(HAVE_OLD_FOR_SCOPING,1,[define if the compiler accepts the old for scoping rules])
    fi
  ])

AC_DEFUN([AC_CMP_FLAGS_OPENMP],[

    ac_openmp=no
    AC_MSG_CHECKING([whether to enable C/C++ OpenMP compilation flags])
    AC_ARG_ENABLE(openmp,
      AS_HELP_STRING([--enable-openmp],[enable C/C++ OpenMP compilation flags]),[
	if test "$enableval" = yes; then
	  if test "$FLAGS_OMP" != ""; then
	    AC_MSG_RESULT([yes])
	    ac_openmp=yes
	    CXXFLAGS="$FLAGS_OMP $CXXFLAGS"
	    CFLAGS="$FLAGS_OMP $CFLAGS"
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

AC_DEFUN([AC_ENABLE_OPTIMIZE],[

    AC_ARG_ENABLE([optimize],
      AS_HELP_STRING([--enable-optimize],
	[build with optimizations enabled (default no);
	  same as --enable-mode=optimize]), [
        # Defaults:
	sat_optimize=yes

	ifs_save="$IFS"
	IFS="$IFS,"
	for item in $enableval; do
	  case "$item" in
	    yes)  sat_optimize=yes ;;
	    no)  sat_optimize=no ;;
	    *) AC_MSG_ERROR([bad value $item for --enable-optimize]) ;;
	  esac
	done
	IFS="$ifs_save"

	],[sat_optimize=no])

    test x$sat_optimize != xno && ac_build_mode=optimize
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_partial_ordering.html
dnl

AC_DEFUN([AC_CXX_PARTIAL_ORDERING],
  [AC_CACHE_CHECK(for the partial ordering,
      ac_cv_cxx_partial_ordering,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<int N> struct I {};
	    template<class T> struct A
	    {  int r;
	      template<class T1, class T2> int operator() (T1, T2)       { r = 0; return r; }
	      template<int N1, int N2>     int operator() (I<N1>, I<N2>) { r = 1; return r; }
	    };],[A<float> x, y; I<0> a; I<1> b; return x (a,b) + y (float(), double());],
	  ac_cv_cxx_partial_ordering=yes, ac_cv_cxx_partial_ordering=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_partial_ordering" = yes; then
      AC_DEFINE(HAVE_PARTIAL_ORDERING,1,
        [define if the compiler supports partial ordering])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_partial_specialization.html
dnl

AC_DEFUN([AC_CXX_PARTIAL_SPECIALIZATION],
  [AC_CACHE_CHECK(for the partial specialization,
      ac_cv_cxx_partial_specialization,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T, int N> class A            { public : enum e { z = 0 }; };
	    template<int N>          class A<double, N> { public : enum e { z = 1 }; };
	    template<class T>        class A<T, 2>      { public : enum e { z = 2 }; };
	    ],[return (A<int,3>::z == 0) && (A<double,3>::z == 1) && (A<float,2>::z == 2);],
	  ac_cv_cxx_partial_specialization=yes, ac_cv_cxx_partial_specialization=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_partial_specialization" = yes; then
      AC_DEFINE(HAVE_PARTIAL_SPECIALIZATION,1,
        [define if the compiler supports partial specialization])
    fi
  ])

AC_DEFUN([AC_CHECK_PLATFORM],
  [
    AC_REQUIRE([AC_CANONICAL_HOST])

    case "$host" in
      *-*-linux-*)   ac_host_os="Linux";    ac_host_os_v="2";;
      *-*-cygwin*)   ac_host_os="Cygwin";   ac_host_os_v="1";;
      *-*-unicos*)   ac_host_os="UnicOS";   ac_host_os_v="1";; # Cray
      *-*-solaris*)  ac_host_os="Solaris";  ac_host_os_v="5";; # Sun
      *-*-osf3*)     ac_host_os="OSF1";     ac_host_os_v="3";;
      *-*-osf4*)     ac_host_os="OSF1";     ac_host_os_v="4";;
      *-*-osf5*)     ac_host_os="OSF1";     ac_host_os_v="5";;
      *-*-hpux10*)   ac_host_os="HPUX";     ac_host_os_v="10";;
      *-*-hpux11*)   ac_host_os="HPUX";     ac_host_os_v="11";;
      *-*-nextstep*) ac_host_os="NextStep"; ac_host_os_v="3";;
      *-*-openstep*) ac_host_os="NextStep"; ac_host_os_v="3";;
      *-*-irix*)     ac_host_os="Irix";     ac_host_os_v="6";; # SGI
      *-*-aix*)      ac_host_os="AIX";      ac_host_os_v="4";; # IBM
      *-*-darwin*)   ac_host_os="Darwin";   ac_host_os_v="1";;
      *-*-freebsd3*) ac_host_os="FreeBSD";  ac_host_os_v="3";;
      *-*-freebsd4*) ac_host_os="FreeBSD";  ac_host_os_v="4";;
      *-*-freebsd5*) ac_host_os="FreeBSD";  ac_host_os_v="5";;
      *-*-freebsd6*) ac_host_os="FreeBSD";  ac_host_os_v="6";;
      *-*-freebsd7*) ac_host_os="FreeBSD";  ac_host_os_v="7";;
      *-*-netbsd*)   ac_host_os="NetBSD";   ac_host_os_v="1";;
      *-*-openbsd*)  ac_host_os="OpenBSD";  ac_host_os_v="3";;
      *-*-sco*)      ac_host_os="OSR5";     ac_host_os_v="5";;
      *)             ac_host_os="Unknown";  ac_host_os_v="0";;
    esac

    ac_host_os_normalized="AS_TR_CPP([$ac_host_os])"

    AC_DEFINE_UNQUOTED(PLATFORM_OS_$ac_host_os_normalized,1,[OS Type])
    AC_DEFINE_UNQUOTED([PLATFORM_OS_NAME],
      ["$ac_host_os"],[String name of OS])
    AC_DEFINE_UNQUOTED([PLATFORM_OS_VERSION],[$ac_host_os_v],[Version of OS])

    case $ac_host_os in
      Darwin)  AC_DEFINE([PLATFORM_MACOSX],1,[Is the operating system MacOSX?]) ;;
      *)       AC_DEFINE([PLATFORM_UNIX],1,[Is the operating system UNIX?]) ;;
    esac
    AC_DEFINE_UNQUOTED([PLATFORM_NAME],
      ["UNIX"],[Sringified platfomr name])

# dnl ** Vendor

    case "$host" in
      *-cray-*)      ac_host_vendor="Cray";;
      *-ibm-*)       ac_host_vendor="IBM";;
      *-pc-*)        ac_host_vendor="PC";;
      *-sgi-*)       ac_host_vendor="SGI";;
      *-unknown-*)   ac_host_vendor="Unknown";;
      *)             ac_host_vendor="$host_vendor"
	AC_MSG_WARN([*****   Put info about vendor into platform.m4 file.  *****])
	;;

    esac

    ac_host_vendor_normalized="AS_TR_CPP([$ac_host_vendor])"

    AC_DEFINE_UNQUOTED(PLATFORM_VENDOR_$ac_host_vendor_normalized,1,[Platform vendor])
    AC_DEFINE_UNQUOTED([PLATFORM_VENDOR_NAME],
      ["$ac_host_vendor"],[Stringified platform vendor])

# dnl ** Processor

    case "$host" in
      x86_64-*)  ac_host_cpu="x86_64";;
      i?86-*)    ac_host_cpu="x86_32";;
      sparc-*)   ac_host_cpu="sparc";;
      alpha*)    ac_host_cpu="alpha";;
      m68k-*)    ac_host_cpu="m68k";;
      mips*)     ac_host_cpu="mips";;
      arm-*)     ac_host_cpu="arm";;
      s390-*)    ac_host_cpu="s390";;
      ia64-*)    ac_host_cpu="ia64";;
      hppa*)     ac_host_cpu="hppa";;
      powerpc*)  ac_host_cpu="ppc";;
      *)         ac_host_cpu="unknown";;
    esac

    ac_host_cpu_normalized="AS_TR_CPP([$ac_host_cpu])"

    AC_DEFINE_UNQUOTED(PLATFORM_PROCESSOR_[$ac_host_cpu_normalized],1,[Processor name])
    AC_DEFINE_UNQUOTED([PLATFORM_PROCESSOR_NAME],
      ["$ac_host_cpu"],[Strigified processor name])

    AC_SUBST(ac_host_cpu)
    AC_SUBST(ac_host_vendor)
    AC_SUBST(ac_host_os)
    AC_SUBST(ac_host_os_v)

  ])
AC_DEFUN([AC_ENABLE_PROFILE],[

    AC_ARG_ENABLE([profile],
      AS_HELP_STRING([--enable-profile],
	[build with profiling information (default no);
	  same as --enable-mode=profile]), [
        # Defaults:
	sat_profile=yes

	ifs_save="$IFS"
	IFS="$IFS,"
	for item in $enableval; do
	  case "$item" in
	    yes)  sat_profile=yes ;;
	    no)  sat_profile=no ;;
	    *) AC_MSG_ERROR([bad value $item for --enable-profile]) ;;
	  esac
	done
	IFS="$ifs_save"

	],[sat_profile=no])

    test x$sat_profile != xno && ac_build_mode=profile
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_reinterpret_cast.html
dnl

AC_DEFUN([AC_CXX_REINTERPRET_CAST],
  [AC_CACHE_CHECK(for the reinterpret_cast<>,
      ac_cv_cxx_reinterpret_cast,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <typeinfo>
	    class Base { public : Base () {} virtual void f () = 0;};
	    class Derived : public Base { public : Derived () {} virtual void f () {} };
	    class Unrelated { public : Unrelated () {} };
	    int g (Unrelated&) { return 0; }],[
	    Derived d;Base& b=d;Unrelated& e=reinterpret_cast<Unrelated&>(b);return g(e);],
	  ac_cv_cxx_reinterpret_cast=yes, ac_cv_cxx_reinterpret_cast=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_reinterpret_cast" = yes; then
      AC_DEFINE(HAVE_REINTERPRET_CAST,1,
        [define if the compiler supports reinterpret_cast<>])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_rtti.html
dnl

AC_DEFUN([AC_CXX_RTTI],
  [AC_CACHE_CHECK(for RTTI support,
      ac_cv_cxx_rtti,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <typeinfo>
	    class Base { public :
              Base () {}
              virtual int f () { return 0; }
            };
	    class Derived : public Base { public :
              Derived () {}
              virtual int f () { return 1; }
            };
	    ],[Derived d;
	    Base *ptr = &d;
	    return typeid (*ptr) == typeid (Derived);
	    ],
	  ac_cv_cxx_rtti=yes, ac_cv_cxx_rtti=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_rtti" = yes; then
      AC_DEFINE(HAVE_RTTI,1,
        [define if the compiler supports Run-Time Type Identification])
    fi
  ])



AC_DEFUN([AC_CXX_HAVE_RUSAGE],
  [AC_CACHE_CHECK(whether the compiler has getrusage() function,
      ac_cv_cxx_have_rusage,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <sys/resource.h>],[
	    struct rusage resUsage; getrusage(RUSAGE_SELF, &resUsage); return 0;],
	  ac_cv_cxx_have_rusage=yes, ac_cv_cxx_have_rusage=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_rusage" = yes; then
      AC_DEFINE(HAVE_RUSAGE,1,[define if the compiler has getrusage() function])
    fi
  ])


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


AC_DEFUN([AC_CXX_STANDARD_LIBRARY],[

AC_MSG_NOTICE([

**************************************************************************
****    Which STL features do we have                                 ****
**************************************************************************
])

AC_CXX_HAVE_COMPLEX
AC_CXX_HAVE_COMPLEX_FCNS
AC_CXX_HAVE_NUMERIC_LIMITS
AC_CXX_HAVE_CLIMITS
AC_CXX_HAVE_VALARRAY
AC_CXX_HAVE_COMPLEX_MATH1
AC_CXX_HAVE_COMPLEX_MATH2
AC_CXX_HAVE_IEEE_MATH
AC_CXX_HAVE_SYSTEM_V_MATH
AC_CXX_MATH_FN_IN_NAMESPACE_STD
AC_CXX_COMPLEX_MATH_IN_NAMESPACE_STD
AC_CXX_ISNAN_IN_NAMESPACE_STD
AC_CXX_HAVE_STD
AC_CXX_HAVE_STL
AC_CXX_HAVE_RUSAGE
AC_CXX_HAVE_FEENABLEEXCEPT
])

dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_static_cast.html
dnl

AC_DEFUN([AC_CXX_STATIC_CAST],
  [AC_CACHE_CHECK(for the static_cast<>,
      ac_cv_cxx_static_cast,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <typeinfo>
	    class Base { public : Base () {} virtual void f () = 0; };
	    class Derived : public Base { public : Derived () {} virtual void f () {} };
	    int g (Derived&) { return 0; }],[
	    Derived d; Base& b = d; Derived& s = static_cast<Derived&> (b); return g (s);],
	  ac_cv_cxx_static_cast=yes, ac_cv_cxx_static_cast=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_static_cast" = yes; then
      AC_DEFINE(HAVE_STATIC_CAST,1,
        [define if the compiler supports static_cast<>])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_std.html
dnl

AC_DEFUN([AC_CXX_HAVE_STD],
  [AC_CACHE_CHECK(whether the compiler supports ISO C++ standard library,
      ac_cv_cxx_have_std,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <iostream>
#include <map>
#include <iomanip>
#include <cmath>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[return 0;],
	    ac_cv_cxx_have_std=yes, ac_cv_cxx_have_std=no)
	  AC_LANG_RESTORE
	])
      if test "$ac_cv_cxx_have_std" = yes; then
	AC_DEFINE(HAVE_STD,1,[define if the compiler supports ISO C++ standard library])
      fi
    ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_stl.html
dnl

AC_DEFUN([AC_CXX_HAVE_STL],
  [AC_CACHE_CHECK(whether the compiler supports Standard Template Library,
      ac_cv_cxx_have_stl,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <list>
#include <deque>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[list<int> x; x.push_back(5);
	    list<int>::iterator iter = x.begin(); if (iter != x.end()) ++iter; return 0;],
	  ac_cv_cxx_have_stl=yes, ac_cv_cxx_have_stl=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_stl" = yes; then
      AC_DEFINE(HAVE_STL,1,[define if the compiler supports Standard Template Library])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_system_v_math.html
dnl

AC_DEFUN([AC_CXX_HAVE_SYSTEM_V_MATH],
  [AC_CACHE_CHECK(whether the compiler supports System V math library,
      ac_cv_cxx_have_system_v_math,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	ac_save_LIBS="$LIBS"
	LIBS="$LIBS -lm"
	AC_TRY_LINK([
#ifndef _ALL_SOURCE
 #define _ALL_SOURCE
#endif
#ifndef _XOPEN_SOURCE
 #define _XOPEN_SOURCE
#endif
#ifndef _XOPEN_SOURCE_EXTENDED
 #define _XOPEN_SOURCE_EXTENDED 1
#endif
#include <math.h>],[double x = 1.0; double y = 1.0;
	    _class(x); trunc(x); finite(x); itrunc(x); nearest(x); rsqrt(x); uitrunc(x);
	    copysign(x,y); drem(x,y); unordered(x,y);
	    return 0;],
	  ac_cv_cxx_have_system_v_math=yes, ac_cv_cxx_have_system_v_math=no)
	LIBS="$ac_save_LIBS"
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_have_system_v_math" = yes; then
      AC_DEFINE(HAVE_SYSTEM_V_MATH,1,[define if the compiler supports System V math library])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_template_keyword_qualifier.html
dnl

AC_DEFUN([AC_CXX_TEMPLATE_KEYWORD_QUALIFIER],
  [AC_CACHE_CHECK(for the use of the template keyword as a qualifier,
      ac_cv_cxx_template_keyword_qualifier,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    class X
	    {
	      public:
	      template<int> void member() {}
	      template<int> static void static_member() {}
	    };
	    template<class T> void f(T* p)
	    {
	      p->template member<200>(); // OK: < starts template argument
	      T::template static_member<100>(); // OK: < starts explicit qualification
	    }
	    ],[X x; f(&x); return 0;],
	  ac_cv_cxx_template_keyword_qualifier=yes, ac_cv_cxx_template_keyword_qualifier=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_template_keyword_qualifier" = yes; then
      AC_DEFINE(HAVE_TEMPLATE_KEYWORD_QUALIFIER,1,
        [define if the compiler supports use of the template keyword as a qualifier])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_template_qualified_base_class.html
dnl

AC_DEFUN([AC_CXX_TEMPLATE_QUALIFIED_BASE_CLASS],
  [AC_CACHE_CHECK(for the template-qualified base class specifiers,
      ac_cv_cxx_template_qualified_base_class,
      [AC_REQUIRE([AC_CXX_TYPENAME])
	AC_REQUIRE([AC_CXX_FULL_SPECIALIZATION_SYNTAX])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
#ifndef HAVE_TYPENAME
 #define typename
#endif
	    class Base1 { public : int f () const { return 1; } };
	    class Base2 { public : int f () const { return 0; } };
	    template<class X> struct base_trait        { typedef Base1 base; };
#ifdef HAVE_FULL_SPECIALIZATION_SYNTAX
	    template<>        struct base_trait<float> { typedef Base2 base; };
#else
            struct base_trait<float> { typedef Base2 base; };
#endif
	    template<class T> class Weird : public base_trait<T>::base
	    { public :
	      typedef typename base_trait<T>::base base;
	      int g () const { return base::f (); }
	    };],[ Weird<float> z; return z.g ();],
	  ac_cv_cxx_template_qualified_base_class=yes, ac_cv_cxx_template_qualified_base_class=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_template_qualified_base_class" = yes; then
      AC_DEFINE(HAVE_TEMPLATE_QUALIFIED_BASE_CLASS,1,
        [define if the compiler supports template-qualified base class specifiers])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_template_qualified_return_type.html
dnl

AC_DEFUN([AC_CXX_TEMPLATE_QUALIFIED_RETURN_TYPE],
  [AC_CACHE_CHECK(for the template-qualified return types,
      ac_cv_cxx_template_qualified_return_type,
      [AC_REQUIRE([AC_CXX_TYPENAME])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
#ifndef HAVE_TYPENAME
 #define typename
#endif
	    template<class X, class Y> struct promote_trait             { typedef X T; };
	    template<>                 struct promote_trait<int, float> { typedef float T; };
	    template<class T> class A { public : A () {} };
	    template<class X, class Y>
	    A<typename promote_trait<X,Y>::T> operator+ (const A<X>&, const A<Y>&)
	    { return A<typename promote_trait<X,Y>::T>(); }
	    ],[A<int> x; A<float> y; A<float> z = x + y; return 0;],
	  ac_cv_cxx_template_qualified_return_type=yes, ac_cv_cxx_template_qualified_return_type=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_template_qualified_return_type" = yes; then
      AC_DEFINE(HAVE_TEMPLATE_QUALIFIED_RETURN_TYPE,1,
        [define if the compiler supports template-qualified return types])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_template_scoped_argument_matching.html
dnl

AC_DEFUN([AC_CXX_TEMPLATE_SCOPED_ARGUMENT_MATCHING],
  [AC_CACHE_CHECK(for the function matching with argument types which are template scope-qualified,
      ac_cv_cxx_template_scoped_argument_matching,
      [AC_REQUIRE([AC_CXX_TYPENAME])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
#ifndef HAVE_TYPENAME
 #define typename
#endif
	    template<class X> class A { public : typedef X W; };
	    template<class Y> class B {};
	    template<class Y> void operator+(B<Y> d1, typename Y::W d2) {}
	    ],[B<A<float> > z; z + 0.5f; return 0;],
	  ac_cv_cxx_template_scoped_argument_matching=yes, ac_cv_cxx_template_scoped_argument_matching=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_template_scoped_argument_matching" = yes; then
      AC_DEFINE(HAVE_TEMPLATE_SCOPED_ARGUMENT_MATCHING,1,
        [define if the compiler supports function matching with argument types which are template scope-qualified])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_templates.html
dnl

AC_DEFUN([AC_CXX_TEMPLATES],
  [AC_CACHE_CHECK(for the basic templates,
      ac_cv_cxx_templates,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([template<class T> class A {public:A(){}};
	    template<class T> void f(const A<T>& ){}],[
	    A<double> d; A<int> i; f(d); f(i); return 0;],
	  ac_cv_cxx_templates=yes, ac_cv_cxx_templates=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_templates" = yes; then
      AC_DEFINE(HAVE_TEMPLATES,1,[define if the compiler supports basic templates])
    fi
  ])
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_templates_as_template_arguments.html
dnl

AC_DEFUN([AC_CXX_TEMPLATES_AS_TEMPLATE_ARGUMENTS],
  [AC_CACHE_CHECK(for the templates as template arguments,
      ac_cv_cxx_templates_as_template_arguments,
      [AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
	    template<class T> class allocator { public : allocator() {}; };
	    template<class X, template<class Y> class T_alloc>
	    class A { public : A() {} private : T_alloc<X> alloc_; };
	    ],[A<double, allocator> x; return 0;],
	  ac_cv_cxx_templates_as_template_arguments=yes, ac_cv_cxx_templates_as_template_arguments=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_templates_as_template_arguments" = yes; then
      AC_DEFINE(HAVE_TEMPLATES_AS_TEMPLATE_ARGUMENTS,1,
        [define if the compiler supports templates as template arguments])
    fi
  ])


AC_DEFUN([AC_CXX_TEMPLATES_FEATURES],[

AC_MSG_NOTICE([

**************************************************************************
****    Checking for templates support                                ****
**************************************************************************
])

AC_CXX_TEMPLATES
AC_CXX_PARTIAL_SPECIALIZATION
AC_CXX_PARTIAL_ORDERING
AC_CXX_DEFAULT_TEMPLATE_PARAMETERS
AC_CXX_MEMBER_TEMPLATES
AC_CXX_MEMBER_TEMPLATES_OUTSIDE_CLASS
AC_CXX_FULL_SPECIALIZATION_SYNTAX
AC_CXX_FUNCTION_NONTYPE_PARAMETERS
AC_CXX_TEMPLATE_QUALIFIED_BASE_CLASS
AC_CXX_TEMPLATE_QUALIFIED_RETURN_TYPE
AC_CXX_EXPLICIT_TEMPLATE_FUNCTION_QUALIFICATION
AC_CXX_TEMPLATES_AS_TEMPLATE_ARGUMENTS
AC_CXX_TEMPLATE_KEYWORD_QUALIFIER
AC_CXX_TEMPLATE_SCOPED_ARGUMENT_MATCHING
AC_CXX_TYPE_PROMOTION
AC_CXX_USE_NUMTRAIT
AC_CXX_ENUM_COMPUTATIONS
AC_CXX_ENUM_COMPUTATIONS_WITH_CAST
])

AC_DEFUN([AC_CXX_TYPE_CASTS],[

AC_MSG_NOTICE([

**************************************************************************
****    Does the compiler understand the casting syntax?              ****
**************************************************************************
])

AC_CXX_CONST_CAST
AC_CXX_STATIC_CAST
AC_CXX_REINTERPRET_CAST
AC_CXX_DYNAMIC_CAST
])




AC_DEFUN([AC_CXX_TYPE_PROMOTION],
  [AC_CACHE_CHECK(for the vector type promotion mechanism,
      ac_cv_cxx_type_promotion,
      [AC_REQUIRE([AC_CXX_TYPENAME])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([
#ifndef HAVE_TYPENAME
 #define typename
#endif
	    template <class T> struct vec3 { T data_[3]; };
	    template <class T1, class T2> struct promote_trait { typedef T1 T_promote; };
	    template <> struct promote_trait<int,double> { typedef double T_promote; };
	    template <class T1, class T2> vec3<typename promote_trait<T1,T2>::T_promote>
	    operator+(const vec3<T1>& a, const vec3<T2>& b) 
	    { vec3<typename promote_trait<T1,T2>::T_promote> c;
	      c.data_[0] = a.data_[0] + b.data_[0];
	      c.data_[1] = a.data_[1] + b.data_[1];
	      c.data_[2] = a.data_[2] + b.data_[2]; return c; }],[
	    vec3<int> a,b; vec3<double> c,d,e; b=a+a; d=c+c; e=b+d; return 0;],
	  ac_cv_cxx_type_promotion=yes, ac_cv_cxx_type_promotion=no)
	AC_LANG_RESTORE
      ])
    if test "$ac_cv_cxx_type_promotion" = yes; then
      AC_DEFINE(HAVE_TYPE_PROMOTION,1,
        [define if the compiler supports the vector type promotion mechanism])
    fi
  ])


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
dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_cxx_have_valarray.html
dnl

AC_DEFUN([AC_CXX_HAVE_VALARRAY],
  [AC_CACHE_CHECK(whether the compiler has valarray<T>,
      ac_cv_cxx_have_valarray,
      [AC_REQUIRE([AC_CXX_NAMESPACES])
	AC_LANG_SAVE
	AC_LANG_CPLUSPLUS
	AC_TRY_COMPILE([#include <valarray>
#ifdef HAVE_NAMESPACES
	    using namespace std;
#endif],[valarray<float> x(100); return 0;],
	    ac_cv_cxx_have_valarray=yes, ac_cv_cxx_have_valarray=no)
	  AC_LANG_RESTORE
	])
      if test "$ac_cv_cxx_have_valarray" = yes; then
	AC_DEFINE(HAVE_VALARRAY,1,[define if the compiler has valarray<T>])
      fi
    ])

#
# set following variables:    ZLIB_LIBS, with_zlib
# generate config file value: HAVE_ZLIB
# Conditional for Automake:   HAVE_ZLIB
#

AC_DEFUN([AC_LIB_ZLIB],[

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

    AM_CONDITIONAL(HAVE_ZLIB, test x$with_zlib = xyes)
])
