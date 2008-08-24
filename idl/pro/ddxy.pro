;second derivative with respect to x and y - on the grid
; dk = step in k   om = 2d fiels omxy 2d fields without borders
pro ddxy, dk1,dk2,om,omxy
s=size(om)
n1=s(1)
n2=s(2)
dki2=.25/(dk1*dk2)
omxy= dki2*(om(2:n1-1,2:n2-1)+om(0:n1-3,0:n2-3) - $
            om(2:n1-1,0:n2-3)-om(0:n1-3,2:n2-1) ) 
return
end
