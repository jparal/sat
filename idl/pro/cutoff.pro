pro cutoff, a, time=time 
if (not(keyword_set(time)))then time=0
ss=size(a)
if(time eq 0) then begin
  if(ss(0) eq 1) then a=a(1:*)
  if(ss(0) eq 2) then a=a(1:*,1:*)
  if(ss(0) eq 3) then a=a(1:*,1:*,1:*)
endif else begin
  if(ss(0) eq 2) then a=a(1:*,*)
  if(ss(0) eq 3) then a=a(1:*,1:*,*)
endelse
return
end
