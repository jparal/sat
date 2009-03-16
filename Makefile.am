###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

SUBDIRS= bin mk libs tools test example tmpl docs analyse bench contrib extern \
 idl matlab simul

ACLOCAL_AMFLAGS  = -I mk/config

distclean-local:
	-rm -rf autom4te.cache

check-%:
	$(MAKE) dist-gzip
	@$(top_srcdir)/mk/scripts/integrate.sh "`echo $@ | sed 's/check-//'`" $(top_srcdir)  $(distdir).tar.gz

checkall: check-goya check-nexus check-cortex

include $(top_srcdir)/mk/amake/doxygen.am
