pro rdss,fil,t01,step1,t1,middle,t0,step,t,auf,verbose=verbose,_extra=extra,$
conc1=conc1,conc2=conc2
if not(keyword_set(verbose))then verbose=0
if not(keyword_set(conc1))then conc1=1
if not(keyword_set(conc2))then conc2=0

suffix=strcompress(middle+string(t0),/remov)
conc=conc1
rds,fil,t01,step1,t1,auf,suffix=suffix,err=err,_extra=extra,conc=conc
if(err eq 0) then begin
  if(verbose ne 0)then print,fil,suffix
endif else begin
  return
endelse
num=(t-t0)/step
for i=1l, num do begin
  suffix=strcompress(middle+string(t0+i*step),/remov)
  conc=conc1
  rds,fil,t01,step1,t1,au1,suffix=suffix,err=err,_extra=extra,conc=conc
  if(err eq 0)then begin
     if(verbose ne 0)then print,fil,suffix
     if(conc2 eq 1)then begin
       auf=[auf, au1]
     endif else begin
       auf=[[auf],[au1]]
     endelse
  endif else begin
	   t=t0+(i-1)*step
     return
  endelse
endfor
return
end 

