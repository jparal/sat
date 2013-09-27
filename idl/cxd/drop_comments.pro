;-------------------------------------------------------------
;+
; NAME:
;       DROP_COMMENTS
; PURPOSE:
;       Drop comment and null lines from a text array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = drop_comments(in)
; INPUTS:
;       in = input text array.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         IGNORE=ig  Text string of allowed comment characters.
;           Default is ';*', so lines starting with the characters'
;           * or ; in column 1 are considered comments and dropped.
;         /NOTRIM  means don't do a strtrim on text array.
;           By default any line with white space but no text is
;           considered a null line and dropped.  If /NOTRIM is
;           specified only true null lines are dropped.
;         ERROR=err  Error flag: 0=OK, 1=All lines dropped.
;         /QUIET  Means suppress error messages.
; OUTPUTS:
;       out = processed text array.     out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 May, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function drop_comments, txt0, ignore=ig, error=err, $
	  notrim=notrim, quiet=quiet, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Drop comment and null lines from a text array.'
	  print,' out = drop_comments(in)'
	  print,'   in = input text array.          in'
 	  print,'   out = processed text array.     out'
	  print,' Keywords:'
	  print,'   IGNORE=ig  Text string of allowed comment characters.'
	  print,"     Default is ';*', so lines starting with the characters'
	  print,'     * or ; in column 1 are considered comments and dropped.'
	  print,"   /NOTRIM  means don't do a strtrim on text array."
	  print,'     By default any line with white space but no text is'
	  print,'     considered a null line and dropped.  If /NOTRIM is'
	  print,'     specified only true null lines are dropped.'
	  print,'   ERROR=err  Error flag: 0=OK, 1=All lines dropped.'
	  print,'   /QUIET  Means suppress error messages.'
	  return, ''
	endif
 
	if n_elements(ig) eq 0 then ig = '*;'	; Default comment chars.
	txt = txt0				; Copy input text array.
	if not keyword_set(notrim) then txt = strtrim(txt,2)	; trim.
 
	;---------  Handle null lines  ------------
	w = where(txt ne '', c)			; Look for non-null lines.
	if c gt 0 then begin			; Found some.
	  txt = txt(w)				; Drop null lines.
	endif else begin			; No non-null lines.
	  if not keyword_set(quiet) then $
	    print,' Error in drop_comments: all lines dropped.'
	  err = 1
	  return, ''
	endelse
 
	;----------  Handle comment lines  ------------
	one = strmid(txt,0,1)			; Pick off first char.
 
	for i = 1, strlen(ig) do begin		; Loop through comment chars.
	  w=where(one ne strmid(ig,i-1,1), c)	; Look for non-comm. lines.
	  if c gt 0 then begin			; Found some.
	    txt = txt(w)			; Drop comments.
	    one = one(w)			; Drop same first chars.
	  endif else begin			; No non-comm. lines.
            if not keyword_set(quiet) then $
              print,' Error in drop_comments: all lines dropped.'
            err = 1
            return, ''
          endelse
	endfor
 
	err = 0
 
	return, txt
 
	end
