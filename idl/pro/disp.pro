; disp fun 
; g= abs(det())
 pro disp, k1, k2,k3,k0,om, phi, ma, v1,v2,al, g
kx=complex(k1,-k0*sin(phi))
ky=complex(k2,0)
kz=complex(k3,-k0*cos(phi))
a=[[1,0],[0,1]]
i=complex(0,1)
g=a*(kx^2+ky^2+kz^2) - $
[[kx^2,kx*ky],[kx*ky,ky^2] ]
print,g
max=ma*sin(phi)
maz=ma*cos(phi)
omd1=om-max*kx-maz*kz
omd4=om-maz*kz
vx=v1*sin(phi)
vy=v2
vz=v1*cos(phi)
omd3=om-vx*kx-vz*kz 
omd5=om-vy*ky-vz*kz
omd2=omd3-vy*ky
g1=i*a
g1(0,0)=-(omd4^2+(ky^2+kz^2)*max^2)/(omd1^2-1)
g1(1,1)=-omd1^2/(omd1^2-1)
g1(0,1)=(-i*omd1-ky*max*omd1 - i*kx*max)/(omd1^2-1)
g1(1,0)=(i*omd1-ky*max*omd1 + i*kx*max)/(omd1^2-1)
g2=i*a
g2(0,0)=-(omd5^2+(ky^2+kz^2)*vx^2)/omd2^2
g2(1,1)=-(omd3^2+(kx^2+kz^2)*vy^2)/omd2^2
g2(0,1)=-(omd2*(kx*vy+ky*vx)+(kx^2+ky^2+kz^2)*vx*vy )/omd2^2
g2(1,0)=g2(0,1)
g=g-(1-al)*g1-al*g2
print, g
g=g(0,0)*g(1,1)-g(0,1)*g(1,0)
g=abs(g)
print,g
return
end
