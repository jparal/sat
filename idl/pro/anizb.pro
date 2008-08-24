;          animates ff along the third index
;          magnifies mag-times (under widgets)  
   pro anizb, mag,ff
s1=size(mag)
s=size(ff)
   n=s(3)
if(s1(0)eq 0) then begin
   sx=mag*s(1)
   sy=mag*s(2)
endif else begin
   sx=mag(1)*s(1)
   sy=mag(2)*s(2)
endelse
fmin=min(ff)
fmax=max(ff)
XINTERANIMATE, SET = [sx, sy, n]
 for i=0,n-1 do begin
   XINTERANIMATE,IMAGE=rebin(reform(ff(*,*,i)),sx,sy),$
   frame=i
 endfor
XINTERANIMATE,/KEEP_PIXMAPS
;XINTERANIMATE,/close
return
end
