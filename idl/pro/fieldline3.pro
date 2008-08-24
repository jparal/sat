pro fieldline3,xi,yi,zi,ds,bx,by,bz,dx,dy,dz,npoint=npoint,nshow=nshow,$
bxout=bxout,byout=byout,color=color,thick=thick,arrow=arrow,narrow=narrow,proj=proj
if(not(keyword_set(npoint)))then npoint=50000l
if(not(keyword_set(nshow))) then nshow=100
if(not(keyword_set(bxout))) then bxout=0.
if(not(keyword_set(byout))) then byout=0. 
if(not(keyword_set(color))) then color=0
if(not(keyword_set(thick))) then thick=1
if(not(keyword_set(arrow))) then arrow=0
if(not(keyword_set(narrow))) then narrow=500 
if(not(keyword_set(proj))) then proj=2
ss=size(bx)
if(ss(0) ne 3) then begin
print, 'field are not 3D'
return
endif
nx=ss(1)
ny=ss(2)
nz=ss(3)
xl=fltarr(2)
yl=xl
zl=xl
xl(1)=xi
yl(1)=yi
zl(1)=zi
iarrow=0
for ipoint=0l,npoint do begin
  ix=xi/dx
  ax1=xi/dx-float(ix)
  ax=1-ax1
  iy=yi/dy
  ay1=yi/dy-float(iy)
  ay=1-ay1
  iz=zi/dz
  az1=zi/dz-float(iz)
  az=1-az1
  byi=byout
  bxi=bxout
  if(ix ge 1 and ix lt nx and iy ge 1 and iy lt ny and iz ge 1 and iz lt nz)then begin
    bxi=bx(ix-1,iy-1,iz-1)*ax*ay*az+bx(ix,iy-1,iz-1)*ax1*ay*az+ $
       bx(ix-1,iy,iz-1)*ax*ay1*az+bx(ix,iy,iz-1)*ax1*ay1*dz +$
       bx(ix-1,iy-1,iz)*ax*ay*az1+bx(ix,iy-1,iz)*ax1*ay*az1+ $
       bx(ix-1,iy,iz)*ax*ay1*az1+bx(ix,iy,iz)*ax1*ay1*dz1
    byi=by(ix-1,iy-1,iz-1)*ax*ay*az+by(ix,iy-1,iz-1)*ax1*ay*iz+ $
       by(ix-1,iy,iz-1)*ax*ay1*az+by(ix,iy,iz-1)*ax1*ay1*az +$
       by(ix-1,iy-1,iz)*ax*ay*az1+by(ix,iy-1,iz)*ax1*ay*iz1+ $
       by(ix-1,iy,iz)*ax*ay1*az1+by(ix,iy,iz)*ax1*ay1*az1
    bzi=bz(ix-1,iy-1,iz-1)*ax*ay*az+bz(ix,iy-1,iz-1)*ax1*ay*iz+ $
       bz(ix-1,iy,iz-1)*ax*ay1*az+bz(ix,iy,iz-1)*ax1*ay1*az +$
       bz(ix-1,iy-1,iz)*ax*ay*az1+bz(ix,iy-1,iz)*ax1*ay*iz1+ $
       bz(ix-1,iy,iz)*ax*ay1*az1+bz(ix,iy,iz)*ax1*ay1*az1
  endif
  xi=xi+ds*bxi
  yi=yi+ds*byi
  zi=zi+ds*bzi
  if( (ipoint mod nshow) eq 0)then begin
    ishow=0
    xl(0)=xl(1)
    yl(0)=yl(1)
    zl(0)=zl(1)
    xl(1)=xi
    yl(1)=yi
    zl(1)=zi
    if(proj eq 2)then begin
      oplot,color=color,xl,yl,thick=thick
      iarrow=iarrow+1
      if(iarrow eq narrow)then begin
        if(ix ge 1 and ix lt nx and iy ge 1 and iy lt ny and iz ge 1 and iz lt nz)then begin 
          if(arrow gt 0) then arrow,xl(0),yl(0),xl(1),yl(1),/data,/SOLID
          if(arrow lt 0) then arrow,xl(1),yl(1),xl(2),yl(2),/data,/SOLID
        endif     
        iarrow=0
      endif
    endif
    if(proj eq 1)then begin
      oplot,color=color,xl,zl,thick=thick
      iarrow=iarrow+1
      if(iarrow eq narrow)then begin
        if(ix ge 1 and ix lt nx and iy ge 1 and iy lt ny and iz ge 1 and iz lt nz)then begin
          if(arrow gt 0) then arrow,xl(0),zl(0),xl(1),zl(1),/data,/SOLID
          if(arrow lt 0) then arrow,xl(1),zl(1),xl(2),zl(2),/data,/SOLID
        endif
        iarrow=0
      endif
    endif
    if(proj eq 0)then begin
      oplot,color=color,yl,zl,thick=thick
      iarrow=iarrow+1
      if(iarrow eq narrow)then begin
        if(ix ge 1 and ix lt nx and iy ge 1 and iy lt ny and iz ge 1 and iz lt nz)then begin
          if(arrow gt 0) then arrow,yl(0),zl(0),yl(1),zl(1),/data,/SOLID
          if(arrow lt 0) then arrow,yl(1),zl(1),yl(2),zl(2),/data,/SOLID
        endif
        iarrow=0
      endif
    endif
  endif
endfor
return
end
