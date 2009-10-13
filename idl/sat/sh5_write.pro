PRO sh5_write, name, attrib, data, COMPRESS=compress

   fid = H5F_CREATE(name) 
 
   ;; get data type and space, needed to create the dataset 
   datatype_id = H5T_IDL_CREATE(data) 
   dataspace_id = H5S_CREATE_SIMPLE(size(data,/DIMENSIONS)) 

   ss = size(data)
   cdim = INDGEN (ss(0))
   cdim = ss(1:ss(0))
   cdim = cdim/4

   ;; create dataset in the output file 
   IF (KEYWORD_SET(compress)) THEN BEGIN
      dataset_id = H5D_CREATE(fid, attrib, datatype_id, dataspace_id, $
                              CHUNK_DIMENSIONS=cdim, GZIP=6, /SHUFFLE) 
   ENDIF ELSE BEGIN
      dataset_id = H5D_CREATE(fid, attrib, datatype_id, dataspace_id)
   ENDELSE

   ;; write data to dataset 
   H5D_WRITE,dataset_id,data 
 
   ;; close all open identifiers 
   H5D_CLOSE,dataset_id   
   H5S_CLOSE,dataspace_id 
   H5T_CLOSE,datatype_id 
   H5F_CLOSE,fid 

END
