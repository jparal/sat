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
	sensor/rectdfcell.h \
	sensor/rectdflist.h \
	sensor/sensmng.h \
	sensor/sensor.h \
	sensor/temp.h

preproc += \
	sensor/rectdfcell.cpp \
	sensor/rectdflist.cpp

sources += \
	sensor/distfnc.cxx \
	sensor/rectdfcell.cxx \
	sensor/rectdflist.cxx \
	sensor/sensmng.cxx \
	sensor/sensor.cxx

extrsrc += \
	sensor/DocSensor.dox
