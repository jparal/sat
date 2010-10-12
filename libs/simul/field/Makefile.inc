###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	field/bwcache.h \
	field/cartstencil.h \
	field/field.h \
	field/layout.h \
	field/mesh.h

preproc += \
	field/updateshare.cpp \
	field/assignop.cpp \
	field/bwcache.cpp \
	field/cartstencil.cpp \
	field/field.cpp \
	field/idxop.cpp \
	field/privutil.cpp \
	field/syncfld.cpp

sources += \
	field/field.cxx \
	field/layout.cxx \
	field/mesh.cxx

# extrsrc += 
