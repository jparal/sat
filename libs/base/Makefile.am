###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = cfgfile common sys

headers = satcfgfile.h satcommon.h satsys.h
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES          = libsatbase.a
libsatbase_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsatbase_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsatbase_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

baseincludedir = $(includedir)/base
nobase_baseinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include cfgfile/Makefile.inc
include common/Makefile.inc
include sys/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh base $(headers)
