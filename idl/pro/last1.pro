pro last1,fil,t0,step,t,auf,suffix=suffix,$
complex=complex,double=double
if not(keyword_set(suffix))then suffix=' '
if(n_elements(complex) le 0) then complex=0
if(n_elements(double) le 0) then double=0
fil=strcompress(fil,/remove_all)
len= strlen(fil)
filename='                                          '
strput,filename,fil,1
strput,filename,String(t0)+suffix,len+5  
if(fexist(strcompress(filename,/remove_all),first=first))then begin
   prev=first
endif else begin
   return
endelse
num=(t-t0)/step
for i=1, num do begin
  strput,filename,String(t0+i*step)+suffix,len+5          
  if(fexist(strcompress(filename,/remove_all),first=first))then begin
     prev=first
  endif else begin
     rd1,prev,auf,complex=complex,double=double
     return
  endelse
endfor
rd1,prev,auf,complex=complex,double=double
return
end 


 
