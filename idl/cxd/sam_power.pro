;-------------------------------------------------------------
;+
; NAME:
;       sam_power
; PURPOSE:
;       Calculate a power spectrum from some samnet data
; CATEGORY:
; CALLING SEQUENCE:
;	return_power=sam_power(data_in, dt)
; INPUTS:
;	data_in		Array of time series data.
;	dt		Sample time interval
; KEYWORD PARAMETERS:
; OUTPUTS:
;	return_power(*,3).  Size may be larger than that of data_in.
;	return_power(*,0) contains the transformed data,
;	return_power(*,1) contains the frequency values,
;	return_power(*,2) contains the period values.
;
;	You probably only want the first n/2 of these.
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
	function sam_power, data_in, dt, $
	help=hlp

; print out help message if /help was used.
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,'NAME:'
	  print,'      sam_power'
	  print,'PURPOSE:'
	  print,'      Calculate a power spectrum from some samnet data'
	  print,'CATEGORY:'
	  print,'CALLING SEQUENCE:'
	  print,'	return_power=sam_power(data_in, dt)'
	  print,'INPUTS:'
	  print,'	data_in		Array of time series data.'
	  print,'	dt		Sample time interval'
	  print,'KEYWORD PARAMETERS:'
	  print,'OUTPUTS:'
	  print,'	return_power(*,3).  Size may be larger than that of data_in.'
	  print,'	return_power(*,0) contains the transformed data,'
	  print,'	return_power(*,1) contains the frequency values,'
	  print,'	return_power(*,2) contains the period values.'
	  print,''
	  print,'	You probably only want the first n/2 of these.'
	  print,''
	  print,'COMMON BLOCKS:'
	  print,'NOTES:'
	  print,'MODIFICATION HISTORY:'
	  print,'      R. Bunting, 11 Jul 1996'
	  print,''
	  return,0
	endif




	n_points=n_elements(data_in)
	undef_points=where(finite(data_in) eq 0, undef_count)
	if undef_count GT 0 then $
	begin
	    print,'*** There are ',undef_count,' undefined points in the '
	    print,'*** input data.  Setting to zero (may give wrong results)'
	    data_in(undef_points)=0.
	endif
;	Zero mean
	data_in=data_in-rb_mean(data_in)

;	Find a most efficient transform.
	n_transform=best_fft(n_points + n_points/40, delta=n_points/40)

;	Prolate spheroidal data window
	pro_spher,data_in,n_points,n_transform, dt, 1./(dt*n_transform)

	n21=n_points/2+1
	freq=findgen(n_transform)
	
	data=fltarr(n_transform)
	data(*)=0.0
	data((n_transform-n_points)/2)=data_in


;	Do the fft
	g=fft(data,1) 
	g=abs(g) ^2.0 /n_transform
;	g=abs(g*conj(g)) ^0.5 /n_transform
;	g=abs(g*conj(g)) ^2.0
;  g = g * (dt / n_transform) ; according to powlib.f ; must check valid.
;				( amp/div, div=df*n*n, df=1/(dt*n) )

;	f2=f(0:n/2-1)
;	g2=g(0:n/2-1)
;	plot,f2,g2,xrange=[0,cutf],/ylog

;	Set the array of frequencies
	n21=n_transform/2+1
	freq=findgen(n_transform)

	freq(n21)=n21-n_transform+findgen(n21-2)
	freq=freq*1.
	freq=freq/(n_transform*dt)

;	set the array of periods

	freq(0)=1E-30
	period=1/freq
	freq(0)=0
	period(0)=!values.d_infinity
	
;	Set up the return array, using only the positive frequencies/periods 
	return_data=fltarr(1+n_transform/2,3)
	return_data(*,0)=g(0:n_transform/2)
	return_data(*,1)=freq(0:n_transform/2)
	return_data(*,2)=period(0:n_transform/2)
	
	return, return_data
	end
	
	
	
