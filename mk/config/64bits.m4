
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
	      CXXFLAGS64="-q64"
#			ARFLAGS64="-cruX64"
	      LDFLAGS64="-b64"
	      ;;
	    *KCC)
	      CXXFLAGS64="-q64"
	      ARFLAGS64="-q64"
	      LDFLAGS64="-b64"
	      ;;
	    *g++)
	      CXXFLAGS64="-maix64"
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
	      CXXFLAGS64="-64"
	      LDFLAGS64="-64"
	      ARFLAGS64="-64"
	      ;;
	    *CC*)
	      CXXFLAGS64="-64"
	      LDFLAGS64="-64"
	      ARFLAGS64="-64"
	      ;;
	    *g++)
	      CXXFLAGS64="-m64"
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
	      CXXFLAGS64="-tp x64"
	      LDFLAGS64="-tp x64"
	      ;;
	    *CC*)
	      CXXFLAGS64="-64"
	      LDFLAGS64="-64"
	      ARFLAGS64="-64"
	      ;;
	    *g++)
	      CXXFLAGS64="-m64"
#			LDFLAGS64="-Wl,-m64"
	      ;;
	  esac
	  ;;
      esac

      if test x"$CXXFLAGS64" = x; then
	AC_MSG_WARN([Unable to find appropriate 64bit flags for OS: $ac_host_os CXX: $CXX])
      else
	ac_bits=64
      fi

    fi # "$ac_64bit" = true

    AC_SUBST(ac_bits)

    if test -n "$CXXFLAGS64"; then
      CXXFLAGS="$CXXFLAGS64 $CXXFLAGS"
    fi
    if test -n "$LDFLAGS64"; then
      LDFLAGS="$LDFLAGS64 $LDFLAGS"
    fi
    if test -n "$ARFLAGS64"; then
      ARFLAGS="$ARFLAGS64 $ARFLAGS"
    fi
  ])
