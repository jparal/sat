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
pro stw_vthpe, run, itt, vthpe, $
  density=density, pepressure=pepressure, $
  dir=dir, nspecie=nspecie, pspecie=pspecie, $
  reload=reload,dnmin=dnmin

ss=size(vthpe)

if ((ss(1) eq 0) or stw_keyword_set(reload)) then begin

  stw_load_once_sca, 'Dn', run, itt, sca=density, $
    dir=dir, specie=nspecie, reload=reload
  stw_load_once_sca, 'Pper', run, itt, sca=pepressure, $
    dir=dir, specie=pspecie, reload=reload

  ss=size(density)
  if (ss(1) eq 0) then return
  ss=size(pepressure)
  if (ss(1) eq 0) then return

  if not(keyword_set(dnmin)) then dnmin=0.005
  if (dnmin lt 0.005) then dnmin=0.005

  dnaux=density
  pepaux=pepressure

  stw_minval_set, dnaux,  srcdata=density, dnmin, replval=1.0
  stw_minval_set, pepaux, srcdata=density, dnmin, replval=0.0

  vthpe = sqrt (2 * pepaux / dnaux)

endif

return
end

;--------------------------------------------------------------------;
