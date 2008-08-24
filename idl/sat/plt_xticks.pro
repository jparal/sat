FUNCTION PLT_XTICKS, axis, index, value

  IF (FIX(ABS(value)) LT ABS(value)) THEN BEGIN
     RETURN, string ("")
  ENDIF ELSE BEGIN
     RETURN, STRING (-value, format='(I3,"")')
  ENDELSE

END
