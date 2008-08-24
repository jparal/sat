;--------------------------------------------------------------------;
; THIS IS A PART OF "LOAD DATA ONLY ONCE" SYSTEM. IN THIS SYSTEM     ;
; DATA ARRAYS ARE PASSED THROUGH KEYWORDS. THIS SERVICE CHECKS       ;
; WHETHER "data" IS SET AND WHETHER IT IS AN ARRAY.                  ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 09/2006, v.0.4.141: Written.                                     ;
;--------------------------------------------------------------------;
function stw_data_set, data=data

  if stw_keyword_set(data) then dataset=1  else dataset=0

  if (dataset eq 1) then begin
    ss=size(data)
    if (ss(1) eq 0) then dataset=0
  endif

  return, dataset

end

;--------------------------------------------------------------------;
