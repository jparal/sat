pro test_plot_1D

  ; test data
  x = (findgen(500)/100)*2.0*!PI
  y1 = cos(x)*exp(-x/4.0/!Pi)
  y2 = sin(x)*exp(-x/4.0/!Pi)
  y3 = exp(-x/4.0/!Pi)

;  plot1D, x, y1

  n_series = 3

  pData = ptrarr(2, n_series)

  pData[0,0] = ptr_new(x)
  pData[1,0] = ptr_new(y1)
  pData[0,1] = ptr_new(x)
  pData[1,1] = ptr_new(y2)
  pData[0,2] = ptr_new(x)
  pData[1,2] = ptr_new(y3)
  
  names = [ 'cos(x)', 'sin(x)', 'exp(-x)' ]

  linestyle = [3,4,6]
  symbol = [0,0,3]

  plot1D, pData, /no_share, name = names, $
          windowtitle = 'Testing Plot 1D',$
          Title = 'Plot 1D', SubTitle = 'Testing', $
          xtitle = 'x [a.u.]', ytitle = 'y [a.u.]', $
          linestyle = linestyle, symbol = symbol

end