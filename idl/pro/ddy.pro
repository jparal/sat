; derivative with respect to y - on the grid
; dk = step in k   om = 2d fiels omy 2d fields
pro ddy, dk,om,omy
s=size(om)
n1=s(1)
dki=1./dk
omy=om
for i=0,n1-1 do begin
omy(i,*)=deriv(reform(om(i,*)))
endfor
omy=dki*omy
return
end
