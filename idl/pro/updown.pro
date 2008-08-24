function updown,a
ss=size(a)
b=a
for i=0,ss(2)-1 do begin
  b(*,i)=a(*,ss(2)-i-1)
endfor
return,b
end
