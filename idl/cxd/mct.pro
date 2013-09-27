;-------------------------------------------------------------
;+
; NAME:
;       MCT
; PURPOSE:
;       Combine multiple color tables into one.
; CATEGORY:
; CALLING SEQUENCE:
;       mct
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /INITIALIZE means clear internal color tables.
;           Should never be needed.
;         CRANGE=[lo,hi] maps current color table into the
;           range lo to hi in the internal color table.
;         IMAGE=img returns given image scaled to the range lo to hi.
;         RED=r returns the red component of the internal ct.
;         GREEN=g returns the green component of the internal ct.
;         BLUE=b returns the blue component of the internal ct.
; OUTPUTS:
; COMMON BLOCKS:
;       mct_com
;       mct_com
; NOTES:
;       Notes: remember to load desired color before calling mct.
;         Images scaled with the IMAGE keyword are modified.
;         Use tv to load the scaled images returned from mct,
;         not tvscl.  Ex:
;         mct, mct,image=z1,crange=[65,150]
;         mct,image=z2,crange=[0,64]
;         mct,image=z3,crange=[151,210],red=r,gr=g,bl=b
;         tv,z1,0 & tv,z2,1 & tv,z3,2
;         tvlct,r,g,b
; MODIFICATION HISTORY:
;       R. Sterner, 26 Oct, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro mct, initialize=init, crange=cran, image=img, $
	  red=red, green=green, blue=blue, help=hlp
 
	common mct_com, rr, gg, bb
 
	if keyword_set(hlp) then begin
	  print,' Combine multiple color tables into one.'
	  print,' mct'
	  print,'   All args keywords.'
	  print,' Keywords:'
	  print,'   /INITIALIZE means clear internal color tables.'
	  print,'     Should never be needed.'
	  print,'   CRANGE=[lo,hi] maps current color table into the'
	  print,'     range lo to hi in the internal color table.'
	  print,'   IMAGE=img returns given image scaled to the range lo to hi.'
	  print,'   RED=r returns the red component of the internal ct.'
	  print,'   GREEN=g returns the green component of the internal ct.'
	  print,'   BLUE=b returns the blue component of the internal ct.'
	  print,' Notes: remember to load desired color before calling mct.'
	  print,'   Images scaled with the IMAGE keyword are modified.'
	  print,'   Use tv to load the scaled images returned from mct,'
	  print,'   not tvscl.  Ex:'
	  print,'   mct, mct,image=z1,crange=[65,150]'
	  print,'   mct,image=z2,crange=[0,64]'
	  print,'   mct,image=z3,crange=[151,210],red=r,gr=g,bl=b'
	  print,'   tv,z1,0 & tv,z2,1 & tv,z3,2'
	  print,'   tvlct,r,g,b'
	  return
	endif
 
	;------  clear internal table  ----------
	if keyword_set(init) then begin
	  rr = bindgen(256)
	  gg = bindgen(256)
	  bb = bindgen(256)
	endif
 
	;------  Make sure internal table defined  -----
	if n_elements(rr) eq 0 then rr = bindgen(256)
	if n_elements(gg) eq 0 then gg = bindgen(256)
	if n_elements(bb) eq 0 then bb = bindgen(256)
 
	;------  Process given color range  -----------
	if n_elements(cran) eq 2 then begin
	  ;-------  Handle color table  --------
	  lo = cran(0)					; Color range start
	  hi = cran(1)					; and end.
	  d = hi - lo + 1				; # in range.
	  ind = byte(findgen(d)/(d-1.)*(!d.n_colors-1))	; D indices into r,g,b.
	  tvlct,r,g,b,/get				; Get current ct.
	  rr(lo) = r(ind)				; Squeeze into internal
	  gg(lo) = g(ind)				; color table.
	  bb(lo) = b(ind)
	  ;-------  Handle image  ------------
	  if n_elements(img) gt 0 then begin
	    img = byte(scalearray(img,min(img),max(img),lo,hi))
	  endif
	endif
 
	;-------  Return color table  --------
	red = rr
	green = gg
	blue = bb
 
	return
 
	end
