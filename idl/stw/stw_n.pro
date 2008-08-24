pro stw_n, run, itt, dir=dir, n=n, reload=reload, specie=specie

;--------------------------------------------------------------------;
; A SHORTCUTT TO "stw_load_once_sca" TO LOAD IONIC DENSITY
;
; HISTORY:
;
; - 02/2007, v.0.5.29: Derived from "stw_u.pro".
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print,'Load ionic density (a shortcutt to "stw_load_once_sca").'
print
print,'Usage:'
print
print,'IDL> stw_n,n=n,/reload,run,itt,dir=dir,specie=0'
print
print,'Requires (v.0.5.29): stw_load_once_sca'
print,'--------------------------------------------------------------'
return
endif

stw_load_once_sca, 'Dn', run, itt, $
  sca=n, dir=dir, reload=reload, specie=specie

return
end

;--------------------------------------------------------------------;
