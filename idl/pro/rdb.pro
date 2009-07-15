pro rdb,file,a,err=err,compress=compress
iunit=9
if(not(keyword_set(compress))) then begin 
 compress=0
 if STREGEX(file,'.gz',/boo) then compress=1  
endif
err=0
filename=file
if( (compress eq 1) and  not(STREGEX(file,'.gz',/boo)) )then begin
 filename=strcompress(file+'.gz',/rem)
endif
if(file_test(filename))then begin
openr,iunit,filename ,compress=compress 
ver=1.0
dtype=1L
type=1L
cat=1L
rank=1L
nx=1L
ny=1L
nz=1L
isize=1L
msize=1L

readu,iunit,ver
readu,iunit,dtype
readu,iunit,type
readu,iunit,cat
readu,iunit,rank
dim=lonarr(rank)
readu,iunit,dim
a=fltarr(dim)
readu,iunit,isize,msize

endif else begin
  filename=strcompress(file+'.gz',/rem)
  if(file_test(filename))then begin
    openr,iunit,filename ,compress=1
ver=1.0
dtype=1L
type=1L
cat=1L
rank=1L
nx=1L
ny=1L
nz=1L
isize=1L
msize=1L

readu,iunit,ver
readu,iunit,dtype
readu,iunit,type
readu,iunit,cat
readu,iunit,rank
dim=lonarr(rank)
readu,iunit,dim
a=fltarr(dim)
readu,iunit,isize,msize
  endif else begin
    print,'Error, not found ', file, ' or ', filename
    err=1
    return
  endelse
endelse 
readu,iunit,a
close,iunit
return
end
