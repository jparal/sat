 pro image_vect1, a, vx,vy,n=n,vxn,vyn, length=length,color=color
;
   if keyword_set(n)then begin
    endif else begin
         n=3
    endelse
   if keyword_set(length)then begin
    endif else begin
         length=2
    endelse
   if keyword_set(color)then begin
    endif else begin
         color=500
    endelse

s=size(a)
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
velovect, vxn,vyn,x,y
     px=!x.window * !d.x_size
     py=!y.window * !d.y_size
     sx=px(1)-px(0)+1
     sy=py(1)-py(0)+1
     sz= size(a)    
;
    erase
;
tvscl,a,px(0),py(0)
;        
velovect, vxn,vyn,x,y,/noerase,length=length,color=color,$
   position=[px(0),py(0),px(0)+sz(1)-1,$
   py(0)+sz(2)-1]

   end

