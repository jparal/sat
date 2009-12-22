###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	mpi/cartdec.h \
	mpi/mpihdr.h \
	mpi/streammpi.h \
	mpi/wrap.h

lochdrs += \
	mpi/mpitype.h

preproc += \
	mpi/streammpi.cpp \
	mpi/wrap.cpp

sources += \
	mpi/cartdec.cxx \
	mpi/streammpi.cxx \
	mpi/wrap.cxx
