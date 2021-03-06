;-------------------------------------------------------------
;+
; NAME:
;       ANNCRV
; PURPOSE:
;       Interactively draw curves on screen with mouse. Annotate.
; CATEGORY:
; CALLING SEQUENCE:
;       anncrv
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set line color (0-255).
;         LINESTYLE=s set line style (0-5).
;         THICK=t set line thickness.
;         XA=x Returned x array of all points in ann memory.
;         YA=y Returned y array of all points in ann memory.
;         PENA=p Returned pen code of all points in ann memory.
;           0=pen up, 1=pen down.
;           Remember to do annres to clear memory before starting.
;           Returned x and y are in normalized coordinates, can
;           use convert_coord to convert to data coordinates.
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools.
;         Results of these tools may be saved, recalled,
;         and repeated later.
;         Do annhlp for more info on the annotate tools.
; MODIFICATION HISTORY:
;       R. Sterner, 23 Oct, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro anncrv, help=hlp, color=color, linestyle=linestyle, thick=thick, $
	  xa=xa, ya=ya, pena=pena
 
	common ann_com, x, y, pen, clr, sty, thk, ntxt, tx, ty, tc, ts, ta, $
	  tt, txt, onechar, pfx, pfy, pfpen, pfclr, pfthk, pfsty, pffc
	; Annotation tool common: --------------------------------------------
	; Lines: x,y = arrays of x,y coordinates.  Pen = pen code.           |
	;        clr = line color, sty = line style, thk = line thickness.   |
	; Text:  tx,ty = text position.  tc,ts,ta = text color, size, angle. |
	;        tt = thickness.  txt = text strings.  ntxt = # text strings.|
	;        onechar = norm. size of 1 char on original device.          |
	; Polyfill: pfx,pfy = polyfill points, pfpen = polyfill pen code,    |
	;        pfclr,pfthk,pfsty = polyfill outline color, thick, style,   |
	;        pffc = polyfill fill color.                                 |
	;---------------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Interactively draw curves on screen with mouse. Annotate.'
	  print,' anncrv'
	  print,'   Left button - new segment.'
	  print,'   Middle button - delete segment.'
	  print,'   Right button - quit curve.'
	  print,' Keywords:'
	  print,'   COLOR=c set line color (0-255).'
	  print,'   LINESTYLE=s set line style (0-5).'
	  print,'   THICK=t set line thickness.'
	  print,'   XA=x Returned x array of all points in ann memory.'
	  print,'   YA=y Returned y array of all points in ann memory.'
	  print,'   PENA=p Returned pen code of all points in ann memory.'
	  print,'     0=pen up, 1=pen down.'
	  print,'     Remember to do annres to clear memory before starting.'
	  print,'     Returned x and y are in normalized coordinates, can'
	  print,'     use convert_coord to convert to data coordinates.'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  return
	endif
 
	;---------  Make sure parameters set  ---------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(x) eq 0 then annres		; Reset memory arrays.
	m = 0
 
	print,' '
	print,' When done drawing do a quit without entering any points.'
 
loop:	drawpoly, xp, yp, /norm, /curve, linestyle=linestyle, $
	  color=color, thick=thick
 
	if n_elements(xp) lt 2 then return
 
	x = [x,xp]
	y = [y,yp]
	p = fix(xp*0 + 1)
	p(0) = 0
	pen = [pen, p]
	clr = [clr, color]
	sty = [sty, linestyle]
	thk = [thk, thick]
	print,' Curve added to memory.'
	xa = x(1:*)
	ya = y(1:*)
	pena = pen(1:*)
 
	goto, loop
 
	end
