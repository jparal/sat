###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	hdf5/filehdf5.h

# preproc +=

sources += \
	hdf5/filehdf5.cxx

extrsrc += \
	hdf5/fakehdf5.cpp \
	hdf5/readhdf5.cpp \
	hdf5/writehdf5.cpp
