;-------------------------------------------------------------
;+
; NAME:
;       read_sam
; PURPOSE:
;       Read SAMNET data from a 5 second format data file (ASCII or binary)
; CATEGORY:
; CALLING SEQUENCE:
;	datafile=read_sam(filename)
; INPUTS:
;	filename	filename of data file
; KEYWORD PARAMETERS:
;         EXITCODE=x Returns exit code.  Always 0 unless the required
;			data could not be read from the file.
;	  TEST		If we just want to test for the accesssibility
;			of the file, not read it in
; OUTPUTS:
;	datafile = anonymous structure containing file name, 
;			header struct, data struct.
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
;       R. Bunting, 29 Jan 1996
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



	function read_sam, filename, $
	help=hlp,test=test, exitcode=exitcode

	if n_elements(filename) eq 0 then filename="    no filename set"
	if n_elements(test) eq 0 then test=0

        if keyword_set(hlp) then $
          begin 
          print,''
	  print,' NAME:'
	  print,'       read_sam'
	  print,' PURPOSE:'
	  print,'       Read SAMNET data from a 5 second format data file. (ASCII or binary)'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	datafile=read_sam(filename)'
	  print,' INPUTS:'
	  print,'	filename	filename of data file'
	  print,' KEYWORD PARAMETERS:'
	  print,'         EXITCODE=x Returns exit code.  Always 0 unless the required'
	  print,'			data could not be read from the file.'
	  print,'	  TEST		If we just want to test for the accesssibility'
	  print,'			of the file, not read it in'
	  print,' OUTPUTS:'
	  print,'	datafile = anonymous structure containing file name, '
	  print,'			header struct, data struct.'
	  print,''
	  print,'	See also help,datafile,/structures'
	  print,''
	  print,'	Structure defined as follows:'
	  print,'		datafile={$,'
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
	  goto,no_output
	endif
	
	tmp=0
	if (strlen(filename)-rstrpos(filename, 'gz') eq 2) then begin
		tmp=1
		tmpname=strmid(filename, 0,rstrpos(filename,'gz'))
		tmpname=strmid(tmpname, rstrpos(tmpname,'/')+1,strlen(tmpname))
		tmpfile="/var/tmp/"+tmpname
		spawn,"/bin/rm -f " + tmpfile
		unzip_command="/usr/local/bin/gunzip -cf " + filename + $
			" > " + tmpfile + " && /bin/echo OK"
		print,unzip_command
;"/usr/local/bin/gunzip -cf " + filename + " > " + tmpfile + " && /bin/echo OK"
		spawn, unzip_command, result, count=rescount
		; we use the && echo OK to get an output if it works, which
		; we can test for in the spawn command.  Otherwise, we have
		; no way of knowing the spawned gunzip worked.
		if rescount ne 1 then begin
			filename=tmpfile
			goto, no_file
		endif
		filename=tmpfile
	; if the uncompress fails, we're in a bit of a muddle.
	endif

	
	if (findfile(filename))(0) eq '' then begin
		goto, no_file
	endif
	if test(0) eq 1 then begin
		exitcode=0
		print,'found file ok', filename
		goto, no_output
	endif

	print,filename

	on_ioerror, no_file
	
	b24=bytarr(24)
	openr,in_unit,filename,/get_lun
	readu,in_unit,b24
	free_lun,in_unit
	if ( b24(0) eq 0 $
	 and b24(1) eq 0 $
	 and b24(2) eq 0 $
	 and b24(3) eq 70) then $
	  begin
	  datafile=read_sam_bin_pure_idl(filename,exitcode=exitcode)
; Or use a call_external version
;	  datafile=read_sam_bin_ext(filename,exitcode=exitcode)
	endif else if b24(0) eq 35 then $
	  begin
	  	datafile=canopus_input_dkm(filename,exitcode=exitcode)

	endif else if b24(0) lt 97 then $
	  begin
	  datafile=read_sam_asc_87(filename,exitcode=exitcode)
;	  datafile=read_sam_asc_87(filename,exitcode=exitcode)
;	endif else if b24(20) eq 48 and b24(21) eq 53 then $
;	  begin
;		datafile=read_sam_asc_95_5s_pure_idl(filename, exitcode=exitcode)

	endif else $
	  begin
		datafile=read_sam_asc_95_pure_idl(filename,exitcode=exitcode)
;		datafile=read_sam_asc_95_ext(filename,exitcode=exitcode)
	endelse
	
	if(tmp eq 1)then spawn,"/bin/rm -f " + tmpfile
	return, datafile
	
	
	no_file: print,!err_string
	print,'### Error reading file '+filename

	exitcode=1
	filename="no-file"
	no_output:
;	Set up some dummy data for exiting with

	titlestring=string(' ',format='(1a,TR69)')
	data_params={datafile_parameters, $
	titlestring: titlestring,$
	st_name: '   ',min:0L,sec:0L,$
	hour:0L,dayno:0L,day:0L,month:0L,year:0L,nmins:0L,$
	npoints:0L,samp_int:0.0}
	data_dummy={data_dummy,h:999.999,d:999.999,z:999.999}
	datafile={$
		filename:filename,$
		data_params:data_params,$
		data_vals:data_dummy}
	print,'### Returning dummy (zero) data'
	if(tmp eq 1)then spawn,"/bin/rm -f " + tmpfile
	return, datafile
	end

