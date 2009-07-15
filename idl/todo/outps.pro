pro outps,FILE=file,CLOSE=close,_EXTRA=extra
;
; OUTPS   (SAT IDL Library Copyright)
;
; Send output to postscript file
;
; SYNTAX:
;
;  OUTPS [,FILE=value] [,/CLOSE] [,_EXTRA=value]
;
; GRAPHICS KEYWORDS:
;
;
; ARGUMENTS:
;
; KEYWORDS:
;
; FILE: Set file name where to write output (default is 'out.ps')
;
; _EXTRA: Extra argument to device command
;
; END: Specifies end of the output. (i.e. close device and set output to x)
;
; AUTHORS:
;  Jan Paral <jparal@gmail.com>
;
; HISTORY:
;  12 Sept 2005 - Created
;
if(not(keyword_set(FILE)))then file='out.ps'

if(not(keyword_set(CLOSE))) then begin
    SET_PLOT,'ps'
    DEVICE,_EXTRA=extra
    DEVICE,/LAND,BITS_PER_PIXEL=16,/COLOR,FILE=file
endif else begin
    DEVICE,/CLOSE
    SET_PLOT,'x'
endelse
return
end
