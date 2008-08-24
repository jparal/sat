function stw_sca_prd, veca, vecb

;---------------------------------------------------------------------
; HISTORY
;
; - 02/2007, v.0.5.30: Written.
;---------------------------------------------------------------------
sa=size(veca,/type)
if (sa(0) eq 0) then return,-1
sb=size(vecb,/type)
if (sb(0) eq 0) then return,-1

sa=size(veca)
dim=sa(0)-1
if (sa(sa(0)) ne dim) then return, -1
sb=size(vecb)
if (sb(0) ne sa(0)) then return, -1
if (sb(sb(0)) ne dim) then return, -1

if (dim eq 3) then begin
  return, veca(*,*,*,0)*vecb(*,*,*,0) + $
          veca(*,*,*,1)*vecb(*,*,*,1) + $
          veca(*,*,*,2)*vecb(*,*,*,2)
endif
if (dim eq 2) then begin
  return, veca(*,*,0)*vecb(*,*,0) + veca(*,*,1)*vecb(*,*,1)
endif

return,-1
end
