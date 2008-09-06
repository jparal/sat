# -*- shell-script -*-
############################################################################
# Initialization, version number, and other random setup/init stuff
############################################################################

AC_INIT(
    [Simalate & Analyse Toolkit],
    [m4_normalize(esyscmd([mk/scripts/getversion.sh VERSION]))],
    [jparal@gmail.com],
    [sat])

PACKAGE_COPYRIGHT="\
\"Copyright (c) 2005-2008 by SAT team. All rights reserved.\""

AC_DEFINE_UNQUOTED(PACKAGE_COPYRIGHT, [$PACKAGE_COPYRIGHT],
  [Copyright of the package])

# Make configure depend on the VERSION file, since it's used in AC_INIT
AC_SUBST([CONFIGURE_DEPENDENCIES], ['$(top_srcdir)/VERSION'])
SAT_SAVE_VERSION([SAT], [$srcdir/VERSION])

AC_PREREQ(2.60)
AC_CONFIG_AUX_DIR(./mk/config)
AC_CONFIG_MACRO_DIR(./mk/config)
AC_CONFIG_HEADER([libs/satconfig.h])

# Get our platform support file.  This has to be done very, very early
# because it twiddles random bits of autoconf
AC_LOAD_PLATFORM

#
# Init automake
#   subdir-objects .. move object file into the subdirectories
AM_INIT_AUTOMAKE([foreign no-define 1.10])

AC_PROG_CXX([xlc++ xlC icpc icc pathCC cxx aCC c++ CC g++ pgCC KCC FCC])
AC_PROG_LN_S

# C++ compiler
AC_LANG(C++)

# Compiler Flags
AC_FLAGS_PRESET
AC_COMPILERS_ENABLE_64BITS
AC_CHECK_ATTRIBUTES
AC_CXX_CHECK_BUILTINS
AC_CHECK_CXX_FEATURES
AC_COMPILERS_ENABLE_OPENMP
AC_ENABLE_MODE

# Libraries
AC_ENABLE_MPI
AC_PATH_ZLIB
AC_PATH_GSL
AC_PATH_HDF5

AC_CHECK_SAT_HEADERS
AC_CHECK_SIZESOF

# Doxygen documentation
DX_HTML_FEATURE(ON)
DX_MAN_FEATURE(ON)
DX_INIT_DOXYGEN(SAT, $srcdir/docs/doxygen.cfg)

#------------------------------------------------------------------------------
# Generate output files.
#------------------------------------------------------------------------------
AC_CONFIG_FILES([bin/filetops], [chmod +x bin/filetops])
AC_CONFIG_FILES([bin/gzeps],    [chmod +x bin/gzeps])
AC_CONFIG_FILES([bin/pssubst],  [chmod +x bin/pssubst])

AC_CONFIG_FILES([
    Makefile
    analyse/Makefile
    analyse/shock/Makefile
    bench/Makefile
    bench/base/Makefile
    bench/tmpl/Makefile
    bench/tmpl/TEMPLATE.cxx.tpl
    bin/Makefile
    connect/Makefile
    contrib/Makefile
    contrib/emacs/Makefile
    docs/Makefile
    docs/html/Makefile
    docs/html/figs/Makefile
    docs/license/Makefile
    docs/logos/Makefile
    docs/tech/Makefile
    docs/tech/cam/Makefile
    docs/tech/cam/fig/Makefile
    docs/tech/cam/pic/Makefile
    etc/Makefile
    example/Makefile
    example/ref/Makefile
    example/tmpl/Makefile
    example/tmpl/TEMPLATE.cxx.tpl
    extern/Makefile
    idl/Makefile
    idl/start.pro
    idl/mpfit/Makefile
    idl/pro/Makefile
    idl/stw/Makefile
    idl/textoidl/Makefile
    idl/todo/Makefile
    idl/zamb/Makefile
    idl/zamb/InputValues/Makefile
    idl/zamb/Movies/Makefile
    idl/zamb/Obsolete/Makefile
    idl/zamb/Scripts/Makefile
    idl/zamb/analysis/Makefile
    idl/zamb/menus/Makefile
    idl/zamb/misc/Makefile
    idl/zamb/plot1d/Makefile
    idl/zamb/plot2d/Makefile
    idl/zamb/plot3d/Makefile
    idl/zamb/test/Makefile
    idl/sat/Makefile
    libs/Makefile
    libs/base/Makefile
    libs/base/cfgfile/Makefile
    libs/base/common/Makefile
    libs/base/sys/Makefile
    libs/code/Makefile
    libs/code/cam/Makefile
    libs/io/Makefile
    libs/io/misc/Makefile
    libs/io/stw/Makefile
    libs/io/xdmf/Makefile
    libs/math/Makefile
    libs/math/misc/Makefile
    libs/math/rand/Makefile
    libs/pint/Makefile
    libs/pint/mpi/Makefile
    libs/pint/omp/Makefile
    libs/simul/Makefile
    libs/simul/field/Makefile
    libs/simul/misc/Makefile
    libs/simul/pcle/Makefile
    libs/simul/sensor/Makefile
    libs/test/Makefile
    libs/test/tester/Makefile
    libs/tmpl/Makefile
    mk/Makefile
    mk/amake/Makefile
    mk/config/Makefile
    mk/integrate/Makefile
    mk/maintain/Makefile
    mk/platform/Makefile
    mk/scripts/Makefile
    mk/scripts/runtest.sh
    mk/scripts/runbench.sh
    simul/Makefile
    simul/alfven/Makefile
    simul/test/Makefile
    simul/tmpl/Makefile
    simul/tmpl/TEMPLATE.cxx.tpl
    test/Makefile
    test/base/Makefile
    test/io/Makefile
    test/math/Makefile
    test/pint/Makefile
    test/simul/Makefile
    test/tmpl/Makefile
    test/tmpl/TEMPLATE.cxx.tpl
    tmpl/Makefile
    tmpl/TEMPLATE.cpp.tpl
    tmpl/TEMPLATE.h.tpl
    tmpl/TEMPLATE.cxx.tpl
    tmpl/TEMPLATE.c.tpl
    tools/Makefile
    tools/info/Makefile
    tools/version/Makefile
  ])

AC_OUTPUT

AC_MSG_NOTICE([

Info:     SAT : v$SAT_VERSION
==================================================================
          CPU : $ac_host_cpu ($ac_bits BITS)
       Vendor : $ac_host_vendor
           OS : $ac_host_os ($ac_host_os_v)

          CXX : $CXX v$CXXVERSION ($CXXVENDOR)
     CXXFLAGS : $CXXFLAGS

Version to build:
==================================================================
   Build Mode : $ac_build_mode
  Extra Debug : $sat_debug (Level: $debug_level)

Parallel INTerface (PINT):
==================================================================
       OpenMP : $ac_openmp
          MPI : $ac_mpi
 CXXFLAGS_MPI : $CXXFLAGS_MPI
  LDFLAGS_MPI : $LDFLAGS_MPI

External libraies:
==================================================================
	 ZLIB : $with_zlib
         HDF5 : $with_hdf5 (parallel: $with_hdf5_parallel)
	  GSL : $with_gsl

])
