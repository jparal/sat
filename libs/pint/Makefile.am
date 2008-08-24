
SUBDIRS = mpi omp

headers = satmpi.h satomp.h
preproc =
sources = 
extrsrc =
lochdrs =

lib_LIBRARIES          = libsatpint.a
libsatpint_a_CXXFLAGS  = $(CXXFLAGS_MPI) $(CXXFLAGS) -I$(top_srcdir)/libs
libsatpint_a_CFLAGS    = $(CXXFLAGS_MPI) $(CFLAGS) -I$(top_srcdir)/libs
libsatpint_a_SOURCES   = $(headers) $(sources)

libs: $(lib_LIBRARIES)

pintincludedir = $(includedir)/pint
nobase_pintinclude_HEADERS = $(headers) $(preproc) $(lochdrs)

#noinst_HEADERS = $(lochdrs)
EXTRA_DIST = $(extrsrc)

include mpi/Makefile.inc
include omp/Makefile.inc

genheaders:
	@$(top_srcdir)/mk/scripts/genheaders.sh pint $(headers)
