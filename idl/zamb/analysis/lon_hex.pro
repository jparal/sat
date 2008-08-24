function lon_hex, instr
  size = strlen(instr)-1
  lstr = strlowcase(instr)
  
  res = 0l
  for i=0, size do begin
    res2 = (byte(strmid(lstr,i,1)))[0] - 48l
    if (res2 gt 9) then res2 = res2 - 39l
    res = res + res2 * (16l^(size-i))  
  end
  
  return, res
end