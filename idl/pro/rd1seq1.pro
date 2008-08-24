pro rd1seq1,fil,t0,step,t,auf,suffix=suffix,$
complex=complex,double=double,verbose=verbose,compress=compress
if not(keyword_set(suffix))then suffix=' '
if(n_elements(complex) le 0) then complex=0
if(n_elements(double) le 0) then double=0
if not(keyword_set(verbose))then verbose=0  
if not(keyword_set(compress))then compress=0
if(compress eq 1)then suffix=suffix+'.gz'
filename=strcompress(fil+String(t0)+suffix,/remove_all)
if(fexist(filename,first=first))then begin
   if(verbose eq  1) then print,first
   rd1,first,au1,complex=complex,double=double,compress=compress
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
ss1=ss(1)
n=ss1*(num+1)
if (complex eq 0) then begin
  if(double eq 0) then begin
   auf=fltarr(n)
  endif else begin
   auf=dblarr(n)
  endelse
endif else begin
  if(double eq 0) then begin
    auf=complexarr(n)
  endif else begin
    auf=dcomplexarr(n)
  endelse
endelse
auf(0:ss1-1)=au1
for i=1, num do begin
filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
  if(fexist(filename,first=first))then begin
     if(verbose eq  1) then print,first
     rd1,first,au1,complex=complex,double=double,compress=compress
     auf(i*ss1:(i+1)*ss1-1)=au1
  endif else begin
     auf=auf(0:(i*ss1-1))
     t=t0+(i-1)*step
     return
  endelse
endfor
return
end 


 
