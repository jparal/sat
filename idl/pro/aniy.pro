;          animates ff along the second index
;          magnifies mag-times (under widgets)  
   pro aniy, mag,ff

s=size(ff)
   n=s(2)
   sx=mag*s(1)
   sy=mag*s(3)
XINTERANIMATE, SET = [sx, sy, n]
 for i=0,n-1 do begin

 XINTERANIMATE,IMAGE=rebin(bytscl(reform(ff(*,i,*) ) ),sx,sy),$
 frame=i
 endfor
  XINTERANIMATE
XINTERANIMATE,/close
return
end
