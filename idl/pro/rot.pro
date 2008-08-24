;
    pro rot,dx,dy,dz, ax, ay,az, bx,by,bz
    dxi=1./dx
    dyi=1./dy
    dzi=1./dz
    bx= dyi*(az-shift(az,0,1,0)) +dzi*(- ay + shift(ay,0,0,1))
    by= dzi*(ax-shift(ax,0,0,1)) +dxi*(- az + shift(az,1,0,0))
    bz= dxi*(ay-shift(ay,1,0,0)) +dyi*(- ax + shift(ax,0,1,0))
    bx=bx(1:*,*,*)
    by=by(1:*,*,*)
    bz=bz(1:*,*,*)   
    return
    end
