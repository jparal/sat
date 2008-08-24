; reads a number of particles and then
; reads x(n) y(n) z(n) vx(n) vy(n) vz(n)
;.r
file=''
iunit=42
read,'File name =',file
n_part=0l
openr,iunit,file
readf,iunit,n_part
x=fltarr(n_part,/nozero)
;y=fltarr(n_part,/nozero)
;z=fltarr(n_part,/nozero)
vx=fltarr(n_part,/nozero)
vy=fltarr(n_part,/nozero)
vz=fltarr(n_part,/nozero)
for i=0l,n_part-1l do begin
  readf,iunit,format='(6G11.5)',xa,ya,za,vxa,vya,vza
  x(i)=xa
;  y(i)=ya
;  z(i)=za
  vx(i)=vxa
  vy(i)=vya
  vz(i)=vza
endfor
close,iunit
end
