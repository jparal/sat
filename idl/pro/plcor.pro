
pro plcor, a,b,c
s=size(a)
s1=s(1)
c=fltarr(s1)
if (s(0)  eq 2)then begin
for i=0,s1-1 do begin
c(i)=correlate(reform(a(i,*)),reform(b(i,*)))
endfor
endif
if (s(0)  eq 3)then begin
for i=0,s1-1 do begin
c(i)=correlate(reform(a(i,*,*)),reform(b(i,*,*)) )
endfor
endif
plot,c
return
end
