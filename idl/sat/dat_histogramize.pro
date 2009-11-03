function dat_histogramize, data, width ;, squeeze

  ss = size(data)
  nd = ss(1)
  rv = findgen(nd)

  for lo=0, nd-1, width do begin
     hi = min([lo+width-1,nd-1])
     rv(lo:hi) = mean(data(lo:hi))
  endfor

  return, rv

end
