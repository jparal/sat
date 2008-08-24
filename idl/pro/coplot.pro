pro coplot, x,y,lev=lev,color=color,z,_EXTRA=extra
if (not(keyword_set(color)) and not(keyword_set(lev))) then begin
   plot,x,y
   return
endif
ss=size(lev)
init=0
for i=0,ss(1)-2 do begin
  x1=lev(i)
  x2=lev(i+1)
  ii=where( z ge x1 and z lt x2 )
  ss=size(ii)
  if (ss(0) ge 1) then begin
    jjj=findgen(ss(1))
    ipre=ii(0)
    jjj(0)=0
    for jj=1,ss(1)-1 do begin
      if(ii(jj) eq ipre + 1)then begin
         jjj(jj)=jjj(jj-1)
      endif else begin
         jjj(jj)=jjj(jj-1)+1
      endelse
      ipre=ii(jj)
    endfor
    for jj=0,jjj(ss(1)-1)do begin
      iii=where(jjj eq jj)
      i1=min(ii(iii))
      if(i1 gt 0)then i1=i1-1
      i2=max(ii(iii))    
      oplot,x(i1:i2),y(i1:i2),color=color(i),_EXTRA=extra
    endfor
  endif
endfor
return
end 
