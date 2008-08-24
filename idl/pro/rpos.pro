;
    iunit=6
    openr,iunit,file
    x=fltarr(nn,/nozero)
    y=x
    z=x
    readf,iunit, x,y,z
    close,iunit
 end
