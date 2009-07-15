pro rds,fil,t0,step,t,auf,suffix=suffix,verbose=verbose,_extra=extra,concat=concat
if not(keyword_set(suffix))then suffix=' '
if not(keyword_set(verbose))then verbose=0
if not(keyword_set(concat))then concat=0

filename=strcompress(fil+String(t0)+suffix,/remove_all)
rd,filename,auf,err=err,_extra=extra


if(err eq 0)then begin
   if(verbose ne 0)then print,filename
endif else begin
   print,'error on',filename
   return
endelse
ss=size(auf)
dconcat=ss(0)+1-concat

num=(t-t0)/step

for i=1l, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)          
  rd,filename,au1,err=err,_extra=extra
  if(err eq 0)then begin
     if(verbose ne 0)then print,filename
     if(dconcat eq 1)then begin 
       auf=[auf, au1]
     endif else begin
       if (dconcat eq 2)then begin
         auf=[[auf],[au1]]  
       endif else begin
         if (dconcat eq 3)then begin
           auf=[[[auf]],[[au1]]]
         endif else begin
;           auf=[[[[auf]]],[[[au1]]]]
         endelse
       endelse  
     endelse
  endif else begin
    t=t0+(i-1)*step
    return
  endelse
endfor
return
end 

