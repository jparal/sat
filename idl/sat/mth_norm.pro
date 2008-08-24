function mth_norm, vec

; Normalize the vectors in an array VEC[*,*,*,3] to unity
;
; HISTORY:
; - v.0.3.0 2007-05-24 Jan Paral
;    Initial version (forked from stw_unit_varr.pro)

s=size(vec,/type)
if (s(0) eq 0) then return,-1

s=size(vec)
dim=s(0)-1
if (s(s(0)) ne dim) then return, -1

if (dim eq 3) then begin
  retv = fltarr(s(1),s(2),s(3),3)
  ampl = sqrt(vec(*,*,*,0)*vec(*,*,*,0) + $
              vec(*,*,*,1)*vec(*,*,*,1) + $
              vec(*,*,*,2)*vec(*,*,*,2))

  retv(*,*,*,0) = vec(*,*,*,0)
  retv(*,*,*,1) = vec(*,*,*,1)
  retv(*,*,*,2) = vec(*,*,*,2)

  ndx = where(ampl lt 0.01, cnt)

  if (cnt gt 0) then begin
    ampl(ndx)=1.0
    retv(ndx,0)=0.0
    retv(ndx,1)=0.0
    retv(ndx,2)=0.0
  endif

  retv(*,*,*,0) = retv(*,*,*,0)/ampl
  retv(*,*,*,1) = retv(*,*,*,1)/ampl
  retv(*,*,*,2) = retv(*,*,*,2)/ampl

  return, retv
endif
if (dim eq 2) then begin
  return, -1
endif

return,-1
end
