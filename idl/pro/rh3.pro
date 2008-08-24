;
    pro rh3, u, dn , ux, uy ,uz,p,px,py,pz,pxy, bx, by, bz, ff
    ff=(ux-u)*dn* uy - bx*by + pxy
    return
    end
