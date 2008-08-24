name='  '
read,'file = ',name
iunit=13
nm=1l
read,'max number of mesures nm = ',nm
kpi=fltarr(nm)
kpr=kpi
thi=kpi
thr=kpi
omi=kpi
omr=kpi
com=complexarr(nm)
phi=kpi
openr,iunit,name
for i=0l,nm-1l do begin
a7=complex(0.,0.)
readf,iunit,a1,a2,a3,a4,a5,a6,a7,a8
kpi(i)=a1
kpr(i)=a2
thi(i)=a3
thr(i)=a4
omr(i)=a5
omi(i)=a6
com(i)=a7
phi(i)=a8
endfor
close,iunit
if(omr(0) lt 0.)then begin
omr=-omr
kpr=-kpr
phi=-phi
endif
end
