;-------------------------------------------------------------
;+
; NAME:
;       sam_filter
; PURPOSE:
;	implement a digital filter of low, high or bandpass type
;	by concolution with a filter kernel.
; CATEGORY:
; CALLING SEQUENCE:
;	filtered_data=sam_filter(data, t_short, t_long, samp_int)
; INPUTS:
;	data		data to be filtered
;	t_short		short period cutoff (0 for low period, high freq pass)
;	t_long		long period cutoff  (0 for high period, low freq pass)
;	samp_int	sample interval, required to calculate f_nyq
; KEYWORD PARAMETERS:
; OUTPUTS:
;	filtered data!
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 7 Jan 1999
;
; Copyright (C) 1999, R Bunting, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function sam_filter, data, t_short, t_long, samp_int, help=hlp
	
	if n_elements(data) eq 0 then begin
		print,'sam_filter: no data given'
		hlp=1
	endif
	if n_elements(t_short) eq 0 then begin
		print,'sam_filter: no t_short given'
		hlp=1
	endif
	if n_elements(t_long) eq 0 then begin
		print,'sam_filter: no t_long given'
		hlp=1
	endif
	if n_elements(samp_int) eq 0 then begin
		print,'sam_filter: no samp_int given'
		hlp=1
	endif

        if keyword_set(hlp) then begin 
          print,''
	  print,' NAME:'
	  print,'       sam_filter'
	  print,' PURPOSE:'
	  print,'	implement a digital filter of low, high or bandpass type'
	  print,'	by concolution with a filter kernel.'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	filtered_data=sam_filter(data, t_short, t_long, samp_int)'
	  print,' INPUTS:'
	  print,'	data		data to be filtered'
	  print,'	t_short		short period cutoff (0 for low period, high freq pass)'
	  print,'	t_long		long period cutoff  (0 for high period, low freq pass)'
	  print,'	samp_int	sample interval, required to calculate f_nyq'
	  print,' KEYWORD PARAMETERS:'
	  print,' OUTPUTS:'
	  print,'	filtered data!'
	  print,''
	  print,''
	  print,' COMMON BLOCKS:'
	  print,' NOTES: requires rb_mean()'
	  print,' MODIFICATION HISTORY:'
	  print,'       R. Bunting, 7 Jan 1999'
	  print,''
	  print,' Copyright (C) 1999, R Bunting, York University Space Geophysics Group'
	  print,' This software may be used, copied, or redistributed as long as it is not'
	  print,' sold and this copyright notice is reproduced on each copy made.  This'
	  print,' routine is provided as is without any express or implied warranties'
	  print,' whatsoever.  Other limitations apply as described in the file disclaimer.txt.'
	  print,''
	  return,0
	endif
	if t_short eq 0 and t_long eq 0 then $
	begin
	  filtering = 0
	endif else $
	begin
;	setup a filter here for later use
;	gibbs was chosen to look most like the lanczos filter we used before!
	gibbs=76.8345
	f_nyquist=1./(2*samp_int)
;	print,f_nyquist,samp_int,t_short,t_long
;	help,f_nyquist,samp_int,t_short,t_long
	filter_terms=3*f_nyquist*max([t_short,t_long])
	
	  filtering=1
	  if t_short gt 2.*samp_int then f_high=1/(f_nyquist*t_short) else f_high=1
	  if t_long gt 2.*samp_int then f_low=1/(f_nyquist*t_long) else f_low=0
	  filter=digital_filter(f_low,f_high, gibbs, filter_terms)
;	  print, f_low, f_high, 'Freqs'
	endelse 	
	if filtering eq 1 then $
	begin
	  data2=data-rb_mean(data)
	  return,convol(data2, filter, /center, /edge_truncate)
	endif else begin
		return, data
	endelse
	
	end



;;g=76.8345
;;;g was chosen to look most like the lanczos filter we used before!
;;dt=5
;;high_t=30
;;low_t=00

;;f_nyquist=1./(2.*dt)
;;nterms=3*high_t*f_nyquist

;;if low_t gt dt then high_f=1/(f_nyquist*low_t) else high_f=1
;;if high_t gt dt then low_f=1/(f_nyquist*high_t) else low_f=0



;;f_nyquist=1./(2.*dt)
;;nterms=3*high_t*f_nyquist


;;;print,low_f, high_f, f_nyquist, 1/20.
;;filter=digital_filter(low_f,high_f, g, nterms)

;;a=read_sam("far_010391")
;;data=a.data_vals.z(14400:17279)
;;data=data-rb_mean(data)
;;hfiltered=convol(data, filter, /center, /edge_truncate)

;;plot,hfiltered

;;end
