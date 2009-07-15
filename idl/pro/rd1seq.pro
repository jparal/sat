pro rd1seq,fil,t0,step,t,auf,suffix=suffix,verbose=verbose,_extra=extra
if not(keyword_set(suffix))then suffix=' '
if not(keyword_set(verbose))then verbose=0
filename=strcompress(fil+String(t0)+suffix,/remove_all)
rd1,filename,au1,err=err,_extra=extra
if(err eq 0)then begin
   if(verbose ne 0)then print,filename
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
auf=replicate(au1(0),ss(1),num+1)
auf(*,0)=au1    
ip=1
for i=1l, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)          
  rd1,filename,au1,err=err,_extra=extra
  if(err eq 0)then begin
     if(verbose ne 0)then print,filename
     auf(*,i)=au1
  endif else begin
     auf=auf(*,0:i-1)
	   t=t0+(i-1)*step
     return
  endelse
endfor
return
end 


 
