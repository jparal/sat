; imco 2d cuts of fi in xy, xz, yz plans + 1D plot in x
; 2x2 format x only in x0,x1 limits, x,y,z cut point 
pro shortcuts, fi,x0,x1,x,y,z,t,dx,dy,dz,title=title,c=c,n=n,nodata=nodata
if not(keyword_set(title)) then title=' '
if not(keyword_set(c)) then c=[255.,255.,255.]
if not(keyword_set(n)) then n=[3,3,3]
if not(keyword_set(nodata)) then nodata=0
!p.multi=[0,2,2,0,0]
s=size(fi)
ix=findgen(x1-x0+1)*dx+x0*dx
iy=findgen(s(2))*dy
iz=findgen(s(3))*dz
if (s(0) eq 4) then begin
imco,reform(fi(t,x0:x1,y,*)),ix,iz,$
title=title+' (xz-plane)',xtitle='!N!18 x /(c/!4x!i!18pi!N)', $
ytitle='!N!18 z /(c/!4x!i!18pi!N)',nlevels=n(0),nodata=nodata
oplot, [x*dx],[z*dz],psym=2,color=c(0)
imco,reform(fi(t,x,*,*)),iy,iz,$
title=title+' (yz-plane)',xtitle='!N!18 y /(c/!4x!i!18pi!N)', $
ytitle='!N!18 z /(c/!4x!i!18pi!N)',nlevels=n(1),nodata=nodata
oplot, [y*dy],[z*dz],psym=2,color=c(1)
imco ,reform(fi(t,x0:x1,*,z)),ix,iy,$
title=title+' (xy-plane)',xtitle='!N!18 x /(c/!4x!i!18pi!N)', $
ytitle='!N!18 y /(c/!4x!i!18pi!N)',nlevels=n(2),nodata=nodata
oplot, [x*dx],[y*dy],psym=2,color=c(2)
plot, ix,reform(fi(t,x0:x1,y,z)),title=title,$
xtitle='!N!18 x /(c/!4x!i!18pi!N)',subtitle='Cuts through p='+ $
strcompress(string([x*dx,y*dx,z*dz]))
oplot, [x*dx],[fi(t,x,y,z)],psym=2
endif
if (s(0) eq 3) then begin
imco,reform(fi(x0:x1,y,*)),ix,iz,$
title=title+' (xz-plane)',xtitle='!N!18 x /(c/!4x!i!18pi!N)', $
ytitle='!N!18 z /(c/!4x!i!18pi!N)',nlevels=n(0),nodata=nodata
oplot, [x*dx],[z*dz],psym=2,color=c(0)
imco,reform(fi(x,*,*)),iy,iz,$
title=title+' (yz-plane)',xtitle='!N!18 y /(c/!4x!i!18pi!N)', $
ytitle='!N!18 x /(c/!4x!i!18pi!N)',nlevels=n(1),nodata=nodata
oplot, [y*dy],[z*dz],psym=2,color=c(1)
imco ,reform(fi(x0:x1,*,z)),ix,iy,$
title=title+' (xy-plane)',xtitle='!N!18 x /(c/!4x!i!18pi!N)', $
ytitle='!N!18 y /(c/!4x!i!18pi!N)',nlevels=n(2),nodata=nodata
oplot, [x*dx],[y*dy],psym=2,color=c(2)
plot, ix,reform(fi(x0:x1,y,z)),title=title,$
xtitle='!N!18 x /(c/!4x!i!18pi!N)'
;,subtitle='Cuts through p='+ $
;strcompress('['+string(x*dx)+','+string(y*dx)+$
;','+string(z*dz)+']')
oplot, [x*dx],[fi(x,y,z)],psym=2
endif
!p.multi=0
return
end
