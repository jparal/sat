

;-------------------------------------------------------------
;+
; NAME:
;       lanczos
; PURPOSE:
;	Calculates a lanczos squared filter  
; CATEGORY:
; CALLING SEQUENCE:
;	filter=lanczos(n_terms,f_cutoff)
; INPUTS:
;	n_terms		Number of terms required in the filter
;	f_cutoff	Cutoff frequency in terms of nyquist frequency 1/2T
;			i.e. f_cutoff_real = f_cutoff * f_nyquist
; KEYWORD PARAMETERS:
;	type=type	Set this to 1 for a low pass,
;			2 for a high pass filter.
; OUTPUTS:
;	filter		A digital lanczos filter.
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 6 Feb 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function lanczos,lm,f,type=lp,help=hlp
	
	if keyword_set(hlp) then $
	  begin
	  print,''
	  print,' NAME:'
	  print,'       lanczos'
	  print,' PURPOSE:'
	  print,'	Calculates a lanczos squared filter  '
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	filter=lanczos(n_terms,f_cutoff)'
	  print,' INPUTS:'
	  print,'	n_terms		Number of terms required in the filter'
	  print,'	f_cutoff	Cutoff frequency in terms of nyquist frequency 1/2T'
	  print,' KEYWORD PARAMETERS:'
	  print,'	type=type	Set this to 1 for a low pass,'
	  print,'			2 for a high pass filter.'
	  print,' OUTPUTS:'
	  print,'	filter		A digital lanczos filter.'
	  print,''
	endif

	if n_elements(lm) eq 0 or lm eq 0 then $
	  begin
	  print,'lanczos.pro: Wrong length or no length of filter'
	  return,0.
	endif

	if n_elements(f) eq 0 or f eq 0 then $
	  begin
	  print,'lanczos.pro: Wrong cutoff frequency or no cutoff frequency'
	  return,0.
	endif
	
	if not keyword_set(lp) then $
	  begin
	  print;'lanczos.pro: no type set.  Defaulting to Low pass filter'
	  lp=1
	endif
	
	if lp ne 1 and lp ne 2 then $ 
	  begin
	  print,'lanczos:  Unknown value of filter type:,lp
	  return,0
	endif

	filter=fltarr(lm)

;	Lanczos squared filter

	del=!pi/float(lm-1.)
	filter(0)=1
	for i=1,lm-1 do begin
	  deli=del*i
	  filter(i)=sin(deli)/(deli)
	  filter(i)=filter(i)*filter(i)
	endfor

;	Apply cutoff factor
	
	pif=!pi*f
	for i=1,lm-1 do begin
	  pifi=pif*i
	  filter(i)=filter(i)*sin(pifi)/(pifi)
	endfor
	
;	Apply normalisation
	
	fnorm=filter(0)
	for i=1,lm-1 do begin
	  fnorm=fnorm + 2.*filter(i)
	endfor
	fnorm=(2.* lm  - 1.) /fnorm
	
	if lp eq 1 then begin
;
;	  Low pass
;
	  for i=0,lm-1 do begin
	    filter(i)=filter(i)*fnorm
	  endfor
	endif else begin
;
;	  High pass
;
	  filter(0)=(2.*lm)-1 - filter(0)*fnorm
	  for i=1,lm-1 do begin
	    filter(i)=-1.*filter(i)*fnorm
	  endfor
	endelse
	
	filter=[0,reverse(filter(1:n_elements(filter)-1)),filter]
;	filter=filter/total(abs(filter))
	filter=filter/	((2.*lm)-1)
;	this seems to make the output normalised like that of the
;	idl digital_filter routine!
	return, filter
	end
	
	
	
	
	
