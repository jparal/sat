###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers += \
	sensor/cbxb.h \
	sensor/dbdt.h \
	sensor/distfnc.h \
	sensor/fldsens.h \
	sensor/jxb.h \
	sensor/kenergy.h \
	sensor/laplace.h \
	sensor/sensmng.h \
	sensor/sensor.h

# preproc += 

sources += \
	sensor/distfnc.cxx \
	sensor/sensmng.cxx \
	sensor/sensor.cxx

extrsrc += \
	sensor/DocSensor.dox
