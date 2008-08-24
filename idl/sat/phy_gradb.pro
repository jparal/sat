FUNCTION PHY_GRADB, bvec, QMS=qms, MIN=min
;+
; NAME:
;
;    PHY_GRADB
;
; PURPOSE:
;
;    Compute grad B drift from the given magnetic field
;
; CATEGORY:
;
;    PHYSICS
;
; INPUTS:
;
;    bvec: Magnetic field vector array in form: bvec[*,*,*,3]
;
; KEYWORD PARAMETERS:
;
;    QMS: charge to mass ratio
;
;    MIN: Trashold for division by zero
;
; OUTPUTS:
;
;    grad B drift vector array with same dimensions as 'bvec'
;
; MODIFICATION HISTORY:
;
; - v.0.3.0 2007-05-24 Jan Paral:
;   Initial version
;
;-

  ON_ERROR, 2
  RESOLVE_ALL, /QUIET

  IF (N_ELEMENTS(qms) EQ 0) THEN qms = 1.
  IF (N_ELEMENTS(min) EQ 0) THEN min = 0.00001

  ss = SIZE(bvec)
  IF (ss(0) NE 4) THEN MESSAGE, 'Wrong parameter'

  bb = SQRT(bvec[*,*,*,0]^2+bvec[*,*,*,1]^2+bvec[*,*,*,2]^2)

  gradb = MTH_CROSS(bvec, DAT_REGRID(MTH_GRAD(bb)))
  tmp = 2. * qms * bb^3
  ndx = WHERE(tmp LT min)
  print, 'PHY_GRADB: Number of elements in m / q B^3 (< ' + STRING(min)+ $
         ') is ' + STRING(n_elements(ndx))
  tmp[ndx] = 1.
  tmp = 1. / tmp

  gradb(*,*,*,0) = tmp * gradb(*,*,*,0)
  gradb(*,*,*,1) = tmp * gradb(*,*,*,1)
  gradb(*,*,*,2) = tmp * gradb(*,*,*,2)

  RETURN, gradb
END
