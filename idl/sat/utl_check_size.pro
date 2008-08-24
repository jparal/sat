PRO UTL_CHECK_SIZE, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, $
                    ss=ss, smin=smin, smax=smax

  ON_ERROR, 2

  nparam = N_PARAMS ()
  IF (nparam LT 1) THEN MESSAGE, 'We require at least two arguments to compare'

  s0 = SIZE (a0)
  IF KEYWORD_SET(ss) THEN BEGIN
     FOR i=0, N_ELEMENTS(ss)-1 DO BEGIN
        IF (s0(i) NE ss(i)) THEN MESSAGE, 'SIZE doesnt match'
     ENDFOR
  ENDIF
  IF KEYWORD_SET(smin) THEN BEGIN
     FOR i=0, N_ELEMENTS(smin)-1 DO BEGIN
        IF (s0(i) LT smin(i)) THEN MESSAGE, 'SIZE doesnt match'
     ENDFOR
  ENDIF
  IF KEYWORD_SET(smax) THEN BEGIN
     FOR i=0, N_ELEMENTS(smax)-1 DO BEGIN
        IF (s0(i) GT smax(i)) THEN MESSAGE, 'SIZE doesnt match'
     ENDFOR
  ENDIF

  msg = 'Incompatibility of size structures in dimension:'
  FOR i=1, nparam-1 DO BEGIN
     IF (i EQ 1) THEN sn = SIZE (a1)
     IF (i EQ 2) THEN sn = SIZE (a2)
     IF (i EQ 3) THEN sn = SIZE (a3)
     IF (i EQ 4) THEN sn = SIZE (a4)
     IF (i EQ 5) THEN sn = SIZE (a5)
     IF (i EQ 6) THEN sn = SIZE (a6)
     IF (i EQ 7) THEN sn = SIZE (a7)
     IF (i EQ 8) THEN sn = SIZE (a8)
     IF (i EQ 9) THEN sn = SIZE (a9)

     ndim = s0(0)
     FOR j=0, ndim DO BEGIN
        IF (s0(j) NE sn(j)) THEN MESSAGE, msg + STRING(j)
     ENDFOR

  ENDFOR

  RETURN
END
