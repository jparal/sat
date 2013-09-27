;-------------------------------------------------------------
;+
; NAME:
;       POINTS
; PURPOSE:
;       Convert from character size in points to IDL charsize.
; CATEGORY:
; CALLING SEQUENCE:
;       sz = points(n)
; INPUTS:
;       n = character size in points (1/72 inch).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       sz = Value for IDL charsize.               out
; COMMON BLOCKS:
; NOTES:
;       Notes: Should be very close for PS Helvetica.
;         Not well tested with other fonts.  Assumes
;         character font size is the distance in points
;         from the bottom of the descenders to the top
;         of capital letters in units of 1/72 ".
; MODIFICATION HISTORY:
;       R. Sterner, 27 Jul, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function points, x, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert from character size in points to IDL charsize.'
	  print,' sz = points(n)'
	  print,'   n = character size in points (1/72 inch).  in'
	  print,'   sz = Value for IDL charsize.               out'
	  print,' Notes: Should be very close for PS Helvetica.'
	  print,'   Not well tested with other fonts.  Assumes'
	  print,'   character font size is the distance in points'
	  print,'   from the bottom of the descenders to the top'
	  print,'   of capital letters in units of 1/72 ".'
	  return,-1
	endif
 
	fx = 0.906*x - 0.59		; Fudged x.
	return, fx/(!d.y_ch_size/!d.y_px_cm*72./2.54)
	end
