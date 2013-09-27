;-------------------------------------------------------------
;+
; NAME:
;       MORE
; PURPOSE:
;       Display a text array using the MORE method.
; CATEGORY:
; CALLING SEQUENCE:
;       more, txtarr
; INPUTS:
;       txtarr = string array to display.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NUMBERS display all array elements and index numbers.
;         NUMBERS=lo  display numbered array elements starting at
;           element number lo.
;         NUMBERS=[lo,hi] display requested array elements
;           and index numbers.
;         FORMAT=fmt  specify format string (def=A).
;           Useful for listing numeric arrays, ex:
;           more,a,form='f8.3'  or  more,a,form='3x,f8.3'
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: when screen is full output will pause
;        until user presses SPACE to continue.
; MODIFICATION HISTORY:
;       R. Sterner, 26 Feb, 1992
;       Jayant Murthy murthy@pha.jhu.edu 31 Oct 92 --- added FORMAT keyword.
;       R. Sterner, 29 Apr, 1993 --- changed for loop to long int.
;       R. Sterner, 1994 Nov 29 --- Allowed specified index range.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
	pro more, txt, help=hlp, numbers=num0, format=fmt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a text array using the MORE method.'
	  print,' more, txtarr'
	  print,'   txtarr = string array to display.  in'
	  print,' Keywords:'
	  print,'   /NUMBERS display all array elements and index numbers.'
	  print,'   NUMBERS=lo  display numbered array elements starting at'
	  print,'     element number lo.'
	  print,'   NUMBERS=[lo,hi] display requested array elements'
	  print,'     and index numbers.'
	  print,'   FORMAT=fmt  specify format string (def=A).
	  print,'     Useful for listing numeric arrays, ex:
	  print,"     more,a,form='f8.3'  or  more,a,form='3x,f8.3'"
	  print,' Note: when screen is full output will pause'
	  print,'  until user presses SPACE to continue.'
	  return
	endif
 
	if n_elements(fmt) eq 0 then fmt='a'
 
	scrn = filepath(/TERMINAL)
 
	openw,lun,scrn,/more,/get_lun
 
	;---------  Element numbering  ---------
	num = 0						; Assume no numbering.
	if n_elements(num0) ne 0 then begin		; Numbers requested.
	  num = 1
	  lo = 0					; Default index range.
	  hi = n_elements(txt)-1
	  if num0(0) gt 1 then lo=num0(0)		; Set start index.
	endif
	if n_elements(num0) eq 2 then begin		; Requested range.
	  lo = num0(0)>0
	  hi = num0(1)<hi
	endif
 
	;---------  List array  ------------
	if keyword_set(num) then begin
	  for i = lo, hi do begin
	    printf,lun,i,txt(i),form='(i5,2x,'+fmt+')'
	  endfor
	endif else begin
	  for i = 0L, n_elements(txt)-1 do printf,lun,txt(i),form='('+fmt+')'
	endelse
 
	free_lun, lun
	return
	end
