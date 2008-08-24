; c(i)=correlate(a(i1:i2),shift(b,i))
; a is extended of a constant begining and end
pro cor3, a,i1,i2,b,c,ii

s=size(a)
if (s(0) eq 1) then begin
s1=s(1)
c=fltarr(2*s1,/nozero)
aa=fltarr(3*s1,/nozero)
bb=fltarr(3*s1,/nozero)
ii=bb
aa(0:s1-1+i1)=a(i1)
aa(s1+i1:s1+i2)=a(i1:i2)
aa(s1+i2+1:3*s1-1)=a(i2)
for i=0, 2*s1-1 do begin
c(i)=correlate(aa(i:i+s1-1),b)
ii(i)=i-s1
endfor
endif
return
end
