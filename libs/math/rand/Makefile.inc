###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/rand/arms.h \
	$(abs_srcdir)/rand/cos.h \
	$(abs_srcdir)/rand/maxwell.h \
	$(abs_srcdir)/rand/psd.h \
	$(abs_srcdir)/rand/range.h \
	$(abs_srcdir)/rand/rndgen.h \
	$(abs_srcdir)/rand/sigmund.h \
	$(abs_srcdir)/rand/sphere.h \
	$(abs_srcdir)/rand/thompson.h

# preproc += \
# 	$(abs_srcdir)/rand/.cpp

sources += \
	$(abs_srcdir)/rand/arms.cxx \
	$(abs_srcdir)/rand/cos.cxx \
	$(abs_srcdir)/rand/maxwell.cxx \
	$(abs_srcdir)/rand/psd.cxx \
	$(abs_srcdir)/rand/range.cxx \
	$(abs_srcdir)/rand/rndgen.cxx \
	$(abs_srcdir)/rand/sigmund.cxx \
	$(abs_srcdir)/rand/sphere.cxx \
	$(abs_srcdir)/rand/thompson.cxx

# extrsrc += 
