 pro image_vect, a, vx,vy,nskip=nskip,ix,iy, length=length,color=color,_EXTRA=extra
;
   if not(keyword_set(nskip))then nskip=3
   if not(keyword_set(length))then length=2
   if not(keyword_set(color))then color=500
si=size(ix)
s=size(a)
s1=s(1)/nskip
s2=s(2)/nskip
if(si(0) ne 1) then begin
  ix=findgen(s(1))
  iy=findgen(s(2))
endif
vxn=fltarr(s1,s2,/nozero)
vyn=vxn
x=fltarr(s1,/nozero)
y=fltarr(s2,/nozero)
for i=0,s1-1 do begin
for j=0,s2-1 do begin
in=i*nskip
jn=j*nskip
vxn(i,j)=vx(in,jn)
x(i)=ix(in)
vyn(i,j)=vy(in,jn)
y(j)=iy(jn)
endfor
endfor
contour, a,ix,iy,/fill,_EXTRA=extra
ovector,vxn(1:*,1:*),vyn(1:*,1:*),x(1:*),y(1:*),length=length,color=color,_EXTRA=extra
   end

