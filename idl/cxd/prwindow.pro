;-------------------------------------------------------------
;+
; NAME:
;       PRWINDOW
; PURPOSE:
;       Print current window on specified color PostScript printer.
; CATEGORY:
; CALLING SEQUENCE:
;       prwindow, pnum
; INPUTS:
;       pnum = optional PS printer numer or tag.   in
;         This may be determined frmo psinit,/list.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: the currect window is captured and printed to
;         the specifed or default PS printer.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 4
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro prwindow, pnum, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Print current window on specified color PostScript printer.'
	  print,' prwindow, pnum'
	  print,'   pnum = optional PS printer numer or tag.   in'
	  print,'     This may be determined frmo psinit,/list.'
	  print,' Notes: the currect window is captured and printed to'
	  print,'   the specifed or default PS printer.'
	  return
	endif
 
	win = !d.window
	if win lt 0 then begin
	  print,' Error in prwindow: no active graphics window to print.'
	  return
	endif
 
	if n_elements(pnum) eq 0 then pnum = 'color'
 
	;------  Get image and color table  -----------
	print,' Reading image from window '+strtrim(win,2)+' . . .'
	a = tvrd()
	tvlct,r,g,b,/get
 
	;------  Find image dimensions  -----------
	sz = size(a)
	nx = sz(1)
	ny = sz(2)
 
	;------  Initialize printer and orientation  -----------
	if nx gt ny then begin
	  psinit, pnum, /land, /auto, cflag=flag
	endif else begin
	  psinit, pnum, /full, /auto, cflag=flag
	endelse
 
	;---------  Deal with B&W printer  ----------------------
	if flag eq 0 then begin
	  print,' Converting image to Black and White . . .'
	  lum = ROUND(.3 * r + .59 * g + .11 * b) < 255	  ; Image brightness.
	  a = lum(a)					  ; To B&W.
	endif
 
	;---------  Load color table and image  -----------------
	print,' Sending image to printer . . .'
	tvlct,r,g,b
	psimg, a
 
	;---------  Terminate printer  ------------
	psterm
 
	return
	end
