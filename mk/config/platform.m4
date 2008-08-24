
AC_DEFUN([AC_CHECK_PLATFORM],
  [
    AC_REQUIRE([AC_CANONICAL_HOST])

    case "$host" in
      *-*-linux-*)   ac_host_os="Linux";    ac_host_os_v="2";;
      *-*-cygwin*)   ac_host_os="Cygwin";   ac_host_os_v="1";;
      *-*-unicos*)   ac_host_os="UnicOS";   ac_host_os_v="1";; # Cray
      *-*-solaris*)  ac_host_os="Solaris";  ac_host_os_v="5";; # Sun
      *-*-osf3*)     ac_host_os="OSF1";     ac_host_os_v="3";;
      *-*-osf4*)     ac_host_os="OSF1";     ac_host_os_v="4";;
      *-*-osf5*)     ac_host_os="OSF1";     ac_host_os_v="5";;
      *-*-hpux10*)   ac_host_os="HPUX";     ac_host_os_v="10";;
      *-*-hpux11*)   ac_host_os="HPUX";     ac_host_os_v="11";;
      *-*-nextstep*) ac_host_os="NextStep"; ac_host_os_v="3";;
      *-*-openstep*) ac_host_os="NextStep"; ac_host_os_v="3";;
      *-*-irix*)     ac_host_os="Irix";     ac_host_os_v="6";; # SGI
      *-*-aix*)      ac_host_os="AIX";      ac_host_os_v="4";; # IBM
      *-*-darwin*)   ac_host_os="Darwin";   ac_host_os_v="1";;
      *-*-freebsd3*) ac_host_os="FreeBSD";  ac_host_os_v="3";;
      *-*-freebsd4*) ac_host_os="FreeBSD";  ac_host_os_v="4";;
      *-*-freebsd5*) ac_host_os="FreeBSD";  ac_host_os_v="5";;
      *-*-freebsd6*) ac_host_os="FreeBSD";  ac_host_os_v="6";;
      *-*-freebsd7*) ac_host_os="FreeBSD";  ac_host_os_v="7";;
      *-*-netbsd*)   ac_host_os="NetBSD";   ac_host_os_v="1";;
      *-*-openbsd*)  ac_host_os="OpenBSD";  ac_host_os_v="3";;
      *-*-sco*)      ac_host_os="OSR5";     ac_host_os_v="5";;
      *)             ac_host_os="Unknown";  ac_host_os_v="0";;
    esac

    ac_host_os_normalized="AS_TR_CPP([$ac_host_os])"

    AC_DEFINE_UNQUOTED(PLATFORM_OS_$ac_host_os_normalized,1,[OS Type])
    AC_DEFINE_UNQUOTED([PLATFORM_OS_NAME],
      ["$ac_host_os"],[String name of OS])
    AC_DEFINE_UNQUOTED([PLATFORM_OS_VERSION],[$ac_host_os_v],[Version of OS])

    case $ac_host_os in
      Darwin)  AC_DEFINE([PLATFORM_MACOSX],1,[Is the operating system MacOSX?]) ;;
      *)       AC_DEFINE([PLATFORM_UNIX],1,[Is the operating system UNIX?]) ;;
    esac
    AC_DEFINE_UNQUOTED([PLATFORM_NAME],
      ["UNIX"],[Sringified platfomr name])

# dnl ** Vendor

    case "$host" in
      *-cray-*)      ac_host_vendor="Cray";;
      *-ibm-*)       ac_host_vendor="IBM";;
      *-pc-*)        ac_host_vendor="PC";;
      *-sgi-*)       ac_host_vendor="SGI";;
      *-unknown-*)   ac_host_vendor="Unknown";;
      *)             ac_host_vendor="$host_vendor"
	AC_MSG_WARN([*****   Put info about vendor into platform.m4 file.  *****])
	;;

    esac

    ac_host_vendor_normalized="AS_TR_CPP([$ac_host_vendor])"

    AC_DEFINE_UNQUOTED(PLATFORM_VENDOR_$ac_host_vendor_normalized,1,[Platform vendor])
    AC_DEFINE_UNQUOTED([PLATFORM_VENDOR_NAME],
      ["$ac_host_vendor"],[Stringified platform vendor])

# dnl ** Processor

    case "$host" in
      x86_64-*)  ac_host_cpu="x86_64";;
      i?86-*)    ac_host_cpu="x86";;
      sparc-*)   ac_host_cpu="sparc";;
      alpha*)    ac_host_cpu="alpha";;
      m68k-*)    ac_host_cpu="m68k";;
      mips*)     ac_host_cpu="mips";;
      arm-*)     ac_host_cpu="arm";;
      s390-*)    ac_host_cpu="s390";;
      ia64-*)    ac_host_cpu="ia64";;
      hppa*)     ac_host_cpu="hppa";;
      powerpc*)  ac_host_cpu="ppc";;
      *)         ac_host_cpu="unknown";;
    esac

    ac_host_cpu_normalized="AS_TR_CPP([$ac_host_cpu])"

    AC_DEFINE_UNQUOTED(PLATFORM_PROCESSOR_[$ac_host_cpu_normalized],1,[Processor name])
    AC_DEFINE_UNQUOTED([PLATFORM_PROCESSOR_NAME],
      ["$ac_host_cpu"],[Strigified processor name])

    AC_SUBST(ac_host_cpu)
    AC_SUBST(ac_host_vendor)
    AC_SUBST(ac_host_os)
    AC_SUBST(ac_host_os_v)

  ])
