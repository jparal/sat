pro meanftr, a, x,y,af,ix,iy,verbose=verbose
if(not(keyword_set(verbose)))then verbose=0
ss=size(a)
if(ss(0) ne 3)then begin
  print,'a should have 3 dim'
  return
endif
foutr,reform(a(0,*,*)),x,y,af,ix,iy
afa=af
for i=1,ss(1)-1 do begin
if(verbose eq 1) then print,i
  foutr,reform(a(i,*,*)),x,y,afa,ix,iy
  af=afa+af
endfor
af=af/ss(1)
return
end 
