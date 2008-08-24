;   c(i)=correlate(a,shift(b,0,i)) if dim(a)=2 and if dim(a)=3
;c(i,j)=correlate(reform(a(i,*,*)),shift(reform(b(i,*,*)),0,j))
pro cor12, a,b,c

s=size(a)
if (s(0) eq 2)then begin
s2=s(2)
c =fltarr(s2)
for i=0,s2-1 do begin
c(i)=correlate(a,shift(b,0,i))
endfor
endif
if (s(0) eq 3)then begin
s1=s(1)
s3=s(3)
c =fltarr(s1,s3)
for i=0,s1-1 do begin
for j=0,s3-1 do begin
c(i,j)=correlate(reform(a(i,*,*)),shift(reform(b(i,*,*)),0,j))
endfor
endfor
endif
return
end
