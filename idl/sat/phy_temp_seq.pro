PRO phy_temp_seq, fil, t0, step, t, $
                    bname=bname, $
                    verbose=verbose, compress=compress,suffix=suffix
;+
; NAME:
;       PHY_TEMP_SEQ
;
;
; PURPOSE:
;       Procedure sequentialy generate parallel and perpendicular temperatures
;       from the sequence of Tx, Ty, Tz and Bx, By, Bz or optionaly magnetic
;       field can be same through out the process
;
;
; CATEGORY:
;       Transform data
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;       None
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;       Feb 18 2007, Jan Paral <jparal@gmail.com>
;		Initial version
;
;-

  RESOLVE_ALL, /QUIET

  IF (NOT (keyword_set(verbose))) THEN verbose=0
  IF (NOT (keyword_set(compress))) THEN compress=0
  IF (NOT (keyword_set(suffix))) THEN suffix=' '

  IF (compress EQ 1)THEN suffix=suffix+'.gz'

  num=(t-t0)/step

  IF (KEYWORD_SET (bname)) THEN BEGIN

     fname = STRCOMPRESS ('Bx'+bname,/REMOVE_ALL)
     IF (FEXIST (fname,FIRST=first)) THEN BEGIN
        IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
        RD3,fname,bx
     ENDIF ELSE BEGIN
        RETURN
     ENDELSE

     fname = STRCOMPRESS ('By'+bname,/REMOVE_ALL)
     IF (FEXIST (fname,FIRST=first)) THEN BEGIN
        IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
        RD3,fname,by
     ENDIF ELSE BEGIN
        RETURN
     ENDELSE

     fname = STRCOMPRESS ('Bz'+bname,/REMOVE_ALL)
     IF (FEXIST (fname,FIRST=first)) THEN BEGIN
        IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
        RD3,fname,bz
     ENDIF ELSE BEGIN
        RETURN
     ENDELSE
     
  ENDIF

  FOR I=0, num DO BEGIN

     IF (NOT (KEYWORD_SET (bname))) THEN BEGIN
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Read magnetic field
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        fname = STRCOMPRESS ('Bx'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
        IF (FEXIST (fname,FIRST=first)) THEN BEGIN
           IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
           RD3,fname,bx,COMPRESS=compress
        ENDIF ELSE BEGIN
           RETURN
        ENDELSE

        fname = STRCOMPRESS ('By'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
        IF (FEXIST (fname,FIRST=first)) THEN BEGIN
           IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
           RD3,fname,by,COMPRESS=compress
        ENDIF ELSE BEGIN
           RETURN
        ENDELSE

        fname = STRCOMPRESS ('Bz'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
        IF (FEXIST (fname,FIRST=first)) THEN BEGIN
           IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
           RD3,fname,bz,COMPRESS=compress
        ENDIF ELSE BEGIN
           RETURN
        ENDELSE

     ENDIF

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Read Temperatures
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     fname = STRCOMPRESS ('Tx'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
     IF (FEXIST (fname,FIRST=first)) THEN BEGIN
        IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
        RD3,fname,tx,COMPRESS=compress
     ENDIF ELSE BEGIN
        RETURN
     ENDELSE

     fname = STRCOMPRESS ('Ty'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
     IF (FEXIST (fname,FIRST=first)) THEN BEGIN
        IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
        RD3,fname,ty,COMPRESS=compress
     ENDIF ELSE BEGIN
        RETURN
     ENDELSE

     fname = STRCOMPRESS ('Tz'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
     IF (FEXIST (fname,FIRST=first)) THEN BEGIN
        IF (verbose EQ  1) THEN PRINT, 'RD: ' + first
        RD3,fname,tz,COMPRESS=compress
     ENDIF ELSE BEGIN
        RETURN
     ENDELSE

     DAT_PAR_PER, tx, ty, tz, bx, by, bz, tpar, tper

     fname = STRCOMPRESS ('Tpar'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
     IF (verbose EQ  1) THEN PRINT, 'WR: ' + fname
     WR, fname, tpar, COMPRESS=compress

     fname = STRCOMPRESS ('Tper'+fil+String(t0+i*step)+suffix,/REMOVE_ALL)
     IF (verbose EQ  1) THEN PRINT, 'WR: ' + fname
     WR, fname, tper, COMPRESS=compress

  ENDFOR

  RETURN
END
