; gamma_of_u

function gamma_of_u, u
  return, sqrt(1D0 + double(u)^2)
end