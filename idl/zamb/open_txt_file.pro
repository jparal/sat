; IDL> data = open_txt_file(ncol=3)
;
; IDL> plot1d, reform(data[0,*]), reform(data[2,*])

function open_txt_file, FILE = filename, PATH = filepath, NCOL = n_col

  ; Set Error handling procedures
  ierror = 0
  ;catch, ierror
  if (ierror ne 0) then begin
    catch, /cancel
    ok = Error_Message()
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

  print, 'Reading file, ',filename,' ...'
 
  ; NCOL
  ;
  ; number of columns on the file

  if (N_Elements(n_col) eq 0) then n_col = 2
  
  line_data =  DblArr(n_col)

  ; Open file

  linenum = 0
  OpenR, fileId, fileName, /Get_Lun
   
  ; Read first line and initialize variables
    
  linenum = linenum+1
  ReadF, fileId, line_data
  data = [[line_data]]  
  

  ; Read next lines and append data to variables

  while not eof(fileID) do begin    
    linenum = linenum+1
    ReadF, fileId, line_data 
    data = [[data],[line_data]]
  end
  
  ; Close file   
 
  Close, fileId
  Free_Lun, fileId  

  ; restore initial dir

  if (current ne '') then cd, current

  ; return data

  print, 'Done Reading text file, ',filename,'.'
  catch, /cancel

  return, data
  
read_fail:
  
  error_text = !ERROR_STATE.MSG
  
  if (linenum gt 0) then error_text=error_text+$
      ', line number '+strtrim(string(linenum),2) 
  
  error = Error_Message(error_text)
    ; Restore floating point exception handling
  !Except = temp_except 

  return, 0
  
end