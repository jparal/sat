; Returns the transformed time interval
;
; c = 1.0
;
; t0 - time interval in the rest frame for two events in the same
;      position (in the rest frame) x

function lorentz_time, t0, v
  ; since c = 1.0 => § = v
  
  beta = double(v)
  b2 = total(beta*beta, /double)
  
  if (b2 ge 1D0) then begin
    res = Error_Message('||Frame velocity|| must be < c')
    return, dblarr(3) 
  end
  
  gamma = 1D0/sqrt(1D0 - b2)
  return, double(t0)*gamma
end