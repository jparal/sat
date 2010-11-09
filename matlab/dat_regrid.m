function out = dat_regrid(data)

out = squeeze(data);
ss = size(out);

assert(length(ss) == 2);

out(1:end-1,1:end-1) = 0.25 * ( out(1:end-1,1:end-1) + ...
    out(2:end,1:end-1) + out(1:end-1,2:end) + out(2:end,2:end) );
