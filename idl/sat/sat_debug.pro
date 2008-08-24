PRO SAT_DEBUG, msg, LEV=lev

  IF NOT(KEYWORD_SET(lev)) THEN lev = 1

  SAT_INIT
  IF !sat.verbose GT 0 THEN BEGIN
     dbg = 'DEBUG(' + STRING(lev) + '): '
     IF lev LE !sat.verbose THEN PRINT, dbg + STRING(msg)
  ENDIF
END
