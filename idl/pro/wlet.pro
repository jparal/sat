function fww, x
z=exp(-x^2)*sin(x)
return,z
end   
;
pro wlet, a, b, alfa, n
s=size(a)
if (s(0) ne 1) then return
s1=s(1)
b=fltarr(s1,n)
au=findgen(s1)
aug=fltarr(s1)
kk=2.*!pi/n*alfa
for i=0,s1-1 do begin
if (i le (n*alfa-1)) then aug(i)=.5*(1.-cos(kk*i))
if (i ge (n*alfa)) then aug(i)=1.
if (i ge (s1-n*alfa)) then aug(i)=.5*(1.-cos(kk*(s1-i-1)))
endfor
for i=0,s1-1 do begin
for j=0,n-1 do begin
jn=alfa/float(j+1)
in=float(i)
;b(i,j) =aug(i)* total(fww((au-in)*jn)*a)*jn^2
b(i,j) = total(fww((au-in)*jn)*a)
endfor
endfor
return
end
