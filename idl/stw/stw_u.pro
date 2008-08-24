pro stw_u, run, itt, $
  dir=dir, uampl=uampl, $
  reload=reload, specie=specie, $
  ux=ux, uy=uy, uz=uz

;--------------------------------------------------------------------;
; A SHORTCUTT TO "stw_load_once_vec" TO LOAD IONIC FLUX/CURRENT
;
; HISTORY:
;
; - 02/2007, v.0.5.29: Revisions.
; - 09/2006, v.0.4.141: Derived from "stw_b.pro".
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print,'Load ionic flux (a shortcutt to "stw_load_once_vec").'
print
print,'Usage:'
print
print,'IDL> stw_u,uampl=u,ux=ux,uy=uy,uz=uz,/reload,run,itt,dir=dir,specie=0'
print
print,'Requires (v.0.5.29): stw_load_once_vec'
print,'--------------------------------------------------------------'
return
endif

stw_load_once_vec, 'U', run, itt, $
  vecx=ux, vecy=uy, vecz=uz, vecampl=uampl, $
  dir=dir, reload=reload, specie=specie

return
end

;--------------------------------------------------------------------;
