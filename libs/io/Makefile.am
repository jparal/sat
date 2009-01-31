###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = hdf5 misc stw xdmf

headers = sathdf5.h satmisc.h satstw.h satxdmf.h
preproc =
sources =
extrsrc = DocIO.dox
lochdrs =

lib_LIBRARIES        = libsatio.a
libsatio_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsatio_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsatio_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

ioincludedir = $(includedir)/io
nobase_ioinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include hdf5/Makefile.inc
include misc/Makefile.inc
include stw/Makefile.inc
include xdmf/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh io $(headers)
