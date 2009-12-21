###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/algebra/quaternion.h \
	$(abs_srcdir)/algebra/vector.h

preproc += \
	$(abs_srcdir)/algebra/vector.cpp

sources += \
	$(abs_srcdir)/algebra/quaternion.cxx

# extrsrc += 
