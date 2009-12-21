###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/misc/fmanip.h \
	$(abs_srcdir)/misc/gzstream.h \
	$(abs_srcdir)/misc/iofile.h \
	$(abs_srcdir)/misc/iomanager.h

preproc += \
	$(abs_srcdir)/misc/iomanager.cpp

sources += \
	$(abs_srcdir)/misc/fmanip.cxx \
	$(abs_srcdir)/misc/gzstream.cxx \
	$(abs_srcdir)/misc/iofile.cxx \
	$(abs_srcdir)/misc/iomanager.cxx

# extrsrc += 
