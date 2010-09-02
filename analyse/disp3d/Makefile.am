###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

include $(top_srcdir)/mk/amake/Makefile.sat
CFLAGS += $(GSL_CFLAGS)
LDADD += $(GSL_LIBS)

EXTRA_PROGRAMS = sat-disp3d

sat_disp3d_SOURCES = cfgdisp.h cfgdisp.cxx conduct.cxx main.cxx solver.h \
solver.cxx
dist_noinst_DATA = *.sin rdl.pro
