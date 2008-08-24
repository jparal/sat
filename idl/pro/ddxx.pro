;spline second derivative with respect to x - on the grid
; dk = step in k   om = 2d fiels omxx 2d fields 
pro ddxx, dk,om,omxx
on_error,2
s=size(om)
n1=s(1)
n2=s(2)
omxx=findgen(n1,n2)
ik=dk*findgen(n1)
for i=0,n2-1 do begin
omxx(*,i)= nr_spline(ik,reform(om(*,i)))
endfor
return
end
