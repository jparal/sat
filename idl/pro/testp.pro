;
pro testp, xp,yp,zp,vxp,vyp,vzp,n, bx,by,bz,ex,ey,ez,xx,yy,zz,vxx,vyy,vzz,$
     bxx,byy,bzz,exx,eyy,ezz
;
xx=fltarr(n+1)
yy=xx
zz=xx
exx=fltarr(n)
eyy=exx
ezz=exx
bxx=fltarr(n)
byy=bxx
bzz=bxx
xx(0)=xp
yy(0)=yp
zz(0)=zp
vxx=fltarr(n+1)
vyy=vxx
vzz=vxx
dx=.125
dy=.25
dz=.25
rmds=1.
ng=30
ms=rmds/float(ng)
qs=rmds*ms
dt=.0001
dta=-dt*qs/ms
dth=dta/2.
;
; Cycle
;
xmax=200.*dx
xmin=0.
ymin=0.
ymax=20.*dy
zmin=0.
zmax=20.*dz
yr=ymax-ymin
zr=zmax-zmin
dxi=1./dx
dyi=1./dy
dzi=1./dz
;
i=fix(xp*dxi)
j=fix(yp*dyi)
k=fix(zp*dzi)
xf=xp*dxi-float(i)
yf=yp*dyi-float(j)
zf=zp*dzi-float(k)
xa=1.-xf
ya=1.-yf
za=1.-zf
w000=xa*ya*za
w100=xf*ya*za
w010=xa*yf*za
w001=xa*ya*zf
w110=xf*yf*za
w101=xf*ya*zf
w011=xa*yf*zf
w111=xf*yf*zf
;
exi= w000*ex(i,j,k) + $
     w100*ex(i+1,j,k) + $
     w010*ex(i,j+1,k) + $
     w001*ex(i,j,k+1) + $
     w101*ex(i+1,j,k+1) + $
     w011*ex(i,j+1,k+1) + $
     w110*ex(i+1,j+1,k) + $
     w111*ex(i+1,j+1,k+1) ;
eyi= w000*ey(i,j,k) + $
     w100*ey(i+1,j,k) + $
     w010*ey(i,j+1,k) + $
     w001*ey(i,j,k+1) + $
     w101*ey(i+1,j,k+1) + $
     w011*ey(i,j+1,k+1) + $
     w110*ey(i+1,j+1,k) + $
     w111*ey(i+1,j+1,k+1) ;
ezi= w000*ez(i,j,k) + $
     w100*ez(i+1,j,k) + $
     w010*ez(i,j+1,k) + $
     w001*ez(i,j,k+1) + $
     w101*ez(i+1,j,k+1) + $
     w011*ez(i,j+1,k+1) + $
     w110*ez(i+1,j+1,k) + $
     w111*ez(i+1,j+1,k+1) ;
bxi= w000*bx(i,j,k) + $
     w100*bx(i+1,j,k) + $
     w010*bx(i,j+1,k) + $
     w001*bx(i,j,k+1) + $
     w101*bx(i+1,j,k+1) + $
     w011*bx(i,j+1,k+1) + $
     w110*bx(i+1,j+1,k) + $
     w111*bx(i+1,j+1,k+1) ;
byi= w000*by(i,j,k) + $
     w100*by(i+1,j,k) + $
     w010*by(i,j+1,k) + $
     w001*by(i,j,k+1) + $
     w101*by(i+1,j,k+1) + $
     w011*by(i,j+1,k+1) + $
     w110*by(i+1,j+1,k) + $
     w111*by(i+1,j+1,k+1) ;
bzi= w000*bz(i,j,k) + $
     w100*bz(i+1,j,k) + $
     w010*bz(i,j+1,k) + $
     w001*bz(i,j,k+1) + $
     w101*bz(i+1,j,k+1) + $
     w011*bz(i,j+1,k+1) + $
     w110*bz(i+1,j+1,k) + $
     w111*bz(i+1,j+1,k+1) 
;
        vxp = vxp + dth*(exi + vyp*bzi - vzp*byi)
        vyp = vyp + dth*(eyi + vzp*bxi - vxp*bzi)
        vzp = vzp + dth*(ezi + vxp*byi - vyp*bxi)
vxx(0)=vxp
vyy(0)=vyp
vzz(0)=vzp
;
for ni=1,n do begin
;
i=fix(xp*dxi)
j=fix(yp*dyi)
k=fix(zp*dzi)
xf=xp*dxi-float(i)
yf=yp*dyi-float(j)
zf=zp*dzi-float(k)
xa=1.-xf
ya=1.-yf
za=1.-zf
w000=xa*ya*za
w100=xf*ya*za
w010=xa*yf*za
w001=xa*ya*zf
w110=xf*yf*za
w101=xf*ya*zf
w011=xa*yf*zf
w111=xf*yf*zf
;
exi= w000*ex(i,j,k) + $
     w100*ex(i+1,j,k) + $
     w010*ex(i,j+1,k) + $
     w001*ex(i,j,k+1) + $
     w101*ex(i+1,j,k+1) + $
     w011*ex(i,j+1,k+1) + $
     w110*ex(i+1,j+1,k) + $
     w111*ex(i+1,j+1,k+1) ;
eyi= w000*ey(i,j,k) + $
     w100*ey(i+1,j,k) + $
     w010*ey(i,j+1,k) + $
     w001*ey(i,j,k+1) + $
     w101*ey(i+1,j,k+1) + $
     w011*ey(i,j+1,k+1) + $
     w110*ey(i+1,j+1,k) + $
     w111*ey(i+1,j+1,k+1) ;
ezi= w000*ez(i,j,k) + $
     w100*ez(i+1,j,k) + $
     w010*ez(i,j+1,k) + $
     w001*ez(i,j,k+1) + $
     w101*ez(i+1,j,k+1) + $
     w011*ez(i,j+1,k+1) + $
     w110*ez(i+1,j+1,k) + $
     w111*ez(i+1,j+1,k+1) ;
bxi= w000*bx(i,j,k) + $
     w100*bx(i+1,j,k) + $
     w010*bx(i,j+1,k) + $
     w001*bx(i,j,k+1) + $
     w101*bx(i+1,j,k+1) + $
     w011*bx(i,j+1,k+1) + $
     w110*bx(i+1,j+1,k) + $
     w111*bx(i+1,j+1,k+1) ;
byi= w000*by(i,j,k) + $
     w100*by(i+1,j,k) + $
     w010*by(i,j+1,k) + $
     w001*by(i,j,k+1) + $
     w101*by(i+1,j,k+1) + $
     w011*by(i,j+1,k+1) + $
     w110*by(i+1,j+1,k) + $
     w111*by(i+1,j+1,k+1) ;
bzi= w000*bz(i,j,k) + $
     w100*bz(i+1,j,k) + $
     w010*bz(i,j+1,k) + $
     w001*bz(i,j,k+1) + $
     w101*bz(i+1,j,k+1) + $
     w011*bz(i,j+1,k+1) + $
     w110*bz(i+1,j+1,k) + $
     w111*bz(i+1,j+1,k+1) 
;
        vxh = vxp + dth*(exi + vyp*bzi - vzp*byi)
        vyh = vyp + dth*(eyi + vzp*bxi - vxp*bzi)
        vzh = vzp + dth*(ezi + vxp*byi - vyp*bxi)
;
        vxp = vxp + dta*(exi + vyh*bzi - vzh*byi)
        vyp = vyp + dta*(eyi + vzh*bxi - vxh*bzi)
        vzp = vzp + dta*(ezi + vxh*byi - vyh*bxi)
;
xp=xp+ dt * vxp
yp=yp+ dt * vyp
zp=zp+ dt * vzp
;
;
vxx(ni)=vxp
vyy(ni)=vyp
vzz(ni)=vzp
;
if (xp gt xmax) then begin
print, xp,vx,vy,vz
read, 'xp, vx :',xp,vx
endif
;
if (xp lt xmin) then xp=yp+yr
;
if (yp gt ymax) then yp=yp-yr
;
if (yp lt ymin) then yp=yp+yr
;
if (zp gt zmax) then zp=zp-zr
;
if (zp lt zmin) then zp=zp+zr
;
xx(ni)=xp
yy(ni)=yp
zz(ni)=zp
bxx(ni-1)=bxi
byy(ni-1)=byi
bzz(ni-1)=bzi
exx(ni-1)=exi
eyy(ni-1)=eyi
ezz(ni-1)=ezi
endfor
return
end
