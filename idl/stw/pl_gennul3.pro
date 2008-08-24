pro pl_gennul3, nx, ny, nz, dx, dy, dz, xpos, radius, a

a=fltarr(nx,ny,nz)

x = findgen(nx)*dx-xpos*nx*dx
y = findgen(ny)*dy -0.5*ny*dy
z = findgen(nz)*dz -0.5*nz*dz

for i=0,nx-1 do begin
  for j=0,ny-1 do begin
    for k=0,nz-1 do begin
      a(i,j,k)=1.0
      dist=sqrt(x(i)^2+y(j)^2+z(k)^2)
      if (dist le radius) then begin
        a(i,j,k)=0.0
      endif
    endfor
  endfor
endfor

return
end
