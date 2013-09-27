;-------------------------------------------------------------
;+
; NAME:
;       SEEDFILL
; PURPOSE:
;       For an array fill a connected region bounded by given values.
; CATEGORY:
; CALLING SEQUENCE:
;       seedfill, img
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SEED=s  Seed point as a 2 element array [ix,iy].
;         FILL=f  Fill pixel value.
;         BOUND=b Region boundary pixel value.
;           May be an array of allowed boundary values.
;         /DISPLAY  Display fill progress.
; OUTPUTS:
;       img = Image to process.    in, out
; COMMON BLOCKS:
;       sf_stk_com
;       sf_stk_com
;       sf_stk_com
;       sf_stk_com
;       sf_stk_com
; NOTES:
;       Notes: Modified from Procedural Elements for Computer
;         Graphics by David Rogers.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Mar 16
;       R. Sterner, 1994 May 23 --- Converted to multiple boundary values.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sfpush, seed, error=err
 
	common sf_stk_com, stack, top
 
	;--------  Init stack  ----------------
	if n_elements(stack) eq 0 then begin
	  stack = intarr(2,50000)
	  top = -1
	endif
 
	;---------  Push  ----------------------
	if top ge 49999 then begin
	  print,' Stack overflow.'
	  err = 1
	  return
	endif
 
	top = top + 1
	stack(0,top) = seed
	err = 0
;print,' Push: ',top, seed
 
	return
	end
 
;===============================================================
;	sfpop = pop a seed from stack.
;===============================================================
 
	pro sfpop, seed, error=err
 
	common sf_stk_com, stack, top
 
	;--------  Stack defined?  ----------------
	if n_elements(stack) eq 0 then begin
	  stop,' Stack undefined.  Stopped.'
	endif
 
	;--------  Stack empty? ----------------
	if top lt 0 then begin
	  print,' Stack underflow.'
	  err = 2
	  return
	endif
 
	;--------  Pop  -----------
	seed = stack(*,top)
;print,' Pop: ',top, seed
	top = top -1
	err = 0
	return
	end
 
;===============================================================
;	sfclr = Clear stack.
;===============================================================
 
	pro sfclr
 
	common sf_stk_com, stack, top
 
	stack = intarr(2,50000)
	top = -1
 
;print,' Stack cleared.'
	return
	end
 
;===============================================================
;	sflst = List stack.
;===============================================================
 
	pro sflst
 
	common sf_stk_com, stack, top
 
	;--------  Stack defined?  ----------------
	if n_elements(stack) eq 0 then begin
	  stop,' Stack undefined.  Stopped.'
	endif
 
	for i = top, 0, -1 do print,i,stack(*,i)
	return
	end
 
;===============================================================
;	sfnotempty = Stack empty status.
;===============================================================
 
	function sfnotempty
 
	common sf_stk_com, stack, top
 
	;--------  Stack defined?  ----------------
	if n_elements(stack) eq 0 then begin
	  stop,' Stack undefined.  Stopped.'
	endif
 
	if top ge 0 then return, 1 else return, 0
	end
 
 
;--------  seedfill.pro = Scan line seed fill routine  ---------
;	From Procedural Elements for Computer Graphics
;	by David Rogers.
 
	pro seedfill, pix, seed=seed,fill=fill,bound=b0,display=disp,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' For an array fill a connected region bounded by given values.'
	  print,' seedfill, img'
	  print,'   img = Image to process.    in, out'
	  print,' Keywords:'
	  print,'   SEED=s  Seed point as a 2 element array [ix,iy].'
	  print,'   FILL=f  Fill pixel value.'
	  print,'   BOUND=b Region boundary pixel value.'
	  print,'     May be an array of allowed boundary values.'
	  print,'   /DISPLAY  Display fill progress.'
	  print,' Notes: Modified from Procedural Elements for Computer'
	  print,'   Graphics by David Rogers.'
	  return
	endif
 
	;---------  initialize some values  ----------
	b = [b0,fill]		; Add fill value to boundary values.
	sz = size(pix)		; Get array limits.
	lstx = sz(1)-1
	lsty = sz(2)-1
	;---------  Initialize stack  ----------
	sfclr
	sfpush, seed
	if max(pix(seed(0),seed(1)) eq b) then begin
	  print,' Error in seedfill: Value at seed point equals'
	  print,'   boundary value.'
	  return
	endif
 
	;---------  Main loop  ------------------
	while sfnotempty() do begin
	  ;------  Process seed pixel  ----------
	  sfpop, s  &  ix=s(0)  &  iy=s(1)
	  pix(ix,iy) = fill
	  ;------  Fill to right  ---------------
	  savex = ix
	  ix = (ix + 1)<lstx
	  while min(pix(ix,iy) ne b) do begin	; Not boundary pt.
	    pix(ix,iy) = fill
	    ix = (ix + 1)<lstx
	  endwhile
	  ;-------  Save right pixel  ----------
	  xright = (ix - 1)>0
	  ;------  Fill to left  -----------
	  ix = savex
	  ix = (ix - 1)>0
	  while min(pix(ix,iy) ne b) do begin	; Not boundary pt.
	    pix(ix,iy) = fill
	    ix = (ix - 1)>0
	  endwhile
	  ;-------  Save left pixel  ----------
	  xleft = (ix + 1)<lstx
	  if keyword_set(disp) then tvscl,pix
	  ;=====================================================
	  ;-------  Check line above, set any seeds  ----------
	  ix = xleft
	  iy = (iy + 1)<lsty
	  while ix le xright do begin
	    ;------  Seed scan line above  -------
	    pflag = 0
	    while min(pix(ix,iy) ne b) and (pix(ix,iy) ne fill) and $
	      	  (ix le xright) do begin
	       if pflag eq 0 then pflag = 1
	       ix = (ix + 1)<lstx
	    endwhile
	    ;-----  Push extreme right pixel on stack  -----
	    if pflag eq 1 then begin
	      if (ix eq xright) and min((pix(ix,iy) ne b)) and $
	        (pix(ix,iy) ne fill) then sfpush,[ix,iy] else $
		 sfpush,[(ix-1)>0,iy]
	    endif  ; pflag eq 1
	    ;------  Continue checking scan line  ------------
	    xenter = ix
	    while max(pix(ix,iy) eq b) or (pix(ix,iy) eq fill) and $
	      (ix lt xright) do ix = (ix + 1)<lstx
	    if ix eq xenter then ix = (ix + 1)<lstx
	  endwhile  ; ix
	  ;-------  Check line below, set any seeds  ----------
	  ix = xleft
	  iy = (iy - 2)>0		; -2 because was on line above.
	  while ix le xright do begin
	    ;------  Seed scan line below  -------
	    pflag = 0
	    while min(pix(ix,iy) ne b) and (pix(ix,iy) ne fill) and $
	      (ix le xright) do begin
	       if pflag eq 0 then pflag = 1
	       ix = (ix + 1)<lstx
	    endwhile
	    ;-----  Push extreme right pixel on stack  -----
	    if pflag eq 1 then begin
	      if (ix eq xright) and min(pix(ix,iy) ne b) and $
	        (pix(ix,iy) ne fill) then sfpush,[ix,iy] else $
		sfpush,[(ix-1)>0,iy]
	    endif  ; pflag eq 1
	    ;------  Continue checking scan line  ------------
	    xenter = ix
	    while max(pix(ix,iy) eq b) or (pix(ix,iy) eq fill) and $
	      (ix lt xright) do ix = (ix + 1)<lstx
	    if ix eq xenter then ix = (ix + 1)<lstx
	  endwhile  ; ix
 
	endwhile ; not empty.
 
	return
	end
