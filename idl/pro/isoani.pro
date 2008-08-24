;          animates ff along the third index
;          magnifies mag-times (under widgets)  
pro isoani, ff,lev=lev,ax=ax,az=az,xsize=xsize,ysize=ysize,$
  file=file,var=var
if(not(keyword_set(lev)))then begin
  print,'lev not set'
  return
endif
if(not(keyword_set(file)))then file=' ' 
if(not(keyword_set(ax)))then ax=30
if(not(keyword_set(az)))then az=30  
if(not(keyword_set(var)))then var=0
level=lev
ss=size(ff)
n=ss(4)
if(file eq ' ')then begin
mmax=max(ff(*,*,*,0))
if(var ne 0)then level=lev*mmax
if(keyword_set(xsize) and keyword_set(ysize))then begin
iso,ff(*,*,*,0),lev=level,ax=ax,az=az,isos,xsize=xsize,ysize=ysize
endif else begin
iso,ff(*,*,*,0),lev=level,ax=ax,az=az,isos
endelse
sis=size(isos)
XINTERANIMATE, SET = [sis(1) ,sis(2), n]
iframe=0
XINTERANIMATE,IMAGE=isos,frame=iframe
 for i=1,n-1 do begin
  mmax=max(ff(*,*,*,i))
  if(var ne 0)then level=lev*mmax
  if(mmax gt level)then begin
   iframe=iframe+1
   if(keyword_set(xsize) and keyword_set(ysize))then begin
   iso,ff(*,*,*,i),lev=level,ax=ax,az=az,isos,xsize=xsize,ysize=ysize
   endif else begin
   iso,ff(*,*,*,i),lev=level,ax=ax,az=az,isos 
   endelse
   XINTERANIMATE,IMAGE=isos,frame=iframe
  endif
 endfor
XINTERANIMATE,/KEEP_PIXMAPS
;XINTERANIMATE,/close
endif else begin
!p.background=255
!p.color=0
 for i=0,n-1 do begin
  mmax=max(ff(*,*,*,i))
  if(var ne 0)then level=lev*mmax
  if(mmax gt level)then begin
   if(keyword_set(xsize) and keyword_set(ysize))then begin
   iso,ff(*,*,*,i),lev=level,ax=ax,az=az,isos,xsize=xsize,ysize=ysize
   endif else begin
   iso,ff(*,*,*,i),lev=level,ax=ax,az=az,isos
   endelse 
   write_gif,file,isos,/multiple
  endif
 endfor
write_gif,file,/close
endelse
return
end
