pro rd1,file,a,complex=complex,double=double ,compress=compress,dim=dim
iunit=9
if(not(keyword_set(complex))) then complex=0
if(not(keyword_set(double))) then double=0
if(not(keyword_set(compress))) then begin 
 compress=0
 if STREGEX(file,'.gz',/boo) then compress=1  
endif
if(fexist(file,first=first))then begin
  openr,iunit,first ,compress=compress 
  if (n_elements(dim) le 0) then begin
  readf,iunit,n
  endif else begin
   n = dim
  endelse
endif else begin
   return
endelse
if (complex eq 0) then begin
  if(double eq 0) then begin
   a=fltarr(n)
  endif else begin
   a=dblarr(n)
  endelse
endif else begin
  if(double eq 0) then begin
    a=complexarr(n)
  endif else begin
    a=dcomplexarr(n)
  endelse
endelse
readf,iunit,a
close,iunit
return
end
