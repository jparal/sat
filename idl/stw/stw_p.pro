pro stw_p, run, itt, dir=dir, pa=pa, pe=pe, reload=reload, specie=specie

;--------------------------------------------------------------------;
; A SHORTCUTT TO "stw_load_once_sca" TO LOAD IONIC PRESSURE
;
; HISTORY:
;
; - 02/2007, v.0.5.29: Derived from "stw_n.pro".
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print,'Load ionic pressure (a shortcutt to "stw_load_once_sca").'
print
print,'Usage:'
print
print,'IDL> stw_p,pa=pa,pe=pe,/reload,run,itt,dir=dir,specie=0'
print
print,'Requires (v.0.5.29): stw_load_once_sca'
print,'--------------------------------------------------------------'
return
endif

stw_load_once_sca, 'Ppar', run, itt, $
  sca=pa, dir=dir, reload=reload, specie=specie
stw_load_once_sca, 'Pper', run, itt, $
  sca=pe, dir=dir, reload=reload, specie=specie

return
end

;--------------------------------------------------------------------;
