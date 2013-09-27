;-------------------------------------------------------------
;+
; NAME:
;       rb_strinit
; PURPOSE:
;	returns the initial substring of string1 composed wholely of
;	characters from string2
; CATEGORY:
; CALLING SEQUENCE:
;	string3=rb_strinint(string1,string2)
; INPUTS:
;	string1		Input string.
;	string2		String of characters to check for.
; KEYWORD PARAMETERS:
; 	remainder=rem	string variable to hold the return
;			of the remaining bit of string1
; OUTPUTS:
;	Returns astring of length less than or equal to that of the input;
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 19 Sep 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

	function rb_strinit,string,test_string,remainder=rem,help=hlp
	
	if keyword_set(hlp) then $
	  begin 
	  print,''
	  print,' NAME:'
	  print,'       rb_strinit'
	  print,' PURPOSE:'
	  print,' 	returns the initial substring of string1 composed wholely of'
	  print,' 	characters from string2'
	  print,' CATEGORY:'
	  print,' CALLING SEQUENCE:'
	  print,' 	string3=rb_strinint(string1,string2)'
	  print,' INPUTS:'
	  print,' 	string1		Input string.'
	  print,' 	string2		String of characters to check for.'
	  print,' KEYWORD PARAMETERS:'
	  print,' 	remainder=rem	string variable to hold the return'
	  print,'			of the ramining bit of string1'
	  print,' OUTPUTS:'
	  print,' 	Returns a string of length less than or equal to that of the input'
	  print,' 	containing the the initial substring made only of characters from the '
	  print,'	second input string'
	  print,' '
	  print,' COMMON BLOCKS:'
	  print,' NOTES:'
	  print,' MODIFICATION HISTORY:'
	  print,'      R. Bunting, 19 Sep 1996'
	  print,''
	endif
	
	b1=byte(string)
	
; maybe do some fiddling with the test string in here, so as to add 
; such things as ranges etc.

	b2=byte(test_string)
	
	initial_string=''
	
	pos=0
	
;	for each position in the string, check that it has at least one match 
;	with the test string, else finish.

	while pos lt strlen(string) and max(b1(pos) eq b2) eq 1 do $
	begin
		initial_string=initial_string+strmid(string,pos,1)
		pos=pos+1
	endwhile
	rem=strmid(string,pos,strlen(string)-pos)

	return, initial_string
	end
