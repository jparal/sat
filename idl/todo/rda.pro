pro rda,name,data,COLUMNS=columns,COMPRESS=compress,DOUBLE=double
;
; RDA   (SAT IDL Library Copyright)
;
; Reads data with various columns from file or compressed file. As compared
; with 'rdn' this procedure doesnt require number of lines at the begining of
; the file. The tradeof is a speed of course.
;
; SYNTAX:
;
;  RDA, name, data [,COLUMNS=value] [,/DOUBLE] [,/COMPRESS]
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
;  31 Oct 2008 - Derived from rdn.pro
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
  endif else begin
     return
  endelse

  if(double eq 0) then begin
     line=fltarr(columns)
  endif else begin
     line=dblarr(columns)
  endelse

  cnt = 0
  while not eof(iunit) do begin
     readf,iunit,line
     if (cnt eq 0) then begin
        data = line
        cnt = 1
     endif else begin
        data = [[data], [line]]
     endelse
  end

  close,iunit

  return
end
