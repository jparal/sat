###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################
#
# Note that LDADD is already specified in Makefile.first as well as
# optimization CXXFLAGS. By specifying prog_CXXFLAGS or prog_LDADD you override
# those settings
#
# Uncoment libraries you want to use:
#
include $(top_srcdir)/mk/amake/Makefile.bench
# include $(top_srcdir)/mk/amake/Makefile.base
# include $(top_srcdir)/mk/amake/Makefile.pint
# include $(top_srcdir)/mk/amake/Makefile.math

# EXTRA_DIST = array.mpi

check_PROGRAMS = bench-array

bench_array_SOURCES = array.cxx

TESTS = $(check_PROGRAMS)
