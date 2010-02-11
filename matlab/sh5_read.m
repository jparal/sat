% Read data from HDF5 file
%   data = sh5_read(sensor,basename,tag,iter)

function [data,attr] = sh5_read(sensor,basename,tag,iter)

fname = sio_fname(sensor,basename,iter);
[data,attr] = hdf5read(fname,tag,'ReadAttributes',true);
