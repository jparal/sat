;-------------------------------------------------------------
;+
; NAME:
;       WORDARRAY
; PURPOSE:
;       Convert text string or string array to 1-d array of words.
; CATEGORY:
; CALLING SEQUENCE:
;       wordarray, instring, outlist
; INPUTS:
;       instring = string or string array to process.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         IGNORE = character or array of characters.
;           These characters are removed before processing.
;           Ex: wordarray,in,out,ignore=','
;               wordarray,in,out,ignore=[',',';','(',')']
; OUTPUTS:
;       outlist = 1-d array of words in instring.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Words are assumed delimited by spaces and/or tabs
;        Non-spaces/tabs are returned as part of the words.
;        Spaces/tabs not needed at the front and end of the strings.
; MODIFICATION HISTORY:
;       R. Sterner, 29 Nov, 1989
;       BLG --- Modified June 22,1991 to include tabs as delimiters
;       R. Sterner, 11 Dec, 1992 --- fixed to handle pure white space.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro wordarray, in0, out, ignore=ign, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert text string or string array to 1-d array of words.'
	  print,' wordarray, instring, outlist'
	  print,'   instring = string or string array to process.  in'
	  print,'   outlist = 1-d array of words in instring.      out'
	  print,' Keywords:'
	  print,'   IGNORE = character or array of characters.'
	  print,'     These characters are removed before processing.'
	  print,"     Ex: wordarray,in,out,ignore=','"
	  print,"         wordarray,in,out,ignore=[',',';','(',')']"
	  print,' Notes: Words are assumed delimited by spaces and/or tabs'
	  print,'  Non-spaces/tabs are returned as part of the words.'
	  print,'  Spaces/tabs not needed at the front and end of the strings.' 
	  return
	endif
 
	in = in0
 
	if n_elements(ign) gt 0 then begin
	  rm = ign
	  for i = 0L, n_elements(rm)-1L do in = repchr(in, rm(i))
	endif
 
	t = ' ' + in + ' '		; Force spaces on ends
	b = byte(t)				; Convert to byte array.
	w = where(b ne 0, count)		; Find non-null chars.
	if count gt 0 then b = b(w)		; Extract non-null characters.
	X = (B NE 32b) and (B NE 9b)		; non-space/tab chars.
	X = [0,X,0]				; tack 0s at ends.
	if total(x) eq 0 then begin		; All white space.
	  out = ''
	  return
	endif
 
	Y = (X-SHIFT(X,1)) EQ 1			; look for transitions.
	Z = WHERE(SHIFT(Y,-1) EQ 1)
	Y2 = (X-SHIFT(X,-1)) EQ 1
	Z2 = WHERE(SHIFT(Y2,1) EQ 1)
 
	NWDS = TOTAL(Y)				; Total words in IN.
	LOC = Z					; Word start positions.
	LEN = Z2 - Z - 1			; Word lengths.
 
	out = bytarr(max(len), nwds)		; Set up output array.
	if nwds gt 1 then begin
	  for i = 0L, nwds-1L do begin
	    out(0,i) = b(loc(i):(loc(i)+len(i)-1L))
	  endfor
	  out = string(out)
	endif else begin
	  out(0) = b(loc(0):(loc(0)+len(0)-1L))
	  out = string(out)
	endelse
 
 
	return
 
	END
