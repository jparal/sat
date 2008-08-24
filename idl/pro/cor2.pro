; c(i) =correlate(a,shift(b,i)
; a extended of a constant beginig and end
pro cor2, a,b,c,ii

s=size(a)
if (s(0) eq 1) then begin
s1=s(1)
c=fltarr(2*s1,/nozero)
aa=fltarr(3*s1,/nozero)
ii=aa
aa(0:s1-1)=a(0)
aa(s1:2*s1-1)=a
aa(2*s1:3*s1-1)=a(s1-1)
for i=0, 2*s1-1 do begin
c(i)=correlate(aa(i:i+s1-1),b)
ii(i)=i-s1
endfor
endif
return
end
