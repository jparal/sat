pro swap, x1, x2
  if (N_Elements(x1) eq 0) or (N_Elements(x2) eq 0) then begin
    res = Error_Message('No data supplied')
    return
  end
  
  temp = temporary(x1)
  x1 = temporary(x2)
  x2 = temporary(temp)
end