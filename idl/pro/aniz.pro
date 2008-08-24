;          animates ff along the third index
;          magnifies magnify-times (under widgets)  
   pro aniz, ff,magnify=magnify,file=file,res=res
if(not(keyword_set(magnify)))then magnify=1
if(not(keyword_set(file)))then file=' '
s1=size(magnify)
s=size(ff)
   n=s(3)
sx=s(1)
sy=s(2)
if(s1(0)eq 0) then begin
   sx=magnify*sx
   sy=magnify*sy
endif else begin
   sx=magnify(0)*sx
   sy=magnify(1)*sy
endelse
fmin=min(ff)
fmax=max(ff)
if(file eq ' ')then begin
XINTERANIMATE, SET = [sx, sy, n]
 for i=0,n-1 do begin
   XINTERANIMATE,IMAGE=rebin(255*(reform(ff(*,*,i))-fmin)/(fmax-fmin),sx,sy),$
   frame=i
 endfor
XINTERANIMATE,/KEEP_PIXMAPS
;XINTERANIMATE,/close
endif else begin
toz
if(keyword_set(res))then device,SET_RESOLUTION=res
for i=0,n-1 do begin
 imb,255*(reform(ff(*,*,i))-fmin)/(fmax-fmin)
 write_gif,file,tvrd(),/multiple
 endfor
write_gif,file,/close
endelse
return
end
