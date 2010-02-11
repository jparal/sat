
function aviobj = ani_anime(data,aviname)
% function aviobj = ani_anime(data,aviname)
%
% DATA is an array of structures containing following data variables:
%
% Example:
%
% by.data = sh5_rdsq('B','test','B1',0,1,1000);
% by.xaxis = (1:500) * 0.5;
% by.xlim = [1 20];
% by.xlabel = 'x [c/\Omega_p]';
%
% bz.data = sh5_rdsq('B','test','B2',0,1,1000);
%
% obj = ani_anime({by; bz},'bfld.avi');

% by.data = [1, 2, 3; 2, 3, 4];
% by.dx = 0.5;
% by.dt = 0.5;
% by.xlim = [1 20];
% by.xlabel = 'x [c/\Omega_p]';
% bz.data = [1, 2, 3; 2, 3, 4];
% 
% aviname = 'out.avi';
% data = {by; bz};

aviobj = avifile(aviname);

gcf_doublebuffer = get(gcf, 'DoubleBuffer');
set(gcf, 'DoubleBuffer', 'on');
gca_nextplot = get(gca, 'nextplot');
set(gca, 'nextplot', 'replace');
gcf_visible = get(gcf, 'Visible');
set(gcf, 'Visible', 'off');

ssd=size(data);
assert(length(ssd) == 2, 'Incorrect dimension of data argument');

ss = size(data{1,1}.data);
ndt = ss(1);

for it=1:ndt
for ip=1:ssd(1)
    for jp=1:ssd(2)
        subplot(ssd(1), ssd(2), (ip-1)*ssd(2)+jp);

        dd = data{ip,jp};
        ss = size(dd.data);
        assert(ss(1) == ndt, 'Number of frames should be same');
        ndx = ss(2);
        
        dx = 1.0;
        if isfield(dd, 'dx')
            dx = dd.dx;
        end
        xaxis = (1:ndx) * dx;
        
        plot(xaxis, dd.data(it,:));
        
        if isfield(dd, 'xlimit')
            xlimit(dd.xlimit);
        end
        if isfield(dd, 'ylimit')
            xlimit(dd.ylimit);
        end

        if isfield(dd, 'xlabel')
            xlabel(dd.xlabel);
        end
        if isfield(dd, 'ylabel')
            xlabel(dd.ylabel);
        end
        
        %frame = getframe(gcf);
        aviobj = addframe(aviobj,gcf);
    end
end
end

aviobj = close(aviobj);

set(gcf, 'DoubleBuffer', gcf_doublebuffer);
set(gca, 'nextplot', gca_nextplot);
set(gcf, 'Visible', gcf_visible);
