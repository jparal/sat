;
pro twlet, a, b, alfa, n
s=size(a)
if (s(0) ne 2) then return
s1=s(1)
s2=s(2)
b=fltarr(s1,s2)
au=findgen(s1)
for i=0,s1-1 do begin
for j=0,s2-1 do begin
jn=alfa/float(n+1)
in=float(i)
b(i,j) = total(fw((au-in)*jn)*a(*,j))*jn^2
endfor
endfor
return
end

