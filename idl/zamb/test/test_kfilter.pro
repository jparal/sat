pro test_kfilter

  x = (findgen(1000)-500)/100*2*!pi
  
  y = sin(x)*exp(-abs(x)/10)
  
  plot, x, y

  py = ptr_new(y)
  
  kfilter, py, 0.5, xaxis = x  

  oplot, x, *py
  
  ptr_free, py  

end