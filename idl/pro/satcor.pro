pro satcor, a, c,e
s=size(a)
ns=s(1)
c=fltarr(ns,ns,/nozero)
e=c
for i=0,ns-2 do begin
  for j=i+1,ns-1 do begin
    cor, reform(a(i,*)), reform(a(j,*)),d
    smax,d,aa,aaa
    c(i,j)=aa
    e(i,j)=aaa
    c(j,i)=aa
    e(j,i)=aaa
  endfor
endfor
return
end
