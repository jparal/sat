PRO UTL_CHECK_PARAMS, nparam, lo, hi

  ON_ERROR, 2

  n = N_PARAMS ()

  IF (n EQ 2 AND nparam NE lo) THEN BEGIN
     msg = STRCOMPRESS ('Number of params should be: ' + STRING(lo))
     MESSAGE, msg
  ENDIF

  IF (n EQ 3 AND nparam LT lo OR nparam GT hi) THEN BEGIN
     msg = STRCOMPRESS ('Number of params should be between : ' + $
                        STRING(lo) + ' and ' + STRING (hi))
     MESSAGE, msg
  ENDIF

  RETURN
END
