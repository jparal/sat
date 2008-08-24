pro stw_b, run, itt, $
  dir=dir, bampl=bampl, $
  reload=reload, $
  bx=bx, by=by, bz=bz, help=help

;--------------------------------------------------------------------;
; A SHORTCUTT TO "stw_load_once_vec" TO LOAD MAGNETIC FIELD
;
; HISTORY:
;
; - 02/2007, v.0.5.29: Revisions.
; - 09/2006, v.0.4.141: Written.
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print,'Load magnetic field (a shortcutt to "stw_load_once_vec").'
print
print,'Usage:'
print
print,'IDL> stw_b,bampl=b,bx=bx,by=by,bz=bz,/reload,run,itt,dir=dir'
print
print,'Requires (v.0.5.29): stw_load_once_vec'
print,'--------------------------------------------------------------'
return
endif

stw_load_once_vec, 'B', run, itt, $
  vecx=bx, vecy=by, vecz=bz, vecampl=bampl, $
  dir=dir, reload=reload

return
end

;--------------------------------------------------------------------;
