function dat = sh5_rdsq (sensor, basename, tag, start, step, stop)

% function varargout = SH5_RDSQ( sensor, basename, tag, start, step, stop )
%   Read sequentially data from SAT output files.
%
%   Example:
%     by = sh5_rdsq('bump/B','test','B1', 0, 10, 1000);

% dat = sh5_read(sensor,basename,tag,start);
% nd = size(dat);
% nt = ((stop-start)/step)+1;
% dat = zeros([nt nd]);

it=1;
for iter=start:step:stop
    tmp = sh5_read(sensor,basename,tag,iter);
    if iter == start
        ss = size(tmp);
        dat = zeros([1 ss]);
    end
    dat(it,:) = tmp(:);
    it=it+1;
end
