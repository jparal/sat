;  c(i)=correlate(a,shift(b,i)) if dim(a)=1
;  a, b are extended of a constant begining and end 
pro cor1, a,b,c,ii

s=size(a)
if (s(0) eq 1) then begin
s1=s(1)
c=fltarr(2*s1,/nozero)
aa=fltarr(3*s1,/nozero)
bb=fltarr(3*s1,/nozero)
ii=bb
aa(0:s1-1)=a(0)
aa(s1:2*s1-1)=a
aa(2*s1:3*s1-1)=a(s1-1)
bb(0:s1-1)=b(0)
bb(s1:2*s1-1)=b
bb(2*s1:3*s1-1)=b(s1-1)
for i=0, 2*s1-1 do begin
c(i)=correlate(aa,shift(bb,i-s1))
ii(i)=i-s1
endfor
endif
return
end
