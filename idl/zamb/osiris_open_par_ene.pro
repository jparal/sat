function osiris_open_par_ene, FILE = filename, PATH = path

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
    filename=Dialog_Pickfile(TITLE = 'Choose particle energy file')
  end

  ; Test if file exists

  test = findfile(filename, COUNT = count)
  if (count eq 0) then begin
    newres = Error_Message("File not found!")
    return, 0
  end

  print, 'Reading Particle Energy file, ',filename,' ...'
  
  linenum = 0
  OpenR, fileId, fileName, /Get_Lun
 
  linenum = linenum+1 
  header = ''
  ReadF, fileId, header  
  
  labels = str_sep(header, ' ', /trim)
  
  ; for i=0, n_elements(labels)-1 do print, labels[i]

  titer = 0L
  ttime = 0D
  tnpar = 0L
  tq1 = 0D
  tq2 = 0D
  tq3 = 0D
  tkin = 0D

  
  linenum = linenum+1
  ReadF, fileId, titer, ttime, tnpar, tq1, tq2, tq3, tkin
    
  iter = titer
  time = ttime
  npar = tnpar
  q1 = tq1
  q2 = tq2
  q3 = tq3
  kin = tkin
  
  while not eof(fileID) do begin    
    linenum = linenum+1
    ReadF, fileId, titer, ttime, tnpar, tq1, tq2, tq3, tkin
    
    iter = [iter,titer]
    time = [time,ttime]
    npar = [npar,tnpar]
    q1   = [q1,tq1]
    q2   = [q2,tq2]
    q3   = [q3,tq3]
    kin   = [kin,tkin]
  end

  ; Close file   
    
  Close, fileId
  Free_Lun, fileId  

  ; restore initial dir

  if (current ne '') then cd, current

  ; return data
  
  res = { iter:iter, $
          time:time, $
          npar:npar, $
          q1:q1, q2:q2, q3:q3, $
          kin:kin }

  print, (size(res.iter, /dimension))[0],' timesteps read'
  print, 'Done Reading Particle Energy file, ',filename,'.'


  ; Restore floating point exception handling
  !Except = temp_except 

  catch, /cancel
  
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