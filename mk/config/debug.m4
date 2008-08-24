
AC_DEFUN([AC_ENABLE_DEBUG],[

    AC_ARG_ENABLE([debug],
      AS_HELP_STRING([--enable-debug@<:@=LIST@:>@],
	[build with debugging information (default yes);
	  same as --enable-mode=debug. The LIST is an optional comma separated
	  list, where allowed values are:
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
