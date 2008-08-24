pro rd3seqxy,fil,t0,step,t,auf,verbose=verbose,compress=compress,suffix=suffix
  if(not(keyword_set(verbose))) then verbose=0
  if(not(keyword_set(suffix))) then suffix=' '
  if(not(keyword_set(compress))) then compress=0
  if(compress eq 1)then suffix=suffix+'.gz'

  filename=strcompress(fil+String(t0)+suffix,/remove_all)          
  if(fexist(filename,first=first))then begin
     if(verbose eq  1) then print,first
     rd3,first,au1,compress=compress
  endif else begin
     return
  endelse
  ss=size(au1)
  num=(t-t0)/step
  auf=fltarr(ss(1),ss(2),num+1)
  auf(*,*,0)=reform(au1(*,*,ss(3)/2))

  for i=1, num do begin
     filename=strcompress(fil+String(t0+i*step)+suffix,/remove_all)
     if(fexist(filename,first=first))then begin
        if(verbose eq  1) then print,first
        rd3,first,au1,compress=compress
        auf(*,*,i)=reform(au1(*,*,ss(3)/2))
     endif else begin
        auf=auf(*,*,*,0:i-1)
        return
     endelse
  endfor

  return
end
 
