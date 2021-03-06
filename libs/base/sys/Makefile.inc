###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	sys/assert.h \
	sys/attributes.h \
	sys/cast.h \
	sys/clock.h \
	sys/extern.h \
	sys/format.h \
	sys/grindwrap.h \
	sys/inline.h \
	sys/fpe.h \
	sys/platform.h \
	sys/porttypes.h \
	sys/predict.h \
	sys/prefetch.h \
	sys/satver.h \
	sys/stdhdrs.h \
	sys/stdfuncs.h \
	sys/sysdefs.h

preproc += \
	sys/assert.cpp

sources += \
	sys/assert.cxx \
	sys/clock.cxx \
	sys/fpe.cxx
