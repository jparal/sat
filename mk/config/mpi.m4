
AC_DEFUN([AC_ENABLE_MPI],[

    ac_mpi=no
    AC_MSG_CHECKING([whether to enable MPI])
    AC_ARG_ENABLE(mpi,
      AS_HELP_STRING([--enable-mpi], [enable Message Passing Interface (MPI) support]), [
	if test "$enableval" = yes; then
	  AC_MSG_RESULT([yes])
	  ac_mpi=yes
	  AC_FIND_MPI
	fi
	],
      [AC_MSG_RESULT([no])])
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
      AC_ARG_WITH(mpi-include, [AC_HELP_STRING([--with-mpi-include=DIR], [the DIR where mpi.h desides])],
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
                          containing the libraries specified by
                          e.g "/usr/lib /usr/local/mpi/lib"])],
                  for mpi_lib_dir in $withval; do
                     MPILIBDIRS="-L$mpi_lib_dir $MPILIBDIRS"
                  done; ac_user_chose_mpi=yes)

      dnl * --with-mpi-flags only adds to automatic selections, 
      dnl * does not override

      AC_ARG_WITH(mpi-flags,
[AC_HELP_STRING([--with-mpi-flags=FLAGS],[FLAGS is space-separated list of whatever flags other
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

	    AC_DEFINE_UNQUOTED(HAVE_MPI,1,
              [Whether we have <mpi.h> header file and we are willing to use it])
         fi
      fi

      AC_CACHE_VAL(ac_cv_mpi_include, ac_cv_mpi_include=$MPIINCLUDE)
      AC_CACHE_VAL(ac_cv_mpi_lib_dirs, ac_cv_mpi_lib_dirs=$MPILIBDIRS)
      AC_CACHE_VAL(ac_cv_mpi_libs, ac_cv_mpi_libs=$MPILIBS)
      AC_CACHE_VAL(ac_cv_mpi_flags, ac_cv_mpi_flags=$MPIFLAGS)

      AC_DEFINE_UNQUOTED(HAVE_MPI,1,
		        [Whether we have <mpi.h> header file and we are willing to use it])
   fi

      AC_ARG_WITH(mpiboot,
          [AC_HELP_STRING([--with-mpiboot=CMD],
                          [how to boot MPI (usualy mpiboot) environment])],
                  MPIBOOT=$withval)
      AC_ARG_WITH(mpirun,
          [AC_HELP_STRING([--with-mpirun=CMD],
                          [how to run MPI (default: mpirun -np @NP @PROG @ARGS) programs])],
                  MPIRUN=$withval)
      AC_ARG_WITH(mpihalt,
          [AC_HELP_STRING([--with-mpihalt=CMD],
                          [how to halt MPI environment])],
                  MPIHALT=$withval)


#    AC_SUBST(MPIINCLUDE)
#    AC_SUBST(MPILIBDIRS)
#    AC_SUBST(MPILIBS)
#    AC_SUBST(MPIFLAGS)
   AC_SUBST(MPIBOOT)
   AC_SUBST(MPIRUN)
   AC_SUBST(MPIHALT)

   CFLAGS_MPI="$MPIFLAGS $MPIINCLUDE"
   CXXFLAGS_MPI="$MPIFLAGS $MPIINCLUDE"
   LDFLAGS_MPI="$MPIFLAGS $MPILIBDIRS $MPILIBS"
   AC_SUBST(CFLAGS_MPI)
   AC_SUBST(CXXFLAGS_MPI)
   AC_SUBST(LDFLAGS_MPI)


#    CFLAGS="$MPIFLAGS $MPIINCLUDE $CFLAGS"
#    CXXFLAGS="$MPIFLAGS $MPIINCLUDE $CXXFLAGS"
#    LDFLAGS="$MPIFLAGS $MPILIBDIRS $MPILIBS $LDFLAGS"
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
