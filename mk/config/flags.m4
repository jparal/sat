
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
	    CXXFLAGS="-std ansi -D__USE_STD_IOSTREAM -DBZ_ENABLE_XOPEN_SOURCE -ieee -model ansi -accept restrict_keyword -nousing_std"
	  else
	    CXXFLAGS="-std ansi -D__USE_STD_IOSTREAM -DBZ_ENABLE_XOPEN_SOURCE -D_OSF_SOURCE -ieee -model ansi -accept restrict_keyword -nousing_std"
	  fi
	  CXXFLAGS_OPT="-fast -inline speed -nocleanup"
	  CXXFLAGS_DBG="-g -msg_display_tag"
	  CXXFLAGS_PRF="-pg -g1"
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
	  CXXFLAGS_OPT="-O4"
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

    if test "$ac_cxx_flags_preset" = yes ; then
      AC_MSG_NOTICE([Setting compiler flags for $CXXVENDOR $CXX])
    else
      AC_MSG_NOTICE([No flags preset found for $CXX])
    fi
    AC_PROG_CC($CC_tmp)
  ])
