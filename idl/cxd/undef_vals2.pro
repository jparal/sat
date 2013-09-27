;-------------------------------------------------------------
;+
; NAME:
;       undef
; PURPOSE:
;       Make data value undefined in regions where there are large data jumps
;	
; CATEGORY:
; CALLING SEQUENCE:
;	return_data=undef(data,max_jump,undef_val)
; INPUTS:
;	data		data array
;	max_jump	maximum permissible data_jump
;	undef_val	undefined data value required
; KEYWORD PARAMETERS:
; OUTPUTS:
; 	return_data	data with undefined stretches
;
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 16 Jul 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function undef_vals2, data,max_jump,undef_val, $
	help=hlp

; print out help message if /help was used.
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,'NAME:'
	  print,'      undef'
	  print,'PURPOSE:'
	  print,'      Make data value undefined in regions where there are large data jumps'
	  print,'	'
	  print,'CATEGORY:'
	  print,'CALLING SEQUENCE:'
	  print,'	return_data=undef(data,max_jump,undef_val)'
	  print,'INPUTS:'
	  print,'	data		data array'
	  print,'	max_jump	maximum permissible data_jump'
	  print,'	undef_val	undefined data value required'
	  print,'KEYWORD PARAMETERS:'
	  print,'OUTPUTS:'
	  print,'	return_data	data with undefined stretches'
	  print,''
	  print,'COMMON BLOCKS:'
	  print,'NOTES:'
	  print,'MODIFICATION HISTORY:'
	  print,'      R. Bunting, 16 Jul 1996'
	  print,''
	  return,0
	endif

; 	data1=data
; 	npoints=n_elements(data1)
; 	data2=fltarr(npoints+1)
; 	
; 	data2(0)=data1(0)
; 	data2(1)=data1
; 	data2=data2(0:npoints-1)
; 	
; 	undef_array=where(abs(data2-data1) GT max_jump, undef_count)
; 	
; 	if undef_count gt 0 then $
; 	begin
; 		for place=0, undef_count-1 do $
; 		begin
; 			count=0
; 			orig=data(undef_array(place))
; 			last=data(undef_array(place)-1)
; 			while undef_array(place)+count le npoints AND $
; 				data(undef_array(place)+count) eq orig do $
; 			begin
; 				data1(undef_array(place)+count) = undef_val
; 				count=count+1
; 			endwhile
; 		endfor
; 	endif
; 		
; 	if undef_count gt 0 then data1(undef_array) = undef_val

;This lot wasn't working where there was a jump and then some small wibbles.
;Go back to the original unimag method; this doesn't work too well if
;max_jump isn't large enough -  it loses all the data after that point.

 	data1=data
 	npoints=n_elements(data1)
	point=1
	firstpoint=data1(0)
;					This below looks a bit odd.
;					Need a value if point=npoints, so use []
;					Need to give a scalar, so use (0)

	while point lt npoints and (data1([point]))(0) eq firstpoint do $
	begin
		point=point+1
	endwhile
	if point gt npoints-1 then point=npoints-1
	if point gt 1 then data1(0:point-1)=undef_val
	last=data1(point)

;	Note the 0L to make sure that i is a long integer type variable
; 	for i=0L+point+1L,npoints-1 do $
; 	begin
; 		if abs(data1(i)-last) gt max_jump then $
; 		begin
; 			data1(i)=undef_val
; 		endif else $
; 		begin
; 			last=data1(i)
; 		endelse
; 	endfor
	
;	New Cunning method

	i=0L+point+1L
	if i+1L gt npoints then goto,clear
	ok:
	next_bad=(where(abs(data1(i:*)-last) gt max_jump))(0)
	if next_bad eq -1 then goto, clear
	print,next_bad
	if abs(data1(next_bad+i)-data1(next_bad+i-1)) le max_jump then $
	begin
		;(not really bad)
		i=i+next_bad
		last=data1(i-1)
		goto,ok
	endif else $
	begin
		i=i+next_bad
		still_bad=(where(abs(data1(i:*)-last) le max_jump))(0)
		if still_bad(0) eq -1 then $
		begin
			data1(i:*)=undef_val
			goto, clear
		endif else $
		begin
			data1(i:still_bad+i-1)=undef_val
			i=i+still_bad
		endelse
	endelse
	
;	stop
	clear:
; 	print,'End'
; 	stop
; 	i=0L+point+1L
; 	still_bad=0
; 	
; 	
; 	for i=0L+point+1L,npoints-1 do $
; 	begin
; 		if abs(data1(i)-last) gt max_jump then $
; 		begin
; 			data1(i)=undef_val
; 		endif else $
; 		begin
; 			last=data1(i)
; 		endelse
; 	endfor
; 
	


;	Now, if there is no legal data, it causes problems later, so 
;	we insert on legal data value.

	dummy=where(finite(data1), where_count)
	if where_count eq 0 then data1(0)=0.
	
	return, data1
	end
	
	
	
