function osiris_open_fld_ene, FILE = filename, PATH = filepath

  ; Set floating point exception handling
  temp_except = !Except
  !Except = 2

  ; Set Error handling procedures
  catch, ierror
  if (ierror ne 0) then begin
    catch, /cancel
    ok = Error_Message()
    ; Restore floating point exception handling
    !Except = temp_except 
    return, 0
  end

  on_ioerror, read_fail

  ; PATH
  ;
  ; Path to the file to be opened
  
  current = ''
  
  if N_Elements(filepath) ne 0 then cd, filepath, current = current 

  ; FILE
  ;
  ; Name of the file to be opened
   
  if (N_Elements(filename) eq 0) then begin
    filename=Dialog_Pickfile(TITLE = 'Choose field energy file')
  end

  ; Test if file exists

  test = findfile(filename, COUNT = count)
  if (count eq 0) then begin
    newres = Error_Message('File not found!')
    return, 0
  end

  print, 'Reading Field Energy file, ',filename,' ...'

  ; Open file

  linenum = 0
  OpenR, fileId, fileName, /Get_Lun
   
  ; Read Header

  linenum = linenum+1
  header = ''
  ReadF, fileId, header  
  
  labels = str_sep(header, ' ', /trim)
  
  ; for i=0, n_elements(labels)-1 do print, labels[i]

  ; Read first line and initialize variables
    

  titer = 0L
  ttime = 0D
  tb1 = 0D
  tb2 = 0D
  tb3 = 0D
  te1 = 0D
  te2 = 0D
  te3 = 0D

  linenum = linenum+1
  ReadF, fileId, titer, ttime, tb1, tb2, tb3, te1, te2, te3
    
  iter = titer
  time = ttime
  b1 = tb1
  b2 = tb2
  b3 = tb3
  e1 = te1
  e2 = te2
  e3 = te3
  

  ; Read next lines and append data to variables

  while not eof(fileID) do begin    
    linenum = linenum+1
    ReadF, fileId, titer, ttime, tb1, tb2, tb3, te1, te2, te3 
    iter = [iter,titer]
    time = [time,ttime]
    b1   = [b1,tb1]
    b2   = [b2,tb2]
    b3   = [b3,tb3]
    e1   = [e1,te1]
    e2   = [e2,te2]
    e3   = [e3,te3]
  end
  
  ; Close file   
 
  Close, fileId
  Free_Lun, fileId  

  ; restore initial dir

  if (current ne '') then cd, current

  ; return data

  res = { iter:iter, $
          time:time, $
          b1:b1, b2:b2, b3:b3, $
          e1:e1, e2:e2, e3:e3 }

  print, 'Done Reading Field Energy file, ',filename,'.'
  catch, /cancel
  ; Restore floating point exception handling
  !Except = temp_except 

  return, res
  
read_fail:
  
  error_text = !ERROR_STATE.MSG
  
  if (linenum gt 0) then error_text=error_text+$
      ', line number '+strtrim(string(linenum),2) 
  
  error = Error_Message(error_text)
    ; Restore floating point exception handling
  !Except = temp_except 

  return, 0
  
end