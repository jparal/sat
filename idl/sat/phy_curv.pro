FUNCTION PHY_CURV, bvec, QMS=qms, MIN=min
;+
; NAME:
;
;    PHY_CURV
;
; PURPOSE:
;
;    Compute curvature drift from the given magnetic field
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
;    curvature drift vector array with same dimensions as 'bvec'
;
; MODIFICATION HISTORY:
;
; - v.0.3.0 2007-05-24 Jan Paral:
;   Initial version
;-

  ON_ERROR, 2
  RESOLVE_ALL, /QUIET

  IF (N_ELEMENTS(qms) EQ 0) THEN qms = 1.
  IF (N_ELEMENTS(min) EQ 0) THEN min = 0.00001

  ss = SIZE(bvec)
  IF (ss(0) NE 4) THEN MESSAGE, 'Wrong parameter'

  ;-------------------------------;
  ; Compute: R_c = - k / |k|^2    ;
  ;-------------------------------;
  rc = MTH_CURV(bvec)
  rc2 = rc(*,*,*,0)^2+rc(*,*,*,1)^2+rc(*,*,*,2)^2
  ndx = WHERE(rc2 LT min)
  print, 'PHY_CURV: Number of elements in k^2 (< ' + STRING(min)+') is ' + $
         STRING(n_elements(ndx))
  rc2[ndx] = 1.

  rc(*,*,*,0) = -1. * rc(*,*,*,0) / rc2
  rc(*,*,*,1) = -1. * rc(*,*,*,1) / rc2
  rc(*,*,*,2) = -1. * rc(*,*,*,2) / rc2
  rc2 = 0. ; Release

  ;--------------------------------------------------;
  ; Compute: v_rc = m / (q R_c^2 B^2) * ( R_c x B )  ;
  ;--------------------------------------------------;
  vrc = MTH_CROSS(rc, bvec)

  tmp = qms * (rc(*,*,*,0)^2+rc(*,*,*,1)^2+rc(*,*,*,2)^2) * $
        (bvec(*,*,*,0)^2+bvec(*,*,*,1)^2+bvec(*,*,*,2)^2)
  ndx = WHERE(tmp LT min)
  print, 'PHY_CURV: Number of elements in m / q R_c^2 B^2 (< ' + STRING(min)+ $
         ') is ' + STRING(n_elements(ndx))
  tmp[ndx] = 1.
  tmp = 1. / tmp

  vrc(*,*,*,0) = tmp * vrc(*,*,*,0)
  vrc(*,*,*,1) = tmp * vrc(*,*,*,1)
  vrc(*,*,*,2) = tmp * vrc(*,*,*,2)

  RETURN, vrc
END
