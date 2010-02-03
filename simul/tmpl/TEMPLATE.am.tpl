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

exename = (>>>PROG_NAME<<<)
srcfile = (>>>PROG_NAME<<<).cxx
hdrfile = (>>>PROG_NAME<<<).h
cfgfile = (>>>PROG_NAME<<<).sin
instdir = $(prefix)/simul/(>>>PROG_NAME<<<)

noinst_PROGRAMS = $(exename)
(>>>PROG_NAME<<<)_SOURCES = $(srcfile)
dist_noinst_DATA = $(srcfile) $(hdrfile) $(cfgfile)
# nobase_inst_DATA = $(cfgfile)
