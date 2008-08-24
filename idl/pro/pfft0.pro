function pfft0, a, n,transpose=transpose
if not(keyword_set(transpose)) then transpose=0
if (transpose eq 1) then a=transpose(a)
s=size(a)
dfof,a,amean
au=0
if (s(0) eq 2) then begin
au=fltarr(s(1),s(2),/nozero)
for i=0,s(1)-1 do begin
aug=fft(reform(a(i,*))-amean(i), n)
au(i,*)=alog(abs(aug))
endfor
endif
if (transpose eq 1) then a=transpose(a)
if (transpose eq 1) then au=transpose(au)
return, au
end
