pro rdn,name,data,COLUMNS=columns,COMPRESS=compress,DOUBLE=double
;
; RDN   (SAT IDL Library Copyright)
;
; Reads data with various columns from file or compressed file.
;
; SYNTAX:
;
;  RDN, name, data [,COLUMNS=value] [,/DOUBLE] [,/COMPRESS]
;
; GRAPHICS KEYWORDS:
;
;
; ARGUMENTS:
;
; name: Name of file where data are stored.
;
; data: Name of variable where to store the data.
;
; KEYWORDS:
;
; COMLUMNS: Number of columns in the file (default is 1)
;
; COMPRESS: Is file compressed?
;
; DOUBLE: Store data as double?
;
; AUTHORS:
;  Jan Paral <jparal@seznam.cz>
;
; HISTORY:
;  12 Sept 2005 - Created
;

iunit=9

if(not(keyword_set(columns))) then columns=1
if(not(keyword_set(double))) then double=0
if(not(keyword_set(compress))) then begin
 compress=0
 if STREGEX(name,'.gz',/boo) then compress=1
endif

if(fexist(name,first=first))then begin
    openr,iunit,first,compress=compress
    readf,iunit,n
endif else begin
    return
endelse

if(double eq 0) then begin
    data=fltarr(columns,n)
endif else begin
    data=dblarr(columns,n)
endelse

readf,iunit,data
close,iunit

return
end
