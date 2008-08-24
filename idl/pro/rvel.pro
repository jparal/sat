;
    iunit=6
    openr,iunit,file
    vx=fltarr(nn,/nozero)
    vy=vx
    vz=vx
    readf,iunit, vx,vy,vz
    close,iunit
 end
