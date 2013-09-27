;-------------------------------------------------------------
;+
; NAME:
;       ARCS
; PURPOSE:
;       Plot specified arcs or circles on the current plot device.
; CATEGORY:
; CALLING SEQUENCE:
;       arcs, r, a1, a2, [x0, y0]
; INPUTS:
;       r = radii of arcs to draw (data units).                  in
;       [a1] = Start angle of arc (deg CCW from X axis, def=0).  in
;       [a2] = End angle of arc (deg CCW from X axis, def=360).  in
;       [x0, y0] = optional arc center (def=0,0).                in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means use device coordinates .
;         /DATA means use data coordinates (default).
;         /NORM means use normalized coordinates.
;         COLOR=c  plot color (scalar or array).
;         LINESTYLE=l  linestyle (scalar or array).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: all parameters may be scalars or arrays.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 12 July, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;       R. Sterner, 17 Jun, 1992 --- added coordinate systems, cleaned up.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro arcs, r, a1, a2, xx, yy, help=hlp,$
	  color=clr, linestyle=lstyl, $
	  device=device, data=data, norm=norm
 
 	np = n_params(0)
	if (np lt 1) or keyword_set(hlp) then begin
	  print,' Plot specified arcs or circles on the current plot device.'
	  print,' arcs, r, a1, a2, [x0, y0]'
	  print,'   r = radii of arcs to draw (data units).                  in'
	  print,'   [a1] = Start angle of arc (deg CCW from X axis, def=0).  in'
	  print,'   [a2] = End angle of arc (deg CCW from X axis, def=360).  in'
	  print,'   [x0, y0] = optional arc center (def=0,0).                in'
	  print,' Keywords:'
          print,'   /DEVICE means use device coordinates .'
          print,'   /DATA means use data coordinates (default).'
          print,'   /NORM means use normalized coordinates.'
	  print,'   COLOR=c  plot color (scalar or array).'
	  print,'   LINESTYLE=l  linestyle (scalar or array).'
	  print,' Note: all parameters may be scalars or arrays.'
	  return
	endif
 
        ;------  Determine coordinate system  -----
        if n_elements(device) eq 0 then device = 0    ; Define flags.
        if n_elements(data)   eq 0 then data   = 0
        if n_elements(norm)   eq 0 then norm   = 0
        if device+data+norm eq 0 then data = 1        ; Default to data.
 
 
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(lstyl) eq 0 then lstyl = !p.linestyle
 
 	if np lt 2 then a1 = 0.
 	if np lt 3 then a2 = 360.
	if np lt 4 then xx = 0.
	if np lt 5 then yy = 0.
 
	nr = n_elements(r)-1		; Array sizes.
	na1 = n_elements(a1)-1
	na2 = n_elements(a2)-1
	nxx = n_elements(xx)-1
	nyy = n_elements(yy)-1
	nclr = n_elements(clr)-1
	nlstyl = n_elements(lstyl)-1
	n = nr>na1>na2>nxx>nyy		; Overall max.
 
	for i = 0, n do begin   	; loop thru arcs.
	  ri  = r(i<nr)			; Get r, a1, a2.
	  a1i = a1(i<na1)
	  a2i = a2(i<na2)
	  xxi = xx(i<nxx)
	  yyi = yy(i<nyy)
	  clri = clr(i<nclr)
	  lstyli = lstyl(i<nlstyl)
	  a = makex(a1i, a2i, 0.25*sign(a2i-a1i))/!radeg
	  polrec, ri, a, x, y
	  plots, x + xxi, y + yyi, color=clri, linestyle=lstyli, $
	    data=data, device=device, norm=norm
	endfor
 
	return
 
	end
