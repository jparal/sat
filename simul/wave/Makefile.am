###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################
#
# Note that LDADD is already specified in Makefile.first as well as
# optimization CXXFLAGS. By specifying prog_CXXFLAGS or prog_LDADD you override
# those settings
#
include $(top_srcdir)/mk/amake/Makefile.sat

exename = wave
srcfile = wave.cxx wave.h alfven.sin
instdir = $(prefix)/simul/wave

noinst_PROGRAMS = $(exename)
wave_SOURCES = $(srcfile)
dist_noinst_DATA = $(srcfile)
# nobase_inst_DATA = $(srcfile)
