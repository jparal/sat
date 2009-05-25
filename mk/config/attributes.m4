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
