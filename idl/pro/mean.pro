; gives mean value of array A
;
function mean, a
ss=size(a)
mm=a
if(ss(0) ge 1) then begin
  mm=total(a)
  for i=1, ss(0) do begin
    mm=mm/ss(i)
  endfor
endif
return,mm
end
