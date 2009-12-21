
headers += \
	$(abs_srcdir)/cfgfile/grammar.h \
	$(abs_srcdir)/cfgfile/cfgcore.h \
	$(abs_srcdir)/cfgfile/cfgfile.h \
	$(abs_srcdir)/cfgfile/private.h \
	$(abs_srcdir)/cfgfile/scanner.h \
	$(abs_srcdir)/cfgfile/wincompat.h

preproc += \
	$(abs_srcdir)/cfgfile/cfgfile.cpp

sources += \
	$(abs_srcdir)/cfgfile/grammar.c \
	$(abs_srcdir)/cfgfile/cfgcore.c \
	$(abs_srcdir)/cfgfile/cfgfile.cxx \
	$(abs_srcdir)/cfgfile/scanner.c

extrsrc += \
	$(abs_srcdir)/cfgfile/fixgrammar.pl \
	$(abs_srcdir)/cfgfile/fixscanner.pl \
	$(abs_srcdir)/cfgfile/genfiles.sh \
	$(abs_srcdir)/cfgfile/grammar.y \
	$(abs_srcdir)/cfgfile/scanner.l
