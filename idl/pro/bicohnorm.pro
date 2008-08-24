pro bicohnorm,amp,ra,seuil,ramp
ss=size(amp)
if(ss(0) eq 2) then begin
ix=ss(1)
iy=ss(2)
ramp=amp
for i=0,ix-1 do begin
  for j=0,iy-1 do begin
    if(ra(i,j) le seuil)then ramp(i,j)=0.
  endfor
endfor
endif
if(ss(0) eq 3) then begin
ix=ss(1)
iy=ss(2)
iw=ss(3)
iz=ss(4)
ramp=amp
for i=0,ix-1 do begin
  for j=0,iy-1 do begin
for k=0,iw-1 do begin
    if(ra(i,j,k) le seuil)then ramp(i,j,k)=0.
endfor
endfor
endfor
endif
if(ss(0) eq 4) then begin
ix=ss(1)
iy=ss(2)
iw=ss(3)
iz=ss(4)
ramp=amp
for i=0,ix-1 do begin
  for j=0,iy-1 do begin
for k=0,iw-1 do begin
  for l=0,iz-1 do begin

    if(ra(i,j,k,l) le seuil)then ramp(i,j,k,l)=0.
  endfor
endfor
endfor
endfor
endif

end
