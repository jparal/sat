###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = cam mcarlo misc

headers = satcam.h satmcarlo.h satmisc.h
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES          = libsatcode.a
libsatcode_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsatcode_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsatcode_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

codeincludedir = $(includedir)/code
nobase_codeinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include cam/Makefile.inc
include mcarlo/Makefile.inc
include misc/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh code $(headers)
