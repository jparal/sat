;
    pro rh2, u, dn , ux, uy ,uz,p,px,py,pz, bx, by, bz, ff
    ff=(ux-u)*dn* ux + (p+px+.5*(bx^2+by^2+bz^2))- bx^2
    return
    end
