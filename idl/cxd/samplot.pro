;-------------------------------------------------------------
;+
; NAME:
;       samplot
; PURPOSE:
;       Plot SAMNET data from a series of 1/5 second format 
;	data files (ASCII or binary)
; CATEGORY:
; CALLING SEQUENCE:
;	samplot,filenames,components
; INPUTS:
;	filenames	Array of filenames to be used to find data
;	components(optional)
;			Array of flags to determine which component will
;			be plotted from each file.
;			The number for a file is constructed bitwise
;			using H=1,D=2,Z=4
;			e.g. to plot H and D, use 3
;			     to plot H,D and Z use 7.
;			To plot H and D from two files use [3,3]
;			If this parameter is left out, a value
;			will be prompted for.
; KEYWORD PARAMETERS:
;	st_min=start_minute
;			Give a value for the start minute of the plot required
;	len_min=length
;			Give a value for the length of plot required in minutes
;	filter_long=filter_long
;			Give a value for the long period filter to be applied
;	filter_short=filter_short
;			Give a value for the short period filter to be applied
;	user_title=user_title
;			Give a value for the user title string
;		If any of these are not set, the user is prompted for them during
;		the run.
;	power		If this is set, power spectra are plotted rather than 
;			raw data.
; OUTPUTS:
;	Creates a plot.  Used current default plot device, but if PS, then
;	sets up full page portrait, if X, sets up a 600x800 window.
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 2 Feb 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

	pro samplot, filename_array, comp_array,st_min=smin,len_min=lmin, $
	filter_long=t_long, filter_short=t_short, user_title=usertitlestring, $
	power=power, x_cutoff_low=x_cutoff_low, x_cutoff_high=x_cutoff_high, $
	pow_xaxis=pow_xaxis, pow_yaxis=pow_yaxis, range=range, $
	help=hlp

; print out help message if /help was used.
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,' NAME:'
	  print,'       samplot'
	  print,' PURPOSE:'
	  print,'       Plot SAMNET data from a series of 5 second format '
	  print,'	data files (ASCII or binary)'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,'	samplot,filenames,components'
	  print,'	e.g. samplot,["far_010391", "oul_010391"],[3,3] plots'
	  print,'	H and D from two station files'
	  print,' INPUTS:'
	  print,'	filenames	Array of filenames to be used to find data'
	  print,'	components(optional)'
	  print,'			Array of flags to determine which component will'
	  print,'			be plotted from each file.'
	  print,'			The number for a file is constructed bitwise'
	  print,'			using H=1,D=2,Z=4'
	  print,'			e.g. to plot H and D, use 3'
	  print,'			     to plot H,D and Z use 7.'
	  print,'			To plot H and D from two files use [3,3]'
	  print,'			If this parameter is left out, a value'
	  print,'			will be prompted for.'
	  print,' KEYWORD PARAMETERS:'
	  print,'	st_min=start_minute'
	  print,'			Give a value for the start minute of the plot required'
	  print,'	len_min=length'
	  print,'			Give a value for the length of plot required in minutes'
	  print,'	filter_long=filter_long'
	  print,'			Give a value for the long period filter to be applied'
	  print,'	filter_short=filter_short'
	  print,'			Give a value for the short period filter to be applied'
	  print,'	user_title=user_title'
	  print,'			Give a value for the user title string'
	  print,'		If any of these are not set, the user is prompted for them during'
	  print,'		the run.'
	  print,'	power		If this is set, power spectra are plotted rather than'
	  print,'			raw data.'
	  print,' OUTPUTS:'
	  print,'	Creates a plot.  Used current default plot device, but if X, '
	  print,'	sets up a 600x800 window.'
	  print,''
	  return
	endif


	; check for a valid call.
	case n_params() of
	1: BEGIN
	  chargot=' '
	  comps=' h d z hd h/d 3 '
;	  while chargot ne 'h' AND chargot ne 'd' AND chargot ne 'z' AND chargot ne '3' do $
	  while strpos(comps, chargot) eq -1 OR chargot eq ' ' do $
	  begin
	    read,chargot, prompt='Components to plot (h, d, z, hd, h/d or 3) : '
	    chargot=strlowcase(chargot)
	  endwhile
	  ncomp=n_elements(filename_array)
	  comp_array=intarr(ncomp)
	  if chargot eq 'h' then comp_array(*)=1
	  if chargot eq 'd' then comp_array(*)=2
	  if chargot eq 'z' then comp_array(*)=4
	  if chargot eq '3' then comp_array(*)=7
	  if chargot eq 'hd' then comp_array(*)=3
	  if chargot eq 'h/d' then comp_array(*)=8
	END
	2: BEGIN
	  ncomp=max([n_elements(comp_array),n_elements(filename_array)])
	END
	else: begin
	  print,'Wrong number of arguments'
	  return
	end
	endcase
	
;	expand any wildcarded filenames in the input string array

	for filenames=0,n_elements(filename_array)-1 do $
	  begin
	  expanded=findfile(filename_array(filenames))
	  if (expanded(0) eq '') then $
	  begin
	    print,'*** Error: file '+filename_array(filenames)+' not found'
	  endif else $
	  begin
	    if n_elements(temp_array) eq 0 then $
	    begin
	      temp_array=[expanded]
	    endif else $
	    begin
	      temp_array=[temp_array,expanded]
            endelse
	  endelse
	end
	if(n_elements(temp_array) gt n_elements(filename_array)) then $
	begin
	  comp=comp_array(0)
	  ncomp=n_elements(temp_array)
	  comp_array=intarr(ncomp)
	  comp_array(*)=comp
	endif
	ncomp=n_elements(temp_array)
	if n_elements(temp_array) eq 0 then $
	begin
		print,'*** Error: no files found'
		exit
	endif
	filename_array=temp_array

; Set a y scale range from input, or use default of 0 for autoscaling if
; not set

	if(n_elements(range) eq 0) then $
		range=0



; work out number of components to plot, checking for files present as we go.
	hdzcomps=intarr(5)
	num_plots=0
	for place=0,ncomp-1 do $
	  begin
	  hdzcomps(*)=0
	  filename=filename_array(place)
	  print,'### Looking for file #',filename,'#'
	  exit_status=1
	  dummy=read_sam(filename, exitcode=exit_status, test=1)
;	  exit_status=0
	  if exit_status ne 0 then begin
	    print,'*** Error: file '+filename+' not found'
	  endif else begin
	    print,'### Found file '+filename
	    component_byte=comp_array(place mod n_elements(comp_array))
	    hdzcomps(0)=(component_byte and 1 )
	    hdzcomps(1)=(component_byte and 2 )/2        
	    hdzcomps(2)=(component_byte and 4 )/4
	    hdzcomps(3)=(component_byte and 8 )/8
	    num_plots=num_plots+hdzcomps(0)+hdzcomps(1)+hdzcomps(2)+hdzcomps(3)
	  endelse
	endfor
	if num_plots eq 0 then return           ; nothing to plot!
	print,'### Plotting ',num_plots,' panels'
;
;
; Here we set up the PAGE LAYOUT
;
;
; Suitably enlarge the plotting window for X
;
;	if !d.name eq 'X' then window,xsize=600,ysize=800
;
; Or make a full page plot for PS (may need to take this out if people
; want to set up their own page formats.  Otherwise, this gets rid of
; the default 'half page only' setup which isn't very sensible for multiple
; plots like these.
;
;	if !d.name eq 'PS' then $
;	  begin
;	  device, /portrait, /inches, xoffset=0.5, yoffset=0.5, $
;	  xsize=7.5, ysize=10.25
;	endif
;
; Set each panel to have individual X axis ticks and label if less than
; six plots, otherwise only bottom panel has these values.  Also need to
; allow space for them by setting the margin size.

	if num_plots lt 1 then $
	  begin
;previous	  !y.margin=[4,1]
	  !y.margin=[4,1]
	  tic_labelling=1
	endif else $
	  begin
;previous	  !y.margin=[0.5,0.5]
	  !y.margin=[0,0.1]
	  tic_labelling=0
	endelse
	  
; A suitable character size for text.  IDL has a tendency to halve this
; when putting a lot of plots (more than 2) on one page.

	!p.charsize = 2.0
	!p.charsize=1.0
	if !d.name eq 'PS' then  begin
		!p.charsize=2.0*!p.charsize
	endif

	!p.thick=0.1
;
;	Largest data jump between points before we consider it a datagap
;	(need this when we're not sure what the undef value is)
	jump_value=500
;	jump_value=50
;
; Set up for plotting num_plots plots on a page.  All in one column.

	!y.omargin=[4,4]	
	!p.multi = [num_plots,1,num_plots,0,0]
	title_xpos=!d.x_size/2
	title_ypos=!d.y_size-(2.0*!d.y_ch_size)
	usertitle_xpos=!d.x_size/2
	usertitle_ypos=!d.y_size-(3.5*!d.y_ch_size)
	last_panel=1
	
;	default number of minor ticks, but may be changed later.
	!x.minor=10
	!y.minor=4
	!y.ticks=4
;	The names for the power plot axes are...
	fp_axis_titles=['Frequency (mHz)','Period (s)']
	loglin_axis_titles=['Power','Log Power']

;
;
; Maybe here would be a good place to get the program parameters from the
; first file, for instance, number of minutes etc.
;

	dssec=0L
	desec=1440L*60-1
	ssec=-1L
	esec=-2L

; Check for a keyworded input value of smin
	if n_elements(smin) gt 0 then ssec=smin*60L

	while ssec lt dssec or ssec gt desec do $
	begin
	  read,shour,smin, prompt='Start time (hours,mins) : '
;	shour=0 & smin=0
	  ssec=0L
	  ssec=ssec+60*smin+3600*shour
	endwhile

	lsec=0
; Check for a keyworded input value of lmin
	if n_elements(lmin) gt 0 then lsec=lmin*60L

	esec=ssec+lsec-1

;	while esec gt desec or esec lt ssec do $
	while esec lt ssec do $
	begin
	  read,lhour,lmin, prompt='Data length (hours,minutes) : '
;	lhour=24 & lmin=0
	  lsec=lhour*3600L + lmin*60L
	  esec=ssec+lsec-1
	endwhile
	
	if lsec gt 4200L AND lsec le 4*3600L then !x.minor=15

	

; Check for a keyworded input value of t_long
	if n_elements(t_long) eq 0 then $
	begin
		read,t_long, prompt='Long period filter (seconds) : '
	endif
; Check for a keyworded input value of t_short
	if n_elements(t_short) eq 0 then $
	begin
		read,t_short, prompt='Short period filter (seconds) : '
	endif

; Check for a keyworded input value of usertitlestring
	if n_elements(usertitlestring) eq 0 then $
	begin
		usertitlestring=''
		read,usertitlestring,format='(a)', prompt='Plot title : '
	endif
	
	if keyword_set(power) then $
	begin
		if n_elements(pow_xaxis) eq 0 then pow_xaxis=''
		if n_elements(pow_yaxis) eq 0 then pow_yaxis=''
		while pow_xaxis ne 't' and pow_xaxis ne 'f' do $
		begin
			read,pow_xaxis, $
				prompt='X axis in Frequency or Time? [f/t] '
			pow_xaxis=strlowcase(pow_xaxis)
		endwhile
		pow_xaxis_type=(pow_xaxis eq 't') + 1
		while pow_yaxis ne 'lin' and pow_yaxis ne 'log' do $
		begin
			read,pow_yaxis, $
				prompt='Y axes Linear or Logarithmic? [lin/log] '
			pow_yaxis=strlowcase(pow_yaxis)
		endwhile
		pow_yaxis_type=(pow_yaxis eq 'log') + 1
		if n_elements(x_cutoff_low) eq 0 then $
		begin
			if pow_xaxis eq 't' then $
			begin
				read, x_cutoff_low, $
					prompt='Low Cutoff on X axis? (seconds) '
			endif else $
			begin
				read, x_cutoff_low, $
					prompt='Low Cutoff on X axis? (mHz) '
			endelse			
		endif
		if n_elements(x_cutoff_high) eq 0 then $
		begin
			if pow_xaxis eq 't' then $
			begin
				read, x_cutoff_high, $
					prompt='High Cutoff on X axis? (seconds) '
			endif else $
			begin
				read, x_cutoff_high, $
					prompt='High Cutoff on X axis? (mHz) '
			endelse
		endif
;	If we have frequency axis, divide by 1000
		if pow_xaxis eq 'f' then $
		begin
			x_cutoff_high=x_cutoff_high/1000.
			x_cutoff_low=x_cutoff_low/1000.
		endif
		!x.title=fp_axis_titles(pow_xaxis_type-1)
		!y.title=loglin_axis_titles(pow_yaxis_type-1)


;	Later need to add smoothing options here etc.
	endif

	print, $
	format='("### Using data from ",i2.2,":",i2.2," for ",i4," minutes")', $
	ssec/3600, (ssec mod 3600)/60, lsec/60
;	print, ssec,lsec,esec

	all_type=comp_array(0)
	    
	for place=0,ncomp-1 do $
	  begin
	  hdzcomps(*)=0
	  filename=filename_array(place)
	  print,format='(/,"### Begun reading data file: ",a)',filename
	  filedata=read_sam(filename,exit=ex)
	  if ex ne 0 then begin
	    print,'*** Error reading file: '+filename
	  endif else begin
	    print,format='("### Done reading data file:  ",a)',filename
	    
;   get some file parameters
	     
;	    titlestring=filename
	    mag_array='SAMNET'
	    titlestring=strmid(filedata.data_params.titlestring,0,3)
	    print,'titlestring= ',filedata.data_params.titlestring
	    if (STRCMP(titlestring,'ima',3,/FOLD_CASE)) THEN BEGIN
	    	print,'IMAGE array detected'
	    	titlestring = strmid(filename,0,3)
		mag_array='IMAGE'
	    ENDIF
		
	    samp_int=filedata.data_params.samp_int
;
;   set start and end of data using info in seconds and sample interval.
;   this should allow us to deal with 5 second, 1 second, etc files.
;
	    file_ssec=filedata.data_params.hour*3600 + filedata.data_params.min*60
	    spoint=(ssec-file_ssec)/samp_int
	    lpoint=lsec/samp_int
	    epoint=spoint+lpoint-1
	    print,format='("### File has      ",i6," points")', $
	    	filedata.data_params.npoints
	    print,format='("### Plotting from ",i6," to ",i6)', $
	    	spoint,epoint
	    num_points_plot=lpoint

	    t=findgen(num_points_plot)
	    tx=t*samp_int + ssec
	     
;   Check which components to plot
	    component_byte=comp_array(place mod n_elements(comp_array))
	    hdzcomps(0)=(component_byte and 1 )
	    hdzcomps(1)=(component_byte and 2 )/2
	    hdzcomps(2)=(component_byte and 4 )/4
	    hdzcomps(3)=(component_byte and 8 )/8
	    if component_byte ne all_type then all_type=0

;	    setup a filter here for later use

;	    gibbs was chosen to look most like the lanczos filter we used before!
	    gibbs=76.8345
	    f_nyquist=1./(2*samp_int)
;	    print,f_nyquist,samp_int
	    filter_terms=3*f_nyquist*max([t_short,t_long])
	
	    if t_short eq 0 and t_long eq 0 then $
	    begin
	      filtering = 0
	    endif else $
	    begin
	      filtering=1
	      if t_short gt 2.*samp_int then f_high=1/(f_nyquist*t_short) else f_high=1
	      if t_long gt 2.*samp_int then f_low=1/(f_nyquist*t_long) else f_low=0
	      filter=digital_filter(f_low,f_high, gibbs, filter_terms)
;	      print, f_low, f_high, 'Freqs'
	    endelse	    

; H component plot
	    if hdzcomps(0) then begin
	      data=filedata.data_vals.h
	      data=data(t+spoint) 	
;	                ^ this cunning ruse allows us to always get num_points_plot
;		     	   datapoints, even if there are not that many in the data
;			   array.  Simply pads with the last data value.  Not totally
;			   convinced this is valid.  May need to find a better way.

              data=undef_vals(data,jump_value,!values.f_nan)
;	      do some filtering here
	      if filtering eq 1 then $
	      begin
	        data=data-rb_mean(data)
	        data=convol(data, filter, /center, /edge_truncate)
	      endif

;	      Change the data for a spectrum if we are power plotting
	      if keyword_set(power) then $
	      begin
	        pow_array=sam_power(data, samp_int)
	        pow_cutoff=cutoff(pow_array, $
	        	x_cutoff_low, x_cutoff_high, pow_xaxis_type)
	        data=pow_cutoff(*,0)
	        tx=pow_cutoff(*,pow_xaxis_type)
	        if pow_xaxis eq 'f' then tx=tx*1000
	        annotation_string=titlestring+',H Power'
	        !x.tickformat='(f8.1)'
	        if pow_yaxis eq 'log' then !y.tickformat='(e6.0)'
;	        Plot a power spectrum with plain old x axis
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0, ytype=pow_yaxis_type-1,$
		  range=range
	      endif else $
	      begin
	        annotation_string=titlestring+',H'
	        
;	        data=undef_vals(data,1000,9999.9)
	        
;		print,'ranges2',range
;	        A time series plot has /time type x axis.
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0,/time,$
		  range=range
	      endelse
	    endif

; D component plot
	    if hdzcomps(1) then begin
	      data=filedata.data_vals.d
	      data=data(t+spoint)
	      
              data=undef_vals(data,jump_value,!values.f_nan)
;	do some filtering here
	      if filtering eq 1 then $
	      begin
	        data=data-rb_mean(data)
	        data=convol(data, filter, /center, /edge_truncate)
	      endif

;	Change the data for a spectrum if we are power plotting
	      if keyword_set(power) then $
	      begin
	        pow_array=sam_power(data, samp_int)
	        pow_cutoff=cutoff(pow_array, $
	        	x_cutoff_low, x_cutoff_high, pow_xaxis_type)
	        data=pow_cutoff(*,0)
	        tx=pow_cutoff(*,pow_xaxis_type)
	        if pow_xaxis eq 'f' then tx=tx*1000
	        annotation_string=titlestring+',D Power'
	        
	        !x.tickformat='(f8.1)
	        if pow_yaxis eq 'log' then !y.tickformat='(e6.0)'
;	Plot a power spectrum with plain old x axis
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0, ytype=pow_yaxis_type-1,$
		  range=range
	      endif else $
	      begin
	        annotation_string=titlestring+',D'
	        
;	        data=undef_vals(data,1000,9999.9)
	        
;		print,'ranges2',range
;	A time series plot has /time type x axis.
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0,/time,$
		  range=range
	      endelse
	    endif

; Z component plot
	    if hdzcomps(2) then begin
	      data=filedata.data_vals.z
	      data=data(t+spoint)
	      
              data=undef_vals(data,jump_value,!values.f_nan)
;	do some filtering here
	      if filtering eq 1 then $
	      begin
	        data=data-rb_mean(data)
	        data=convol(data, filter, /center, /edge_truncate)
	      endif

;	Change the data for a spectrum if we are power plotting
	      if keyword_set(power) then $
	      begin
	        pow_array=sam_power(data, samp_int)
	        pow_cutoff=cutoff(pow_array, $
	        	x_cutoff_low, x_cutoff_high, pow_xaxis_type)
	        data=pow_cutoff(*,0)
	        tx=pow_cutoff(*,pow_xaxis_type)
	        if pow_xaxis eq 'f' then tx=tx*1000
	        annotation_string=titlestring+',Z Power'
	        
	        !x.tickformat='(f8.1)
	        if pow_yaxis eq 'log' then !y.tickformat='(e6.0)'
;	Plot a power spectrum with plain old x axis
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0, ytype=pow_yaxis_type-1,$
		  range=range
	      endif else $
	      begin
	        annotation_string=titlestring+',Z'
	        
;	        data=undef_vals(data,1000,9999.9)
	        
;	A time series plot has /time type x axis.
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0,/time,$
		  range=range
	      endelse
	    endif
; H/D component plot
	    if hdzcomps(3) then begin
	      data=filedata.data_vals.h/filedata.data_vals.d
	      data=data(t+spoint)
	      
              data=undef_vals(data,jump_value,!values.f_nan)
;	do some filtering here
	      if filtering eq 1 then $
	      begin
	        data=data-rb_mean(data)
	        data=convol(data, filter, /center, /edge_truncate)
	      endif

;	Change the data for a spectrum if we are power plotting
	      if keyword_set(power) then $
	      begin
	        pow_array=sam_power(data, samp_int)
	        pow_cutoff=cutoff(pow_array, $
	        	x_cutoff_low, x_cutoff_high, pow_xaxis_type)
	        data=pow_cutoff(*,0)
	        tx=pow_cutoff(*,pow_xaxis_type)
	        if pow_xaxis eq 'f' then tx=tx*1000
	        annotation_string=titlestring+',H/D Power'
	        
	        !x.tickformat='(i5)
	        if pow_yaxis eq 'log' then !y.tickformat='(e6.0)'
;	Plot a power spectrum with plain old x axis
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0, ytype=pow_yaxis_type-1,$
		  range=range
	      endif else $
	      begin
	        annotation_string=titlestring+',H/D'
	        
;	        data=undef_vals(data,1000,9999.9)
	        
;	A time series plot has /time type x axis.
	        panel_comp_plot,data,tx,annotation_string,tic_labelling,$
		  last_panel, text_xalign=0.05, text_xjust=0.0,$
		  text_yalign=0.95, text_yjust=1.0,/time,$
		  range=range
	      endelse
	    endif
	  endelse
	endfor
	
	
	
	
	
	
;	Plot title
	type_string=['','H component','D component','H and D component', $
	'Z component','','','3 component','H/D components']
	if (mag_array EQ 'IMAGE') THEN titlestring='IMAGE '+type_string(all_type) $
	ELSE titlestring='SAMNET '+type_string(all_type)
	
	titlestring=titlestring+' plot: Day' + $
	string(filedata.data_params.day,format='(i2)')+ $
	' Month: ' + $
	string(filedata.data_params.month,format='(i2)')+ $
	' Year: ' + $
	string(filedata.data_params.year,format='(i4)')
	if filtering eq 0 then $
	begin
	  titlestring=titlestring+' Unfiltered'
	endif else $
	begin
	  titlestring=titlestring + ' Filter (' + $
	    string(t_long,format='(i3)')+','+ $
	    string(t_short,format='(i3)')+')'
	endelse


;	position not right yet
	xyouts, title_xpos, title_ypos, titlestring, /device, $
	  alignment=0.5, charsize=1.2
	xyouts, usertitle_xpos, usertitle_ypos, usertitlestring, /device, $
	  alignment=0.5, charsize=1.2

	return
	end


