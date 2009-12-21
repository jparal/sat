
headers += \
	$(abs_srcdir)/common/allocator.h \
	$(abs_srcdir)/common/array.h \
	$(abs_srcdir)/common/bitarray.h \
	$(abs_srcdir)/common/blkallocator.h \
 	$(abs_srcdir)/common/callstack-impl.h \
 	$(abs_srcdir)/common/callstack.h \
 	$(abs_srcdir)/common/csbacktrace.h \
	$(abs_srcdir)/common/customallocated.h \
	$(abs_srcdir)/common/comparator.h \
	$(abs_srcdir)/common/debug.h \
 	$(abs_srcdir)/common/demangle.h \
	$(abs_srcdir)/common/fifo.h \
	$(abs_srcdir)/common/fixallocator.h \
 	$(abs_srcdir)/common/hash.h \
	$(abs_srcdir)/common/list.h \
	$(abs_srcdir)/common/macros.h \
	$(abs_srcdir)/common/memdebug.h \
	$(abs_srcdir)/common/meta.h \
	$(abs_srcdir)/common/plog.h \
	$(abs_srcdir)/common/pbuff.h \
	$(abs_srcdir)/common/ref.h \
 	$(abs_srcdir)/common/refaccess.h \
	$(abs_srcdir)/common/refarr.h \
	$(abs_srcdir)/common/refcount.h \
	$(abs_srcdir)/common/string.h \
	$(abs_srcdir)/common/strutil.h \
	$(abs_srcdir)/common/tau.h \
	$(abs_srcdir)/common/timer.h \
	$(abs_srcdir)/common/typetraits.h \
	$(abs_srcdir)/common/utils.h \
	$(abs_srcdir)/common/value.h

lochdrs += \
	$(abs_srcdir)/common/alignedalloc.h \
 	$(abs_srcdir)/common/reftrack.h

preproc += \
	$(abs_srcdir)/common/list.cpp \
	$(abs_srcdir)/common/timer.cpp

sources += \
 	$(abs_srcdir)/common/callstack-impl.cxx \
 	$(abs_srcdir)/common/csbacktrace.cxx \
 	$(abs_srcdir)/common/hash.cxx \
	$(abs_srcdir)/common/memdebug.cxx \
	$(abs_srcdir)/common/meta.cxx \
	$(abs_srcdir)/common/pbuff.cxx \
	$(abs_srcdir)/common/plog.cxx \
 	$(abs_srcdir)/common/refaccess.cxx \
 	$(abs_srcdir)/common/reftrack.cxx \
	$(abs_srcdir)/common/string.cxx \
	$(abs_srcdir)/common/strutil.cxx \
	$(abs_srcdir)/common/timer.cxx \
	$(abs_srcdir)/common/value.cxx
