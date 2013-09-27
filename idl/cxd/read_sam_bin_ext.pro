;-------------------------------------------------------------
;+
; NAME:
;       read_sam_bin
; PURPOSE:
;       Read SAMNET data from a 5 second format FORTRAN binary file.
; CATEGORY:
; CALLING SEQUENCE:
;	datafile=read_sam_bin(filename)
; INPUTS:
;	filename	filename of fortran data file
; KEYWORD PARAMETERS:
;         EXITCODE=x Returns exit code.  Always 0 unless the required
;			data could not be read from the file.
; OUTPUTS:
;	datafile = anonymous structure containing file name, 
;		   	header struct, data struct.
;
;	See also help,datafile,/structures
;
;	Structure defined as follows:
;		datafile={$
;			filename:filename,$
;			data_params:data_params,$
;			data_vals:data_vals}
;	Sub-definitions:
;
;
;		filename=string
;
;		data_params={datafile_parameters, $
;			titlestring: titlestring,$
;			st_name: '   ',$
;			min:L,$
;			sec:L,$
;			hour:L,$
;			dayno:L,$
;			day:L,$
;			month:L,$
;			year:L,$
;			nmins:L,$
;			npoints:L,$
;			samp_int:float}
;		
;		data_vals={data_values,$
;			h:fltarr(num_mins*num_per_min),$
;			d:fltarr(num_mins*num_per_min),$
;			z:fltarr(num_mins*num_per_min)}
;
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 25 Jan 1996
;	Modified to use structures pointing to data values and header
;			29 Jan 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------



	function read_sam_bin_ext, filename, $
	help=hlp, exitcode=exitcode

	if n_elements(filename) eq 0 then filename="    no filename set"

        if keyword_set(hlp) then $
          begin 
          print,''
	  print,' NAME:'
	  print,'       read_sam_bin'
	  print,' PURPOSE:'
	  print,'       Read SAMNET data from a 5 second format FORTRAN binary file.'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	datafile=read_sam_bin(filename)'
	  print,' INPUTS:'
	  print,'	filename	filename of fortran data file'
	  print,' KEYWORD PARAMETERS:'
	  print,'         EXITCODE=x Returns exit code.  Always 0 unless the required'
	  print,'			data could not be read from the file.'
	  print,' OUTPUTS:'
	  print,'	datafile = structure containing file name, header struct, data struct.'
	  print,''
	  print,'	See also help,datafile,/structures'
	  print,''
	  print,'	Structure defined as follows:'
	  print,'		datafile={$'
	  print,'			filename:filename,$'
	  print,'			data_params:data_params,$'
	  print,'			data_vals:data_vals}'
	  print,'	Sub-definitions:'
	  print,''
	  print,''
	  print,'		filename=string'
	  print,''
	  print,'		data_params={datafile_parameters, $'
	  print,'			titlestring: titlestring,$'
	  print,'			st_name: 3char string,$'
	  print,'			min:L,$'
	  print,'			sec:L,$'
	  print,'			hour:L,$'
	  print,'			dayno:L,$'
	  print,'			day:L,$'
	  print,'			month:L,$'
	  print,'			year:L,$'
	  print,'			nmins:L,$'
	  print,'			npoints:L,$'
	  print,'			samp_int:real}'
	  print,'		'
	  print,'		data_vals={data_values,$'
	  print,'			h:fltarr(num_mins*num_per_min),$'
	  print,'			d:fltarr(num_mins*num_per_min),$'
	  print,'			z:fltarr(num_mins*num_per_min)}'
	  print,''
	  print,''
	  print,''
	endif
	
	
	
	min=0L
	sec=0L
	hour=0L
	dayno=0L
	day=0L
	month=0L
	year=0L
	num_mins=0L
	num_points=0L
	num_per_min=0L
	sample_interval=0.
	titlestring_bytes=bytarr(70)
	titlestring_bytes(*)=32
	stn1_byte=bytarr(1)
	stn2_byte=bytarr(1)
	stn3_byte=bytarr(1)
	titlestring=string(titlestring_bytes)
	st_name='   '

	ret1=call_external('/usr/people/robert/lib/idl/readsambin.so', $
	'header_info', $
	filename, $
	titlestring, $
	st_name, $
	min, $
	hour, $
	dayno, $
	year, $
	num_mins, $
	num_points, $
	sample_interval)

	if year lt 50 then $
	begin
		print,'Year is ', year, ' assuming ', year+2000
		year=year+2000
	endif else if year lt 100 then $
	begin
		print,'Year is ', year, ' assuming ', year+1900
		year=year+1900
	endif

	ydn2md,year,dayno,month,day
; Want month to be a long. (not srictly necessary, but we do)
	month=0L+month
	
	data_params={datafile_parameters, $
	titlestring: titlestring,$
	st_name: st_name,min:min,sec:sec,$
	hour:hour,dayno:dayno,day:day,month:month,year:year,nmins:num_mins,$
	npoints:num_points,samp_int:sample_interval}


;	test return value.
	data_dummy={data_dummy,h:999.999,d:999.999,z:999.999}
	if ret1 ne 0  then $
	begin
	datafile={$
		filename:filename,$
		data_params:data_params,$
		data_vals:data_dummy}
	exitcode=1
	return, datafile
	
	endif
	
	h=fltarr(num_points)
	d=fltarr(num_points)
	z=fltarr(num_points)
	
	
	ret2=call_external('/usr/people/robert/lib/idl/readsambin.so', $
	'read_bin_data', $
	filename, $
	h, $
	d, $
	z, $
	num_points)
	
;	test return value.
	if ret2 ne 0  then $
	begin
	datafile={$
		filename:filename,$
		data_params:data_params,$
		data_vals:data_dummy}
	exitcode=1
	return, datafile
	endif
	
	data_vals={data_values,$
	h:h, $
	d:d, $
	z:z $
	}


	data_vals={data_values,$
		h:h, $
		d:d, $
		z:z  $
		}
	

	undef_array=where(data_vals.h eq 0.25*9999,undef_count)
	if undef_count ne 0 then data_vals.h(undef_array)=0
	undef_array=where(data_vals.d eq 0.25*9999,undef_count)
	if undef_count ne 0 then data_vals.d(undef_array)=0
	undef_array=where(data_vals.z eq 0.25*9999,undef_count)
	if undef_count ne 0 then data_vals.z(undef_array)=0
	datafile={$
			filename:filename,$
			data_params:data_params,$
			data_vals:data_vals}

	exitcode=0
	return, datafile
	
	io_error:
	no_output:
	no_file: print,!err_string
	datafile={$
		filename:filename,$
		data_params:data_params,$
		data_vals:data_dummy}
	exitcode=1
	return, datafile
	end

