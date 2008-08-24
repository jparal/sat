 pro image_vec, vx,vy,n=n,vxn,vyn, length=length,color=color
;
   if keyword_set(n)then begin
    endif else begin
         n=5
    endelse
   if keyword_set(length)then begin
    endif else begin
         length=2
    endelse
   if keyword_set(color)then begin
    endif else begin
         color=500
    endelse

s=size(vx)
s1=s(1)/n
s2=s(2)/n

vxn=fltarr(s1,s2,/nozero)
vyn=vxn
x=fltarr(s1,/nozero)
y=fltarr(s2,/nozero)
for i=0,s1-1 do begin
for j=0,s2-1 do begin
in=i*n
jn=j*n
vxn(i,j)=vx(in,jn)
x(i)=in
vyn(i,j)=vy(in,jn)
y(j)=jn
endfor
endfor
      
velovect, vxn,vyn,x,y,length=length,color=color
;contour, a, nlevels=10,/overplot

   end

