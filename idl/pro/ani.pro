;          animates ff along the first index
;          magnifies mag-times (under widgets)  
   pro ani, mag,ff

s=size(ff)
   n=s(1)
   sx=mag*s(2)
   sy=mag*s(3)
XINTERANIMATE, SET = [sx, sy, n]
 for i=0,n-1 do begin

 XINTERANIMATE,IMAGE=rebin(bytscl(reform(ff(i,*,*) ) ),sx,sy),$
 frame=i

 endfor
  
  XINTERANIMATE,/KEEP_PIXMAPS
return
end
