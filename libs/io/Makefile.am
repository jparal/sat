###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = misc stw xdmf

headers = satmisc.h satstw.h satxdmf.h
preproc =
sources =
extrsrc =
lochdrs =

lib_LIBRARIES        = libsatio.a
libsatio_a_CXXFLAGS  = $(CXXFLAGS) -I$(top_srcdir)/libs
libsatio_a_CFLAGS    = $(CFLAGS) -I$(top_srcdir)/libs
libsatio_a_SOURCES   = $(headers) $(sources)

# if DEBUG
# lib_LIBRARIES             += libsatio-dbg.a
# libsatio_dbg_a_CXXFLAGS  = $(CXXFLAGS_DBG) -I$(top_srcdir)/libs
# libsatio_dbg_a_CFLAGS    = $(CFLAGS_DBG) -I$(top_srcdir)/libs
# libsatio_dbg_a_SOURCES   = $(headers) $(sources)
# # libsatio_dbg_a_LIBADD    = $(libs_dir)/simul/libsatsimul-dbg.a
# endif

# if PROFILE
# lib_LIBRARIES             += libsatio-prf.a
# libsatio_prf_a_CXXFLAGS  = $(CXXFLAGS_PRF) -I$(top_srcdir)/libs
# libsatio_prf_a_CFLAGS    = $(CFLAGS_PRF) -I$(top_srcdir)/libs
# libsatio_prf_a_SOURCES   = $(headers) $(sources)
# endif

libs: $(lib_LIBRARIES)

ioincludedir = $(includedir)/io
nobase_ioinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include misc/Makefile.inc
include stw/Makefile.inc
include xdmf/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh io $(headers)
