pro pl_gennul2, nx, ny, dx, dy, xpos, radius, a

a=fltarr(nx,ny)

x = findgen(nx)*dx-xpos*nx*dx
y = findgen(ny)*dy -0.5*ny*dy

for i=0,nx-1 do begin
  for j=0,ny-1 do begin
    a(i,j)=1.0
    dist=sqrt(x(i)^2+y(j)^2)
    if (dist le radius) then begin
      a(i,j)=0.0
    endif
  endfor
endfor

return
end
