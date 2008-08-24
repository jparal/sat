
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
