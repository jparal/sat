pro stw_load_once_vec, data, run, itt, $
  vecx=vecx, vecy=vecy, vecz=vecz, vecampl=vecampl, $
  dir=dir, specie=specie, reload=reload, help=help

;--------------------------------------------------------------------;
; THIS IS A PART OF "LOAD DATA ONLY ONCE" SYSTEM.
;
; LOAD SIMULATED VECTOR DATA. IT DOES NOT RELOAD THE DATA IF
; "vec?" ARE ARRAYS ON ENTRY OF THIS ROUTINE (UNLESS RELOAD
; IS SET).
;
; HISTORY:
;
; - 02/2007, v.0.5.29: Revisions. "specie" was a string in previous
;   version, now it is an integer. Improoved failsafe behaviour:
;   size of required parameters is checked, procedure returns if
;   they are not set.
; - 09/2006, v.0.4.141: Written.
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print,'Load simulated VECTOR data. It does not reload the data'
print,'if "sca" is an array on entry of this procedure (unless'
print,'the keyword /reload is set).'
print
print,'Usage:'
print
print,'IDL> stw_load_once_vec,"B","b25Kp","t40",vecx=bx,vecy=by,vecz=bz,vecampl=b,dir="",/reload'
print
print,'Requires (v.0.5.29): stw_data_set, stw_keyword_set, strlen, rd'
print,'  strcompress, size'
print,'--------------------------------------------------------------'
return
endif

;--------------------------------------------------------;
; Check whether required input parameters are provided.  ;
; Return if not.                                         ;
;--------------------------------------------------------;
chkrun=size(run,/type) & if (chkrun eq 0) then return
chkitt=size(itt,/type) & if (chkitt eq 0) then return

if (not(stw_data_set(data=vecx)) or $
    not(stw_data_set(data=vecy)) or $
    not(stw_data_set(data=vecz)) or $
  stw_keyword_set(reload)) then begin

  if (not(stw_keyword_set(dir))) then dir='.'
  if (strlen(dir) eq 0) then dir='.'
  if not(stw_keyword_set(specie)) then specie=''

  rd, strcompress(dir+'/'+data+'x'+string(specie)+run+itt+'.gz',/rem), vecx
  rd, strcompress(dir+'/'+data+'y'+string(specie)+run+itt+'.gz',/rem), vecy
  rd, strcompress(dir+'/'+data+'z'+string(specie)+run+itt+'.gz',/rem), vecz

  ssx=size(vecx)
  if (ssx(1) eq 0) then return
  ssy=size(vecy)
  if (ssy(1) eq 0) then return
  ssz=size(vecz)
  if (ssz(1) eq 0) then return

  vecampl = sqrt (vecx*vecx + vecy*vecy + vecz*vecz)

endif else begin

  ; vecx, vecy, vecz are set (available) and no reload
  ; however, vecampl maybe unset. So check and set it ...

  if not(stw_data_set(data=vecampl)) then begin
    vecampl = sqrt (vecx*vecx + vecy*vecy + vecz*vecz)
  endif

endelse

return
end

;--------------------------------------------------------------------;
