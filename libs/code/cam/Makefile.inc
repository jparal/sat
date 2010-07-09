###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers_cam = \
	cam/cam.h

preproc_cam = \
	cam/advmom.cpp \
	cam/advfld.cpp \
	cam/calcb.cpp \
	cam/calce.cpp \
	cam/calcmom.cpp \
	cam/calcpe.cpp \
	cam/efldbc.cpp \
	cam/exec.cpp \
	cam/first.cpp \
	cam/hyb.cpp \
	cam/init.cpp \
	cam/last.cpp \
	cam/mombc.cpp \
	cam/mominit.cpp \
	cam/momfirst.cpp \
	cam/momlast.cpp \
	cam/momnorm.cpp \
	cam/move.cpp \
	cam/movesp.cpp \
	cam/pclebc.cpp \
	cam/pcleinj.cpp \
	cam/smooth.cpp

# sources +=

extrsrc += \
	cam/DocCAM.dox

headers += $(headers_cam)
preproc += $(preproc_cam)

pdf-cam:
	a2ps -o cam.ps -A virtual $(headers_cam) $(preproc_cam)
	ps2pdf cam.ps && rm -f cam.ps
