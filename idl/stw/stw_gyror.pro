;--------------------------------------------------------------------;
; GIVEN SIMULATED DATA THIS FUNCTION PRODUCES                        ;
; GYRORADIUS OF THE GIVEN SPECIE.                                    ;
;                                                                    ;
; Baumjohan:          m v_perp                                       ;
;               r_g = --------                                       ;
;                       q B                                          ;
; where we use m=amu, q=charge (in units of |q|)                     ;
; v_perp = vthpe                                                     ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 09/2006, v.0.4.141: Written.                                     ;
;--------------------------------------------------------------------;
pro stw_gyror, run, itt, gyror, $
  dir=dir, amu=amu, charge=charge, bampl=bampl, vthpe=vthpe, $
  nspecie=nspecie, pspecie=pspecie, $
  reload=reload,dnmin=dnmin, $
  bx=bx, by=by, bz=bz, bamplmin=bamplmin

ss=size(gyror)

if ((ss(1) eq 0) or stw_keyword_set(reload)) then begin

  stw_load_once_vec, 'B', run, itt, $
    vecx=bx, vecy=by, vecz=bz, vecampl=bampl, $
    dir=dir, specie=nspecie, reload=reload

  ;--------------------------;
  ; Check if we need vthpe   ;
  ;--------------------------;
  if (not(stw_data_set(data=vthpe)) or $
      stw_keyword_set(reload)) then begin

    stw_vthpe, run, itt, vthpe, nspecie=nspecie, pspecie=pspecie, $
      reload=reload,dnmin=dnmin

  endif

  ss=size(bampl)
  if (ss(1) eq 0) then return
  ss=size(vthpe)
  if (ss(1) eq 0) then return

  if not(keyword_set(bamplmin)) then bamplmin=0.01
  if (bamplmin lt 0.01) then bamplmin=0.01

  bamplaux=bampl
  vthpeaux=vthpe

  stw_minval_set, bamplaux, srcdata=bampl, bamplmin, replval=1.0
  stw_minval_set, vthpeaux, srcdata=bampl, bamplmin, replval=0.0

  if not(stw_keyword_set(amu)) then amu=1
  if not(stw_keyword_set(charge)) then charge=1
  if (charge lt 0) then charge=1

  gyror=amu*vthpe/charge/bampl

endif

return
end

;--------------------------------------------------------------------;
