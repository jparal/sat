pro vect_cont, a, vx,vy,n=n,vxn,vyn, length=length, _EXTRA=extra
;
   if keyword_set(n)then begin
    endif else begin
         n=3
    endelse
   if keyword_set(length)then begin
    endif else begin
         length=2.
    endelse
s=size(a)
ix=findgen(s(1))
iy=findgen(s(2))
s1=s(1)/n
s2=s(2)/n
vxn=fltarr(s1,s2)
vyn=fltarr(s1,s2)
x=fltarr(s1)
y=fltarr(s2)
for i=1,s1-1 do begin
for j=1,s2-1 do begin
in=i*n
jn=j*n
x(i)=in
y(j)=jn
vxn(i,j)=vx(in,jn)
vyn(i,j)=vy(in,jn)
endfor
endfor
velovect, vxn,vyn,x,y,len=length,_EXTRA=extra
contour, a,ix,iy, nlevels=9,/overplot,colo=220
return
end
