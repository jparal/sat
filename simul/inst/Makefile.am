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

exename = inst
srcfile = inst.cxx
hdrfile = init.cpp inst.h
cfgfile = *.sin
instdir = $(prefix)/simul/inst

EXTRA_PROGRAMS = $(exename)
inst_SOURCES = $(srcfile)
dist_noinst_DATA = $(srcfile) $(hdrfile) $(cfgfile)
# nobase_inst_DATA = $(cfgfile)

SUBDIRS = linear
