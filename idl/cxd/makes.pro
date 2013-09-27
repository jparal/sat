;-------------------------------------------------------------
;+
; NAME:
;       MAKES
; PURPOSE:
;       Make a string array of integers from lo to hi by step.
; CATEGORY:
; CALLING SEQUENCE:
;       s = makes(lo, hi, step)
; INPUTS:
;       lo, hi = array start and end values.       in
;       step = distance beteen values.             in
;         Sign of step determines order of result.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = resulting string array.                out
; COMMON BLOCKS:
; NOTES:
;       Note: no leading or trailing spaces, useful for
;         generating file names with embedded numbers.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Feb 22
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makes,lo,hi,st, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make a string array of integers from lo to hi by step.'
	  print,' s = makes(lo, hi, step)'
	  print,'   lo, hi = array start and end values.       in'
	  print,'   step = distance beteen values.             in'
	  print,'     Sign of step determines order of result.'
	  print,'   s = resulting string array.                out'
	  print,' Note: no leading or trailing spaces, useful for'
	  print,'   generating file names with embedded numbers.'
	  return, -1
	endif
 
	return, strtrim(makei(lo,hi,st),2)
 
	end
