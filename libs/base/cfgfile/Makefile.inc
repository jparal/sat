
headers += \
	cfgfile/grammar.h \
	cfgfile/cfgcore.h \
	cfgfile/cfgfile.h \
	cfgfile/private.h \
	cfgfile/scanner.h \
	cfgfile/wincompat.h

preproc += \
	cfgfile/cfgfile.cpp

sources += \
	cfgfile/grammar.c \
	cfgfile/cfgcore.c \
	cfgfile/cfgfile.cxx \
	cfgfile/scanner.c

extrsrc += \
	cfgfile/fixgrammar.pl \
	cfgfile/fixscanner.pl \
	cfgfile/genfiles.sh \
	cfgfile/grammar.y \
	cfgfile/scanner.l
