###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = misc rand

headers = satmisc.h satrand.h
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES          = libsatmath.a
libsatmath_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsatmath_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsatmath_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

mathincludedir = $(includedir)/math
nobase_mathinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include misc/Makefile.inc
include rand/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh math $(headers)
