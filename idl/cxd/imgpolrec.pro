;-------------------------------------------------------------
;+
; NAME:
;       IMGPOLREC
; PURPOSE:
;       Map an angle/radius image to an X/Y image.
; CATEGORY:
; CALLING SEQUENCE:
;       xy = IMGPOLREC(ar, a1, a2, r1, r2, x1, x2, dx, y1, y2, dy)
; INPUTS:
;       ar = angle/radius image.                            in
;          Angle is in x direction, and radius is in y direction
;       a1, a2 = start and end angles in ar (degrees)       in
;       r1, r2 = start and end radius in ar.                in
;       x1, x2, dx = desired start x, end x, x step.        in
;       y1, y2, dy = desired start y, end y, y step.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         /BILINEAR does bilinear interpolation,
;           else nearest neighbor is used.
;         /MASK masks values outside image to 0.
; OUTPUTS:
;       xy = returned X/Y image.                            out
; COMMON BLOCKS:
; NOTES:
;       Notes: Angle is 0 along + X axis and increases CCW.
; MODIFICATION HISTORY:
;       R. Sterner.  12 May, 1986.
;       R. Sterner, 3 Sep, 1991 --- converted to IDL vers 2.
;       R. Sterner, 5 Sep, 1991 --- simplified and added bilinear interp.
;       Johns Hopkins Applied Physics Lab.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION IMGPOLREC, AR, A1, A2, R1, R2, X1, X2, DX, Y1, Y2, DY, $
	  mask=mask, help=hlp, bilinear=bilin
 
	IF (N_PARAMS(0) LT 11) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Map an angle/radius image to an X/Y image.
	  PRINT,' xy = IMGPOLREC(ar, a1, a2, r1, r2, x1, x2, dx, y1, y2, dy)
	  PRINT,'   ar = angle/radius image.                            in
	  PRINT,'      Angle is in x direction, and radius is in y direction
	  PRINT,'   a1, a2 = start and end angles in ar (degrees)       in
	  PRINT,'   r1, r2 = start and end radius in ar.                in
	  PRINT,'   x1, x2, dx = desired start x, end x, x step.        in
	  PRINT,'   y1, y2, dy = desired start y, end y, y step.        in
	  PRINT,'   xy = returned X/Y image.                            out
	  print,' Keywords:'
          print,'   /BILINEAR does bilinear interpolation,'
          print,'     else nearest neighbor is used.'
	  print,'   /MASK masks values outside image to 0.'
          print,' Notes: Angle is 0 along + X axis and increases CCW.'
	  RETURN, 0
	ENDIF
 
	;--------  Get input image size and make sure its an image  ------
	S = SIZE(AR)				; Error check.
	IF S(0) NE 2 THEN BEGIN
	  PRINT,' Error in IMGRECPOL: First arg must be a 2-d array.'
	  RETURN, -1
	ENDIF
	NA = S(1)				; Size of AR in a.
	NR = S(2)				; Size of AR in r.
 
	;--------  Set up X and Y arrays  ---------
	X = MAKEX(X1, X2, DX)			; Generate X array.
	NX = N_ELEMENTS(X)
	Y = transpose(MAKEX(Y1, Y2, DY))	; Generate Y array.
	NY = N_ELEMENTS(Y)
	x = rebin(x,nx,ny)			; Make both 2-d.
	y = rebin(y,nx,ny)
 
	;-------  Compute angle and radius from X and Y  ------ 
	R = SQRT(X^2 + Y^2)			; From XY coordinates find R.
	w = where(r eq 0., count)		; ATAN(0,0) won't work. Fix.
	if count gt 0 then begin
	  x(w) = 1.0e-25
	  y(w) = 1.0e-25
	endif
	;--- Longest step  -------
	A = !RADEG*ATAN(Y, X)			; From XY coordinates find A.
	IF A1 ge 0 THEN BEGIN
	  W=WHERE(A LT 0.,count)		; Principal value 0 to 360
	  if count gt 0 then A(W)=A(W)+360.
	ENDIF
 
	;--------  Convert angle and radius to indices  --------
	IA = (A-A1)*(NA-1)/(A2-A1)		; From A find A indices.
	IR = (R-R1)*(NR-1)/(R2-R1)		; From R find R indices.
 
	;---------  Interpolate  ------------
	if not keyword_set(bilin) then begin
	  ;--------  Nearest Neighbor interpolation  ----------
	  xy = ar(fix(.5+ia)<(na-1), fix(.5+ir)<(nr-1))  ; Pick off values.
	endif else begin
	  ;--------  Bilinear interpolation  ------
	  ia0 = floor(ia)	; Indices of the 4 surrounding points.
	  ia1 = (ia0+1)<(na-1)
	  ir0 = floor(ir)
	  ir1 = (ir0+1)<(nr-1)
	  v00 = ar(ia0,ir0)	; Values of the 4 surrounding points.
	  v01 = ar(ia0,ir1)
	  v10 = ar(ia1,ir0)
	  v11 = ar(ia1,ir1)
	  fa = ia - ia0		; Fractional angle between points.
	  v0 = v00 + (v10-v00)*fa	; A interp at r0.
	  v1 = v01 + (v11-v01)*fa	; A interp at r1.
	  xy = v0+(v1-v0)*(ir-ir0)	; R interp at a.
	endelse
 
	;------ Mask points outside input image to 0  ------
	if keyword_set(mask) then begin
	  W = WHERE((IR lt 0) or (IR ge (NR-1)) or $
	            (IA lt 0) or (IA ge (NA-1)), count)
	  if count gt 0 then XY(w) = 0
	endif
 
	;------  Return result  --------- 
	RETURN, XY
 
	END
