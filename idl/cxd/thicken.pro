;-------------------------------------------------------------
;+
; NAME:
;       THICKEN
; PURPOSE:
;       Thicken graphics in an existing image.  Good for viewgraphs.
; CATEGORY:
; CALLING SEQUENCE:
;       thicken, img, color
; INPUTS:
;       color = color index to thicken.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         BOLD=b  Desired thickness (def=2).
;           BOLD may also be set to an N x M array which defines
;           a brush stroke by non-zero elements.  For example:
;           BOLD=shift(dist(3),-2,-2) lt 1.2
;         /NOCENTER thicken on positive side of points (default is
;            to center thickening.
;         MASK=m   Optionally returned mask with 0 for pixels
;           in thickened areas, else 1.  May be useful for more
;           complex processing.
; OUTPUTS:
;       img = input image (byte).        in, out
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful to make existing graphics such as axes,
;         text, data curves, and so on thicker in an existing
;         image.  Makes viewgraphs more readable.  May want to
;         make original graphics in different colors so thickness
;         can be customized: For axes use 0, for text use 1, ...
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Feb 2.
;       R. Sterner, 1994 Apr 4 --- Allowed 2-d brush stroke.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro thicken, img, clr, bold=b, mask=mm, nocenter=nocenter, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Thicken graphics in an existing image.  Good for viewgraphs.'
	  print,' thicken, img, color'
	  print,'   img = input image (byte).        in, out'
	  print,'   color = color index to thicken.  in'
	  print,' Keywords:'
	  print,'   BOLD=b  Desired thickness (def=2).'
          print,'     BOLD may also be set to an N x M array which defines'
          print,'     a brush stroke by non-zero elements.  For example:'
          print,'     BOLD=shift(dist(3),-2,-2) lt 1.2'
	  print,'   /NOCENTER thicken on positive side of points (default is'
	  print,'      to center thickening.'
	  print,'   MASK=m   Optionally returned mask with 0 for pixels'
	  print,'     in thickened areas, else 1.  May be useful for more'
	  print,'     complex processing.'
	  print,' Notes: Useful to make existing graphics such as axes,'
	  print,'   text, data curves, and so on thicker in an existing'
	  print,'   image.  Makes viewgraphs more readable.  May want to'
	  print,'   make original graphics in different colors so thickness'
	  print,'   can be customized: For axes use 0, for text use 1, ...'
	  return
	endif
 
        ;---------  Handle brush  ----------
	if n_elements(b) eq 0 then b = 2		; Default thickness.
        sz = size(b)
        if sz(0) le 1 then br=bytarr(b,b)+1 else br=b	; Define brush.
        sz = size(br)					; Brush size in x and y.
        nx = sz(1)
        ny = sz(2)
        w = where(br ne 0, cnt)                         ; Find brush points.
        if cnt eq 0 then begin
          bell
          print,' Error in xyoutb: BOLD was set to a 2-d array.  Must'
          print,'   have at least 1 non-zero element.'
          return
        endif
        one2two, w, br, xx, yy				; Want 2-d shifts.
	if not keyword_set(nocenter) then begin
          xx = xx-(nx-1)/2				; Shift table.
          yy = yy-(ny-1)/2
	endif
        n = n_elements(xx)				; Number of shifts.
 
	;-------  Image size  -----------
	sz = size(img)
	nx = sz(1)
	ny = sz(2)
 
	;--------  Find all points to thicken  ----------
	wc = where(img eq clr, cnt)
	if cnt eq 0 then begin				; No such color.
	  print,' Error in thicken: color not found: ',clr
	  return
	endif
	one2two, wc, [nx,ny], ix, iy			; 2-d indices.
 
	;-------  Loop through all shifts in brush  -------
	for i = 1, n-1 do begin
	  ix2 = ix + xx(i)				; New points.
	  iy2 = iy + yy(i)
	  w = where( (ix2 ge 0) and (ix2 lt nx) $	: Drop wrap points.
	       and (iy2 ge 0) and (iy2 lt ny), cnt)
	  if cnt gt 0 then img(ix2(w),iy2(w)) = clr	; Set color.
	endfor
 
	return
	end
