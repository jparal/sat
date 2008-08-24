pro del, filename
  if (N_Params() ne 1) then begin
    print, 'invalid number of parameters'
    print, 'IDL > del, filename'
    return
  end 
  
  if (N_Elements(filename) eq 0) then begin
    print, 'invalid argument, you must supply either a filename or a filter'
    print, 'IDL > del, filename'
    return
  end
  
  filelist = findfile(filename, count = nfiles)

  if (nfiles gt 0) then begin
    for i=0,nfiles-1 do begin
        script = [ 'tell application "Finder" ', $
                   'delete file "'+filename[i]+'"',$
                   'end tell' ]
        do_apple_script, script
    end
  end else begin
    print, 'file not found, ',filename
  end
  
end