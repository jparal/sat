###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = field misc pcle sensor

headers = satfield.h satmisc.h satpcle.h satsensor.h
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES           = libsatsimul.a
libsatsimul_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsatsimul_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsatsimul_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

simulincludedir = $(includedir)/simul
nobase_simulinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include field/Makefile.inc
include misc/Makefile.inc
include pcle/Makefile.inc
include sensor/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh simul $(headers)
