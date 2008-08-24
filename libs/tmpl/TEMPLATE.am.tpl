###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS =

headers =
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES          = libsat(>>>LIBRARY<<<).a
libsat(>>>LIBRARY<<<)_a_CXXFLAGS  = $(CXXFLAGS_OPT) -I$(top_srcdir)/libs
libsat(>>>LIBRARY<<<)_a_CFLAGS    = $(CFLAGS_OPT) -I$(top_srcdir)/libs
libsat(>>>LIBRARY<<<)_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

(>>>LIBRARY<<<)includedir = $(includedir)/(>>>LIBRARY<<<)
nobase_(>>>LIBRARY<<<)include_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include (>>>POINT<<<)/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh (>>>LIBRARY<<<) $(headers)
