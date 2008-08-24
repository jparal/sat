pro cutoff, a
ss=size(a)
if(ss(0) eq 1) then a=a(1:*)
if(ss(0) eq 2) then a=a(1:*,1:*)
if(ss(0) eq 3) then a=a(1:*,1:*,1:*)
return
end
