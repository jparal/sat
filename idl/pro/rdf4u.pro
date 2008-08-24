pro rdf4u,fil,num,t,auf
filename=strcompress(fil+'_pe00_'+string(t),/remove)
if(fexist(filename,first=first))then begin
   rd4u,first,au1
endif else begin
   return
endelse
ss=size(au1)
auf=fltarr(ss(1)*num,ss(2),ss(3),ss(4))
auf(0:ss(1)-1,*,*,*)=au1
for i=1, num-1 do begin
 if(i lt 10)then begin 
   filename=strcompress(fil+'_pe0'+string(i)+'_'+string(t),/remove)
 endif else begin
   filename=strcompress(fil+'_pe'+string(i)+'_'+string(t),/remove)
 endelse         
  if(fexist(filename,first=first))then begin
     rd2,first,au1
     auf((i*ss(1)):((i+1)*ss(1)-1),*,*,*)=au1
  endif else begin
     auf=auf(0:(i*ss(1)-1),*,*,*)
     return
  endelse
endfor
return
end 
