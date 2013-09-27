;-------------------------------------------------------------
;+
; NAME:
;       PSIMG
; PURPOSE:
;       Display an image on postscript printer.
; CATEGORY:
; CALLING SEQUENCE:
;       psimg, img
; INPUTS:
;       img = image to display.       in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: img must be correctly scaled,
;         tv is used (not tvscl).  psimg displays
;         image at maximum size that shows entire image
;         in the page window.
; MODIFICATION HISTORY:
;       R. Sterner, 28 Aug, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro psimg, img, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display an image on postscript printer.'
	  print,' psimg, img'
	  print,'   img = image to display.       in'
	  print,' Notes: img must be correctly scaled,'
	  print,'   tv is used (not tvscl).  psimg displays'
	  print,'   image at maximum size that shows entire image'
	  print,'   in the page window.'
	  return
	endif
 
	sz = size(img)
	nx = float(sz(1))
	ny = float(sz(2))
 
	px = !d.x_size/!d.x_px_cm
	py = !d.y_size/!d.y_px_cm
 
	y = py
	x = py*nx/ny
	if x gt px then begin
	  x = px
	  y = px*ny/nx
	endif
 
	tv, img, xsize=x, ysize=y, /cent
 
	return
	end
