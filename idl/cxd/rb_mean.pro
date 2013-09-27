;-------------------------------------------------------------
;+
; NAME:
;       rb_mean
; PURPOSE:
;	Calculates the mean of an input series of numbers.  Works if n=1
;	whereas moment() does not.  
; CATEGORY:
; CALLING SEQUENCE:
;	mean=rb_mean(data)
; INPUTS:
;	data		Array of data to have mean taken.
; KEYWORD PARAMETERS:
; OUTPUTS:
;	Returns a double value, the mean of the input numbers.
;	NB if n_elements(data)=0, then of course the result is undefined,
;	and this routine returns 0.
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 5 Feb 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

	function rb_mean,data,help=hlp
	
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,' NAME:'
	  print,'       rb_mean'
	  print,' PURPOSE:'
	  print,'	Calculates the mean of an input series of numbers.  Works if n=1'
	  print,'	whereas moment() does not.  '
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	mean=rb_mean(data)'
	  print,' INPUTS:'
	  print,'	data		Array of data to have mean taken.'
	  print,' KEYWORD PARAMETERS:'
	  print,' OUTPUTS:'
	  print,'	Returns the mean of the input numbers.'
	  print,'	NB if n_elements(data)=0, then of course the result is undefined,'
	  print,'	and this routine returns 0.'
	  print,''
	endif

	realcount=total(finite(data))
;	 Avoid doing a divide by zero
	case realcount of
	0: begin
	  mval=0.0
	  print,'Mean of zero length series taken'
	end
	else: begin
	  mval=total(data,/nan)/realcount
	end
	endcase
	return, mval
	end
	
;Commented out the old way of doing this.  It was rather slower.
	

;	realnums=where(finite(data), realcount)
;; do away with non real data elements.  
;	if(realcount gt 0) then realdata=data(realnums)
;	
;	case n_elements(realdata) of
;	0: begin
;	  mval=0.0
;	  print,'Mean of zero length series taken'
;	end
;	1: begin
;	  mval=data(0)
;	end
;	else: begin
;;	  mval=(moment(realdata))(0)
;	  mval=total(realdata)/n_elements(realdata)
;	end
;	endcase
;	
;	return, mval
;	end
