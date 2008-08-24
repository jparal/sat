pro rd2seq2,fil,t0,step,t,auf,complex=complex,double=double,sufix=sufix,$
compress=compress
if(n_elements(complex) le 0) then complex=0
if(n_elements(double) le 0) then double=0
if not(keyword_set(compress))then compress=0
if(not(keyword_set(sufix))) then sufix=' '
if(compress eq 1)then sufix=sufix+'.gz'
 filename=strcompress(fil+String(t0)+sufix,/remove_all)          
if(fexist(filename,first=first))then begin
   rd2,first,au1,complex=complex,double=double,compress=compress
endif else begin
   return
endelse
ss=size(au1)
num=(t-t0)/step
if (complex eq 0) then begin
  if(double eq 0) then begin
   auf=fltarr(ss(1),ss(2)*(num+1))
  endif else begin
   auf=dblarr(ss(1),ss(2)*(num+1))
  endelse
endif else begin
  if(double eq 0) then begin
    auf=complexarr(ss(1),ss(2)*(num+1))
  endif else begin
    auf=dcomplexarr(ss(1),ss(2)*(num+1))
  endelse
endelse
auf(*,0:ss(2)-1)=au1
for i=1, num do begin
filename=strcompress(fil+String(t0+i*step)+sufix,/remove_all)
  if(fexist(filename,first=first))then begin
     rd2,first,au1,complex=complex,double=double,compress=compress
     auf(*,(i*ss(2)):((i+1)*ss(2)-1))=au1
  endif else begin
     auf=auf(*,0:(i*ss(2)-1))
     return
  endelse
endfor
return
end 
