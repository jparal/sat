###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	$(abs_srcdir)/sensor/cbxb.h \
	$(abs_srcdir)/sensor/dbdt.h \
	$(abs_srcdir)/sensor/distfnc.h \
	$(abs_srcdir)/sensor/fldsens.h \
	$(abs_srcdir)/sensor/jxb.h \
	$(abs_srcdir)/sensor/kenergy.h \
	$(abs_srcdir)/sensor/sensmng.h \
	$(abs_srcdir)/sensor/sensor.h

# preproc += 

sources += \
	$(abs_srcdir)/sensor/distfnc.cxx \
	$(abs_srcdir)/sensor/sensmng.cxx \
	$(abs_srcdir)/sensor/sensor.cxx

extrsrc += \
	$(abs_srcdir)/sensor/DocSensor.dox
