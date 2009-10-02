
function data = sh5_read(sensor,basename,tag,iter)

fname = sio_fname(sensor,basename,iter);
data = hdf5read(fname,tag);
