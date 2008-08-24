function strip_fname, fname 
  if N_Elements(fname) eq 1 then begin
    res = StrArr(2)
    pos = rstrpos(fname, ':')
    
    if (pos ne -1) then begin
      path = fname
      filename = strmid(path, pos+1, strlen(path) -1)
      path = strmid(path, 0, pos)
    end else begin
      filename = fname
      path = ''
    end
    res[0] = filename
    res[1] = path
    return, res    
  end else return, ['','']
end