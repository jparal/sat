###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS = convert

if HAVE_GSL
SUBDIRS += disp1d disp3d shock
endif

if HAVE_NOVA
SUBDIRS += mercury
endif

dist_noinst_DATA = README
