; resolve the particle trajectory in a planar wave (k,om)
; e, b=(k x e)/om + (0,0,1), starting from v ,x=[0,0,0]
pro wavenh,om,k,e,v,zmax=zmax,xmax=xmax  ;q/m=1, dt=.001
if not(keyword_set(zmax))then zmax=10
if not(keyword_set(xmax))then xmax=10
t=0.
lam=20.
dt=.001
dth=dt*.5
i=complex(0.,1.)
b=vect(k,e)/om
ay=-float(i*e(1)/om)
print, sqrt(total(abs(b)^2))
b0=[0,0,1]
x=[0,0,0]
phi=0.
c1=v(1)+ay
c2=total(v^2)
c3=float(vect(v,b+b0))^2/total(float(b+b0)^2)^(3/2)
;window,0,xsize=342,ysize=342
;plot,[x(0)],[x(2)],psym=3,xrange=[-xmax,xmax],yrange=[0,zmax],$
;xtitle=' x ',ytitle=' z '
;window,1,xsize=342,ysize=342
;plot,[x(1)],[x(2)],psym=3,xrange=[-xmax,xmax],yrange=[0,zmax],$
;xtitle=' y ',ytitle=' z '
;window,2,xsize=342,ysize=342
;plot,[c3],[c2],psym=3,xrange=[-xmax,xmax],yrange=[0,zmax],$
;xtitle=' Mu ',ytitle=' E '
new:
for ii=1,10000 do begin
for jj=1,10 do begin
if(abs(x(2)) gt zmax) then begin
phi=k*x(2)+phi
x(2)=0
endif
et=exp(i*(total(k*x)-om*t+phi))*(1+x(0)/lam)
ei=e*et
bi=b*et
vn=v+float(dth*(ei+vect(v,bi+b0)))
et=exp(i* (total(k*x)-om*(t+dth)+phi))*(1+x(0)/lam)
ei=e*et
bi=b*et
vp=v+float(dt*(ei+vect(vn,bi+b0)))
x=x+dt*vp
v=vp
t=t+dt
endfor
exh=exp(i*(total(k*x)-om*t+phi))
et=e*exh
bt=b*exh
ay=x(0)-float(i*et(1)/om)
c1=v(1)+ay
c2=total(v^2)
c3=float(vect(v,bt+b0))^2/total(float(bt+b0)^2)^(3/2)
;wset,0
;oplot,[x(0)],[x(2)],psym=3
;wset,1
;oplot,[x(1)],[x(2)],psym=3
;wset,2
;oplot,[c3],[c2],psym=3
print,x(0)
endfor
ans=' '
read,'repeat from x= 0 ? y',ans
if(ans eq 'y')then goto, new
return
end
