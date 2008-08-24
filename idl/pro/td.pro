; resolve the particle trajectory in a planar wave (k,om)
; e, b=(k x e)/om + (0,0,1), starting from v ,x=[0,0,0]
pro td,x0,v,zmax=zmax,xmax=xmax  ;q/m=1, dt=.025
if not(keyword_set(zmax))then zmax=1
if not(keyword_set(xmax))then xmax=3
t=0
dt=.05
dth=dt*.5
i=complex(0,1)
x=[x0,0,0]
c20=total(v^2)
plot,[t],[c20],psym=3,xrange=[0,zmax],yrange=[-xmax,xmax],$
xtitle=' t ',ytitle=' E '
new:
for ii=1,1000 do begin
for jj=1,10 do begin
if(abs(x(2)) gt zmax) then begin
x(2)=0
endif
ei=[0,0,0]
bi=[0,0,tanh(x(0))]
vn=v+float(dth*(ei+vect(v,bi)))
bi=[0,0,tanh(x(0))]
vp=v+float(dt*(ei+vect(vn,bi)))
x=x+dt*vp
v=vp
t=t+dt
endfor
bi=[0,0,tanh(x(0))]
c2=total(v^2)
;wset,0
;oplot,[x(0)],[x(2)],psym=3
;wset,1
;oplot,[x(1)],[x(2)],psym=3
;wset,2
;oplot,[t],100*[c2-c20]/c20,psym=3
oplot,[t],[x(0)],psym=2,color=(x(0)+20)/40.*256
endfor
ans=' '
read,'continue y',ans
if(ans eq 'y')then goto, new
return
end
