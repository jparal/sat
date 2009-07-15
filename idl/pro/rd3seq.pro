pro rd3seq,fil,t0,step,t,auf,verbose=verbose,suffix=suffix,_extra=extra
if(not(keyword_set(verbose))) then verbose=0
if(not(keyword_set(suffix))) then suffix=' '
filename=strcompress(fil+String(t0)+suffix,/remove_all)          
rd3,filename,au1,err=err,_extra=extra
if(err eq 0)then begin
   if(verbose eq  1) then print,first
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
auf=replicate(au1(0),ss(1),ss(2),ss(3),num+1)
auf(*,*,*,0)=au1
for i=1l, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
  rd3,filename,au1,err=err,_extra=extra
  if(err eq 0)then begin
     if(verbose eq  1) then print,filename
     auf(*,*,*,i)=au1
  endif else begin
     auf=auf(*,*,*,0:i-1)
     return
  endelse
endfor
return
end 
 
