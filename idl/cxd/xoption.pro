;-------------------------------------------------------------
;+
; NAME:
;       XOPTION
; PURPOSE:
;       Widget option selection panel.
; CATEGORY:
; CALLING SEQUENCE:
;       opt = xoption(menu)
; INPUTS:
;       menu = string array, one element per option.  in
;         These are the option button titles (from top down).
; KEYWORD PARAMETERS:
;       Keywords:
;         VALUES=v  Array of values corresponding to each option.
;           Default value is the menu element index.
;         DEFAULT=n Button number to use as default value (top is 0).
;           Sets mouse to point at this element
;         TITLE=txt A scalar text string to use as title (def=none).
; OUTPUTS:
;       opt = returned option value.                 out
; COMMON BLOCKS:
; NOTES:
;       Notes: An example call:
;         opt = xoptions(['OK','Abort','Continue'])
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Jan 10.
;       R. Sterner, 1994 Jan 13 --- Added DEFAULT keyword.
;       R. Sterner, 1994 Apr 12 --- Added TITLE keyword.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function xoption, txt, values=val, default=def, title=ttl, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Widget option selection panel.'
	  print,' opt = xoption(menu)'
	  print,'   menu = string array, one element per option.  in'
	  print,'     These are the option button titles (from top down).'
	  print,'   opt = returned option value.                 out'
	  print,' Keywords:'
	  print,'   VALUES=v  Array of values corresponding to each option.'
	  print,'     Default value is the menu element index.'
	  print,'   DEFAULT=n Button number to use as default value (top is 0).'
	  print,'     Sets mouse to point at this element'
	  print,'   TITLE=txt A scalar text string to use as title (def=none).'
	  print,' Notes: An example call:'
	  print,"   opt = xoptions(['OK','Abort','Continue'])"
	  return,''
	endif
 
	n = n_elements(txt)
	if n_elements(val) eq 0 then val = indgen(n)
	if n_elements(def) eq 0 then def = -1
	dsave = -1		; WID of default button.
 
	top = widget_base(/column,title=' ')
	if n_elements(ttl) ne 0 then id=widget_label(top,val=ttl)
	for i = 0, n-1 do begin
          b = widget_base(top,/row)
          id = widget_button(b,val='-',uval=val(i))
	  if i eq def then dsave = id
          id = widget_label(b,val=txt(i))
	endfor
 
        widget_control, top, /real
	if dsave ge 0 then widget_control, dsave, /input_focus
 
        ev = widget_event(top)
        widget_control, ev.id, get_uval=uval
 
	widget_control, top, /dest
 
	return, uval
 
	end
