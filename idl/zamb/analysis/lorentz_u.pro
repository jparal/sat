; Returns the tranformed normalized velocity [ux,uy,uz]
;
; c = 1.0
; 
; u0 - normalized velocity [ux,uy,uz] in rest frame k0
;
; v - relative velocity of second frame k1

function lorentz_vel, u0, v
  
  ; since c = 1.0 => § = v
  
  beta = double(v)
  b2 = total(beta*beta, /double)
  
  if (b2 ge 1D0) then begin
    res = Error_Message('||Frame velocity|| must be < c')
    return, dblarr(3) 
  end
  
  gamma = 1D0/sqrt(1D0 - b2)

  ; compute lorentz transformation for velocity (Jackson, sect. 11.4)
  ;
  ; the 4-vector (gamma_u*u, gamma_u*c) transforms like (x, ct)
  
  ; get gamma_u0*u0
  _u0 = double(u0)
  gamma_u0 = 1D0/sqrt(1D0 - total(_u0*_u0, /double))
  _u0 = _u0*gamma_u0
 
  ; get gamma_u1
  a0 = total(beta*_u0, /double)
  _gamma_u1 = gamma*(gamma_u0  - a0)
  
  ; get gamma_u1*u1  
  u1 = dblarr(3)
  a1 = a0*(gamma - 1D0)/b2 - gamma*gamma_u0
  _u1 = _u0 + a1*beta

  ; get u1  
  _u1 = _u1 / _gamma_u1
    
  ; return result
  
  return, _u1

end