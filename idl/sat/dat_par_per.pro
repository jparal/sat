PRO dat_par_per, tx, ty, tz, bx, by, bz, tpar, tper
;+
; NAME:
;       SAT_PAR_PER
;
;
; PURPOSE:
;       Transform T[X,Y,Z] into parallel and perpendicular direction in sence
;       of B[X,Y,Z]
;
;
; CATEGORY:
;       Data transformations
;
;
; CALLING SEQUENCE:
;       SATTR_PAR_PER, tx, ty, tz, bx, by, bz, tpar, tper
;
;
; INPUTS:
;       tx, ty, tz, bx, by, bz
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
;       tpar, tper
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
;       Modifies parameters tpar, tper
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

  tt = sqrt(tx^2 + tz^2 + tz^2)
  bb = sqrt(bx^2 + bz^2 + bz^2)
  bx0 = bx / bb
  by0 = by / bb
  bz0 = bz / bb

  tpar = tx*bx0 + ty*by0 + tz*bz0
  tper = sqrt( (tx - tpar*bx0)^2 + (ty - tpar*by0)^2 + (tz - tpar*bz0)^2 )

  RETURN
END
