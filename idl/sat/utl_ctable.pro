PRO UTL_CTABLE, STORE=store, RESTORE=restore

  IF NOT(KEYWORD_SET(restore)) THEN BEGIN
     TVLCT, r, g, b, /GET
     store = BYTARR (3, 256)
     store(0) = r
     store(1) = g
     store(2) = b
  ENDIF ELSE BEGIN
     UTL_CHECK_SIZE, restore, ss=[2, 3, 256]
     TVLCT, restore(0), restore(1), restore(2)
  ENDELSE

END
