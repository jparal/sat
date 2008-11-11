%
%
function fname = sio_fname(sensor, basename, iter)

fname = sprintf('%s%s%d.h5',sensor,basename,iter);
