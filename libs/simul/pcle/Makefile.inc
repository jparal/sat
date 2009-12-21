###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/pcle/camspecie.h \
	$(abs_srcdir)/pcle/cmdpcle.h \
	$(abs_srcdir)/pcle/pcle.h \
	$(abs_srcdir)/pcle/specie.h

# preproc +=

sources += \
	$(abs_srcdir)/pcle/camspecie.cxx \
	$(abs_srcdir)/pcle/specie.cxx

extrsrc += \
	$(abs_srcdir)/pcle/DocSpecie.dox
