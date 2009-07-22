
if ZLIB
LDADD += $(ZLIB_LIBS)
endif

if HDF5
CXXFLAGS += $(HDF5_CPPFLAGS)
LDFLAGS += $(HDF5_LDFLAGS)
LDADD += $(HDF5_LIBS)

if H5PART
CXXFLAGS += $(H5PART_CPPFLAGS)
LDFLAGS += $(H5PART_LDFLAGS)
LDADD += $(H5PART_LIBS)
endif

endif

LDADD += $(libs_dir)/io/libsatio.a
