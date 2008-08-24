pro pldev, a,c
s=size(a)
s1=s(1)
c=fltarr(s1)
if (s(0)  eq 2)then begin
for i=0,s1-1 do begin
ai=total(reform(a(i,*)))/s(2)
c(i)=sqrt(total(reform(a(i,*))-ai)^2)/s(2)
endfor
endif
if (s(0)  eq 3)then begin
for i=0,s1-1 do begin
ai=total(reform(a(i,*,*)))/s(2)/s(3)
c(i)=sqrt(total(reform(a(i,*,*))-ai)^2)/s(2)/s(3)
endfor
endif
return
end
