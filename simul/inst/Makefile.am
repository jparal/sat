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

exename = inst1d inst2d
srcfile1d = inst1d.cxx
srcfile2d = inst2d.cxx
hdrfile = init.cpp inst.h
cfgfile = *.sin
instdir = $(prefix)/simul/inst

EXTRA_PROGRAMS = $(exename)
inst1d_SOURCES = $(srcfile1d)
inst2d_SOURCES = $(srcfile2d)
dist_noinst_DATA = $(srcfile1d) $(srcfile2d) $(hdrfile) $(cfgfile)
# nobase_inst_DATA = $(cfgfile)

SUBDIRS = linear
