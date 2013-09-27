;-------------------------------------------------------------
;+
; NAME:
;       SCALE_DB
; PURPOSE:
;       Scale given data to db (meant for images).
; CATEGORY:
; CALLING SEQUENCE:
;       d = scale_db(p, db, pmax, minout, maxout)
; INPUTS:
;       p = original data.                      in
;       db = Decibel range to cover.            in
;       pmax = reference value to map to 0 db.  in
;       minout = value to map -DB db to.        in
;       maxout = value to map 0 db to.          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       d = scaled values.                      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  3 Apr, 1987.
;	R. Sterner, 15 Jul, 1991 --- updated to IDL V2.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION SCALE_DB, P, DB, PMAX, MINOUT, MAXOUT, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Scale given data to db (meant for images).'
	  print,' d = scale_db(p, db, pmax, minout, maxout)'
	  print,'   p = original data.                      in'
	  print,'   db = Decibel range to cover.            in'
	  print,'   pmax = reference value to map to 0 db.  in'
	  print,'   minout = value to map -DB db to.        in'
	  print,'   maxout = value to map 0 db to.          in'
	  print,'   d = scaled values.                      out'
	  return, -1
	endif
 
	W = WHERE(P LT 0., count)
	IF count gt 0 THEN BEGIN
	  PRINT,' Error in SCALE_DB: negative values not allowed.'
	  RETURN, -1
	ENDIF
	NP = N_PARAMS(0)
	IF NP LT 2 THEN BEGIN
	  DB = 60
	  PRINT,' SCALE_DB routine using default of 60 db.'
	ENDIF
	IF NP LT 3 THEN BEGIN
	  PMAX = MAX(P)
	ENDIF
	IF NP LT 4 THEN MINOUT = 0.
	IF NP LT 5 THEN MAXOUT = 255.
 
	P2 = P/PMAX
	W = WHERE(P2 LE 0., count)
	if count gt 0 then P2(W) = 1.E-30
	T = 10.*ALOG10(P2)
	T = T >(-DB)<0
	D = SCALEARRAY(T, (-DB), 0, MINOUT, MAXOUT)
 
	RETURN, D
	END
