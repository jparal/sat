;-------------------------------------------------------------
;+
; NAME:
;       read_sam_asc
; PURPOSE:
;       Read SAMNET data from a 5 second format (1987 format) ASCII file.
; CATEGORY:
; CALLING SEQUENCE:
;	datafile=read_sam_asc_87(filename)
; INPUTS:
;	filename	filename of ASCII data file
; KEYWORD PARAMETERS:
;         EXITCODE=x Returns exit code.  Always 0 unless the required
;			data could not be read from the file.
; OUTPUTS:
;	datafile = structure containing file name, header struct, data struct.
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
;			samp_int:real}
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
;       R. Bunting, 29 Jan 1996.  A modification of read_sam_bin()
;	Modified to use structures pointing to data values and header
;			29 Jan 1996
;	Name changed read_sam_asc -> read_sam_asc_87 to allow for
;	additional input modeule to read new (1995) format 1s files
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------



	function read_sam_asc_87, filename, $
	help=hlp, exitcode=exitcode

	if n_elements(filename) eq 0 then filename="    no filename set"

        if keyword_set(hlp) then $
          begin 
          print,''
	  print,' NAME:'
	  print,'       read_sam_asc_87'
	  print,' PURPOSE:'
	  print,'       Read SAMNET data from a 5 second format (1987) ASCII file.'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	datafile=read_sam_asc_87(filename)'
	  print,' INPUTS:'
	  print,'	filename	filename of ASCII data file'
	  print,' KEYWORD PARAMETERS:'
	  print,'         EXITCODE=x Returns exit code.  Always 0 unless the required'
	  print,'			data could not be read from the file.'
	  print,' OUTPUTS:'
	  print,'	datafile = anonymous structure containing file name, '
	  print,'			header struct, data struct.'
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
	
	
	
	stn1=" "
	stn2=" "
	stn3=" "
	min=0L
	sec=0L
	hour=0L
	dayno=0L
	day=0L
	month=0L
	year=0L
	num_mins=0L
	num_points=0L
	sample_interval=0.
	titlestring_bytes=bytarr(70)
	stn1_byte=bytarr(1)
	stn2_byte=bytarr(1)
	stn3_byte=bytarr(1)
	titlestring=string(titlestring_bytes)
	
	data_params={datafile_parameters, $
	titlestring: titlestring,$
	st_name: stn1+stn2+stn3,min:min,sec:sec,$
	hour:hour,dayno:dayno,day:day,month:month,year:year,nmins:num_mins,$
	npoints:num_points,samp_int:sample_interval}

	data_dummy={data_dummy,h:!values.f_nan,d:!values.f_nan,z:!values.f_nan}
	
	on_ioerror, no_file
	
	openr,in_unit,filename,/get_lun
	
	on_ioerror, io_error

	readf,in_unit,stn1,stn2,stn3,$
	year,month,day,hour,min,sec,sample_interval,$
	format='(A1,A1,A1,1X,i2,1x,2i2,1x,3i2,2x,i1)'

	titlestring=string(stn1,stn2,stn3, format='(3a1,TR67)')
	
        if year lt 50 then $
        begin
                print,'Year is ', year, ' assuming ', year+2000
                year=year+2000
        endif else if year lt 100 then $
        begin
                print,'Year is ', year, ' assuming ', year+1900
                year=year+1900
        endif

	dayno=ymd2dn(year,month,day)

;	Assume a whole day file
	num_mins=1440
	num_points=17280

	data_params={datafile_parameters, $
	titlestring: titlestring,$
	st_name: stn1+stn2+stn3,min:min,sec:sec,$
	hour:hour,dayno:dayno,day:day,month:month,year:year,nmins:num_mins,$
	npoints:num_points,samp_int:sample_interval}

	point_lun,in_unit,0	
	
	num_points=0L
	templine=lonarr(18)
	st_id=' '
	num_per_min=60./sample_interval
	
	h=fltarr(num_mins*num_per_min)
	d=fltarr(num_mins*num_per_min)
	z=fltarr(num_mins*num_per_min)
	temp=fltarr(num_per_min*3)

	hdzvals=fltarr(3,17280)
;	The / starts the next line of input, the : is used to not do the 
;	last newline if there is not any more input. (eg if there is no
;	final newline on the file or something)

;	if there is an io error here, we would rather keep what data we have.
	on_ioerror,continue
	
	readf,in_unit,hdzvals,format='(/,60(18i4,:,/))'
	continue:
	h(0)=reform(hdzvals(2,*))
	d(0)=reform(hdzvals(1,*))
	z(0)=reform(hdzvals(0,*))
	h=h/4.0
	d=d/4.0
	z=z/4.0

;	This compound read takes half the time of the loop version

; 	for block=1,48 do $
; 	  begin
; 	  readf,in_unit,stn1,stn2,stn3,$
; 	  year,month,day,hour,min,sec,sample_interval,$
; 	  format='(A1,A1,A1,1X,i2,1x,2i2,1x,3i2,2x,i1)'
; 	  
; 	  for line=1,60 do $
; 	    begin
; 	    readf,in_unit,templine,st_id,day_id,rec_id,$
; 	    format='(18i4,a1,i3,i4)'
; 	    for samp=0,5 do $
; 	      begin
; 	      data_vals.h(num_points)=0.25 * templine((3*samp ))
; 	      data_vals.d(num_points)=0.25 * templine((3*samp )+1)
; 	      data_vals.z(num_points)=0.25 * templine((3*samp )+2)
;       	      num_points=num_points+1
; 	    endfor
; 	  endfor
; 	endfor	
	data_vals={data_values,$
		h:h,$
		d:d,$
		z:z}
	close,in_unit
	free_lun,in_unit
	
	undef_array=where(data_vals.h eq 0.25*9999,undef_count)
	if undef_count ne 0 then data_vals.h(undef_array)=0
	undef_array=where(data_vals.d eq 0.25*9999,undef_count)
	if undef_count ne 0 then data_vals.d(undef_array)=0
	undef_array=where(data_vals.z eq 0.25*9999,undef_count)
	if undef_count ne 0 then data_vals.z(undef_array)=0

;	alternatively, generate a bit array, then multiply by an array a(i)=i,
;	and use this to set relevant elements to zero.  This doesn't work,
;	cos it always sets h(0).

;	data_vals.h((data_vals.h eq 0.25*9999)*findgen(n_elements(data_vals.h)))=0
;	data_vals.d((data_vals.d eq 0.25*9999)*findgen(n_elements(data_vals.d)))=0
;	data_vals.z((data_vals.z eq 0.25*9999)*findgen(n_elements(data_vals.z)))=0

	datafile={$
			filename:filename,$
			data_params:data_params,$
			data_vals:data_vals}
	free_lun,in_unit
	exitcode=0

	return, datafile
	
	
	io_error:
	free_lun,in_unit
	stop
	no_output:
	no_file: print,!err_string
	datafile={$
		filename:filename,$
		data_params:data_params,$
		data_vals:data_dummy}
	exitcode=1
	return, datafile
	end

