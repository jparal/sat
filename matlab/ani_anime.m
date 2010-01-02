
function aviobj = ani_anime(data,aviname)
    
    aviobj = avifile(aviname);

    gcf_doublebuffer = get(gcf, 'DoubleBuffer');
    set(gcf, 'DoubleBuffer', 'on');
    gca_nextplot = get(gca, 'nextplot');
    set(gca, 'nextplot', 'replace');
    gcf_visible = get(gcf, 'Visible');
    set(gcf, 'Visible', 'off');
    
    ss=size(data);
    ndt = ss(1);
    ndx = ss(2);
    yl = [min(data(:)), max(data(:))];
    
    for i=1:ndt
        plot(data(i,:))
        ylim(yl);
        
        %frame = getframe(gcf);
        aviobj = addframe(aviobj,gcf);
    end
    
    aviobj = close(aviobj);

    set(gcf, 'DoubleBuffer', gcf_doublebuffer);
    set(gca, 'nextplot', gca_nextplot);
    set(gcf, 'Visible', gcf_visible);
