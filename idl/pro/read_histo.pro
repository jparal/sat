iunit=8
file='  '
read,'filename = ',file
openr, iunit, file
readf,iunit, nx, it,nx1
dn=fltarr(nx,it,/nozero)
bz=fltarr(nx,it,/nozero)
by=fltarr(nx1,it,/nozero)
bx=fltarr(nx1,it,/nozero)
readf,iunit, dn
readf,iunit, bz
readf,iunit, bx
readf,iunit, by
close,iunit
end
