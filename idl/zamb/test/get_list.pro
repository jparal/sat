pro get_list

  n_values = 10
  
  base = widget_base(/column)

  frame_base = widget_base(base, /column, /frame)



  table = widget_table(frame_base, xsize = 1, ysize = n_values, /no_headers, $
                       value = reform(findgen(n_values),1,n_values), /editable)
                       
                       
  

  widget_control,base,/realize 
  xmanager,'get_list',base 

end