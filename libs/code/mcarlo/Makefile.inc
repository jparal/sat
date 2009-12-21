###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers_mcarlo = \
	$(abs_srcdir)/mcarlo/mcarlo.h

# preproc_mcarlo = \
# 	$(abs_srcdir)/mcarlo/mcarlo.cpp

# sources +=

headers += $(headers_mcarlo)
preproc += $(preproc_mcarlo)

pdf-mcarlo:
	a2ps -o mcarlo.ps -A virtual $(headers_mcarlo) $(preproc_mcarlo)
	ps2pdf mcarlo.ps && rm -f mcarlo.ps
