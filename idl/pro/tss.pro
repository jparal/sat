;
  pro tss
; Initial conditions
common tether, v0, b0, ba
v0=1. 
; unity 8*10^3 m/s
;
a= .0012/8 *10^4
print,' a = ',a 
x=0.   
y=20*a    
z=.01*a 
; unity 8*10^-4 m    
vx=10.
vy=0.
vz=0.
t=0.          ;
dt=.01       ; unity 10^-7 s
;           
rqm= 1.  ; unity 
dta= dt * rqm
dth=dta*.5
b0=1.
a= .0012/8 *10^4
b=b0*2.
ba= b*a
n=10000
;
xx=fltarr(n)
yy=xx
zz=xx
vxx=fltarr(n+1)
vyy=vxx
vzz=vxx
xxt=fltarr(n)
yyt=xxt
zzt=xxt
yt=0
;
; Cycle
;
exi=ex(t,x,y,z)
byi=by(t,x,y,z)
bzi=bz(t,x,y,z)
vxp=vx-dth*(exi+vy*bzi-vz*byi)
vyp=vy-dth*(          -vx*bzi)
vzp=vz-dth*(   +byi*vx       )
vxx(0)=vxp
vyy(0)=vyp
vzz(0)=vzp
for i=1,n do begin
; h velocity
exi=ex(t,x,y,z)
byi=by(t,x,y,z)
bzi=bz(t,x,y,z)
; demi-advanced
vxh=vxp+dth*(exi+vyp*bzi-vzp*byi)
vyh=vyp+dth*(           -vxp*bzi)
vzh=vzp+dth*(   +byi*vxp        )
; new velocity
vxp=vxp+dta*(exi+vyh*bzi-vzh*byi)
vyp=vyp+dta*(           -vxh*bzi)
vzp=vzp+dta*(   +byi*vxh        )
;
x=x+ dt * vxp
y=y+ dt * vyp
z=z+ dt * vzp
yt=yt+dt*v0 
;
t=t+dt
;
vxx(i)=vxp
vyy(i)=vyp
vzz(i)=vzp
;
yyt(i-1)=yt
xx(i-1)=x
yy(i-1)=y
zz(i-1)=z
endfor
v2=vxx^2+vyy^2+vzz^2
r=sqrt(xx^2+(yy-yyt)^2+zz^2)
save, xx,yy,zz,vxx,vyy,vzz,v2,yyt,r
end
