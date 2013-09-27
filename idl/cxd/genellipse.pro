;-------------------------------------------------------------
;+
; NAME:
;       GENELLIPSE
; PURPOSE:
;       Generate points on an ellipse.
; CATEGORY:
; CALLING SEQUENCE:
;       genellipse, xm, ym, ang, a, b, x, y, z
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  10 june, 1986.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro genellipse, xm, ym , ang, a, b, x, y, z, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Generate points on an ellipse.'
	  print,' genellipse, xm, ym, ang, a, b, x, y, z'
	  print,'   xm, ym = Center of ellipse.
	  print,'   ang = Angle of ellipse.
	  print,'   a, b = Semi-axes.
	  print,'   x, y = Ellipse points.
	  return
	endif
 
	ap = makex(0, 2*!pi, !pi/36.)
 
	xt = a*cos(ap)
	yt = b*sin(ap)
 
	x2 = [a, -a, 0,  0,  0]
	y2 = [0,  0, 0,  b, -b]
 
	xt = [xt,x2]
	yt = [yt,y2]
 
	cs = cos(ang/!radeg)
	sn = sin(ang/!radeg)
 
	x = xt*cs - yt*sn
	y = xt*sn + yt*cs
 
	x = x + xm
	y = y + ym
 
	z = intarr(n_elements(x)-4) + 1
	z(0) = 0
	z = [z,0,1,0,1]
 
	return
	end
