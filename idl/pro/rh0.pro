;
    pro rh0, u, dn , ux, uy ,uz,p,px,py,pz,pxy,pxz,pxxx,$
    pxyz, sx, ff
    ff=(-u)*(.5*dn*((ux)^2+uy^2+uz^2)+p+.5*(px+py+pz))+ $
    (ux)*(.5*dn*((ux)^2-uy^2-uz^2)+p+.5*(px+py+pz))+ $
    (ux-u)*(px+p)    +sx+ $
    .5*(pxxx+pxyz)+uy* pxy + uz*pxz
    return
    end
