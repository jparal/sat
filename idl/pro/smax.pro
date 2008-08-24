; finds a maximum of an array a (1,2 or 3 D) with
; and gives coordinate m and value am
pro smax,a,m,am
s=size(a)
am=-1.e12
if(s(0) eq 3) then begin
for  i=0,s(1)-1 do begin
for  j=0,s(2)-1 do begin
for  k=0,s(3)-1 do begin
 if( a(i,j,k) gt am)then begin
   am=a(i,j,k)
   m=[i,j,k]
 endif
endfor 
endfor
endfor
endif
if(s(0) eq 2) then begin
for  i=0,s(1)-1 do begin
for  j=0,s(2)-1 do begin
 if( a(i,j) gt am)then begin
   am=a(i,j)
   m=[i,j]
 endif
endfor
endfor
endif
if(s(0) eq 1) then begin
for  i=0,s(1)-1 do begin
 if( a(i) gt am)then begin
   am=a(i)
   m=i
 endif
endfor
endif
return
end
