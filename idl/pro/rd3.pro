pro rd3,file,a,complex=complex,compress=compress,dim=dim,double=double
iunit=9
if (n_elements(complex) le 0)then complex=0
if(not(keyword_set(double)))then double=0
if(not(keyword_set(compress))) then begin
 compress=0
 if STREGEX(file,'.gz',/boo) then compress=1
endif

if(fexist(file,first=first))then begin
  openr,iunit,first,compress=compress 
  if (n_elements(dim) le 0) then begin
    readf,iunit,n1,n2,n3
  endif else begin
    n1 = dim(0)
    n2 = dim(1)
    n3 = dim(2)
  endelse
endif else begin
   return
endelse
if(double eq 0) then begin
if (complex eq 1)then begin
a=complexarr(n1,n2,n3)
endif else begin
a=fltarr(n1,n2,n3)
endelse
endif else begin
if (complex eq 1)then begin
a=dcomplexarr(n1,n2,n3)
endif else begin
a=dblarr(n1,n2,n3)
endelse
endelse
readf,iunit,a
close,iunit
return
end
