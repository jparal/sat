pro rdsav,fil,t0,step,t,auf,suffix=suffix,verbose=verbose,_extra=extra
if not(keyword_set(suffix))then suffix=' '
if not(keyword_set(verbose))then verbose=0
filename=strcompress(fil+String(t0)+suffix,/remove_all)
rd,filename,au1,err=err,_extra=extra
if(err eq 0)then begin
   if(verbose ne 0)then print,filename
endif else begin
   return
endelse
num=(t-t0)/step
auf=mean(au1)
for i=1l, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)          
  rd1,filename,au1,err=err,_extra=extra
  if(err eq 0)then begin
     if(verbose ne 0)then print,filename
     auf=[auf,mean(au1)]
  endif else begin
	   t=t0+(i-1)*step
     return
  endelse
endfor
return
end 


 
