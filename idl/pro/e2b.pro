pro e2b, e, b
ss=size(e)
if(ss(0) eq 3) then begin
b=0*e
for i=0,1 do begin
for j=0,1 do begin
for k=0,1 do begin
  b=b+shift(e,-i,-j,-k)
endfor
endfor
endfor
b=b/8.
b=b(0:ss(1)-2,0:ss(2)-2,0:ss(3)-2)
endif
return
end
