pro ovector, u, v, x,y ,length=length,color=color,value=value$
,xrange=xrange,yrange=yrange_EXTRA=extra
if(not(keyword_set(length)))then length=1.
if(not(keyword_set(color)))then color=1
if(not(keyword_set(value)))then value=0.00001
if(not(keyword_set(xrange)))then xrange=[min(x),max(x)]
if(not(keyword_set(yrange)))then yrange=[min(y),max(y)]
ss=size(u)
ssc=size(color)
for i=0,ss(1)-1 do begin
  for j=0,ss(2)-1 do begin
    x0=x(i)
    y0=y(j)
    x1=x(i)+length*u(i,j)
    y1=y(j)+length*v(i,j)
    if(sqrt(u(i,j)^2+v(i,j)^2) gt value and  $
      x0 gt xrange(0) and x0 lt xrange(1) and $
      y0 gt yrange(0) and y0 lt yrange(1) and $
      x1 gt xrange(0) and x1 lt xrange(1) and $
      y1 gt yrange(0) and y1 lt yrange(1) )then begin
      if(ssc(0) eq 2) then begin
        arrow, x0,y0,x1,y1,/data,color=color(i,j) 
      endif else begin
        arrow, x0,y0,x1,y1,/data,color=color
      endelse
    endif
  endfor
endfor
return
end
