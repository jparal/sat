pro dir, filter

  if (N_Params() gt 1) then begin
    print, 'invalid number of parameters'
    print, 'IDL > dir, [filter]'
    return
  end 

  if (N_Elements(filter) eq 0) then filter = '*'

  cd, current = cdir

  print, 'Files in ',cdir

  filelist = findfile(filter, count = nfiles)

  if (nfiles gt 0) then begin
      for i=0,nfiles-1 do print, filelist[i]
      print, nfiles, ' file(s)'
  end else begin
      print, 'no files found'
  end

end