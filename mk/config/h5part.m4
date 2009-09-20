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
