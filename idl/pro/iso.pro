pro iso, a,lev=lev,ax=ax,az=az,im,xsize=xsize,ysize=ysize
if(not(keyword_set(ax)))then ax=30.
if(not(keyword_set(az)))then az=30.
SHADE_VOLUME, a, lev, v, p, /LOW
s = SIZE(a) 
SCALE3, XRANGE=[0,S[1]], YRANGE=[0,S[2]],$
ZRANGE=[0,S[3]], AX=ax, AZ=az
if(keyword_set(xsize) and keyword_set(ysize))then begin
im=POLYSHADE(v, p, /T3D,xsize=xsize,ysize=ysize)
endif else begin
im=POLYSHADE(v, p, /T3D) 
endelse
return
end
