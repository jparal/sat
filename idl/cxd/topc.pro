;-------------------------------------------------------------
;+
; NAME:
;       TOPC
; PURPOSE:
;       Return top color number for current device.
; CATEGORY:
; CALLING SEQUENCE:
;       tc = topc()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Aug 9
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function topc, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return top color number for current device.'
	  print,' tc = topc()'
	  print,'   No arguments.'
	  return,''
	endif
 
	return, !d.n_colors-1
	end
