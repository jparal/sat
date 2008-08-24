; resolve the particle trajectory in 2 planar waves (k,om),(k1,om1)
; e+e1, b=(k x e)/om+(k1 x e1)/om1 + (0,0,1), starting from v ,x=[0,0,0]
pro wave2,om,k,e,v,om1,k1,e1,zmax=zmax,xmax=xmax  ;q/m=1, dt=.001
if not(keyword_set(zmax))then zmax=10
if not(keyword_set(xmax))then xmax=10
t=0
dt=.001
dth=dt*.5
i=complex(0,1)
b=vect(k,e)/om
b1=vect(k1,e1)/om1
print, sqrt(total(abs(b)^2)),sqrt(total(abs(b1)^2))
b0=[0,0,1]
x=[0,0,0]
mu=atan(v(2),sqrt(v(0)^2+v(1)^2))
vect=(float(b(0))*v(1)-float(b(1))*v(0))/sqrt(float(b(0))^2+float(b(1))^2)
phi=asin(vect/sqrt(v(0)^2+v(1)^2))
print,mu,phI
plot,[phi]/!pi,[MU]/!pI,psym=3,xrange=[-1,1],yrange=[-1,1]
new:
for ii=1,10000 do begin
for jj=1,50 do begin
et=exp(i*(total(k*x)-om*t))
et1=exp(i*(total(k1*x)-om1*t))
ei=e*et+e1*et1
bi=b*et+b1*et1
vn=v+float(dth*(ei+vect(v,bi+b0)))
et=exp(i* (total(k*x)-om*(t+dth)))
et1=exp(i* (total(k1*x)-om1*(t+dth)))
ei=e*et+e1*et1
bi=b*et+b1*et1
vp=v+float(dt*(ei+vect(vn,bi+b0)))
x=x+dt*vp
v=vp
t=t+dt
endfor
MU=atan(v(2),sqrt(v(0)^2+v(1)^2))
bb=float(b*et)
vect=(bb(0)*v(1)-bb(1)*v(0))/sqrT(bb(0)^2+bb(1)^2)
phi=asin(vect/sqrT(v(0)^2+v(1)^2))
Oplot,[phi]/!pI,[MU]/!pI,psym=3
;oplot,[v(2)],[sqrt(v(0)^2+v(1)^2)],psym=3
endfor
ans=' '
read,'continue ? [y]',ans
if(ans eq 'y')then goto, new
return
end
