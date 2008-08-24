pro test_input_values
  arr = StrArr(2)
  for i=0,0 do arr[i] = 'Series '+strtrim(i+1,1)

  arr  = [1b]

  data = { $
           Autoscale : 0b, $
           Logarithmic : 1b, $
           Minimum : 0.0, $
           Maximum : 1.0, $
           arr:arr $
           }           
           
  labels = [ $
           'Autoscale', $
           'Use Log Scale', $
           'Minimum', $
           'Maximum', $
           'array' $
           ]  

  res = InputValues( data, $
                     labels = labels, $
                     Title = 'Input Values' )
  
  help, data.arr[0]
end