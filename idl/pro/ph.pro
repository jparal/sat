; for 2d (or 3d) array a  ph find a maximum in the last direction
;  b return 1d (or 2d) array of its position c its value 
pro ph, a, b,c
s=size(a)
s0=s(0)
if(s0 eq 2) then begin
s1=s(1)
b=fltarr(s1)
c=b
for i=0,s1-1 do begin
smax,reform(a(i,*)),aa,aaa
b(i)=aa
c(i)=aaa
endfor
endif
if(s0 eq 3) then begin
s1=s(1)
s2=s(2)
b=fltarr(s1,s2)
c=b
for i=0,s1-1 do begin
for j=0,s2-1 do begin
smax,reform(a(i,j,*)),aa,aaa
b(i,j)=aa
c(i,j)=aaa
endfor
endfor
endif
return
end
