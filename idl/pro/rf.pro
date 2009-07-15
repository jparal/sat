pro rf,file,a,err=err,compress=compress

iunit=9
close, iunit

if(not(keyword_set(compress))) then begin 
 compress=0
 if STREGEX(file,'.gz',/boo) then compress=1  
endif
err=0
filename=file
if( (compress eq 1) and  not(STREGEX(file,'.gz',/boo)) )then begin
 filename=strcompress(file+'.gz',/rem)
endif

if (file_test(filename))then begin
  openr,iunit,filename ,compress=compress 
endif else begin
  filename=strcompress(file+'.gz',/rem)
  if (file_test(filename))then begin
    openr,iunit,filename ,compress=1
  endif else begin
    print,'Error, not found ', file, ' or ', filename
    err=1
    return
  endelse
endelse

ver=1.0    ; Version of the binary file format
dtype=1L   ; Data type
dim=1L     ; Dimension of the space
readu, iunit, ver
readu, iunit, dtype
readu, iunit, dim

print, 'ver =',ver
print, 'dtype =',dtype
print, 'dim =',dim

siz1 = 1L
ds1 = double(1.0)
siz = lonarr (dim)
ds = dblarr (dim)

for id=0,dim-1 do begin
  readu, iunit, siz1
  readu, iunit, ds1
  siz(id)=siz1
  ds(id)=ds1
endfor

print, 'size =', siz
print, 'ds =', ds

btype=1L    ;
ecat=1L
erank=1L
readu, iunit, btype
readu, iunit, ecat
readu, iunit, erank

print, 'btype =', btype
print, 'ecat =', ecat
print, 'erank =', erank

if erank gt 0 then begin
  eshape = lonarr (erank)
  readu, iunit, eshape
endif

esize=1L
msize=1L
readu, iunit, esize
readu, iunit, msize

print, 'esize =', esize
print, 'msize =', msize

if (erank eq 0) then a = fltarr(siz)
if (erank eq 1) then a = fltarr([dim,siz])
if (erank eq 2) then a = fltarr([dim,dim,siz])
if (erank eq 3) then a = fltarr([dim,dim,dim,siz])
help,a

readu,iunit,a
close,iunit
return

end
