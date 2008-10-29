###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################
#
# Note that LDADD is already specified in Makefile.first as well as
# optimization CXXFLAGS. By specifying prog_CXXFLAGS or prog_LDADD you override
# those settings
#
include $(top_srcdir)/mk/amake/Makefile.sat

EXTRA_DIST = hdf5.sin
LDADD += $(HDF5_LIBS)

check_PROGRAMS = test-stw test-hdf5 test-filexdmf

test_stw_SOURCES = stw.cxx
test_hdf5_SOURCES = hdf5.cxx
test_filexdmf_SOURCES = filexdmf.cxx

TESTS = $(check_PROGRAMS)

CLEANFILES = *.gz *.h5 *.xmf
