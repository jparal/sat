function out = dat_regridsq(data)
% Assume that first index is the iteration index (ie. time)

out = squeeze(data);
ss = size(out);

assert(length(ss) == 3);

for i=1:ss(1)
    out(i,:,:) = dat_regrid(data(i,:,:));
end