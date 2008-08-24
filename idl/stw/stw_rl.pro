function stw_rl, bampl, vthpe, $
  amu=amu, charge=charge, bamplmin=bamplmin

;--------------------------------------------------------------------;
; GIVEN SIMULATED DATA THIS FUNCTION PRODUCES
; GYRORADIUS OF THE GIVEN SPECIE.
;
; Baumjohan:          m v_perp
;               r_L = --------
;                       q B
;
; where we use m=amu, q=charge (in units of |q|)
; v_perp = vthpe
;
; HISTORY:
;
; - 02/2007, v.0.5.30: Reviding.
; - 09/2006, v.0.4.143: Removed "specie" keyvord from loading of
;   the magnetic field data.
; - 09/2006, v.0.4.141: Written.
;--------------------------------------------------------------------;
ss=size(bampl,/type)
if (ss(0) eq 0) then return, -1
ss=size(vthpe,/type)
if (ss(0) eq 0) then return, -1

if not(stw_keyword_set(amu)) then amu=1.0 else amu=float(amu)
if not(stw_keyword_set(charge)) then charge=1.0 else charge=float(charge)

if not(keyword_set(bamplmin)) then bamplmin=0.01
if (bamplmin lt 0.01) then bamplmin=0.01

bamplaux=bampl
vthpeaux=vthpe

stw_minval_set, bamplaux, srcdata=bampl, bamplmin, replval=1.0
stw_minval_set, vthpeaux, srcdata=bampl, bamplmin, replval=0.0

ss=size(bamplaux)
dim=ss(0)

if (dim eq 3) then begin
  nx=ss(1)
  ny=ss(2)
  nz=ss(3)
  ss=size(vthpe)
  if (ss(0) ne 3) then return, -1
  if ((ss(1) ne nx) or (ss(2) ne ny) or (ss(3) ne nz)) then return, -1
endif

if (dim eq 2) then begin
  nx=ss(1)
  ny=ss(2)
  ss=size(vthpe)
  if (ss(0) ne 2) then return, -1
  if ((ss(1) ne nx) or (ss(2) ne ny)) then return, -1
endif

if (dim eq 1) then begin
  nx=ss(1)
  ss=size(vthpe)
  if (ss(0) ne 1) then return, -1
  if (ss(1) ne nx) then return, -1
endif

return, amu*vthpe/charge/bampl
end

;--------------------------------------------------------------------;
