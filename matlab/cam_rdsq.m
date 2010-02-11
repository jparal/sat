function varargout = cam_rdsq (sensor, basename, tags, start, step, stop)

% function varargout = CAM_RDSQ( sensor, basename, tags, start, step, stop )
%   Read sequentially data from SAT output file.
%
%   Example:
%     [by, bz] = cam_rdsq('bump/B','test',{'B1','B2'}, 0, 10, 1000);
%     by =
%       data:   [100, 100] % [time, xaxis]
%       resol:  [0.02, 0.1]
%       center: 'Node'   % Node or Cell
%       label:  {'time / \Omega^{-1}', 'x / c/\omega_p'}
%

if iscellstr(tags)
    assert(nargout == length(tags), ...
    'Number of output agrs must match number of tags.');
end
    
for itag=1:length(tags)
    tag = char(tags(itag));
    dat.data = sh5_rdsq(sensor, basename, tag, start, step, stop);
    varargout(itag) = {dat};
end
