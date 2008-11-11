
% create video
function aviobj = video(basename,start,step,stop,dt,sentag,splot,aviname)

ss = size(sentag);

fig=figure;
set(fig,'DoubleBuffer','on');
set(fig,'nextplot','replace','Visible','off');

aviobj = avifile(aviname);

for iter=start:step:stop

    time = sprintf('%.2f %s',dt*iter,'\Omega^{-1}');

    for ipic=0:ss(1)/2-1
        subplot(splot(1),splot(2),ipic+1);
        sensor = deblank(sentag(2*ipic+1,:));
        tag = deblank(sentag(2*ipic+2,:));
        data = sh5_read(sensor,basename,iter,tag);
        plot(data);
        mm = mean(data);
        if strcmp(sensor,'DbDt')
            ylim([-0.03 0.03]+mm);
        else
            ylim([-0.15 0.15]+mm);
        end
        ylabel(tag);
        xlabel('L_x [c/\omega_{p,sw}]');
        legend(time);
    end

    frame = getframe(fig);
    aviobj = addframe(aviobj,frame);
end

aviobj = close(aviobj);
