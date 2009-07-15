;
    pro rot,dx,dy,dz, bx, by,bz, rbx,rby,rbz
    dxi=.5/dx
    dyi=.5/dy
    dzi=.5/dz
    rbx= dyi*(shift(bz,0,-1,0)-shift(bz,0,1,0)) $
       +dzi*(-shift(by,0,0,-1) + shift(by,0,0,1))
    rby= dzi*(shift(bx,0,0,-1)-shift(bx,0,0,1)) $
       +dxi*(-shift(bz,-1,0,0) + shift(bz,1,0,0))
    rbz= dxi*(shift(by,-1,0,0)-shift(by,1,0,0)) $
       +dyi*(-shift(bx,0,-1,0) + shift(bx,0,1,0))
    bx=bx(*,*,*)
    by=by(*,*,*)
    bz=bz(*,*,*)   
    return
    end
