pro fieldline,xi,yi,ds,bx,by,dx,dy,npoint=npoint,nshow=nshow,$
bxout=bxout,byout=byout,color=color,thick=thick,arrow=arrow,narrow=narrow
if(not(keyword_set(npoint)))then npoint=50000l
if(not(keyword_set(nshow))) then nshow=100
if(not(keyword_set(bxout))) then bxout=0.
if(not(keyword_set(byout))) then byout=0. 
if(not(keyword_set(color))) then color=0
if(not(keyword_set(thick))) then thick=1
if(not(keyword_set(arrow))) then arrow=0
if(not(keyword_set(narrow))) then narrow=500 
ss=size(bx)
nx=ss(1)
ny=ss(2)
xl=fltarr(2)
yl=xl
xl(1)=xi
yl(1)=yi
iarrow=0
for ipoint=0l,npoint do begin
  ix=xi/dx
  ax1=xi/dx-float(ix)
  ax=1-ax1
  iy=yi/dy
  ay1=yi/dy-float(iy)
  ay=1-ay1
  byi=byout
  bxi=bxout
  if(ix ge 1 and ix lt nx and iy ge 1 and iy lt ny)then begin
    bxi=bx(ix-1,iy-1)*ax*ay+bx(ix,iy-1)*ax1*ay+ $
       bx(ix-1,iy)*ax*ay1+bx(ix,iy)*ax1*ay1
    byi=by(ix-1,iy-1)*ax*ay+by(ix,iy-1)*ax1*ay+ $
       by(ix-1,iy)*ax*ay1+by(ix,iy)*ax1*ay1
  endif
  xi=xi+ds*bxi
  yi=yi+ds*byi
  if( (ipoint mod nshow) eq 0)then begin
    ishow=0
    xl(0)=xl(1)
    yl(0)=yl(1)
    xl(1)=xi
    yl(1)=yi
    oplot,color=color,xl,yl,thick=thick
    iarrow=iarrow+1
    if(iarrow eq narrow)then begin
      if(ix ge 1 and ix lt nx and iy ge 1 and iy lt ny)then begin 
        if(arrow gt 0) then arrow,xl(0),yl(0),xl(1),yl(1),/data,/SOLID
        if(arrow lt 0) then arrow,xl(1),yl(1),xl(2),yl(2),/data,/SOLID
      endif     
      iarrow=0
    endif
  endif
endfor
return
end
