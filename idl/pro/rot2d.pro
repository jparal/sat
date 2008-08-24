;
    pro rot2d ,dx,dy, ax, ay,az, bx,by,bz
    dxi=1./dx
    dyi=1./dy
    bx= dyi*(az-shift(az,0,1))
    by= +dxi*(- az + shift(az,1,0))
    bz= dxi*(ay-shift(ay,1,0)) +dyi*(- ax + shift(ax,0,1))
    bx=bx(1:*,*)
    by=by(1:*,*)
    bz=bz(1:*,*)   
    return
    end
