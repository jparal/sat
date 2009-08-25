###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	hdf5/filehdf5.h \
	hdf5/hdf5types.h

# preproc +=

sources += \
	hdf5/filehdf5_rd_fldv.cxx \
	hdf5/filehdf5_rd_flds.cxx \
	hdf5/filehdf5_wr_arrs.cxx \
	hdf5/filehdf5_wr_fldv.cxx \
	hdf5/filehdf5_wr_flds.cxx

extrsrc += \
	hdf5/fakehdf5.cpp \
	hdf5/readhdf5.cpp \
	hdf5/writehdf5.cpp
