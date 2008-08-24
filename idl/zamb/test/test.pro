pro test

  
  data = dist(100,100)
  
  x = findgen(100,100) mod 100
  
  data = exp(-data/10.0)*sin(x*2.0*!pi/10.0)
  
  ;data = shift(data, -50,-50)
  
  res = local_max(data, /verbose, /periodic)

end