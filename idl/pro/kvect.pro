pro kvect, a ,b
aa=abs(pfft(a,1))^2
s=size(a)
ns=s(2)/2
i=findgen(ns)^2
b=fltarr(s(1),/nozero)
for j=0,s(1)-1 do begin
b(j)=total(aa(j,0:ns-1)*i)/total(aa(j,0:ns-1))
endfor
return
end
