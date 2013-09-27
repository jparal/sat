;-------------------------------------------------------------
;+
; NAME:
;       rb_maxarray
; PURPOSE:
;	calculates the max value array from two input arrays.
;	If array b has NaN values, then ignores them.  If array 1 has 
;	NaN values, use the new ones from b.
; CATEGORY:
; CALLING SEQUENCE:
;	mean=rb_maxarray(data1,data2)
; INPUTS:
;	data1, data2		Arrays of data to have max taken.
; KEYWORD PARAMETERS:
; OUTPUTS:
;	Returns an array the same type as data1;
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 3 Sep 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

	function rb_maxarray,data1,data2,help=hlp
	
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,' NAME:'
	  print,'       rb_maxarray'
	  print,' PURPOSE:'
	  print,'	calculates the max value array from two input arrays.'
	  print,'	If array b has NaN values, then ignores them.  If array 1 has '
	  print,'	NaN values, use the new ones from b.'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	mean=rb_maxarray(data1,data2)'
	  print,' INPUTS:'
	  print,'	data1, data2		Arrays of data to have max taken.'
	  print,' KEYWORD PARAMETERS:'
	  print,' OUTPUTS:'
	  print,'	Returns an array the same type as data1'
	  print,''
	  print,''
	  print,' COMMON BLOCKS:'
	  print,' NOTES:'
	  print,' MODIFICATION HISTORY:'
	  print,'       R. Bunting, 3 Sep 1996'
	endif
	
	
	d1=data1
	d2=data2
	
	; Here we need to get around some arrays containing !value.f_nan
	; so we want the value from the other array if this is the case.
	; we can't use finite() though, as this would also trap values
	; with !values.f_infinity, which I would like to let through
	; (so that a(x)=infinity > b(x)=r !)

	; Use -254 because `not' returns a byte value.	
	nan=where(not (d2 ge d1 or d2 le d1) - 254, num_nan)
	if num_nan gt 0 then d2(nan) = d1(nan)

	maxdata=d1 ((d1 ge d2) * indgen(n_elements(d1))) $
	 + d2 ((d1 lt d2)* indgen(n_elements(d2)))
	;get rid of those NaN information messages.
	junk = check_math()

	return, maxdata
	end
