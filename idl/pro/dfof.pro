; for a (dim(a)=3) calculates am =mean(a) over 2 and 3 ind.
;  and da= max(a - am)
pro dfof, a, am, da
s=size(a)
if(s(0) eq 3)then begin
s1=s(1)
s2=s(2)
s3=s(3)
si=1./(s2*s3)
am=fltarr(s1)
da=am
for i=0,s1-1 do begin
am(i)=total(a(i,*,*))*si
da(i)=total((a(i,*,*)-am(i))^2)*si
endfor
endif
if(s(0) eq 2)then begin
s1=s(1)
s2=s(2)
si=1./(s2)
am=fltarr(s1)
da=am
for i=0,s1-1 do begin
am(i)=total(a(i,*))*si
da(i)=total((a(i,*)-am(i))^2)*si
endfor
endif
return
end
