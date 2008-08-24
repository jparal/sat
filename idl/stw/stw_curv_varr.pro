function stw_curv_varr, avec, dx=dx,dy=dy,dz=dz

s=size(avec,/type)
if (s(0) eq 0) then return,-1

s=size(avec)
dim=s(0)-1
if (s(s(0)) ne dim) then return, -1

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0
if (dx lt 0.0001) then dx = 1.0
if (dy lt 0.0001) then dy = 1.0
if (dz lt 0.0001) then dz = 1.0

if (dim eq 3) then begin

  ;------------------------------------------;
  ; 1) Calculate: B0^2 = Bx^2 + By^2 + Bz^2  ;
  ;------------------------------------------;
  ampl2 = avec(*,*,*,0)^2+avec(*,*,*,1)^2+avec(*,*,*,2)^2
  ndx = where(ampl2 lt 0.01, cnt)
  if (cnt gt 0) then ampl2(ndx)=1.0

  ;--------------------------------;
  ; 2) Calculate: grad [ln(B0)]    ;
  ;--------------------------------;
  grad = stw_varr_ext_grid(stw_grad(alog(sqrt(ampl2)),dx=dx,dy=dy,dz=dz))

  ;-------------------------------------;
  ; 3) Calculate: B/B0 * grad [ln(B0)]  ;
  ;-------------------------------------;
  aux = stw_unit_varr(avec)
  sprd = stw_sca_prd(aux,grad)

  ;-------------------------------------------------------------;
  ; 4) Calculate: {grad [ln(B0)] - B/B0 (B/B0 * grad [ln(B0)])} ;
  ;-------------------------------------------------------------;
  grad(*,*,*,0) = grad(*,*,*,0) - aux(*,*,*,0) * sprd
  grad(*,*,*,1) = grad(*,*,*,1) - aux(*,*,*,1) * sprd
  grad(*,*,*,2) = grad(*,*,*,2) - aux(*,*,*,2) * sprd
  sprd=0.0  ; Release

  ;---------------------------------------;
  ; 5) Calculate: [(rot B) x B] / B0^2    ;
  ;---------------------------------------;
  aux = stw_varr_ext_grid(stw_rot(avec,dx=dx,dy=dy,dz=dz))
  aux = stw_cross_prd(aux,avec)
  aux(*,*,*,0) = aux(*,*,*,0)/ampl2
  aux(*,*,*,1) = aux(*,*,*,1)/ampl2
  aux(*,*,*,2) = aux(*,*,*,2)/ampl2

  return, grad+aux

endif

if (dim eq 2) then begin
  return, -1
endif

return, -1
end
