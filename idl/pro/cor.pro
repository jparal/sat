;  c(i)=correlate(a,shift(b,i))      if dim(a)=1
;  c(i,j)=correlate(a,shift(b,i,j))  if dim(a)=2 
pro cor, a,b,c

s=size(a)

if (s(0) eq 1) then begin
s1=s(1)
c=fltarr(s1,/nozero)
for i=0, s1-1 do begin
c(i)=correlate(a,shift(b,i))
endfor
plot,c
endif

if (s(0) eq 2) then begin
s1=s(1)
s2=s(2)
c=fltarr(s1,s2,/nozero)
for i=0, s1-1 do begin
for j=0, s2-1 do begin
c(i,j)=correlate(a,shift(b,i,j))
endfor
endfor
endif
return
end
