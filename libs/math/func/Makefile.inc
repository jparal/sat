###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/func/faddeeva.h \
	$(abs_srcdir)/func/plasmafnc.h \
 	$(abs_srcdir)/func/stdmath.h

preproc += \
	$(abs_srcdir)/func/stdmath.cpp

sources += \
	$(abs_srcdir)/func/faddeeva.cxx \
	$(abs_srcdir)/func/plasmafnc.cxx

# extrsrc += 
