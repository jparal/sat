; resolve the particle trajectory in a planar wave (k,om)
; e, b=(k x e)/om + (0,0,1), starting from v ,x=[0,0,0]
pro waveng,om,k,e,v,zmax=zmax,xmax=xmax  ;q/m=1, dt=.001
if not(keyword_set(zmax))then zmax=100
if not(keyword_set(xmax))then xmax=10
t=0
dt=.001
dth=dt*.5
i=complex(0,1)
b=vect(k,e)/om
absk=sqrt(total(k^2))
ay=-float(i*e(1)/om)
print, sqrt(total(abs(b)^2))
b0=[0,0,1]
; x=[0,0,0]
xx=fltarr(3,101)
xx(2,*)=findgen(101)/100.*2*!pi/absk
vv=xx
for iv=0,100 do vv(*,iv)=v
phi=0.
plot,xx(2,*),xx(0,*),psym=3,xrange=[0,zmax],yrange=[-xmax,xmax],$
xtitle=' z ',ytitle=' Time '
openw,11,'xng.dat'
new:
for ii=1,100 do begin
for jj=1,100 do begin
for ip=0,100 do begin
et=exp(i*(total(k*xx(*,ip))-om*t+phi))
ei=e*et
bi=b*et
vn=vv(*,ip)+float(dth*(ei+vect(reform(vv(*,ip)),bi+b0)))
et=exp(i* (total(k*xx(*,ip))-om*(t+dth)+phi))
ei=e*et
bi=b*et
vp=vv(*,ip)+float(dt*(ei+vect(vn,bi+b0)))
xx(*,ip)=xx(*,ip)+dt*vp
vv(*,ip)=vp
endfor
t=t+dt
endfor
oplot,xx(2,*),xx(0,*),psym=3
printf,11,reform(xx(0,*))
endfor
print,bi
ans=' '
read,'repeat from x= 0 ? y',ans
if(ans eq 'y')then goto, new
close,11
return
end
