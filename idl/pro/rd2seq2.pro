pro rd2seq2,fil,t0,step,t,auf,err=err,suffix=suffix,verbose=verbose,_extra=extra
if(not(keyword_set(suffix))) then suffix=' '
if(not(keyword_set(verbose))) then verbose=0
filename=strcompress(fil+String(t0)+suffix,/remove_all)          
rd2,filename,au1,err=err,_extra=extra
if(err eq 0)then begin
  if(verbose eq 1)then print, filename
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
auf=replicate(au1(0),ss(1),ss(2)*(num+1))
auf(*,0:ss(2)-1)=au1
for i=1l, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
  rd2,filename,au1,err=err,_extra=extra
  if(err eq 0)then begin
     auf(*,(i*ss(2)):((i+1)*ss(2)-1))=au1
     if(verbose eq 1)then print, filename
  endif else begin
     auf=auf(*,0:(i*ss(2)-1))
     return
  endelse
endfor
return
end 
