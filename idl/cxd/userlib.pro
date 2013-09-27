;-------------------------------------------------------------
;+
; NAME:
;       USERLIB
; PURPOSE:
;       List and give help for users library routines.
; CATEGORY:
; CALLING SEQUENCE:
;       userlib
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: for VMS only.
; MODIFICATION HISTORY:
;       R. Sterner, 4 Dec, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro userlib, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' List and give help for users library routines.'
	  print,' userlib'
	  print,'   No args.'
	  print,' Note: for VMS only.'
	  return
	endif
 
	print," Extracting User's Library routine names . . ."
	spawn, 'lib/text/list idl_dir:[lib]userlib', txt
	w = where(txt eq '')
 
	txt = txt(w(0)+1:*)
	if !d.name ne 'X' then goto, nox
 
	txt = ['--- Quit ---',txt]
 
loop:	wshow, 0
	in = wmenu(txt)
	if in eq 0 then return
	wshow, 0, 0
	print,' Extracting help for '+txt(in)+' . . .'
	doc_library,txt(in)
 
	print,' Press any key to continue'
	print,' '
	k = get_kbrd(1)
	goto, loop
 
nox:	print,txt
	tmp = ''
	read,' Enter routine name for help: ',tmp
	if tmp eq '' then return
	print,' Extracting help for '+tmp+' . . .'
	doc_library, tmp
	print,' Press any key to continue'
	print,' '
	k = get_kbrd(1)
	goto, nox
 
	end
