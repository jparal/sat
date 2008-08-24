###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = tester

headers = sattester.h
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES          = libsattest.a
libsattest_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsattest_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsattest_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

testincludedir = $(includedir)/test
nobase_testinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include tester/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh test $(headers)
