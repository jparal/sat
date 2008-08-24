function stw_exb_drift, ex, ey, ez, bx, by, bz

;--------------------------------------------------------------------;
; GIVEN SIMULATED DATA THIS FUNCTION PRODUCES                        ;
; ExB DRIFT ARRAY:                                                   ;
;                                                                    ;
; Baumjohan (2.19):                                                  ;
;                          E x B                                     ;
;                   v_E = -------                                    ;
;                           B^2                                      ;
; HISTORY:                                                           ;
;                                                                    ;
; - 02/2007, v.0.5.29: Started.                                      ;
;--------------------------------------------------------------------;

ssex = size(ex)
ssey = size(ey)
ssez = size(ez)
ssbx = size(bx)
ssby = size(by)
ssbz = size(bz)

dim = ssex(0)
if ((dim lt 1) or (dim gt 3)) then return, -1
if ((ssey(0) ne dim) or (ssez(0) ne dim) or $
    (ssbx(0) ne dim) or (ssby(0) ne dim) or (ssbz(0) ne dim)) then return, -1

nx = ssex(1)
ny = 1
nz = 1
if ((ssey(1) ne nx) or (ssez(1) ne nx) or $
    (ssbx(1) ne nx) or (ssby(1) ne nx) or (ssbz(1) ne nx)) then return, -1
if (dim gt 1) then begin
  ny = ssex(2)
  if ((ssey(2) ne ny) or (ssez(2) ne ny) or $
      (ssbx(2) ne ny) or (ssby(2) ne ny) or (ssbz(2) ne ny)) then return, -1
endif
if (dim gt 2) then begin
  nz = ssex(3)
  if ((ssey(3) ne nz) or (ssez(3) ne nz) or $
      (ssbx(3) ne nz) or (ssby(3) ne nz) or (ssbz(3) ne nz)) then return, -1
endif

b2 = bx*bx + by*by + bz*bz
ndx = where(b2 lt 0.001, cnt)
ssndx = size(ndx)
if (cnt gt 0) then b2(ndx) = 1.0

if (dim eq 1) then begin
  exb = fltarr(nx,3)
  exb(*,0) = (ey*bz - ez*by) / b2
  exb(*,1) = (ez*bx - ex*bz) / b2
  exb(*,2) = (ex*by - ey*bx) / b2
endif

if (dim eq 2) then begin
  exb = fltarr(nx,ny,3)
  exb(*,*,0) = (ey*bz - ez*by) / b2
  exb(*,*,1) = (ez*bx - ex*bz) / b2
  exb(*,*,2) = (ex*by - ey*bx) / b2
endif

if (dim eq 3) then begin
  exb = fltarr(nx,ny,nz,3)
  exb(*,*,*,0) = (ey*bz - ez*by) / b2
  exb(*,*,*,1) = (ez*bx - ex*bz) / b2
  exb(*,*,*,2) = (ex*by - ey*bx) / b2
endif

if (cnt gt 0) then exb(ndx) = 0.0

return, exb
end

;--------------------------------------------------------------------;
