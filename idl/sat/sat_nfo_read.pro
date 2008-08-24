PRO SAT_NFO_READ, dir, fname

;;  RESOLVE_ALL, /QUIET

  np = N_PARAMS()

  UTL_CHECK_PARAMS, np, 1, 2

  IF (np EQ 1) THEN BEGIN
     fname = dir
     dir = FILE_EXPAND_PATH('')
  ENDIF

  fpath = STRCOMPRESS( dir + PATH_SEP() + fname )

;  IF (FILE_TEST( fpath, /READ,/REGULAR )) THEN BEGIN
     print, 'Execute: ' + fpath
     r = execute (fname)
;  ENDIF

  RETURN
END
