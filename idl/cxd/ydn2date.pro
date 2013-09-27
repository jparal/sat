;-------------------------------------------------------------
;+
; NAME:
;       YDN2DATE
; PURPOSE:
;       Convert year and day of the year to a date string.
; CATEGORY:
; CALLING SEQUENCE:
;       date = ydn2date(Year, dn)
; INPUTS:
;       Year = year.                      in
;       dn = day of the year.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT = format string.  (see ymd2date).
; OUTPUTS:
;       date = returned date string.      out
;              (like 86-APR-25).
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,    25 APR, 1986.
;       Johns Hopkins University Applied Physics Laboratory
;       R. Sterner, 1994 May 27 --- Renamed from dn2date.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function ydn2date, yr, dn, help=hlp, format=frmt
 
	if (n_params(0) lt 2) or keyWord_set(hlp) then begin
	  print,' Convert year and day of the year to a date string.'
	  print,' date = ydn2date(Year, dn)'
	  print,'   Year = year.                      in'
	  print,'   dn = day of the year.             in'
	  print,'   date = returned date string.      out'
	  print,'          (like 86-APR-25).
	  print,' Keywords:' 
	  print,'   FORMAT = format string.  (see ymd2date).'
	  return, -1
	endif
 
	ydn2md,yr,dn,m,d
	if m lt 0 then begin
	  print,' Error in month in dn2date.'
	  m = 0
	endif
	return, ymd2date(yr,m,d,format=frmt)
 
	end
