function v_of_u, u
  return, double(u)/sqrt(1D0+double(u)^2)
end