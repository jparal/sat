PRO PHY_ANI, tpar, tper, ani, MIN=min, INVERSE=inverse

  IF NOT (KEYWORD_SET(pamin)) THEN min=0.01
  IF (min LT 0.01) THEN min=0.01

  ndx = WHERE (tpar LT min, cnt)
  sn = SIZE (ndx)
  IF (sn (0) EQ 0) THEN RETURN

  IF KEYWORD_SET(inverse) THEN BEGIN
    tpar(ndx)=0.0
    tper(ndx)=1.0
    ani=tpar/tper ;;-1.
  ENDIF ELSE BEGIN
    tpar(ndx)=1.0
    tper(ndx)=0.0
    ani=tper/tpar ;;-1.
  ENDELSE

  RETURN
END
