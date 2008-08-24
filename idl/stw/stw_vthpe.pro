function stw_vthpe, n, pe, nmin=nmin

;--------------------------------------------------------------------;
; GIVEN SIMULATED DATA THIS FUNCTION PRODUCES                        ;
; PERPENDICULAR THERMAL VELOCITY OF THE GIVEN SPECIE.                ;
;                                                                    ;
; Baumjohan p. 115: (<v>_perp)^2 = 2 kB T_perp                       ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 09/2006, v.0.4.141: Written.                                     ;
;--------------------------------------------------------------------;
ss=size(n,/type)
if (ss(0) eq 0) then return, -1
ss=size(pe,/type)
if (ss(0) eq 0) then return, -1

if not(keyword_set(nmin)) then nmin=0.005
if (nmin lt 0.005) then nmin=0.005

naux=n
peaux=pe

stw_minval_set, naux,  srcdata=n, nmin, replval=1.0
stw_minval_set, peaux, srcdata=n, nmin, replval=0.0

ss=size(naux)
dim=ss(0)

if (dim eq 3) then begin
  nx=ss(1)
  ny=ss(2)
  nz=ss(3)
  ss=size(peaux)
  if (ss(0) ne 3) then return, -1
  if ((ss(1) ne nx) or (ss(2) ne ny) or (ss(3) ne nz)) then return, -1
endif

if (dim eq 2) then begin
  nx=ss(1)
  ny=ss(2)
  ss=size(peaux)
  if (ss(0) ne 2) then return, -1
  if ((ss(1) ne nx) or (ss(2) ne ny)) then return, -1
endif

if (dim eq 1) then begin
  nx=ss(1)
  ss=size(peaux)
  if (ss(0) ne 1) then return, -1
  if (ss(1) ne nx) then return, -1
endif

return, sqrt(2.0*peaux/naux)
end

;--------------------------------------------------------------------;
