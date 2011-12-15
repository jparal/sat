###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################
#
# Uncoment necessary libraries you want to use:
#
include $(top_srcdir)/mk/amake/Makefile.first
include $(top_srcdir)/mk/amake/Makefile.test
include $(top_srcdir)/mk/amake/Makefile.pint
include $(top_srcdir)/mk/amake/Makefile.base

EXTRA_DIST = wrap.mpi mpistream.mpi

check_PROGRAMS = test-cartdec test-mpistream test-wrap

test_wrap_SOURCES = wrap.cxx
test_cartdec_SOURCES = cartdec.cxx
test_mpistream_SOURCES = mpistream.cxx

TESTS = $(check_PROGRAMS)
