function data = sh5_assemble(sensor, basename, tag, iter, split)

for j=0:split(2)-1
    for i=0:split(1)-1
        rank = j*split(1) + i;
        fname = sio_fname(sensor,basename,iter,rank);
        tmp = hdf5read(fname,tag);
        ss = size(tmp);
        data(i*ss(1)+1:(i+1)*ss(1),j*ss(2)+1:(j+1)*ss(2)) = tmp;
    end
end
