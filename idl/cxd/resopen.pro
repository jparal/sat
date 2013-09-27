;-------------------------------------------------------------
;+
; NAME:
;       RESOPEN
; PURPOSE:
;       Open a results file for reading or writing.
; CATEGORY:
; CALLING SEQUENCE:
;       resopen, file
; INPUTS:
;       file = results data file name.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /WRITE means open file for write.
;         /APPEND used with /WRITE to append to a file.
;         /XDR means use XDR.
;         HEADER=h returned header array on open for read.
;         FSTAT=fst returned file status structure.
;         ERROR=e  error code:
;           0 = OK.
;           1 = File not found.
;           2 = File not a results file.
;           3 = File not opened.
;         TEXT_ERROR=txterr returned error message.
;         /QUIET means don't display any error messages.
; OUTPUTS:
; COMMON BLOCKS:
;       results_common
; NOTES:
;       Notes: one of the results file utilities.
;         See also resput, resget, rescom, resclose.
;       Error in resopen: IDL does not allow XDR files to be
;         opened for both input and output simultaneously.
; MODIFICATION HISTORY:
;       R. Sterner, 5 Jun, 1991
;       R. Sterner, 2 Jan, 1992 --- added def='.' to open*
;       R. Sterner, 1994 Jun 22 --- Added automatic close of an open file.
;       R. Sterner, 1994 Jul 26 --- Modified automatic close.
;       R. Sterner, 1994 Aug 11 --- Made sure r_open was defined.
;       R. Sterner, 1994 Sep 12 --- Added /APPEND.
;       R. Sterner, 1994 Sep 27 --- Fixed /XDR openu problem.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro resopen, file, header=hdr, error=err, fstat=fst, $
	  write=write, xdr=xdr, help=hlp, quiet=quiet, $
	  text_error=errtxt, append=append
 
        common results_common, r_file, r_lun, r_open, r_hdr
        ;----------------------------------------------------
        ;       r_file = Name of results file.
        ;       r_lun  = Unit number of results file.
        ;       r_open = File open flag. 0: not open.
        ;                                1: open for read.
        ;                                2: open for write.
        ;       r_hdr  = String array containing file header.
        ;----------------------------------------------------
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
          print,' Open a results file for reading or writing.'
          print,' resopen, file'
          print,'   file = results data file name.    in'
          print,' Keywords:'
	  print,'   /WRITE means open file for write.'
	  print,'   /APPEND used with /WRITE to append to a file.'
	  print,'   /XDR means use XDR.'
	  print,'   HEADER=h returned header array on open for read.'
	  print,'   FSTAT=fst returned file status structure.'
          print,'   ERROR=e  error code:'
	  print,'     0 = OK.'
	  print,'     1 = File not found.'
          print,'     2 = File not a results file.'
	  print,'     3 = File not opened.'
	  print,'   TEXT_ERROR=txterr returned error message.'
	  print,"   /QUIET means don't display any error messages."
	  print,' Notes: one of the results file utilities.'
	  print,'   See also resput, resget, rescom, resclose.'
   	  return
	end
 
	;-----------  Open file for read or write  --------
	if n_elements(xdr) eq 0 then xdr = 0
	if n_elements(r_open) eq 0 then r_open = 0
	if n_elements(append) eq 0 then append = 0
	if keyword_set(xdr) and keyword_set(append) then begin
	  print,' Error in resopen: IDL does not allow XDR files to be'
	  print,'   opened for both input and output simultaneously.'
	  err = 3
	  return
	endif
	aflag = 0				; Append flag.
	if n_elements(r_lun) ne 0 then begin
	  if r_open ne 0 then free_lun, r_lun	; Close any open file.
	endif
        on_ioerror, err
	get_lun, r_lun
	;=============  Open for WRITE  ================
	if keyword_set(write) then begin	; WRITE.
	  f = findfile(file, count=cnt)		; See if file exists.
	  ;------  create new file using openw  ----------
	  if cnt eq 0 then begin
	    if !version.os eq 'vms' then begin	; VAX.
	      openw, r_lun, file, /stream, xdr=xdr, def='.'
	    endif else begin			; Unix.
	      openw, r_lun, file, /stream, xdr=xdr
	    endelse
	    close, r_lun			; File now exists.
	  endif
	  ;------  File exists, open using openu  -------
	  if !version.os eq 'vms' then begin	; VAX.
	    if keyword_set(xdr) then begin	;    XDR
	      openw, r_lun, file, /stream, xdr=xdr, def='.'
	    endif else begin			;    Non-XDR.
	      openu, r_lun, file, /stream, xdr=xdr, def='.'
	    endelse
	  endif else begin			; Unix.
	    if keyword_set(xdr) then begin	;    XDR
	      openw, r_lun, file, /stream, xdr=xdr
	    endif else begin			;    Non-XDR.
	      openu, r_lun, file, /stream, xdr=xdr
	    endelse
	  endelse
	  ;-----------------------------------------------
	  on_ioerror, null
	  r_open = 2				; Set open flag to write.
	  r_file = file				; Set file name in common.
	  if append eq 1 then aflag=1		; Requested append.
	  f = fstat(r_lun)			; Look at opened file.
	  if f.size eq 0 then aflag=0		; New file, no append.
	  if aflag eq 0 then begin		; If no append.
	    r_hdr = ['']			; Initialize header array.
	    writeu, r_lun, [0L,0L,0L]		; This is to set file pointer.
	    err = 0
	    return
	  endif
	;=============  Open for READ  ================
	endif else begin			; READ.
	  if !version.os eq 'vms' then begin
	    openr, r_lun, file, xdr=xdr, def='.'
	  endif else begin
	    openr, r_lun, file, xdr=xdr
	  endelse
	  r_open = 1				; Set open flag to read.
	endelse
 
;===================================================================
	;----------  read header  ----------
	front = lonarr(3)			; Header pointer array.
	readu, r_lun, front			; read header pointer.
	if front(0) eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Nothing is in the file '+file
	  err = 2
	  goto, done
	endif
	if front(2) gt 2500 then begin		; Not RES file.
	  if not keyword_set(quiet) then print,' Not a results file.'
	  err = 2
	  goto, done
	endif
	b = bytarr(front(1),front(2))		; Set up header byte array.
	point_lun, r_lun, front(0)		; Set file pointer to header.
	on_ioerror, err2
	readu, r_lun, b				; Read header byte array.
	on_ioerror, null
 
	;----------  Convert byte array to a string array  ---------
	hdr = string(b)
 
	;------  Handle /APPEND  ------------
	if aflag eq 1 then begin
	  hdr = hdr(0:front(2)-2)  		; Drop END from hdr if APPEND.
	  hdr = ['',hdr]			; Add null string to front.
	  point_lun, r_lun, front(0)		; Set file ptr for next write.
	endif
 
	;-----  Set common values  -------
	r_file = file
	r_hdr = hdr
 
        err = 0
	fst = fstat(r_lun)
	return
 
err:    errtxt = ' Error: Results file '+file+' not opened.'
        err = 1
        goto, errex
 
err2:   errtxt = ' Error: file '+file+' not a results file.'
        err = 2
        goto, errex
 
errex:	if not keyword_set(quiet) then print,errtxt
 
done:	free_lun, r_lun
	return
 
	end
