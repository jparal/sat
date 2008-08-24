FUNCTION DAT_CONGRID, data, nx, ny, nz, RESIN=resin, RESOUT=resout, $
                      CENTER=center

  IF (N_PARAMS() LT 2) THEN MESSAGE, 'Number of params is wrong'

  IF NOT(KEYWORD_SET(resin)) THEN   resin=[1.0, 1.0, 1.0]
  IF NOT(KEYWORD_SET(resout)) THEN resout=[1.0, 1.0, 1.0]
  IF NOT(KEYWORD_SET(center)) THEN center=[0.5, 0.5, 0.5]

  ss = size(data)

  ;; c(x|y|z): Total number of cells we need from 'data'

  IF (ss(0) GE 1) THEN BEGIN
     cx = nx * resout(0) / resin(0)
     nxmin = long(ss(1) * center(0) - cx / 2.)
     nxmax = long(ss(1) * center(0) + cx / 2.)
     IF (nxmin LT 0)     THEN nxmin = 0
     IF (nxmax GE ss(1)) THEN nxmax = ss(1)-1
  ENDIF

  IF (ss(0) GE 2) THEN BEGIN
     cy = ny * resout(1) / resin(1)
     nymin = long(ss(2) * center(1) - cy / 2.)
     nymax = long(ss(2) * center(1) + cy / 2.)
     IF (nymin LT 0)     THEN nymin = 0
     IF (nymax GE ss(2)) THEN nymax = ss(2)-1
  ENDIF

  IF (ss(0) GE 3) THEN BEGIN
     cz = nz * resout(2) / resin(2)
     nzmin = long(ss(3) * center(2) - cz / 2.)
     nzmax = long(ss(3) * center(2) + cz / 2.)
     IF (nzmin LT 0)     THEN nzmin = 0
     IF (nzmax GE ss(3)) THEN nzmax = ss(3)-1
  ENDIF

  CASE ss(0) OF  
     1: BEGIN
        dataloc = data[nxmin:nxmax]
        dataout = CONGRID(dataloc,nx,ny,nz)
     END
     2: BEGIN
        dataloc = data[nxmin:nxmax, nymin:nymax]
        dataout = CONGRID(dataloc,nx,ny,nz)
     END
     3: BEGIN
        dataloc = data[nxmin:nxmax, nymin:nymax, nzmin:nzmax]
        dataout = CONGRID(dataloc,nx,ny,nz)
     END
  ENDCASE

  RETURN, dataout

END
