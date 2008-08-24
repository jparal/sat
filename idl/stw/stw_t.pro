;--------------------------------------------------------------------;
; GIVEN SIMULATED DATA THIS FUNCTION PRODUCES                        ;
; TEMPERATURE OF THE GIVEN SPECIE.                                   ;
;                                                                    ;
; P = n kB T; P = 1/3 * (2*Pe+Pa), kB=1                              ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 09/2006, v.0.4.141: Derived from "stw_vthpe.pro".                ;
;--------------------------------------------------------------------;
pro stw_t, run, itt, temp, $
  density=density, papressure=papressure, pepressure=pepressure, $
  dir=dir, nspecie=nspecie, pspecie=pspecie, $
  reload=reload,dnmin=dnmin

ss=size(temp)

if ((ss(1) eq 0) or stw_keyword_set(reload)) then begin

  stw_load_once_sca, 'Dn', run, itt, sca=density, $
    dir=dir, specie=nspecie, reload=reload
  stw_load_once_sca, 'Ppar', run, itt, sca=papressure, $
    dir=dir, specie=pspecie, reload=reload
  stw_load_once_sca, 'Pper', run, itt, sca=pepressure, $
    dir=dir, specie=pspecie, reload=reload

  ss=size(density)
  if (ss(1) eq 0) then return
  ss=size(papressure)
  if (ss(1) eq 0) then return
  ss=size(pepressure)
  if (ss(1) eq 0) then return

  if not(keyword_set(dnmin)) then dnmin=0.005
  if (dnmin lt 0.005) then dnmin=0.005

  dnaux=density
  papaux=papressure
  pepaux=pepressure

  stw_minval_set, dnaux,  srcdata=density, dnmin, replval=1.0
  stw_minval_set, papaux, srcdata=density, dnmin, replval=0.0
  stw_minval_set, pepaux, srcdata=density, dnmin, replval=0.0

  temp = (2.0*pepaux+papaux)/3.0

endif

return
end

;--------------------------------------------------------------------;
