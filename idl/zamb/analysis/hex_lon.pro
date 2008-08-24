function hex_lon, inlon
  b0 = byte('0')
  bA_10 = byte('A')-10b
  
  x = long(inlon)
  d = byte(x mod 16l)
  res = (d le 9)? string(d+b0) : string(d+bA_10)
  
  x = x/16l
  while (x ne 0) do begin
    d = byte(x mod 16l)
    res1 = (d le 9)? string(d+b0) : string(d+bA_10)
    res = res1+res
    x = x/16l
  end
  
  return, res
end