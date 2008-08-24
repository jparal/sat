FUNCTION MTH_CURV, avec, DX=dx, DY=dy, DZ=dz
;
; CALCULATE Local curvature (\kappa) of the field.
; Then Local curvature radius is:
;     R_C = - \kappa \ |\kappa|^2
;
; HISTORY:
; - v.0.3.0 2007-05-24 Jan Paral
;    Initial version (forked from stw_curv_varr.pro)

  s=size(avec,/type)
  IF (s(0) EQ 0) THEN MESSAGE, 'Wrong input type'

  s=size(avec)
  dim=s(0)-1
  IF (s(s(0)) NE dim) THEN MESSAGE, 'Wrong input dimensions'

  IF (N_ELEMENTS(dx) EQ 0) THEN dx=1.0
  IF (N_ELEMENTS(dy) EQ 0) THEN dy=1.0
  IF (N_ELEMENTS(dz) EQ 0) THEN dz=1.0
  IF (dx LT 0.0001) THEN dx = 1.0
  IF (dy LT 0.0001) THEN dy = 1.0
  IF (dz LT 0.0001) THEN dz = 1.0

  IF (dim EQ 3) THEN BEGIN

  ;------------------------------------------;
  ; 1) Calculate: B0^2 = Bx^2 + By^2 + Bz^2  ;
  ;------------------------------------------;
  ampl2 = avec(*,*,*,0)^2+avec(*,*,*,1)^2+avec(*,*,*,2)^2
  ndx = where(ampl2 LT 0.01, cnt)
  IF (cnt GT 0) THEN ampl2(ndx)=1.0

  ;--------------------------------;
  ; 2) Calculate: grad [ln(B0)]    ;
  ;--------------------------------;
  grad = DAT_REGRID(MTH_GRAD(alog(sqrt(ampl2)),dx=dx,dy=dy,dz=dz))

  ;-------------------------------------;
  ; 3) Calculate: B/B0 * grad [ln(B0)]  ;
  ;-------------------------------------;
  aux = MTH_NORM(avec)
  sprd = MTH_DOT(aux,grad)

  ;-------------------------------------------------------------;
  ; 4) Calculate: {grad [ln(B0)] - B/B0 (B/B0 * grad [ln(B0)])} ;
  ;-------------------------------------------------------------;
  grad(*,*,*,0) = grad(*,*,*,0) - aux(*,*,*,0) * sprd
  grad(*,*,*,1) = grad(*,*,*,1) - aux(*,*,*,1) * sprd
  grad(*,*,*,2) = grad(*,*,*,2) - aux(*,*,*,2) * sprd
  sprd=0.0  ; Release

  ;---------------------------------------;
  ; 5) Calculate: [(rot B) x B] / B0^2    ;
  ;---------------------------------------;
  aux = DAT_REGRID(MTH_ROT(avec,dx=dx,dy=dy,dz=dz))
  aux = MTH_CROSS(aux,avec)
  aux(*,*,*,0) = aux(*,*,*,0)/ampl2
  aux(*,*,*,1) = aux(*,*,*,1)/ampl2
  aux(*,*,*,2) = aux(*,*,*,2)/ampl2

  RETURN, grad+aux

ENDIF

IF (dim EQ 2) THEN BEGIN
  RETURN, -1
ENDIF

RETURN, -1
END
