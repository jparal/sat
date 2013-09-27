;-------------------------------------------------------------
;+
; NAME:
;       SET_SCALE
; PURPOSE:
;       Set scaling from currently displayed image.
; CATEGORY:
; CALLING SEQUENCE:
;       set_scale
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /QUIET No message if scaling info not found.
;         /LIST  lists screen and data windows.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: current image must have scaling info embedded as
;         expected by this routine.  The needed values are in the
;         first 90 bytes of the bottom image line are are:
;           m, ix1, ix2, iy1, iy2, x1, x2, y1, y2, xtyp, ytyp
;         where m is 1234567890,
;         ix1, ix2 is the image X range in screen coordinates,
;         iy1, iy2 is the image Y range in screen coordinates,
;         x1,x2 is the image X range in data coordinates,
;         y1,y2 is the image Y range in data coordinates.
;         xtyp, ytyp is the X and Y axis types: 0=linear, 1=log.
;         The format for all these values is:
;           I10,  4I6,  4G13.6, 2I2.
;         This scaling info may be placed in the image by the
;         routine put_scale.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Feb 28
;       R. Sterner, 1995 Mar  7 --- Added /LIST keyword.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro set_scale, quiet=quiet, list=list, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Set scaling from currently displayed image.'
	  print,' set_scale'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   /QUIET No message if scaling info not found.'
	  print,'   /LIST  lists screen and data windows.'
 	  print,' Notes: current image must have scaling info embedded as'
	  print,'   expected by this routine.  The needed values are in the'
	  print,'   first 90 bytes of the bottom image line are are:'
	  print,'     m, ix1, ix2, iy1, iy2, x1, x2, y1, y2, xtyp, ytyp'
	  print,'   where m is 1234567890,'
	  print,'   ix1, ix2 is the image X range in screen coordinates,'
	  print,'   iy1, iy2 is the image Y range in screen coordinates,'
	  print,'   x1,x2 is the image X range in data coordinates,'
	  print,'   y1,y2 is the image Y range in data coordinates.'
	  print,'   xtyp, ytyp is the X and Y axis types: 0=linear, 1=log.'
	  print,'   The format for all these values is:'
 	  print,'     I10,  4I6,  4G13.6, 2I2.'
	  print,'   This scaling info may be placed in the image by the'
	  print,'   routine put_scale.'
	  return
	endif
 
	if !d.x_size lt 90 then return		; Image too small.
	t = tvrd(0,0,90,1)
	m = string(t(0:9))
 
	if m ne '1234567890' then begin
	  if not keyword_set(quiet) then begin
	    print,' Warning in set_scale: no scaling information available.'
	  endif
	  return
	endif
 
	s = string(t(10:*))
	ix1 = 0
	ix2 = 0
	iy1 = 0
	iy2 = 0
	xtyp = 0
	ytyp = 0
	on_ioerror, skip
	reads,s,ix1,ix2,iy1,iy2,x1,x2,y1,y2,xtyp,ytyp, $
	  form='(4I6,4G13.6,2I2)'
 
	if xtyp eq 1 then begin
	  x1 = 10.^x1
	  x2 = 10.^x2
	endif
 
	if ytyp eq 1 then begin
	  y1 = 10.^y1
	  y2 = 10.^y2
	endif
 
	plot,[x1,x2],[y1,y2],pos=[ix1,iy1,ix2,iy2],/dev,$
	  xstyl=5,ystyl=5,/noerase,/nodata, xtyp=xtyp, ytyp=ytyp
 
	if keyword_set(list) then begin
	  print,' '
	  print,' Values set from embedded scaling:'
	  print,' Screen window ix1, iy1, ix2, iy2: '+$
	    '['+strtrim(ix1,2)+','+strtrim(iy1,2)+','+$
	    strtrim(ix2,2)+','+strtrim(iy2,2)+']'
	  print,' Data window x1, x2, y1, y2: '+$
	    strtrim(x1,2)+','+strtrim(x2,2)+','+$
	    strtrim(y1,2)+','+strtrim(y2,2)
	  print,' '
	endif
 
skip:	on_ioerror, null
	return
	end
