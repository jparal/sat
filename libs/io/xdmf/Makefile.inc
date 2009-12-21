###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/xdmf/filexdmf.h \
	$(abs_srcdir)/xdmf/hdf5types.h

preproc +=  \
	$(abs_srcdir)/xdmf/filexdmf.cpp

sources += \
	$(abs_srcdir)/xdmf/filexdmf.cxx

# extrsrc += 
