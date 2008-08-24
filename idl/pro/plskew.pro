
pro plskew, a, ky,x0, y0, x
s=size(a)
sm=s(2)-1
x=fltarr(s(1))
y0=y0-x0*ky
for i=0, s(1)-1 do begin
j=ky*i + y0
eichler:
if(j gt sm) then begin
 j=j-sm
goto, eichler
endif
grusa:
if(j lt 0) then begin
 j=j+sm
goto, grusa
endif
x(i)=a(i,j)
endfor
plot, x
return
end
