% Generate file name from its components.
%   fname = sio_fname(sensor, basename, iter)
%
%   sensor .... string example: B, E, Pci, ...
%   basename .. base name of simulation
%   iter ...... integer
%
%   generates the file name as [SENSOR][BASENAME]i[ITER].h5
%   the example:
%     fname = sio_fname('B','test',10);

function fname = sio_fname(sensor, basename, iter, rank)

if (nargin == 3)
    fname = sprintf('%s%si%d.h5',sensor,basename,iter);
end

if (nargin == 4)
    fname = sprintf('%s%si%d_%d.h5',sensor,basename,iter,rank);
end
