pro hdf5_addstw3, fid, fname, h5tag

  rd3, fname, data
  ss = size(data)
  datatype_id =  H5T_IDL_CREATE(data)  
  dataspace_id = H5S_CREATE_SIMPLE([ss(1),ss(2),ss(3)])  
  dataset_id =   H5D_CREATE(fid,h5tag,datatype_id,dataspace_id, $  
                            chunk_dimensions=[50,50,50], GZIP=6, /SHUFFLE)

  H5D_WRITE,dataset_id,data
  H5S_CLOSE,dataspace_id
  H5T_CLOSE,datatype_id
  H5D_CLOSE,dataset_id

  return
end

; create HDF5 file  
file = 'Eb25Kai2000.h5'  
fid = H5F_CREATE(file)  

hdf5_addstw3, fid, 'Exb25Kai2000.gz', 'E0'
hdf5_addstw3, fid, 'Eyb25Kai2000.gz', 'E1'
hdf5_addstw3, fid, 'Ezb25Kai2000.gz', 'E2'

H5F_CLOSE,fid

end
