pro rd1seq1,fil,t0,step,t,auf,suffix=suffix,verbose=verbose,_extra=extra,err=err
if not(keyword_set(suffix))then suffix=' '
if not(keyword_set(verbose))then verbose=0  
filename=strcompress(fil+String(t0)+suffix,/remove_all)
rd1,filename,au1,err=err,_extra=extra
if(err eq 0)then begin
  if(verbose eq  1) then print,filename
endif else begin
  return
endelse
ss=size(au1)
num=(t-t0)/step
ss1=ss(1)
n=ss1*(num+1)
auf=replicate(au1(0),n)
auf(0:ss1-1)=au1
for i=1l, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
  rd1,filename,au1,err=err,_extra=extra 
  if(err eq 0)then begin
     if(verbose eq  1) then print,filename
     auf(i*ss1:(i+1)*ss1-1)=au1
  endif else begin
     auf=auf(0:(i*ss1-1))
     t=t0+(i-1)*step
     err=0
     return
  endelse
endfor
return
end 
 
