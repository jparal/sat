;-------------------------------------------------------------
;+
; NAME:
;       read_sam_asc
; PURPOSE:
;       Read SAMNET data from a 1 second format (1995 format) ASCII file.
; CATEGORY:
; CALLING SEQUENCE:
;	datafile=read_sam_asc_95(filename)
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
;       R. Bunting, 29 Jan 1996.  A modification of read_sam_bin()
;	Modified to use structures pointing to data values and header
;			29 Jan 1996
;	Name changed read_sam_asc -> read_sam_asc_95 to allow for
;	additional input module to read new (1995) format 1s files
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------



	function read_sam_asc_95_ext, filename, $
	help=hlp, exitcode=exitcode

	if n_elements(filename) eq 0 then filename="    no filename set"

        if keyword_set(hlp) then $
          begin 
          print,''
	  print,' NAME:'
	  print,'       read_sam_asc_95'
	  print,' PURPOSE:'
	  print,'       Read SAMNET data from a 1 second format (1995) ASCII file.'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	datafile=read_sam_asc_95(filename)'
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
	  print,'			samp_int:float}'
	  print,'		'
	  print,'		data_vals={data_values,$'
	  print,'			h:fltarr(num_mins*num_per_min),$'
	  print,'			d:fltarr(num_mins*num_per_min),$'
	  print,'			z:fltarr(num_mins*num_per_min)}'
	  print,''
	  print,''
	  print,''
	endif



	
	full_names=['far','nor','oul','gml','kvi','nur','yor','han','kil']
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
	titlestring_bytes(*)=32
	titlestring=string(titlestring_bytes)
	st_name='   '

        ret1=call_external('/usr/people/robert/lib/idl/readsamasc95.so', $
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

	st_name=strlowcase(string(st_name, format='(a2)'))
	full_pos=(where(strpos(full_names,st_name) eq 0))(0)
        if full_pos ne -1 then $
                st_name=full_names(full_pos)

        st_name=strupcase(st_name)
	titlestring=string(st_name, format='(a3,TR67)')


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



	data_vals={data_dummy,h:!values.f_nan,d:!values.f_nan,z:!values.f_nan}
	
	data_params={datafile_parameters, $
	titlestring: titlestring,$
	st_name: st_name,min:min,sec:sec,$
	hour:hour,dayno:dayno,day:day,month:month,year:year,nmins:num_mins,$
	npoints:num_points,samp_int:sample_interval}

	if ret1 ne 0 then $
	begin
		datafile={$
			filename:filename,$
			data_params:data_params,$
			data_vals:data_vals}
		exitcode=1
		return, datafile
	endif
	num_per_min=60./sample_interval
	h=fltarr(num_mins*num_per_min)
	d=fltarr(num_mins*num_per_min)
	z=fltarr(num_mins*num_per_min)

	ret2=call_external('/usr/people/robert/lib/idl/readsamasc95.so', $
        'read_asc95_data', $
        filename, $
        h, $
        d, $
        z, $
        num_points)

	
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
		h:h,$
		d:d,$
		z:z}
	
	undef_array=where(data_vals.h eq 9999.9,undef_count)
	if undef_count ne 0 then data_vals.h(undef_array)=0
	undef_array=where(data_vals.d eq 9999.9,undef_count)
	if undef_count ne 0 then data_vals.d(undef_array)=0
	undef_array=where(data_vals.z eq 9999.9,undef_count)
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
	exitcode=0

	return, datafile
	
	
	io_error:
	no_output:
	no_file: print,!err_string
	datafile={$
		filename:filename,$
		data_params:data_params,$
		data_vals:data_vals}
	exitcode=1
	return, datafile
	end

