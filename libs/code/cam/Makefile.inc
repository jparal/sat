###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################

headers_cam = \
	$(abs_srcdir)/cam/cam.h

preproc_cam = \
	$(abs_srcdir)/cam/advmom.cpp \
	$(abs_srcdir)/cam/advfld.cpp \
	$(abs_srcdir)/cam/calcb.cpp \
	$(abs_srcdir)/cam/calce.cpp \
	$(abs_srcdir)/cam/calcmom.cpp \
	$(abs_srcdir)/cam/calcpe.cpp \
	$(abs_srcdir)/cam/efldbc.cpp \
	$(abs_srcdir)/cam/exec.cpp \
	$(abs_srcdir)/cam/first.cpp \
	$(abs_srcdir)/cam/hyb.cpp \
	$(abs_srcdir)/cam/init.cpp \
	$(abs_srcdir)/cam/last.cpp \
	$(abs_srcdir)/cam/mombc.cpp \
	$(abs_srcdir)/cam/mominit.cpp \
	$(abs_srcdir)/cam/momfirst.cpp \
	$(abs_srcdir)/cam/momlast.cpp \
	$(abs_srcdir)/cam/momnorm.cpp \
	$(abs_srcdir)/cam/move.cpp \
	$(abs_srcdir)/cam/movesp.cpp \
	$(abs_srcdir)/cam/pclebc.cpp \
	$(abs_srcdir)/cam/smooth.cpp

# sources +=

extrsrc += \
	$(abs_srcdir)/cam/DocCAM.dox

headers += $(headers_cam)
preproc += $(preproc_cam)

pdf-cam:
	a2ps -o cam.ps -A virtual $(headers_cam) $(preproc_cam)
	ps2pdf cam.ps && rm -f cam.ps
