;-------------------------------------------------------------
;+
; NAME:
;       USRLIB_ONE
; PURPOSE:
;       Generate a brief description file of IDL users lib routines.
; CATEGORY:
; CALLING SEQUENCE:
;       usrlib_one
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Output goes into file userlib.one.
; MODIFICATION HISTORY:
;       R. Sterner, 5 Dec, 1990
;       R. Sterner, 26 Feb, 1991 --- Renamed from userlib_liner.pro
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro usrlib_one, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Generate a brief description file of IDL users lib routines.'
	  print,' usrlib_one'
	  print,'   No args.'
	  print,' Notes: Output goes into file userlib.one.'
	  return
	endif
 
	;-------  Get all routine names  ---------
	print,' Extracting routine names from IDL users lib . . .'
	spawn,'lib/text/list idl_dir:[lib]userlib', list
	w = where(list eq '')
	list = list(w(0)+1:*)
	nlist = n_elements(list)
 
	mar = ''	; Left margin. Set to none for now.
 
	;--------  Start output file  ---------
	get_lun, lun2
	openw, lun2, 'userlib.one'
	printf, lun2, mar+$
	  "Contents of the standard IDL User's library as of "+systime()
	printf, lun2,' '
 
	txt = ''	; Input record.
	get_lun, lun	; Get lun for tmp.tmp.
 
	;--------  Process each library routine  ---------
	print,' Looping through routines . . .'
	for i = 0, nlist-1 do begin
	  print,list(i)
	  cmd = 'lib/text/extract='+list(i)+'/out=tmp.tmp idl_dir:[lib]userlib'
	  spawn, cmd			; Extract routine into tmp.tmp.
	  openr,lun,'tmp.tmp',/delete	; Open tmp.tmp for reading.
loop1:	  if eof(lun) then goto, done
	  readf, lun, txt
	  if txt ne '; PURPOSE:' then goto, loop1	; Search for PURPOSE.
	  front = list(i) + ': '
	  front = front + spc(5-strlen(front))
loop2:	  if eof(lun) then goto, done
	  readf, lun, txt
	  if strmid(txt,0,6) eq '; CALL' then goto, done  ; Print purpose.
	  if strmid(txt,0,5) eq '; CAT' then goto, done
	  txt = strtrim(strmid(txt,1,99),2)
	  if txt ne '' then printf,lun2, mar + front + txt
	  front = spc(5)
	  goto, loop2
done:	  close, lun
	endfor
 
	close, lun2
	free_lun, lun
	free_lun, lun2
 
	bell
	print," IDL user's library description is in the file userlib.one."
 
	return
	end
