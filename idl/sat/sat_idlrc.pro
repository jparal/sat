FUNCTION SAT_IDLRC, CBARMARGIN=cbarmargin, PUBENV=pubenv

  IF N_ELEMENTS(pubenv) NE 0 THEN BEGIN
     !P.FONT=0
;;     !P.CHARSIZE=0.8
;;      !P.THICK=2
;;      !X.STYLE=2
;;      !Y.STYLE=2
  ENDIF

  IF N_ELEMENTS(cbarmargin) NE 0 THEN RETURN, .12

  RETURN, 0
END
