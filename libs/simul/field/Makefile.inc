###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/field/bwcache.h \
	$(abs_srcdir)/field/cartgrid.h \
	$(abs_srcdir)/field/cartstencil.h \
	$(abs_srcdir)/field/field.h \
	$(abs_srcdir)/field/layout.h \
	$(abs_srcdir)/field/mesh.h

preproc += \
	$(abs_srcdir)/field/updateshare.cpp \
	$(abs_srcdir)/field/assignop.cpp \
	$(abs_srcdir)/field/bwcache.cpp \
	$(abs_srcdir)/field/cartstencil.cpp \
	$(abs_srcdir)/field/field.cpp \
	$(abs_srcdir)/field/idxop.cpp \
	$(abs_srcdir)/field/privutil.cpp \
	$(abs_srcdir)/field/syncfld.cpp

sources += \
	$(abs_srcdir)/field/field.cxx \
	$(abs_srcdir)/field/layout.cxx \
	$(abs_srcdir)/field/mesh.cxx

# extrsrc += 
