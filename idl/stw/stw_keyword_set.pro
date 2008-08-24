;--------------------------------------------------------------------;
; IDL'S KEYWORD_SET RETURNS "FALSE" EVEN THE VALUE IS DEFINED,       ;
; BUT IT EQUALS TO ZERO. THIS HACK TRYES TO CHANGE THIS.             ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 08/2006, v.0.4.141: Written.                                     ;
;--------------------------------------------------------------------;
function stw_keyword_set, key
  s=size(key,/TYPE)
  if (s eq 0) then return, 0
  return, 1
end

;--------------------------------------------------------------------;
