;
  pro tevol, x,x0, dx
si=size(x)
a=si(1)
plot,x(a-1,*)+(a-1)*dx+x0
for i=0,a-2 do begin 
oplot, x(i,*)+i*dx +x0
endfor
return
end
