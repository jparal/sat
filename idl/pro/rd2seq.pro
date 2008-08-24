pro rd2seq,fil,t0,step,t,auf,complex=complex,double=double,verbose=verbose,$
suffix=suffix,compress=compress
fil=strcompress(fil,/remove_all)
if(n_elements(complex) le 0) then complex=0
if(n_elements(double) le 0) then double=0
if(not(keyword_set(verbose))) then verbose=0
if(not(keyword_set(suffix))) then suffix=' '
if not(keyword_set(compress))then compress=0
if(compress eq 1)then suffix=suffix+'.gz'
filename=strcompress(fil+String(t0)+suffix,/remove_all)         
if(fexist(filename,first=first))then begin
   if(verbose eq  1) then print,first
   rd2,first,au1,complex=complex,double=double,compress=compress
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
if (complex eq 0) then begin
  if(double eq 0) then begin
   auf=fltarr(ss(1),ss(2),num+1)
  endif else begin
   auf=dblarr(ss(1),ss(2),num+1)
  endelse
endif else begin
  if(double eq 0) then begin
    auf=complexarr(ss(1),ss(2),num+1)
  endif else begin
    auf=dcomplexarr(ss(1),ss(2),num+1)
  endelse
endelse
auf(*,*,0)=au1
for i=1, num do begin
 filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
  if(fexist(filename,first=first))then begin
     if(verbose eq  1) then print,first
     rd2,first,au1,complex=complex,double=double,compress=compress
     auf(*,*,i)=au1
  endif else begin
     auf=auf(*,*,0:i-1)
     return
  endelse
endfor
return
end 

