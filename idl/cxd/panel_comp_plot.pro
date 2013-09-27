;-------------------------------------------------------------
;+
; NAME:
;       panel_comp_plot
; PURPOSE:
;	Plot a panel of data, with zero minimum and a rounded maximum
; CATEGORY:
; CALLING SEQUENCE:
;	panel_comp_plot, ydata, xdata, annotation_string, tic_labelling,
;	last_panel
; INPUTS:
;	ydata:	time series data to plot
;	xdata:	x values
;	annotation_string:	some label on the panel
;	tic_labelling:	Do we want tic labels on our X axis for the last panel?
;	last_panel:	Number of the last panel in a multi-panel plot (for 
;			which we need some labels on the X axis)
; KEYWORD PARAMETERS:
;	text_xalign:	x alignment within plot of the annotation string
;	text_xjust:	x justification within plot of the annotation string
;	text_yalign:	y alignment within plot of the annotation string
;	text_yjust:	y justification within plot of the annotation string
;	no_fsd:		Do we want the FSD (or total yrange) written in
;	time:		If we want a time axis along the bottom; in this case
;			xdata is in seconds from start of day
;	range:		limit of Y data size; set to 0 for auto, or -1 if
;			you have already set the !y.range, !y.tick etc,
;			and want them left unchanged.
; OUTPUTS:
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;
; Copyright (C) 1997, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

function make_blank_labels,axis,index,value
	return,''
	end


pro panel_comp_plot,data,tx,annotation_string,tic_labelling,last_panel,$
	text_xalign=text_xalign, text_xjust=text_xjust, $
	text_yalign=text_yalign, text_yjust=text_yjust, $
	no_fsd=no_fsd, time=time, range=range, _EXTRA=extra
      max_undef=9999.9
      
      
      def_array=where(data NE max_undef and finite(data) eq 1, def_count)
      if(def_count lt 2) then $
        begin
        data(*)=0
        def_array=[0,1]
      endif
;      if undef_count gt 0 then data(undef_array)=max_undef
      datarange=1
;			Must have two points to plot a graph.
;      if (undef_count + 2) GT n_elements(data) then $
;	data(*)=0 else $
      datamax=max(data(def_array))
;      datamax=max((data(where(data NE max_undef and finite(data) eq 1))))
      datamin=min(data(def_array))
;      datamin=min((data(where(data NE max_undef and finite(data) eq 1))))
;
; save the !y variable and re-instate later for safety.
      y_temp=!y
      if(n_elements(range) eq 0) then $
	range=0
      if(range gt 0) then begin
        datarange=range
        !y.range=[0,range]
	!y.style=!y.style OR 1
	print,'@@@@ Using range ',!y.range
      endif else if (range eq -1) then begin
        datarange=!y.range[1]
	print,'@@@@ Using range ',!y.range
	print,'@@@@ Using ticks ',!y.ticks
      endif else begin
        datarange=datamax - datamin
	rb_ticks=0
	!y.range=rb_axisrange(0,datarange,majorticks=rb_ticks)
	!y.style=!y.style OR 1
	!y.ticks=rb_ticks
	print,'@@@@ Using range ',!y.range
	print,'@@@@ Using ticks ',!y.ticks
      endelse

      if(abs(!y.range[1]-!y.range[0]) lt 1.0e-10) then begin
	!y.range[1]=!y.range[0]+1.0
      endif

;print,'range: ', range, datarange
      
      txrange=tx(n_elements(tx)-1)
      
      if tic_labelling eq 0 and !p.multi(0) gt last_panel then $
      begin
        if keyword_set(time) then $
        begin
          jsplot,tx,data-datamin,max_value=datarange,$
            xtitle='',ytitle='nT',format='  ', _EXTRA=extra
        endif else $
        begin
;          plot,tx,data,max_value=max_undef-1,$
; DKM fix 09-11-04
	   plot,tx,data,max_value=datamax,$
            xtitle='', xtickformat='make_blank_labels', _EXTRA=extra
        endelse
      endif else $
      begin
        if keyword_set(time) then $
        begin
          jsplot,tx,data-datamin,max_value=datarange,$
          xtitle='Time (UT)',ytitle='nT',format='', _EXTRA=extra
        endif else $
        begin
;          plot,tx,data,max_value=max_undef-1,$
; DKM fix 09-11-04
	   plot,tx,data,max_value=datamax,$ 
          _EXTRA=extra
        endelse
      endelse
      	
      if not keyword_set(no_fsd) then $
      begin
        annotation_string=annotation_string+' FSD:'+string(datarange,$
      						   format='(f7.2)')
      endif


	if (0 eq n_elements(text_xalign)) then text_xalign=0.5
	if (0 eq n_elements(text_xjust)) then text_xjust=0.5
	if (0 eq n_elements(text_yalign)) then text_yalign=1.0
	if (0 eq n_elements(text_yjust)) then text_yjust=1.0
;	print,text_xalign, text_xjust

       align,!p.clip(0)+(!p.clip(2)-!p.clip(0))*text_xalign,$
       !p.clip(1)+(!p.clip(3)-!p.clip(1))*text_yalign,$
       annotation_string,$
       ax=text_xjust,ay=text_yjust,charsize=!p.charsize/2,/device, $
       xout=xpos,yout=ypos

       xyouts,xpos,ypos,/device,annotation_string,charsize=!p.charsize/2
;       print,'*** yrange ', !y.range
       !y=y_temp
end


