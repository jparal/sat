; u = findgen(1000)/100 & plot1d, u, weibel_growth(1.0, gamma_of_u(u)), ytitle = '!MG!Dweibel',xtitle = 'u'

function weibel_growth, wpe0, gamma0, $
         k = k, two_spec = two_spec
         
  if (Keyword_Set(two_spec)) then a0 = 2D0 $
  else a0 = 4D0
             
  beta0 = v_of_gamma(gamma0)
  growth = sqrt(a0) * double(wpe0) * double(beta0) / sqrt(double(gamma0))
 
  if (N_Elements(k) ne 0) then begin
    k2 = total(k*k, /double)
    growth = growth/(1D0 + a0*wpe0^2/double(gamma0)/k2)
  end
 
  return, growth
end