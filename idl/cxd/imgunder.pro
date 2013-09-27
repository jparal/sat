;-------------------------------------------------------------
;+
; NAME:
;       IMGUNDER
; PURPOSE:
;       Display image in same area as last plot.
; CATEGORY:
; CALLING SEQUENCE:
;       imgunder, z
; INPUTS:
;       z = scaled byte image to display.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /INTERP causes bilinear interpolation to be used,
;           otherwise nearest neighbor interpolation is used.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Do plot,/nodata first to setup plot area,
;         then use imgunder to display image, then repeat
;         plot with data, but with /noerase.
; MODIFICATION HISTORY:
;       R. Sterner, 15 Feb, 1991
;       R. Sterner,  2 Dec, 1993 --- Added /minus_one to congrid call.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro imgunder, z, interp=interp, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display image in same area as last plot.'
	  print,' imgunder, z'
	  print,'   z = scaled byte image to display.  in'
	  print,' Keywords:'
	  print,'   /INTERP causes bilinear interpolation to be used,'
	  print,'     otherwise nearest neighbor interpolation is used.'
	  print,' Notes: Do plot,/nodata first to setup plot area,'
	  print,'   then use imgunder to display image, then repeat'
	  print,'   plot with data, but with /noerase.'
	  return
	endif
 
	if !d.name ne 'PS' then begin
	  xx = !x.window*!d.x_size
	  yy = !y.window*!d.y_size
	  dx = xx(1) - xx(0)
	  dy = yy(1) - yy(0)
	  tv, congrid(z, dx, dy, interp=interp,/minus_one), xx(0), yy(0)
	endif else begin
	  xx = !x.window*!d.x_size/!d.x_px_cm
	  yy = !y.window*!d.y_size/!d.y_px_cm
	  dx = xx(1) - xx(0)
	  dy = yy(1) - yy(0)
	  tv, z, xx(0), yy(0), xsize=dx, ysize=dy, /cent
	endelse
 
	return
	end
 
