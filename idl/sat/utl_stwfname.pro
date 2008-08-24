FUNCTION UTL_STWFNAME, sensor, runname, iter, DIR=dir, SUFFIX=suffix, $
                       SPECIE=specie, EXIST=exist

; exist .. Force the check whether the file exists

  ON_ERROR, 2

  IF (N_PARAMS() NE 3) THEN MESSAGE, 'Not enough params'
  IF NOT(KEYWORD_SET(dir)) THEN dir='.'
  IF NOT(KEYWORD_SET(suffix)) THEN suffix=' '

  dir=dir+'/'

  filename=STRCOMPRESS(dir+sensor+runname+'i'+String(iter)+suffix,/REMOVE_ALL)
  IF NOT KEYWORD_SET(exist) THEN RETURN, filename

  fname=FINDFILE(filename)
  ss = SIZE(fname)
  IF (ss(0) GT 0) THEN BEGIN
     IF (ss(0) GT 1) THEN BEGIN
        MESSAGE, 'More then one file match (using first one)', /INFORMATIONAL
     ENDIF
     RETURN, fname(0)
  ENDIF

  suffix=suffix+'.gz'
  filename=STRCOMPRESS(dir+sensor+runname+'i'+String(iter)+suffix,/REMOVE_ALL)
  fname=FINDFILE(filename)
  ss = SIZE(fname)
  IF (ss(0) GT 0) THEN BEGIN
     IF (ss(0) GT 1) THEN BEGIN
        MESSAGE, 'More then one file match (using first one)', /INFORMATIONAL
     ENDIF
     RETURN, fname(0)
  ENDIF ELSE BEGIN
     MESSAGE, 'File doesnt exist:' + filename
  ENDELSE

END
