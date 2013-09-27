;-------------------------------------------------------------
;+
; NAME:
;       JSPLOT
; PURPOSE:
;       Make a time series plot with time in Julian Seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       jsplot, js, y
; INPUTS:
;       js = Time array in Julian Seconds.   in
;       y  = Data to be plotted.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         GAP=gs  Gap in seconds.  This or greater time difference
;           will cause a break in the curve.  If a plot symbol
;           is desired use a negative psym number to connect pts.
;         CCOLOR=cc     Curve and symbol color (def=same as axes).
;         XTITLE=txt    Time axis title text.
;         XTICKLEN=xtl  Time axis tick length (fraction of plot).
;         XTICKS=n      Suggested number of time axis ticks.
;           The actual number of tick marks may be quite different.
;         FORMAT=fmt    Set date/time format (see timeaxis,/help).
;         LABELOFF=off  Adjust label position (see timeaxis,/help).
;         MAJOR=mjr     Major grid linestyle.
;         MINOR=mnr     Minor grid linestyle.
;         TRANGE=[js1,js2] Specified time range in JS.
;         OFF=off       Returned JS of plot min time. Use to plot
;           times in JS: VER, js(0)-off.
;         /OVER         Make overplot.  oplot,js-off,y also works
;           but will not handle any gaps.
;         Any plot keywords will be passed on to the plot call.
; OUTPUTS:
; COMMON BLOCKS:
;       js_com
; NOTES:
;       Notes:  Julian seconds are seconds after 0:00 1 Jan 2000.
;         See also dt_tm_tojs(), dt_tm_fromjs(), ymds2js(), js2ymds.
; MODIFICATION HISTORY:
;       R. Sterner 1994 Mar 30
;       R. Sterner, 1994 May 17 --- Added common js_com.
;	R. Bunting, 1996 Jan 7  --- Added min_value.  
;	R. Bunting, 1996 May 21 --- Added check for !x.style and 4
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro jsplot, t, y, help=hlp, charsize=csz, color=clr, $
	  format=frm, xtitle=xtitl, xticklen = xtl, xticks=ntics, $
	  labeloff=lbloff, _extra=extra, major=mjr, minor=mnr, $
	  trange=tran, gap=gap, max_value=maxv, min_value=minv,linestyle=lstyl, $
	  thick=thk, ccolor=cclr, off=off, psym=psym, symsize=symsize, $
	  nodata=nodata, over=over
 
	common js_com, jsoff
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a time series plot with time in Julian Seconds.'
	  print,' jsplot, js, y'
	  print,'   js = Time array in Julian Seconds.   in'
	  print,'   y  = Data to be plotted.             in'
	  print,' Keywords:'
	  print,'   GAP=gs  Gap in seconds.  This or greater time difference'
	  print,'     will cause a break in the curve.  If a plot symbol'
	  print,'     is desired use a negative psym number to connect pts.'
	  print,'   CCOLOR=cc     Curve and symbol color (def=same as axes).'
	  print,'   XTITLE=txt    Time axis title text.'
	  print,'   XTICKLEN=xtl  Time axis tick length (fraction of plot).'
	  print,'   XTICKS=n      Suggested number of time axis ticks.'
	  print,'     The actual number of tick marks may be quite different.'
	  print,'   FORMAT=fmt    Set date/time format (see timeaxis,/help).'
	  print,'   LABELOFF=off  Adjust label position (see timeaxis,/help).'
	  print,'   MAJOR=mjr     Major grid linestyle.'
	  print,'   MINOR=mnr     Minor grid linestyle.'
	  print,'   TRANGE=[js1,js2] Specified time range in JS.'
	  print,'   OFF=off       Returned JS of plot min time. Use to plot'
	  print,'     times in JS: VER, js(0)-off.'
	  print,'   /OVER         Make overplot.  oplot,js-off,y also works'
	  print,'     but will not handle any gaps.'
	  print,'   Any plot keywords will be passed on to the plot call.'
	  print,' Notes:  Julian seconds are seconds after 0:00 1 Jan 2000.'
	  print,'   See also dt_tm_tojs(), dt_tm_fromjs(), ymds2js(), js2ymds.'
	  return
	endif
 
	;-------  Define defaults  ----------
	if n_elements(csz) eq 0 then csz=!p.charsize
	if csz eq 0 then csz = 1
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(cclr) eq 0 then cclr=clr
	if n_elements(xtitl) eq 0 then xtitl=!x.title
	if n_elements(xtl) eq 0 then xtl=.02
	if n_elements(ntics) eq 0 then ntics=!x.ticks
	if n_elements(lbloff) eq 0 then lbloff=0
	if n_elements(frm) eq 0 then frm=''
	if n_elements(tran) eq 0 then tran=[t(0),t(n_elements(t)-1)]
	if n_elements(maxv) eq 0 then maxv=max(y)
	if n_elements(minv) eq 0 then minv=min(y)
	if n_elements(lstyl) eq 0 then lstyl=!p.linestyle
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(psym) eq 0 then psym=!p.psym
	if n_elements(symsize) eq 0 then symsize=!p.symsize
	symsz = symsize
	if symsz eq 0 then symsz = 1.
	if !p.multi(1) gt 1 then symsz = symsz/2.
 
	;-------  Find JD and offset  ---------
	if not keyword_set(over) then begin
	  time2jdoff, t(0), jd=jd, off=off
	  jsoff = off
	endif else off = jsoff
 
	;-------  Handle GAP keyword  ----------
	w = lindgen(n_elements(t))
	nr = 1
	if n_elements(gap) ne 0 then begin
	  w = where((t(1:*)-t) lt gap, cnt)
	  if cnt eq 0 then begin
	    bell
	    print,' Error in jsplot: given gap size of '+strtrim(gap,2)+$
	    ' seconds is too small, no points selected.'
	    return
	  endif
	  nr = nruns(w)
	endif
 
	;------  Plot  -------------------------
	if not keyword_set(over) then $
	  plot, t-off, y, charsize=csz, color=clr, xstyle=5, $
	    xrange=tran-off, /nodata, max_value=maxv, min_value=minv, $
	    linestyle=lstyl, thick=thk, _extra=extra
	if psym ne 0 then oplot, t-off,y,psym=abs(psym),color=cclr, $
	  symsize=symsz, linestyle=lstyl,thick=thk
	if not keyword_set(nodata) and (psym le 0) then begin
	  for i=0, nr-1 do begin
	    ww = getrun(w,i)
	    ww = [ww,max(ww)+1]
	    oplot, t(ww)-off, y(ww), max_value=maxv, min_value=minv, $
	    symsize=symsz, color=cclr, linestyle=lstyl, thick=thk, psym=psym
	  endfor
	endif
	lastplot
	if not keyword_set(over) then $
	  plot, t-off, y, charsize=csz, color=clr, xstyle=5, $
	    xrange=tran-off, /nodata, max_value=maxv, min_value=minv, $
	    linestyle=lstyl, thick=thk, /noerase, _extra=extra
	nextplot
 
	if not keyword_set(over) and not (!x.style and 4)/4 then $
	  timeaxis, jd=jd, form=frm, nticks=ntics, title=xtitl, $
	    ticklen=xtl*100, labeloffset=lbloff, charsize=csz, $
	    color=clr, major=mjr, minor=mnr
 
	return
	end
