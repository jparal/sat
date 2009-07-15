pro reduce, a, nred=nred
if(not(keyword_set(nred)))then nred=10l
ss=size(a)
if(ss(0) eq 1) then begin
  dim=ss(1)/nred
  b=replicate(a(0),dim)
  for i=0l, dim-1 do begin
    b(i)=a((i+1)*nred-1)
  endfor
  a=b
endif
if(ss(0) eq 2) then begin
  dim=ss(1)/nred
  b=replicate(a(0),dim,ss(2))
  for i=0l, dim-1 do begin
    b(i,*)=a((i+1)*nred-1,*)
  endfor
  a=b
endif
return
end
