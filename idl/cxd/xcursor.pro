;-------------------------------------------------------------
;+
; NAME:
;       XCURSOR
; PURPOSE:
;       Cursor coordinate display in a pop-up widget window.
; CATEGORY:
; CALLING SEQUENCE:
;       xcursor
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   display data coordinates (default).
;         /DEVICE display device coordinates.
;         /NORMAL display normalized coordinates.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1 Nov, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xcursor, help=hlp, data=data, normal=norm, device=dev
 
	if keyword_set(hlp) then begin
	  print,' Cursor coordinate display in a pop-up widget window.'
	  print,' xcursor'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   /DATA   display data coordinates (default).'
	  print,'   /DEVICE display device coordinates.'
	  print,'   /NORMAL display normalized coordinates.'
	  return
	endif
 
	typ = 'Data'
	if keyword_set(norm) then typ = 'Normalized'
	if keyword_set(dev) then typ = 'Device'
	if strupcase(strmid(typ,0,2)) eq 'DA' then begin
	  if !x.s(1) eq 0 then begin
	    print,' Data coordinate system not established.'
	    return
	  endif
	endif
 
	top = widget_base(/column,title=' ')
	id = widget_label(top,val=typ+' coordinates')
	id = widget_label(top,val='    Press any button to exit    ')
	id = widget_label(top,val=' ')
 
	widget_control, top, /real
	!err = 0
 
	while !err eq 0 do begin
	  cursor, x, y, data=data, norm=norm, dev=dev, /change
	  widget_control, id, set_val=strtrim(string(x,y),2)
	endwhile
 
	widget_control, top, /dest
 
	return
	end
