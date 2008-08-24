FUNCTION GENFNAMES, sensor, runname, from, step, to

  FOR iter = from, to, step DO BEGIN
     IF (iter EQ from) THEN BEGIN
        fnames = utl_stwfname(sensor, runname, iter, suffix='.h5')
     ENDIF ELSE BEGIN
        fnames = [fnames, utl_stwfname(sensor, runname, iter, suffix='.h5')]
     ENDELSE
  ENDFOR

  RETURN, fnames
END
