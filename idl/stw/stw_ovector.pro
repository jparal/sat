;--------------------------------------------------------------------;
; (OVER)PLOTS VECTORS OVER AN CONTOUR PLOT                           ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 08/2006, v.0.4.141: Arowheads now have the same size.            ;
;   Adding "maxlen" and "normalise" parameters.                      ;
; - 08/2006, v.0.4.140: Sytax bug fixes made.                        ;
;--------------------------------------------------------------------;
pro stw_ovector, u, v, x, y, $
  length=length,color=color,value=value,$
  xrange=xrange,yrange=yrange,hsize=hsize, $
  maxlen=maxlen, normalise=normalise, $
  EXTRA=extra

;-----------------------------------------------------------;
; Setup default values if all parameters are not set        ;
; Note, that setting a keyword to ZERO value by the caller  ;
; means that the keyword is not set!                        ;
;-----------------------------------------------------------;
if not (stw_keyword_set(length)) then length = 1.
if not (stw_keyword_set(color))  then color  = 1
if not (stw_keyword_set(value))  then value  = 0.00001
if not (stw_keyword_set(xrange)) then xrange = [min(x),max(x)]
if not (stw_keyword_set(yrange)) then yrange = [min(y),max(y)]
if not (stw_keyword_set(hsize))  then hsize  = -0.4

ss=size(u)
ssc=size(color)

for i=0,ss(1)-1 do begin
  for j=0,ss(2)-1 do begin

    x0 = x(i)
    y0 = y(j)
    dx = length*u(i,j)
    dy = length*v(i,j)

    if (stw_keyword_set(normalise)) then begin
      dd=sqrt(dx^2+dy^2)
      if (dd gt 0.01) then begin
        dx = dx / dd
        dy = dy / dd
      endif
    endif

    if (stw_keyword_set(maxlen)) then begin
      dd=sqrt(dx^2+dy^2)
      if (dd gt maxlen and maxlen gt 0.) then begin
        dx = dx / dd * maxlen
        dy = dy / dd * maxlen
      endif
    endif

    x1 = x(i) + dx
    y1 = y(j) + dy

    if(sqrt(u(i,j)^2+v(i,j)^2) gt value and $
      x0 gt xrange(0) and x0 lt xrange(1) and $
      y0 gt yrange(0) and y0 lt yrange(1) and $
      x1 gt xrange(0) and x1 lt xrange(1) and $
      y1 gt yrange(0) and y1 lt yrange(1) )then begin

      ;------------------------------------------------------;
      ; ARROW: (x0,y0) is the start point                    ;
      ;        (x1,y1) is the endpoint                       ;
      ;                                                      ;
      ; All values are given (!) in the units on axises      ;
      ; Downscalling to planetary radius means, that we      ;
      ; shall end up with long vectors if their "length"     ;
      ; has been given on "finner" mesh.                     ;
      ;                                                      ;
      ; HSIZE - this keyword to set the length of the        ;
      ; lines used to draw the arrowhead. The default is     ;
      ; 1/64th the width of the display (!D.X_SIZE / 64.).   ;
      ; If the HSIZE is positive, the value is assumed to    ;
      ; be in device coordinate units. If HSIZE is negative, ;
      ; the arrowhead length is set to the vector            ;
      ; "length * ABS(HSIZE)". The lines are separated       ;
      ; by 60 degrees to make the arrowhead.                 ;
      ;------------------------------------------------------;
      if (ssc(0) eq 2) then begin

        arrow, x0, y0, x1, y1, /data, color=color(i,j), $
          hsize=hsize

      endif else begin

        xx=x1-x0
        yy=y1-y0
        len=sqrt(xx^2+yy^2)
        if (len lt 0.01) then len = 0.01
        arrow, x0, y0, x1, y1, /data, color=color, $
          hsize=hsize/len

      endelse
    endif

  endfor
endfor

return
end
