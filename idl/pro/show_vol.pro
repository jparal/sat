;
    pro show_vol, a, value, low=low,ax=ax, az=az
     s=size(a)
     !x.s=[0.,1./s(1)]
     !y.s=[0.,1./s(2)]
     !z.s=[0.,1./s(3)]
     t3d,/reset
     scale3d 
     surfr, ax=ax,az=az
     shade_volume, a, value, v,p, low=low
     tv, polyshade(v,p,/t3d)
    return
    end  
