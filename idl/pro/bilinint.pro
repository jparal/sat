function bilinint,a,dx=dx,dy=dy,x,y
ss=size(a)
if(ss(0) ne 2)then begin
  print,'Not 2D array' 
  return,0
endif
if(not(keyword_set(dx)))then dx=1
if(not(keyword_set(dy)))then dy=1
i=fix(x/dx)
a2=x/dx-i
a1=1.-a2
j=fix(y/dy)
b2=y/dy-j
b1=1.-b2
if(i ge 0 and j ge 0 and i le ss(1)-2 and j le ss(2)-2)then begin
  aa=a(i,j)*a1*b1+a(i+1,j)*a2*b1+a(i,j+1)*a1*b2+a(i+1,j+1)*a2*b2
endif else begin
  aa=0
endelse
return, aa
end
