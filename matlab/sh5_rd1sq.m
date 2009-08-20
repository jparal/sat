function dat = sh5_rd1sq(sensor,basename,tag,start,step,stop)

dat = sh5_read(sensor,basename,tag,start);
nd = length(dat);
nt = ((stop-start)/step)+1;
dat = zeros(nt,nd);

it=0;
for iter=start:step:stop
    it=it+1;
    % Mag. Field:
    dat(it,:) = sh5_read('B',basename,tag,iter);
end
