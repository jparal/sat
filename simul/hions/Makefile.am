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

headers = emitter.h hions.h pclehi.h speciehi.h sws_emit.h utils.h
preproc = utils.cpp tmplspec.cpp
sources = applybc.cxx calcout.cxx emitter.cxx exec.cxx hions.cxx init.cxx \
ionize.cxx iter.cxx load.cxx misc.cxx move.cxx sws_emit.cxx
extrsrc = hions.sin

exename = hions
instdir = $(prefix)/simul/hions

noinst_PROGRAMS = $(exename)
hions_SOURCES = $(headers) $(sources)
EXTRA_DIST = $(extrsrc) $(preproc)
dist_noinst_DATA = $(srcfile)
