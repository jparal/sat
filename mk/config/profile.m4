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
