pro velspace, vx0,vth, f
vxmin=-(vx0+3)
vymin=vxmin
vxmax=vx0+3
vymax=vxmax 
nx=201
ny=201
nt=201
f=fltarr(nt,nx,ny)
ix=fltarr(nx)
iy=fltarr(ny)
dx=(vxmax-vxmin)/(nx-1)
dy=(vymax-vymin)/(ny-1)
for it=0,nt-1 do begin
t=2*!pi/(nt-1)*it
for i=0, nx-1 do begin
vx=vxmin+dx*i
ix(i)=vx
for j=0, ny-1 do begin
vy=vymin+dy*j
iy(j)=vy
vp=sqrt(vx^2+vy^2)
if(vp gt (dx/2)) then phi=atan(vx,vy)
f(it,i,j)=exp(-(vp^2+vx0^2)/vth^2+2*vp*vx0*sin(phi+t)/vth^2)
endfor
endfor
endfor
end
