pro stw_load_once_sca, data, run, itt, $
  sca=sca, dir=dir, specie=specie, reload=reload, help=help

;--------------------------------------------------------------------;
; THIS IS A PART OF "LOAD DATA ONLY ONCE" SYSTEM.           
;                                                           
; LOAD SIMULATED SCALAR DATA. IT DOES NOT RELOAD THE DATA IF
; "sca" IS AN ARRAY ON ENTRY OF THIS ROUTINE (UNLESS /RELOAD
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
print,'Load simulated SCALAR data. It does not reload the data'
print,'if "sca" is an array on entry of this procedure (unless'
print,'the keyword /reload is set).'
print
print,'Usage:'
print
print,'IDL> stw_load_once_sca,"Dn","b25Kp","t40",sca=dn,dir="",specie=0,/reload'
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

if (not(stw_data_set(data=sca)) or $
  stw_keyword_set(reload)) then begin

  if (not(stw_keyword_set(dir))) then dir='.'
  if (strlen(dir) eq 0) then dir='.'
  if not(stw_keyword_set(specie)) then specie=''

  rd, strcompress(dir+'/'+data+string(specie)+run+itt+'.gz',/rem), sca

endif

return
end

;--------------------------------------------------------------------;
