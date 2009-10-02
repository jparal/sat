% Read particles from HDF5 file stored using H5Part library
%   [data] = sh5_rdpcles(fname,tag,itbeg,itstep,itend)

function [data] = sh5_rdpcles(fname,tag,itbeg,itstep,itend)

path = sprintf('/Step#%d/%s',itbeg,tag);

tmp = hdf5read(fname,path);
len = length(tmp);
nit = (itend-itbeg)/itstep;

data = zeros(nit,len);
data(1,:) = tmp;

for i=2:nit
    iter = itbeg + i*itstep;
    path = sprintf('/Step#%d/%s',iter,tag);
    data(i,:) = hdf5read(fname,path);
end