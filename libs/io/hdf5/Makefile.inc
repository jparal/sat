###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/hdf5/filehdf5.h \
	$(abs_srcdir)/hdf5/hdf5types.h

# preproc +=

sources += \
	$(abs_srcdir)/hdf5/filehdf5.cxx \
	$(abs_srcdir)/hdf5/filehdf5_rd_fldv.cxx \
	$(abs_srcdir)/hdf5/filehdf5_rd_flds.cxx \
	$(abs_srcdir)/hdf5/filehdf5_wr_arrs.cxx \
	$(abs_srcdir)/hdf5/filehdf5_wr_fldv.cxx \
	$(abs_srcdir)/hdf5/filehdf5_wr_flds.cxx

extrsrc += \
	$(abs_srcdir)/hdf5/fakehdf5.cpp \
	$(abs_srcdir)/hdf5/readhdf5.cpp \
	$(abs_srcdir)/hdf5/writehdf5.cpp
