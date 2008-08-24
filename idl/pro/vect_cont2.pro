pro vect_cont2, a, vx,vy,ix,iy,n=n,vxn,vyn, length=length ,$
xtitle=xtitle,ytitle=ytitle,$
title=title, _EXTRA=extra
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
s1=s(1)/n
s2=s(2)/n
vxn=fltarr(s1,s2)
vyn=fltarr(s1,s2)
x=fltarr(s1)
y=fltarr(s2)
for i=0,s1-1 do begin
for j=0,s2-1 do begin
in=i*n
jn=j*n
x(i)=ix(in)
y(j)=iy(jn)
vxn(i,j)=vx(in,jn)
vyn(i,j)=vy(in,jn)
endfor
endfor
        x0 = min(x)                     ;get scaling
        x1 = max(x)
        y0 = min(y)
        y1 = max(y)
        x_step=float(x1-x0)/float(s1)   ; Convert to float. Integer math
        y_step=float(y1-y0)/float(s2)   ; could result in divide by 0
 
        x_b0=x0-x_step
        x_b1=x1+x_step
        y_b0=y0-y_step
        y_b1=y1+y_step
  
contour, a,ix,iy, nlevels=22,/fill,/xst,/yst,xtitle=xtitle,ytitle=ytitle,$
title=title
velovect, vxn,vyn,x,y,len=length,/noerase,_EXTRA=extra
return
end
