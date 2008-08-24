;
    pro rot3, ax, ay,az, bx,by,bz
    bx= az-shift(az,0,0,1,0) - ay + shift(ay,0,0,0,1)
    by= ax-shift(ax,0,0,0,1) - az + shift(az,0,1,0,0)
    bz= ay-shift(ay,0,1,0,0) - ax + shift(ax,0,0,1,0)
    bx=bx(*,1:*,*,*)
    by=by(*,1:*,*,*)
    bz=bz(*,1:*,*,*)   
    return
    end
