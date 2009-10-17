% Read 1D data from a sequence of files
%   dat = sh5_rd1sq(sensor,basename,tag,start,step,stop)

function dat = sh5_rd1sq(sensor,basename,tag,start,step,stop)

dat = sh5_read(sensor,basename,tag,start);
nd = size(dat);
nt = ((stop-start)/step)+1;
dat = zeros([nt nd]);

it=0;
for iter=start:step:stop
    it=it+1;
    % Mag. Field:
    tmp = sh5_read('B',basename,tag,iter);
    dat(it,:) = tmp(:);
end
