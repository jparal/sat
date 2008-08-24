FUNCTION PHY_ExB, ex, ey, ez, bx, by, bz, ux, uy, uz

;--------------------------------------------------------------------;
; GIVEN SIMULATED DATA THIS FUNCTION PRODUCES                        ;
; ExB DRIFT ARRAY:                                                   ;
;                                                                    ;
; Baumjohan (2.19):                                                  ;
;                          E x B                                     ;
;                   v_E = -------                                    ;
;                           B^2                                      ;
;
; Where (when present parameters ux, uy, uz) electric field is recalculated
; into plasma's local rest coordiante system:
;
;                    E_local = E - u x B
;
; HISTORY:                                                           ;
;                                                                    ;
; - v0.3.0 2007-06-04 Jan Paral
;    Add parameters ux, uy, uz so we can express ExB in plasma reference system
;    by subtracting "- u x B" term.
; - v0.3.0 2007-05-23 Jan Paral                                     ;
;    Initial version (forked from stw_exb_drift.pro)
;--------------------------------------------------------------------;

nparam = N_PARAMS()
IF ((nparam NE 6) AND (nparam NE 9)) THEN $
   MESSAGE, 'PHY_ExB: Number of params can be 6 or 9'

ssex = size(ex)
ssey = size(ey)
ssez = size(ez)
ssbx = size(bx)
ssby = size(by)
ssbz = size(bz)

IF (nparam EQ 6) THEN BEGIN
   ssux = size(ux)
   ssuy = size(uy)
   ssuz = size(uz)
ENDIF

IF (nparam EQ 6) THEN BEGIN
   UTL_CHECK_SIZE, ex, ey, ez, bx, by, bz, SMIN=[1], SMAX=[3]
ENDIF ELSE BEGIN
   UTL_CHECK_SIZE, ex, ey, ez, bx, by, bz, ux, uy, uz, SMIN=[1], SMAX=[3]
ENDELSE

dim = ssex(0)
ss = ssex

b2 = bx*bx + by*by + bz*bz
ndx = where(b2 lt 0.001, cnt)
ssndx = size(ndx)
if (cnt gt 0) then b2(ndx) = 1.0

IF (nparam EQ 9) THEN BEGIN
   ex = ex + (uy*bz - uz*by)
   ey = ey + (uz*bx - ux*bz)
   ez = ez + (ux*by - uy*bx)
ENDIF

if (dim eq 1) then begin
  exb = fltarr(ss(1),3)
  exb(*,0) = (ey*bz - ez*by) / b2
  exb(*,1) = (ez*bx - ex*bz) / b2
  exb(*,2) = (ex*by - ey*bx) / b2
endif

if (dim eq 2) then begin
  exb = fltarr(ss(1),ss(2),3)
  exb(*,*,0) = (ey*bz - ez*by) / b2
  exb(*,*,1) = (ez*bx - ex*bz) / b2
  exb(*,*,2) = (ex*by - ey*bx) / b2
endif

if (dim eq 3) then begin
  exb = fltarr(ss(1),ss(2),ss(3),3)
  exb(*,*,*,0) = (ey*bz - ez*by) / b2
  exb(*,*,*,1) = (ez*bx - ex*bz) / b2
  exb(*,*,*,2) = (ex*by - ey*bx) / b2
endif

if (cnt gt 0) then exb(ndx) = 0.0

return, exb
end

;--------------------------------------------------------------------;
