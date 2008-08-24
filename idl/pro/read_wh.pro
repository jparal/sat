name='  '
read,'file = ',name
iunit=13
nm=1l
read,'max number of mesures nm = ',nm
kpe=fltarr(nm)
kpa=kpe
omi=kpe
omr=kpe
com=complexarr(nm)
phi=kpe
openr,iunit,name
for i=0l,nm-1l do begin
a5=complex(0.,0.)
readf,iunit,a1,a2,a3,a4,a5,a6
kpe(i)=a1
kpa(i)=a2
omr(i)=a3
omi(i)=a4
com(i)=a5
phi(i)=a6
endfor
close,iunit
if(omr(0) lt 0.)then begin
omr=-omr
kpe=-kpe
kpa=-kpa
phi=-phi
endif
end
