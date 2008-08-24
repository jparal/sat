iunit=8
file='  '
read,'filename = ',file
openr, iunit, file
readf,iunit, nx, it
dn=fltarr(nx,it,/nozero)
bz=fltarr(nx,it,/nozero)
readf,iunit, dn
readf,iunit, bz
close,iunit
end
