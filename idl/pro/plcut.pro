pro plcut, a, x0,y0,z0,dx,dy,dz,n,del,kx,ky,kz,pl
k=1./sqrt(kx^2+ky^2+kz^2)
s=size(a)
s1=s(1)
s2=s(2)
s3=s(3)
kx=kx*k
ky=ky*k
kz=kz*k
pl=fltarr(2*n+1)
for i=-n,n do begin
x=x0+i*del*kx
y=y0+i*del*ky
z=z0+i*del*kz
nx=fix(x/dx)
ny=fix(y/dy)
nz=fix(z/dz)
if((nx ge 0) and (nx lt s1-1))then begin
if((ny ge 0) and (ny lt s2-1))then begin
if((nz ge 0) and (nz lt s3-1))then begin
xd=x-dx*nx
yd=y-dy*ny
zd=z-dz*nz
pl(i+n)=(1.-xd)*(1.-yd)*(1-zd)*a(nx,ny,nz) + $
        (xd)*(1.-yd)*(1-zd)*a(nx+1,ny,nz) + $
        (xd)*(yd)*(1-zd)*a(nx+1,ny+1,nz) + $
        (xd)*(yd)*(zd)*a(nx+1,ny+1,nz+1) + $
        (xd)*(1.-yd)*(zd)*a(nx+1,ny,nz+1) + $
        (1.-xd)*(yd)*(1-zd)*a(nx,ny+1,nz) + $
        (1.-xd)*(1.-yd)*(zd)*a(nx,ny,nz+1) + $
        (1.-xd)*(yd)*(zd)*a(nx,ny+1,nz+1)
endif
endif
endif
endfor
;plot,pl
return
end
