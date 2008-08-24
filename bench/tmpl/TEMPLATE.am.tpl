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
include $(top_srcdir)/mk/amake/Makefile.first
include $(top_srcdir)/mk/amake/Makefile.bench
(>>>POINT<<<)# include $(top_srcdir)/mk/amake/Makefile.base
# include $(top_srcdir)/mk/amake/Makefile.pint
# include $(top_srcdir)/mk/amake/Makefile.mat
# include $(top_srcdir)/mk/amake/Makefile.simul

# EXTRA_DIST = (>>>BENCH_NAME<<<).mpi

check_PROGRAMS = bench-(>>>BENCH_NAME<<<)

bench_(>>>BENCH_NAME<<<)_SOURCES = (>>>BENCH_NAME<<<).cxx

TESTS = $(check_PROGRAMS)
