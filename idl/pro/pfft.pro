function pfft, a, n,transpose=transpose,aa=aa
if not(keyword_set(aa)) then aa=0
if not(keyword_set(transpose)) then transpose=0
if (transpose eq 1) then a=transpose(a)
s=size(a)
au=0
if (s(0) eq 2) then begin
if (aa eq 0)then begin
au=complexarr(s(1),s(2),/nozero)
endif else begin
au=fltarr(s(1),s(2),/nozero)
endelse
for i=0,s(1)-1 do begin
aug=fft(reform(a(i,*)), n)
if (aa eq 0)then begin
au(i,*)=aug/sqrt(s(2)*1.)
endif else begin
au(i,*)=alog(abs(aug)/sqrt(s(2)*1.))
endelse
endfor
endif
if (transpose eq 1) then a=transpose(a)
if (transpose eq 1) then au=transpose(au)
return, au
end
