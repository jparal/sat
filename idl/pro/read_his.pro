iunit=8
file='  '
read,'filename = ',file
openr, iunit, file
readf,iunit, nx, it
dn=fltarr(nx,it,/nozero)
bx=fltarr(nx,it,/nozero)
by=fltarr(nx,it,/nozero)
bz=fltarr(nx,it,/nozero)
readf,iunit, dn,bx,by,bz
close,iunit
end
