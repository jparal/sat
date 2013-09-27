;-------------------------------------------------------------
;+
; NAME:
;       MOVTXT
; PURPOSE:
;       Interactively position text and list xyouts statement.
; CATEGORY:
; CALLING SEQUENCE:
;       movtxt, txt
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA use data coordinates (def).
;         /DEVICE use device coordinates.
;         /NORMAL use normalized coordinates.
;         COLOR=clr  Used only in code display.
; OUTPUTS:
; COMMON BLOCKS:
;       movtxt_com
; NOTES:
;       Notes: click mouse button for options (right button exits).
;         May change text size and angle.
;         May list xyouts call to plot text in current position.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Nov 1.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro movtxt, txt, data=data,device=dev,normal=norm, help=hlp, $
	  color=clr
 
	common movtxt_com, csz, ang, x, y, mx, my
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Interactively position text and list xyouts statement.'
	  print,' movtxt, txt'
	  print,'   txt = Text to position.'
	  print,' Keywords:'
	  print,'   /DATA use data coordinates (def).'
	  print,'   /DEVICE use device coordinates.'
 	  print,'   /NORMAL use normalized coordinates.'
	  print,'   COLOR=clr  Used only in code display.'
	  print,' Notes: click mouse button for options (right button exits).'
	  print,'   May change text size and angle.'
	  print,'   May list xyouts call to plot text in current position.'
	  return
	endif
 
	device, set_graph=6
 
	;------  Set initial values  ---------
	if n_elements(data) eq 0 then data=0
	if n_elements(dev) eq 0 then dev=0
	if n_elements(norm) eq 0 then norm=0
	if (data+dev+norm) eq 0 then data=1
	if n_elements(csz) eq 0 then csz = 2.
	if n_elements(ang) eq 0 then ang = 0.
	if n_elements(mx) eq 0 then mx = 0
	if n_elements(my) eq 0 then my = 0
 
	;--------  Check for data coordinates  --------
	if keyword_set(data) then begin
	  if total(abs(!x.crange)) eq 0 then begin
	    print,' Error in movtxt: Data coordinates not established yet.'
	    return
	  endif
	endif
 
	!err = 0
	xlst = -1000
	ylst = -1000
	alst = 0.
	slst = 1.
	def = 1
 
	tvcrs, mx, my
 
	while !err ne 4 do begin
 
	while !err eq 0 do begin
	  cursor, x, y, data=data,dev=dev,norm=norm,/change
	  xyouts, xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst,ori=alst
	  xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz, ori=ang
	  xlst=x
	  ylst=y
	  alst = ang
	  slst = csz
	endwhile
	xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz, ori=ang
 
	if !err ne 4 then begin
	  xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz, ori=ang
	  xlst = x
	  ylst = y
	  alst = ang
	  slst = csz
	  !err = 0
	  opt = xoption(['Quit','Continue','Size','Angle','Code'],def=def)
	  if opt eq 0 then begin
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz, ori=ang
	    goto, done
	  endif
	  if opt eq 2 then begin
	    tmp = ''
	    read,' Enter new text size (def='+strtrim(csz,2)+'): ',tmp
	    if tmp eq '' then tmp = csz
	    csz = tmp + 0.
	    xyouts,xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst,ori=alst
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz, ori=ang
	    xlst=x
	    ylst=y
	    alst = ang
	    slst = csz
	    def = opt
	  endif
	  if opt eq 3 then begin
	    tmp = ''
	    read,' Enter new text angle (def='+strtrim(ang,2)+'): ',tmp
	    if tmp eq '' then tmp = ang
	    ang = tmp + 0.
	    xyouts,xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst,ori=alst
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz, ori=ang
	    xlst=x
	    ylst=y
	    alst = ang
	    slst = csz
	    def = opt
	  endif
	  if opt eq 4 then begin
	    def = opt
	    if keyword_set(data) then begin
	      sys = ''
	      xy = ','+strtrim(x,2)+','+strtrim(y,2)
	    endif
	    if keyword_set(dev) then begin
	      sys=',/dev'
	      xy = ','+strtrim(fix(x),2)+','+strtrim(fix(y),2)
	    endif
	    if keyword_set(norm) then begin
	      sys=',/norm'
	      xy = ','+strtrim(x,2)+','+strtrim(y,2)
	    endif
	    tsz = ''
	    if csz ne 0 then tsz = ',chars='+strtrm2(csz,2,'0')
	    tang = ''
	    if ang ne 0 then tang = ',orient='+strtrm2(ang,2,'0')
	    tclr = ''
	    if n_elements(clr) ne 0 then tclr=',col='+strtrim(clr,2)
	    print,' IDL code:'
	    print,'xyouts'+sys+xy+",'"+txt+"'"+tsz+tang+tclr
	  endif
	  tvcrs, !mouse.x,!mouse.y
	endif
 
	endwhile  ; !err ne 4.
 
done:
	mx = !mouse.x
	my = !mouse.y
	device, set_graph=3
	return
	end
