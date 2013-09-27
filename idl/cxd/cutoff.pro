;-------------------------------------------------------------
;+
; NAME:
;       cutoff
; PURPOSE:
;       Use high and low cutoffs in frequency or period to truncate
;	an array containing a power spectrum
; CATEGORY:
; CALLING SEQUENCE:
;	return_power=cutoff(pow_array, low_cut, high_cut, type)
; INPUTS:
;	pow_array(*,3)	Input array of the spectrum, where:
;			pow_array(*,0) are the spectral samples,
;			pow_array(*,1) are the frequency values,
;			pow_array(*,2) are the period values.
;	low_cut		Low value of frequency or period.
;	high_cut	High value of frequency or period.
;	type		Type is 1 for frequency, 2 for period.
; KEYWORD PARAMETERS:
; OUTPUTS:
;	return_power(*,3).
;	return_power(*,0) contains the transformed data,
;	return_power(*,1) contains the frequency values,
;	return_power(*,2) contains the period values.
;
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 11 Jul 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function cutoff, power, low_cut, high_cut, type, $
	help=hlp

; print out help message if /help was used.
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,'NAME:'
	  print,'      cutoff'
	  print,'PURPOSE:'
	  print,'      Use high and low cutoffs in frequency or period to truncate'
	  print,'	an array containing a power spectrum'
	  print,'CATEGORY:'
	  print,'CALLING SEQUENCE:'
	  print,'	return_power=cutoff(pow_array, low_cut, high_cut, type)'
	  print,'INPUTS:'
	  print,'	pow_array(*,3)	Input array of the spectrum, where:'
	  print,'			pow_array[*,0] are the spectral samples,'
	  print,'			pow_array[*,1] are the frequency values,'
	  print,'		       pow_array[*,2] are the period values.'
	  print,'	low_cut		Low value of frequency or period.'
	  print,'	high_cut	High value of frequency or period.'
	  print,'	type		Type is 1 for frequency, 2 for period.'
	  print,'KEYWORD PARAMETERS:'
	  print,'OUTPUTS:'
	  print,'	return_power(*,3).'
	  print,'	return_power(*,0) contains the transformed data,'
	  print,'	return_power(*,1) contains the frequency values,'
	  print,'	return_power(*,2) contains the period values.'
	  print,''
	  print,'COMMON BLOCKS:'
	  print,'NOTES:'
	  print,'MODIFICATION HISTORY:'
	  print,'      R. Bunting, 11 Jul 1996'
	  print,''
	  return,0
	endif


	spectrum=power(*,0)
	frequency=power(*,1)
	period=power(*,2)
	
	if type eq 1 then $
	begin
		index=where(frequency ge low_cut and frequency le high_cut, count)
		if count eq 0 then $
		begin
			spectrum_cut=[0]
			frequency_cut=[0]
			period_cut=[0]
		endif else $
		begin
			spectrum_cut=spectrum(index)
			frequency_cut=frequency(index)
			period_cut=period(index)
		
		endelse			
	endif else $
	begin
		index=where(period ge low_cut and period le high_cut, count)
		if count eq 0 then $
		begin
			spectrum_cut=[0]
			frequency_cut=[0]
			period_cut=[0]
		endif else $
		begin
			spectrum_cut=spectrum(index)
			frequency_cut=frequency(index)
			period_cut=period(index)
		
		endelse				
	
	endelse

;	Set up the return array
	return_data=fltarr(n_elements(spectrum_cut),3)
	return_data(*,0)=spectrum_cut
	return_data(*,1)=frequency_cut
	return_data(*,2)=period_cut
	
	return, return_data
	end
	
	
	
