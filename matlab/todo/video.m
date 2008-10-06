
% create video

sensor = 'B';
tag = 'B1';
basename = 'testi';
dt = 0.02;
start = 0;
stop = 1400;
step = 10;

outsuff = 'va20Lx45dx10';

fig=figure;
set(fig,'DoubleBuffer','on');
set(fig,'nextplot','replace','Visible','off')

aviobj = avifile(sprintf('%s_%s_%s.avi',basename,tag,outsuff));

for iter=start:step:stop
    name = sprintf('%s%s%d.h5',sensor,basename,iter);
    time = sprintf('%.2f %s',dt*iter,'\Omega^{-1}');
    data = hdf5read(name,tag);
    h = plot(data);
    ylim([-0.1 0.1]);
    ylabel(tag);
    xlabel('L_x [c/\omega_{p,sw}]');
    legend(time);
    frame = getframe(fig);
    aviobj = addframe(aviobj,frame);
end

aviobj = close(aviobj);
