pro rd2f,file,a,complex=complex
iunit=9
if (n_elements(complex) le 0)then complex=0
openr,iunit,file
readf,iunit,n1,n2
if (complex eq 1)then begin
a=complexarr(n1,n2)
endif else begin
a=fltarr(n1,n2)
endelse
readf,iunit,a,Form='(G)'
close,iunit
return
end
