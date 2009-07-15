pro rd2of3seq,fil,t0,step,t,auf,verbose=verbose,suffix=suffix,$
compress=compres,x=x,n=n
if(not(keyword_set(verbose))) then verbose=0
if(not(keyword_set(x))) then x=2
if(not(keyword_set(n))) then n=0
if(not(keyword_set(compress))) then compress=0
if(not(keyword_set(suffix))) then suffix=' '
if(compress eq 1)then suffix=suffix+'.gz'
filename=strcompress(fil+String(t0)+suffix,/remove_all)          
if(fexist(filename,first=first))then begin
   if(verbose eq  1) then print,first
   rd3,first,au1
   ss=size(au1)
   if(ss(x+1) le n) then begin 
      n=0
      print,'n too great, set to 0'
   endif
   if(x eq 0)then au1=reform(au1(n,*,*))
   if(x eq 1)then au1=reform(au1(*,n,*))
   if(x eq 2)then au1=reform(au1(*,*,n))
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
auf=fltarr(ss(1),ss(2),num+1)
auf(*,*,0)=au1
for i=1l, num do begin
filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
  if(fexist(filename,first=first))then begin
     if(verbose eq  1) then print,first
     rd3,first,au1
   if(x eq 0)then auf(*,*,i)=reform(au1(n,*,*))
   if(x eq 1)then auf(*,*,i)=reform(au1(*,n,*))
   if(x eq 2)then auf(*,*,i)=reform(au1(*,*,n))
  endif else begin
     auf=auf(*,*,0:i-1)
     return
  endelse
endfor
return
end 
 
