function trilinint,a,dx=dx,dy=dy,dz=dz,x,y,z
ss=size(a)
if(ss(0) ne 3)then begin
  print,'Not 3D array' 
  return,0
endif
if(not(keyword_set(dx)))then dx=1
if(not(keyword_set(dy)))then dy=1
if(not(keyword_set(dz)))then dz=1

i=fix(x/dx)
a2=x/dx-i
a1=1.-a2
j=fix(y/dy)
b2=y/dy-j
b1=1.-b2
k=fix(z/dz)
c2=z/dz-k
c1=1.-c2

if(i ge 0 and j ge 0 and k ge 0 and $
   i le ss(1)-2 and j le ss(2)-2 and k le ss(3)-2)then begin
aa=a(i,j,k)*a1*b1*c1+a(i+1,j,k)*a2*b1*c1+a(i,j+1,k)*a1*b2*c1+a(i+1,j+1,k)*a2*b2*c1 $
  +a(i,j,k+1)*a1*b1*c2+a(i+1,j,k+1)*a2*b1*c2+a(i,j+1,k+1)*a1*b2*c2+a(i+1,j+1,k+1)*a2*b2*c2 
endif else begin
  aa=0
endelse
return, aa
end
