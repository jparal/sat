pro slmax,a,m,am
s=size(a)
am=-1.e-12
am=fltarr(20)
m=am
ilm=0
if(s(0) eq 1) then begin
for  i=1,s(1)-2 do begin
 if( (a(i) gt a(i-1)) and(a(i) gt a(i+1)))then begin
   am(ilm)=a(i)
   m(ilm)=i
   ilm=ilm+1
 endif
endfor
endif
am=am(0:ilm-1)
m=m(0:ilm-1)
return
end
