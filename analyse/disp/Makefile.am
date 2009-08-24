###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

include $(top_srcdir)/mk/amake/Makefile.sat
CFLAGS += $(GSL_CFLAGS)
LDADD += $(GSL_LIBS)

bin_PROGRAMS = sat-disp

sat_disp_SOURCES = cfgdisp.h cfgdisp.cxx main.cxx *.sin
