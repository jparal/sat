iunit=7
file='     '
read,'filename = ',file
openr, iunit, file
readf,iunit, nsat, nmes
bx=fltarr(nsat,nmes,/nozero)
readf, iunit, bx
by=fltarr(nsat,nmes,/nozero)
readf, iunit, by
bz=fltarr(nsat,nmes,/nozero)
readf, iunit, bz
ex=fltarr(nsat,nmes,/nozero)
readf, iunit, ex
ey=fltarr(nsat,nmes,/nozero)
readf, iunit, ey
ez=fltarr(nsat,nmes,/nozero)
readf, iunit, ez
ux=fltarr(nsat,nmes,/nozero)
readf, iunit, ux
uy=fltarr(nsat,nmes,/nozero)
readf, iunit, uy
uz=fltarr(nsat,nmes,/nozero)
readf, iunit, uz
dn=fltarr(nsat,nmes,/nozero)
readf, iunit, dn
close,iunit
end
