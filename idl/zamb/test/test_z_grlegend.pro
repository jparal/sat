pro test_z_grlegend

  oView = obj_new('IDLgrView', VIEW = [0.0,0.0,1.0,1.0], $
              COLOR = [0,0,0])
  oWindow = obj_new('IDLgrWindow') 
  oModel = obj_new('IDLgrModel')
  oView -> Add, oModel

  labels = strarr(7)
  for i=0,6 do labels[i] = 'Series '+strtrim(i,1)

  linecolor = [ [255,255,255], $
                [255,255,0], $
                [255,0,255], $
                [0,255,255], $
                [255,0,0], $
                [0,255,0], $
                [0,0,255] ]
  
  linestyle = indgen(7)
  linestyle[6] = 0
  symbol = indgen(7)+1
  symbolcolor = reverse(linecolor, 2)

  oLegend = obj_new('z_grLegend', labels )
  
  oLegend -> SetProperty, /show_outline
  oLegend -> SetProperty, linestyle = linestyle, symbolstyle = symbol
  oLegend -> SetProperty, linecolor = linecolor, symbolcolor = symbolcolor
  oLegend -> SetProperty, location = [0.5,0.5], alignment = 0.5, vertical_alignment = 0.5

  oLegend -> SetProperty, LABELS = labels[0:3]

  print, ' Adding Legend to model'
  oModel -> Add, oLegend 

  print, ' Drawing view'
  oWindow -> Draw, oView
  
  
end