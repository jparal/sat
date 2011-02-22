function data = sh5_assemble(sensor, basename, tag, iter, split)

if ~iscell(tag)
    tag={tag};
end

for itag=1:length(tag)

    ctag = char(tag(itag));
    
    if length(split) == 2
        for j=0:split(2)-1
            for i=0:split(1)-1
                rank = j*split(1) + i;
                fname = sio_fname(sensor,basename,iter,rank);
                tmp = hdf5read(fname,ctag);
                ss = size(tmp);
                data(i*ss(1)+1:(i+1)*ss(1),j*ss(2)+1:(j+1)*ss(2)) = tmp;
            end
        end
    end

    if length(split) == 3
        for k=0:split(3)-1
            for j=0:split(2)-1
                for i=0:split(1)-1
                    rank = k*split(2) + j*split(1) + i;
                    fname = sio_fname(sensor,basename,iter,rank);
                    tmp = hdf5read(fname,ctag);
                    ss = size(tmp);

                    data(i*ss(1)+1:(i+1)*ss(1),j*ss(2)+1:(j+1)*ss(2),k*ss(3)+1:(k+1)*ss(3)) = tmp;
                end
            end
        end
    end

    fname = sio_fname(sensor,basename,iter);
    if itag == 1
        hdf5write(fname,ctag,data,'WriteMode','overwrite');
    else
        hdf5write(fname,ctag,data,'WriteMode','append');
    end
end
