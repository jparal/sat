pro rd4,file,a,err=err,complex=complex,compress=compress,dim=dim,double=double
iunit=9
if (n_elements(complex) le 0)then complex=0
if(not(keyword_set(double)))then double=0
if(not(keyword_set(compress))) then begin
 compress=0
 if STREGEX(file,'.gz',/boo) then compress=1
endif
err=0
filename=file
if( (compress eq 1) and  not(STREGEX(file,'.gz',/boo)) )then begin
 filename=strcompress(file+'.gz',/rem)
endif

if(fexist(filename,first=first))then begin
  openr,iunit,first,compress=compress 
  if (n_elements(dim) le 0) then begin
    readf,iunit,n1,n2,n3,n4
  endif else begin
    n1 = dim(0)
    n2 = dim(1)
    n3 = dim(2)
    n4 = dim(3)
  endelse
endif else begin
  filename=strcompress(file+'.gz',/rem)
  if(fexist(filename,first=first,/now))then begin
    openr,iunit,first ,compress=1
    if (n_elements(dim) le 0) then begin
      readf,iunit,n1,n2,n3,n4
    endif else begin
      n1 = dim(0)
      n2 = dim(1)
      n3 = dim(2)
      n4 = dim(3)
    endelse
  endif else begin
    print,'Error, not found ', file, ' or ', filename
    err=1
    return
  endelse
endelse
if(double eq 0) then begin
if (complex eq 1)then begin
a=complexarr(n1,n2,n3,n4)
endif else begin
a=fltarr(n1,n2,n3,n4)
endelse
endif else begin
if (complex eq 1)then begin
a=dcomplexarr(n1,n2,n3,n4)
endif else begin
a=dblarr(n1,n2,n3,n4)
endelse
endelse
readf,iunit,a
close,iunit
return
end
