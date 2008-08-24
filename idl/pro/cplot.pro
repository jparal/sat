pro cplot, x,y,lev=lev,color=color,z,_EXTRA=extra
if (not(keyword_set(color)) and not(keyword_set(lev))) then begin
   plot,x,y
   return
endif
plot,x,y,/nodata,_EXTRA=extra
ss=size(lev)
init=0
for i=0,ss(1)-2 do begin
  x1=lev(i)
  x2=lev(i+1)
  ii=where( z ge x1 and z lt x2 )
  ss=size(ii)
  if (ss(0) ge 1) then begin
    oplot,x(ii),y(ii),color=color(i),_EXTRA=extra
  ;to make it smooth
    lev(i+1)=max(z(ii))
  endif
endfor
return
end 
