; create HDF5 file  
file = 'hions.h5'  
fid = H5F_CREATE(file)  
  
; create some data  
rd3,'Dnb25Kpi300000.gz',data
ss = size(data)
datatype_id =  H5T_IDL_CREATE(data)  
dataspace_id = H5S_CREATE_SIMPLE([ss(1),ss(2),ss(3)])  
dataset_id =   H5D_CREATE(fid,'Dn',datatype_id,dataspace_id) ;;, $  
;;                        chunk_dimensions=[20,20,20])
H5D_WRITE,dataset_id,data  
H5S_CLOSE,dataspace_id  
H5T_CLOSE,datatype_id  
H5D_CLOSE,dataset_id  

rd3,'EnDnb25Kpi300000.gz',data
ss = size(data)
datatype_id = H5T_IDL_CREATE(data)  
dataspace_id = $  
   H5S_CREATE_SIMPLE([ss(1),ss(2),ss(3)])  
dataset_id = H5D_CREATE(fid,'En',datatype_id,dataspace_id, $  
                        chunk_dimensions=[20,20,20])
H5D_WRITE,dataset_id,data  
H5S_CLOSE,dataspace_id  
H5T_CLOSE,datatype_id  
H5D_CLOSE,dataset_id  

rd2,'Mapb25Kpi300000.gz',data
ss = size(data)
datatype_id = H5T_IDL_CREATE(data)  
dataspace_id = $  
   H5S_CREATE_SIMPLE([ss(1),ss(2)])  
dataset_id = H5D_CREATE(fid,'Map',datatype_id,dataspace_id, $  
                        chunk_dimensions=[20,20])
H5D_WRITE,dataset_id,data  
H5S_CLOSE,dataspace_id  
H5T_CLOSE,datatype_id  
H5D_CLOSE,dataset_id  

rd2,'EnMapb25Kpi300000.gz',data
ss = size(data)
datatype_id = H5T_IDL_CREATE(data)  
dataspace_id = $  
   H5S_CREATE_SIMPLE([ss(1),ss(2)])  
dataset_id = H5D_CREATE(fid,'EnMap',datatype_id,dataspace_id, $  
                        chunk_dimensions=[20,20])
; H5D_EXTEND,dataset_id,size(data,/dimensions)  
H5D_WRITE,dataset_id,data  
H5S_CLOSE,dataspace_id  
H5T_CLOSE,datatype_id  
H5D_CLOSE,dataset_id  

H5F_CLOSE,fid

end
