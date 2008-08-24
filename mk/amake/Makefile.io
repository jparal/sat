
if ZLIB
LDADD += $(ZLIB_LIBS)
endif

if HDF5
CXXFLAGS += $(HDF5_CPPFLAGS)
LDFLAGS += $(HDF5_LDFLAGS)
LDADD += $(HDF5_LIBS)
endif

LDADD += $(libs_dir)/io/libsatio.a
