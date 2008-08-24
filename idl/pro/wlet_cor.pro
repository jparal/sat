
pro wlet_cor, a, c,e, alfa, n
s=size(a)
if (s(0) ne 1) then return
s1=s(1)

wlet,a,b,alfa,n
wlet,c,d,alfa,n

e=fltarr(s1,n)
for i=0,s1-1 do begin
for j=0,n-1 do begin
e(i,j)= correlate(shift(b(*,j),i),d(*,j))
endfor
endfor

return
end
