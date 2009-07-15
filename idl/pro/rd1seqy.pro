pro rd1seqy,fil,t0,step,t,auf,suffix=suffix,complex=complex,double=double,$
compress=compress
if not(keyword_set(suffix))then suffix=' '
if(n_elements(complex) le 0) then complex=0
if(n_elements(double) le 0) then double=0
if not(keyword_set(compress))then compress=0
if(compress eq 1)then suffix=suffix+'.gz'
filename=strcompress(fil+String(t0)+suffix,/remove_all)
if(fexist(filename,first=first))then begin
   rd2,first,au1,complex=complex,double=double,compress=compress
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
ss1=ss(2)
if (complex eq 0) then begin
  if(double eq 0) then begin
   auf=fltarr(ss1,(num+1))
  endif else begin
   auf=dblarr(ss1,(num+1))
  endelse
endif else begin
  if(double eq 0) then begin
    auf=complexarr(ss1,(num+1))
  endif else begin
    auf=dcomplexarr(ss1,(num+1))
  endelse
endelse
auf(*,0)=au1(0,*)    
ip=1
for i=1, num do begin
  filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)          
  if(fexist(filename,first=first))then begin
     rd2,first,au1,complex=complex,double=double,compress=compress
     auf(*,i)=au1(0,*)
  endif else begin
  filename=strcompress(fil+String(t0+i*step),/remove_all)
  if(fexist(filename,first=first))then begin
     rd2,first,au1,complex=complex,double=double
     auf(*,i)=au1(0,*)
     endif else begin
       auf=auf(*,0:i-1)
       return
     endelse
  endelse
endfor
return
end 


 
