PRO sh5_read, name, attrib, data

   ; Open the HDF5 file.
   file = H5F_OPEN(name)

   dataset = H5D_OPEN(file, attrib)

   data = H5D_READ(dataset)

   ; Close all our identifiers so we don't leak resources.
   H5D_CLOSE, dataset
   H5F_CLOSE, file

END
