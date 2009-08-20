%
%
function fname = sio_fname(sensor, basename, iter)

fname = sprintf('%s%si%d.h5',sensor,basename,iter);
