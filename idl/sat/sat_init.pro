PRO SAT_INIT, RESET=reset, TMP_DIR=tmp_dir

  DEFSYSV, '!sat', EXISTS=exists
  IF NOT KEYWORD_SET(exists) THEN BEGIN
     str= { $
          init:    0,  $
          tmp_dir: '', $
          verbose: 2   $
          }
     DEFSYSV,'!sat', str
  ENDIF

  IF KEYWORD_SET(reset) THEN !sat.init=0

  IF !sat.init NE 0 THEN RETURN

  IF NOT KEYWORD_SET(tmp_dir) THEN tmp_dir = GETENV ("SAT_TMP_DIR")
  IF NOT KEYWORD_SET(tmp_dir) THEN tmp_dir = '~/data/sat/'
  IF KEYWORD_SET(tmp_dir) THEN BEGIN
     temp_string = STRTRIM(tmp_dir, 2)
     ll = STRMID(temp_string, STRLEN(temp_string)-1, 1)
     ; add a slash if needed
     IF (ll NE '/' AND ll NE '\') THEN temp_string = temp_string+'/'
     !sat.tmp_dir = TEMPORARY(temp_string)
  ENDIF

  !sat.init = 1

END
