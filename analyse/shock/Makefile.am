# CXXFLAGS += -I$(top_srcdir)/libs/base $(CXXFLAGS_OPT)

shock_bin_CFLAGS = $(GSL_CFLAGS)
shock_bin_LDADD = $(GSL_LIBS)

dist_bin_SCRIPTS = shock
bin_PROGRAMS = shock-bin

shock_bin_SOURCES = common.c exp_lfy.c exp_tanh.c fit.h parse.c util.h common.h \
exp_lstat.c exp_top.c main.c parse.h exp_foot.c exp_npfx.c exp_yft.c exp_info.c \
export.h fit.c util.c

# sat_info_CXXFLAGS = -I$(top_srcdir)/libs/base
