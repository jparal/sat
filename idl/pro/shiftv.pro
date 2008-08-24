; shifts 2D array a(x,t) to a(x-vt,t)
; dx, dt are steps in x, t, respectively
pro shiftv, a, dx,dt, v, aout
s=size(a)
aout=a*0
for i=0,s(2)-1 do begin
x=v*dt*i
j=round(x/dx+.5)
j1=j+1
g1=x/dx-j
g=1.-g1
aout(*,i)=g*shift(a(*,i),j)+g1*shift(a(*,i),j1)
endfor
return
end
