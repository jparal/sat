% Read data from HDF5 file
%   data = sh5_read(sensor,basename,tag,iter)

function [data,attr] = sh5_read(sensor,basename,tag,iter,rank)

if (nargin == 4)
    fname = sio_fname(sensor,basename,iter);
end

if (nargin == 5)
    fname = sio_fname(sensor,basename,iter,rank);
end

[data,attr] = hdf5read(fname,tag,'ReadAttributes',true);
data=permute(data,length(size(data)):-1:1);
