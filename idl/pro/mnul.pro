pro mnul, a, b, level=level, value=value
if(not(keyword_set(value)))then value=0.
if(not(keyword_set(level)))then level=.1
ss=size(a)
sb=size(b)
if(ss(0) eq 3)then begin
for i=0,ss(1)-1 do begin
for j=0,ss(2)-1 do begin
for k=0,ss(3)-1 do begin
if(sb(0) eq 3)then begin
if(a(i,j,k) lt level) then b(i,j,k) = value 
endif
if(sb(0) eq 4)then begin
if(a(i,j,k) lt level) then b(i,j,k,*) = value
endif
endfor
endfor
endfor
endif

if(ss(0) eq 2)then begin
for i=0,ss(1)-1 do begin
for j=0,ss(2)-1 do begin
if(a(i,j) lt level) then b(i,j) = value
endfor
endfor
endif

return
end
