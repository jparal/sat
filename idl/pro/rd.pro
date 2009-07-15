pro rd,file,a,err=err,complex=complex,double=double ,compress=compress,dim=dim
iunit=9
if(not(keyword_set(complex))) then complex=0
if(not(keyword_set(double))) then double=0
if(not(keyword_set(compress))) then begin 
 compress=0
 if STREGEX(file,'.gz',/boo) then compress=1  
endif
err=0
filename=file
if( (compress eq 1) and  not(STREGEX(file,'.gz',/boo)) )then begin
 filename=strcompress(file+'.gz',/rem)
endif
if(fexist(filename,first=first,/now))then begin
  openr,iunit,first ,compress=compress 
  if (n_elements(dim) le 0) then begin
    dimstr='                                                               '
    readf,iunit,dimstr
    dim = long(strsplit(dimstr,/ext))
  endif 
endif else begin
  filename=strcompress(file+'.gz',/rem)
  if(fexist(filename,first=first,/now))then begin
    openr,iunit,first ,compress=1
    if (n_elements(dim) le 0) then begin
      dimstr='                                                             '
      readf,iunit,dimstr
      dim = long(strsplit(dimstr,/ext))
    endif 
  endif else begin
    print,'Error, not found ', file, ' or ', filename
    err=1
    return
  endelse
endelse
if (complex eq 0) then begin
  if(double eq 0) then begin
   a=fltarr(dim)
  endif else begin
   a=dblarr(dim)
  endelse
endif else begin
  if(double eq 0) then begin
    a=complexarr(dim)
  endif else begin
    a=dcomplexarr(dim)
  endelse
endelse
readf,iunit,a
close,iunit
return
end
