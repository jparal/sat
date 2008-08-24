; Returns the tranformed fields e1 = [e1x,e1y,e1z], b1 = [b1x,b1y,b1z]
;
; c = 1.0
; 
; e0 - [e0x,e0y,e0z], Electric Field in the rest frame
; b0 - [b0x,b0y,b0z], Magnetic Field in the rest frame
;
; v - relative velocity of second frame k1


pro lorentz_fld, e0, b0, e1, b1, v
  ; since c = 1.0 => § = v
  
  beta = double(v)
  b2 = total(beta*beta, /double)
  
  if (b2 ge 1D0) then begin
    res = Error_Message('||Frame velocity|| must be < c')
    return
  end
  
  gamma = 1D0/sqrt(1D0 - b2)
  
  ; compute lorentz transformation for EM Fields (Jackson, sect. 11.10)

  a0 = gamma^2/(gamma + 1D0) * beta
  
  _e0 = double(e0)
  _b0 = double(b0)
  
  e1 = gamma*(_e0 + crossp(beta,_b0)) - a0*total(beta*_e0,/double)
  b1 = gamma*(_b0 - crossp(beta,_e0)) - a0*total(beta*_b0,/double)
  
end