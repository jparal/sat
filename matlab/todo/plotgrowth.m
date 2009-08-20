
% create video
function [db,bby,bbz] = plotgrowth(basename,start,step,stop,dt,dx)

bx = sh5_read('B',basename,'B1',start);
ss=size(bx);
nstep = 1+((stop-start)/step);
ndb = ss(1);
db = zeros(ndb/2,nstep);
bby = zeros(ndb,nstep);
bbz = zeros(ndb,nstep);

i=0;
for iter=start:step:stop
    i=i+1;
    % Mag. Field:
    by = sh5_read('B',basename,'B1',iter);
    bz = sh5_read('B',basename,'B2',iter);
    bby(:,i) = by;
    bbz(:,i) = bz;
    
    bb1 = abs(fft(by));
    bb2 = abs(fft(bz));
    bb = sqrt(bb1.*bb1 + bb2.*bb2);

    db(:,i) = bb(1:ndb/2);

end

imagesc(log(db+1))