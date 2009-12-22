###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	common/allocator.h \
	common/array.h \
	common/bitarray.h \
	common/blkallocator.h \
 	common/callstack-impl.h \
 	common/callstack.h \
 	common/csbacktrace.h \
	common/customallocated.h \
	common/comparator.h \
	common/debug.h \
 	common/demangle.h \
	common/fifo.h \
	common/fixallocator.h \
 	common/hash.h \
	common/list.h \
	common/macros.h \
	common/memdebug.h \
	common/meta.h \
	common/plog.h \
	common/pbuff.h \
	common/ref.h \
 	common/refaccess.h \
	common/refarr.h \
	common/refcount.h \
	common/string.h \
	common/strutil.h \
	common/tau.h \
	common/timer.h \
	common/typetraits.h \
	common/utils.h \
	common/value.h

lochdrs += \
	common/alignedalloc.h \
 	common/reftrack.h

preproc += \
	common/list.cpp \
	common/timer.cpp

sources += \
 	common/callstack-impl.cxx \
 	common/csbacktrace.cxx \
 	common/hash.cxx \
	common/memdebug.cxx \
	common/meta.cxx \
	common/pbuff.cxx \
	common/plog.cxx \
 	common/refaccess.cxx \
 	common/reftrack.cxx \
	common/string.cxx \
	common/strutil.cxx \
	common/timer.cxx \
	common/value.cxx
