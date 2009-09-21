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
