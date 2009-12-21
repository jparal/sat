
headers += \
	$(abs_srcdir)/mpi/cartdec.h \
	$(abs_srcdir)/mpi/mpihdr.h \
	$(abs_srcdir)/mpi/streammpi.h \
	$(abs_srcdir)/mpi/wrap.h

lochdrs += \
	$(abs_srcdir)/mpi/mpitype.h

preproc += \
	$(abs_srcdir)/mpi/streammpi.cpp \
	$(abs_srcdir)/mpi/wrap.cpp

sources += \
	$(abs_srcdir)/mpi/cartdec.cxx \
	$(abs_srcdir)/mpi/streammpi.cxx \
	$(abs_srcdir)/mpi/wrap.cxx
