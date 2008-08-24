restore,'p80m2t10'
y=0
z=0
x0=10.
dxx=.5
i1=where(x gt x0 and  x lt (x0+dxx))
i2=where(x gt (x0+dxx) and  x lt (x0+2*dxx))
i3=where(x gt (x0+2*dxx) and  x lt (x0+3*dxx))
i4=where(x gt (x0+3*dxx) and  x lt (x0+4*dxx))
x=0
kx=-4.2
ky=3.7
kz=-3.7
hist_along, vx(i1)-2.,vy(i1),vz(i1),kx,ky,kz,h1,ix1
hist_along, vx(i2)-2.,vy(i2),vz(i2),kx,ky,kz,h2,ix2
hist_along, vx(i3)-2.,vy(i3),vz(i3),kx,ky,kz,h3,ix3
hist_along, vx(i4)-2.,vy(i4),vz(i4),kx,ky,kz,h4,ix4
save, h1,ix1,h2,ix2,h3,ix3,h4,ix4,dxx,x0,filename='reso'
end
