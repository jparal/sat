; Returns the tranformed 4-vector [x,y,z,t]
;
; c = 1.0
;
; x0 - position 4-vector [x,y,z,t] in rest frame k0
;
; v0 - relative velocity of second frame k1

function lorentz_pos, x0, v
  _t0 = double(x0[3])
  
  x1 = dblarr(4)
  
  ; since c = 1.0 => § = v
  
  beta = double(v)
  b2 = total(beta*beta, /double)
  
  if (b2 ge 1D0) then begin
    res = Error_Message('||Frame velocity|| must be < c')
    return, dblarr(3) 
  end

  gamma = 1D0/sqrt(1D0 - b2)

  ; compute lorentz transformation for 4-vector (Jackson, sect. 11.3)
  ;
  ; c t' = gamma ( c t - beta.x )
  ;
  ; x' = x + ((gamma - 1)/beta^2) (beta.x) beta - gamma beta c t
  ;
  ; for c = 1.0

  _x0 = double(x0[0:2])
  a0 = total(beta*_x0, /double)
  x1[3] = gamma*(_t0 - a0)
  a1 = a0*(gamma - 1D0)/b2 - gamma*_t0
  x1[0:2] = _x0 + a1*beta
  
  ; return result
  
  return, x1

end