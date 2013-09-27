;-------------------------------------------------------------
;+
; NAME:
;       rb_axisrange
; PURPOSE:
; CATEGORY:
; CALLING SEQUENCE:
;	range=rb_axisrange(ymin,ymax)
; INPUTS:
;	ymin,ymax: original min and max of data
; KEYWORD PARAMETERS:
;	majorticks: useful number of major tick intervals to use.
;	minorticks: useful number of minor tick intervals to use.
; OUTPUTS:
;	Returns a 2 element array with a (hopefully) suitable plotting range
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 21 Sep 1998
;
; Copyright (C) 1998, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

	function rb_axisrange,ymin,ymax,majorticks=majorticks,$
	minorticks=minorticks,help=hlp
	
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,' NAME:'
	  print,'       rb_axisrange'
	  print,' PURPOSE:'
	  print,'	Calculates a suitable plotting range.  '
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	range=rb_datarange(data)'
	  print,' INPUTS:'
	  print,'	ymin,ymax: original data range'
	  print,' KEYWORD PARAMETERS:'
	  print,'	majorticks: useful number of major tick intervals to use.'
	  print,'	minorticks: useful number of minor tick intervals to use.'
	  print,' OUTPUTS:'
	  print,'	Returns a (hopefully) suitable plotting range .'
	  print,'	(as a 2-element array)'
	  print,''
	endif

	ret_range=dblarr(2)
	range=ymax-ymin
	logrange=floor(alog10(range))
	tenfact=10^logrange
	range_factor=range/tenfact
	if(range_factor lt 4.0) then begin
		divis=0.4D
	endif else begin
		divis=0.8D
	endelse
	ret_range(0)=divis*tenfact*floor(ymin/(divis*tenfact))
	ret_range(1)=divis*tenfact*ceil(ymax/(divis*tenfact))
	
	if(n_elements(majorticks) gt 0)then begin
		majorticks=4
	endif
	if(n_elements(minorticks) gt 0)then begin
		minorticks=(ret_range(1)-ret_range(0))/(divis*tenfact)
	endif

	return,ret_range
	end
