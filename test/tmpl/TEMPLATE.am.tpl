###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################
#
# Note that LDADD is already specified in Makefile.first as well as
# optimization CXXFLAGS. By specifying prog_CXXFLAGS or prog_LDADD you override
# those settings
#
# Uncoment libraries you want to use:
#
include $(top_srcdir)/mk/amake/Makefile.first
include $(top_srcdir)/mk/amake/Makefile.test
(>>>POINT<<<)# include $(top_srcdir)/mk/amake/Makefile.base
# include $(top_srcdir)/mk/amake/Makefile.code
# include $(top_srcdir)/mk/amake/Makefile.io
# include $(top_srcdir)/mk/amake/Makefile.math
# include $(top_srcdir)/mk/amake/Makefile.pint
# include $(top_srcdir)/mk/amake/Makefile.simul

# EXTRA_DIST =

check_PROGRAMS = test-(>>>PROG_NAME<<<)

test_(>>>PROG_NAME<<<)_SOURCES = (>>>PROG_NAME<<<).cxx

TESTS = $(check_PROGRAMS)
