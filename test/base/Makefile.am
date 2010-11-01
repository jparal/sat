###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

include $(top_srcdir)/mk/amake/Makefile.first
include $(top_srcdir)/mk/amake/Makefile.test

EXTRA_DIST = cfgfile.sin

check_PROGRAMS = test-cfgfile test-debug test-time

test_cfgfile_SOURCES = cfgfile.cxx
test_debug_SOURCES = debug.cxx
test_time_SOURCES = time.cxx

TESTS = $(check_PROGRAMS)
