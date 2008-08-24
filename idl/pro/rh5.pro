;
    pro rh5, u, dn , ux, uy ,uz,p,px,py,pz,pxy,pxz, bx, by, bz, ff
    ff=(-u)*(.5*dn*(ux^2+uy^2+uz^2)+p+.5*(px+py+pz)+.5*(bx^2+by^2+bz^2))+ $
    (ux)*(.5*dn*(ux^2-uy^2-uz^2)+p+.5*(px+py+pz)+.5*(bx^2+by^2+bz^2))+ $
    ux*(p+px+(bx^2+by^2+bz^2)*.5)-bx*(bx*ux+by*uy+bz*uz)    + $
    uy* pxy + uz*pxz
    return
    end
