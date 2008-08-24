;2nd order analytic extrapolation of omega(k) to complex k=kr+i*ki
; and shock solution of given theta and vsh
pro anex2, ikpe,ikpa,omer,omei,theta,vsh,ki,kim,om,omm,disk,er,oo 
s=size(omei)
n1=s(1)
n2=s(2)
thetan=theta*!pi/180.
nx=sin(thetan)
ny=cos(thetan)
dkx=ikpe(1)-ikpe(0)
dky=ikpa(1)-ikpa(0)
ddx,dkx,omer,omx
ddy,dky,omer,omy
vg=nx*omx+ny*omy
print, nx,ny
ddxx,dkx,omei,omxx
ddyy,dky,omei,omyy
ddxy,dkx,dky,omei,omxy
omega=nx^2*omxx+ny^2*omyy+2*nx*ny*omxy
vau=vg-vsh
oo=omega
er=-omei(1:n1-2,1:n2-2)/vau
disk=(vau)^2+omei(1:n1-2,1:n2-2)*omega
ki=(vau+sqrt(disk))/omega
kim=(vau-sqrt(disk))/omega
ddx,dkx,omei,omx
ddy,dky,omei,omy
vg=nx*omx+ny*omy
ddxx,dkx,omer,omxx
ddyy,dky,omer,omyy
ddxy,dkx,dky,omer,omxy
omega=nx^2*omxx+ny^2*omyy+2*nx*ny*omxy
om=omer(1:n1-2,1:n2-2)-ki*vg-.5*ki^2*omega
omm=omer(1:n1-2,1:n2-2)-kim*vg-.5*kim^2*omega
return
end
