###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
        algebra/matrix3.h \
	algebra/quaternion.h \
	algebra/vector.h \
	algebra/transfrm.h

preproc += \
        algebra/matrix3.cpp \
	algebra/vector.cpp

sources += \
        algebra/matrix3.cxx \
	algebra/quaternion.cxx \
	algebra/transfrm.cxx

# extrsrc += 
