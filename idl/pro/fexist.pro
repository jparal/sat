function fexist,fnaux,first=first
gau=findfile(fnaux)
saux=size(gau)
if(saux(0) gt 0)then begin
   if(saux(1) gt 1) then print,'Warning: Multiple files '+fnaux
   first=gau(0)
   return, 1
endif else begin
   print, 'Error: File '+fnaux+' does not exist'
   return, 0
endelse
end
