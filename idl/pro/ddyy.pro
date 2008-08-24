;second derivative with respect to y - on the grid
; dk = step in k   om = 2d fiels omyy 2d fields without borders
pro ddyy, dk,om,omyy
s=size(om)
n1=s(1)
n2=s(2)
dki2=1./dk^2
omyy= dki2*(om(*,2:n2-1)+om(*,0:n2-3)-2.*om(*,1:n2-2))
omyy=reform(omyy(1:n1-2,*))
return
end
