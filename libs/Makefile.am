
LIBDIRS = base code io math pint simul test
SUBDIRS = $(LIBDIRS) tmpl

include_HEADERS = newdisable.h newenable.h sat.h satbase.h satcode.h satio.h satmath.h satpint.h satsimul.h satsysdef.h sattest.h

CLEANFILES = satconfig.h

dist_noinst_DATA = README

genheaders:
	@for dir in $(LIBDIRS); do cd $${dir}; make genheaders; cd ..; done;
