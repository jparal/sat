
% create video
function db = plotgrowth(basename,start,step,stop,dt,dx)

bx = sh5_read('B',basename,start,'B1');
ss=size(bx);
nstep = 1+((stop-start)/step);
ndb = ss(1);
db = zeros(ndb/2,nstep);

i=0;
for iter=start:step:stop
    i=i+1;
    % Mag. Field:
    by = sh5_read('B',basename,iter,'B1');
    bz = sh5_read('B',basename,iter,'B2');
    bb1 = abs(fft(by));
    bb2 = abs(fft(bz));
    bb = sqrt(bb1.*bb1 + bb2.*bb2);

    db(:,i) = log(bb(1:ndb/2)+1);

end

imagesc(db)