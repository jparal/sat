###############################################################################
##   Copyright (C) by Jan Paral and SAT team                                  #
##   See docs/license/sat file for copying and redistribution conditions.     #
###############################################################################
#
# Note that LDADD is already specified in Makefile.first as well as
# optimization CXXFLAGS. By specifying prog_CXXFLAGS or prog_LDADD you override
# those settings
#
# Uncoment libraries you want to use:
#
include $(top_srcdir)/mk/amake/Makefile.sat

EXTRA_DIST = sensor.sin simtime.sin specie.sin

check_PROGRAMS = test-field test-sensor test-simtime test-specie

test_field_SOURCES = field.cxx
test_sensor_SOURCES = sensor.cxx
test_simtime_SOURCES = simtime.cxx
test_specie_SOURCES = speciet.cxx

TESTS = $(check_PROGRAMS)
