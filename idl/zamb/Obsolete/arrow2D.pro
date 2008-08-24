PRO ARROW2D, x0, y0, x1, y1, HSIZE = hsize, COLOR = color, HTHICK = hthick, $
	THICK = thick, DATA = data, DEVICE = device, NORMALIZED = norm, $
	SOLID = solid

if n_elements(thick) eq 0 then thick = 1.
if n_elements(hthick) eq 0 then hthick = thick

				;Head size in device units
if n_elements(hsize) eq 0 then arrowsize = !d.x_size/64. * (hthick/2. > 1) $
    else arrowsize = float(hsize)
if n_elements(color) eq 0 then color = !P.color

mcost = -.866		;We use 30 degrees for head angle
sint = .500
msint = - sint

for i = 0, n_elements(x0)-1 do begin		;Each vector
	if keyword_set(data) then $		;Convert?
	    p = convert_coord([x0[i],x1[i]],[y0[i],y1[i]], /data, /to_dev) $
	else if keyword_set(norm) then $
	    p = convert_coord([x0[i],x1[i]],[y0[i],y1[i]], /norm, /to_dev) $
	else p = [[x0[i], y0[i]],[x1[i], y1[i]]]

	xp0 = p[0,0]
	xp1 = p[0,1]
	yp0 = p[1,0]
	yp1 = p[1,1]

	dx = float(xp1-xp0)
	dy = float(yp1-yp0)
	zz = sqrt(dx^2 + dy^2)	;Length

	if zz gt 1e-6 then begin
		dx = dx/zz		;Cos th
		dy = dy/zz		;Sin th
	endif else begin
		dx = 1.
		dy = 0.
		zz = 1.
	endelse
	if arrowsize gt 0 then a = arrowsize $  ;a = length of head
	else a = -zz * arrowsize

	xxp0 = xp1 + a * (dx*mcost - dy * msint)
	yyp0 = yp1 + a * (dx*msint + dy * mcost)
	xxp1 = xp1 + a * (dx*mcost - dy * sint)
	yyp1 = yp1 + a * (dx*sint  + dy * mcost)

	if keyword_set(solid) then begin	;Use polyfill?
	  b = a * mcost*.9	;End of arrow shaft (Fudge to force join)
	  plots, [xp0, xp1+b*dx], [yp0, yp1+b*dy], /DEVICE, $
		COLOR = color, THICK = thick
	  polyfill, [xxp0, xxp1, xp1, xxp0], [yyp0, yyp1, yp1, yyp0], $
		/DEVICE, COLOR = color
	endif else begin
	  plots, [xp0, xp1], [yp0, yp1], /DEVICE, COLOR = color, THICK = thick
	  plots, [xxp0,xp1,xxp1],[yyp0,yp1,yyp1], /DEVICE, COLOR = color, $
			THICK = hthick
	endelse
	ENDFOR
end
