pro stw_e, run, itt, $
  dir=dir, eampl=eampl, $
  reload=reload, $
  ex=ex, ey=ey, ez=ez, help=help

;--------------------------------------------------------------------;
; A SHORTCUTT TO "stw_load_once_vec" TO LOAD ELECTRIC FIELD
;
; HISTORY:
;
; - 02/2007, v.0.5.29: Revisions.
; - 09/2006, v.0.4.141: Derived from "stw_b.pro".
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print,'Load electric field (a shortcutt to "stw_load_once_vec").'
print
print,'Usage:'
print
print,'IDL> stw_e,eampl=e,ex=ex,ey=ey,ez=ez,/reload,run,itt,dir=dir'
print
print,'Requires (v.0.5.29): stw_load_once_vec'
print,'--------------------------------------------------------------'
return
endif

stw_load_once_vec, 'E', run, itt, $
  vecx=ex, vecy=ey, vecz=ez, vecampl=eampl, $
  dir=dir, reload=reload

return
end

;--------------------------------------------------------------------;
