
AC_DEFUN([AC_ENABLE_MODE],[

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
	CFLAGS="$CFLAGS $CFLAGS_OPT"
	;;
      debug)
        AC_DEFINE_UNQUOTED([SAT_MODE_DEBUG],1,[Compilation mode is debug])
	CXXFLAGS="$CXXFLAGS $CXXFLAGS_DBG"
	CFLAGS="$CFLAGS $CFLAGS_DBG"
	;;
      profile)
        AC_DEFINE_UNQUOTED([SAT_MODE_PROFILE],1,[Compilation mode is profile])
	CXXFLAGS="$CXXFLAGS $CXXFLAGS_PRF"
	CFLAGS="$CFLAGS $CFLAGS_PRF"
	;;
    esac

    AC_DEFINE_UNQUOTED([SAT_MODE], ["$ac_build_mode"],[Compilation mode])

    AM_CONDITIONAL([DEBUG],    [test $ac_build_mode = debug])
    AM_CONDITIONAL([PROFILE],  [test $ac_build_mode = profile])
    AM_CONDITIONAL([OPTIMIZE], [test $ac_build_mode = optimize])
  ])
