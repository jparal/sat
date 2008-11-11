
function data = sh5_read(sensor,basename,iter,tag)

fname = sio_fname(sensor,basename,iter);
data = hdf5read(fname,tag);
