;
    pro rh4, u, dn , ux, uy ,uz,p,px,py,pz,pxz, bx, by, bz, ff
    ff=(ux-u)*dn* uz - bx*bz +pxz
    return
    end
