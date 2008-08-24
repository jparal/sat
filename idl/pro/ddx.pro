; derivative with respect to x - on the grid
; dk = step in k   om = 2d fiels omx 2d fields
pro ddx, dk,om,omx
s=size(om)
n2=s(2)
dki=1./dk
omx=om
for i=0,n2-1 do begin
omx(*,i)=deriv(om(*,i))
endfor
omx=omx*dki
return
end
