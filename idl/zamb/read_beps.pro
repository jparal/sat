;+
; NAME:
;    READ_BEPS
;
; PURPOSE:
;
;    The purpose of this routine is to open output from the new_beps3 code and generate a 
;    plot. It will first open a header file containing the data size information and then
;    the actual data file. If any plot was done previously by this routine with the same
;    header file, this routine will automatically close (if still active) that widget
;
; AUTHOR:
;
;   Ricardo Fonseca
;   E-mail: zamb@physics.ucla.edu
;
; CATEGORY:
;
;    Misc.
;
; CALLING SEQUENCE:
;
;    read_beps, [header_filename, [data_filename]]
;
; INPUTS:
;
;    header_filename: This is the filename of the header file containing the dimensions
;       of the data. If not specified the routine will prompt the user for one.
;
;    data_filename: This is the filename of the data file to read. If not specified the
;       routine will prompt the user for one.
;
; KEYWORDS:
;
;    PATH: Set this keyword to the path to use for opening the files. If not supplied file names
;       are assumed to be either relative to the current path or refering to an absolute path
;
;    DELETE_OLD: Set this keyword to delete the datafile used to generate the previous plot done
;       with this headerfile. Even if this keyword is not set the window with that plot will be
;       closed
;
;    TEST_DATA: Set this keyword to test the datafile for NaNs and Infinities. If any found
;       the routine will abort
;
;    SLICER3D: Set this keyword to call the SLICER3D routine instead of PLOT3D for the plot
;    
; OUTPUTS:
;
;    The routine generates a window with a plot of the data supplied through datafile. The system
;    variable !read_beps_plots is updated (or created if necessary) by adding the information
;    relative to the current plot and removing the data referencing any earlier plots with the
;    same header file
;
; RESTRICTIONS:
;
;    The system variable !read_beps_plots is used by this routine and no other routine can use it.
;    Also, this routine is limited to 128 different header files  
;
; EXAMPLE:
;
;    To generate a plot using relative paths
;
;    read_beps, "pot3head", "pot3_24", PATH = "uclapic10:Desktop Folder:new_pbeps3:"
;
;    To generate a plot without supplying relative path
;
;    read_beps, "uclapic10:Desktop Folder:new_pbeps3:pot3head", "uclapic10:Desktop Folder:new_pbeps3:pot3_24"
;    
;    To generate a plot, testing the data and deleting the previous datafile
;
;    read_beps, "pot3head", "pot3_24", /TEST_DATA, /DELETE_OLD     
;
; MODIFICATION HISTORY:
;
;    Written by: Ricardo Fonseca, 14 September 2000.
;-
;###########################################################################


pro read_beps, _EXTRA = extrakeys, $
               fheadername,$			; Header file
               fdataname,$				; data file
               PATH = path,$			; path to use
               DELETE_OLD = delete_old,$	; delete old data file
               TEST_DATA = test_data,$	; test data for nan and inf
               SLICER3D				; use slicer3D
               
  ; Set Error handling procedures
  catch, ierror
  if (ierror ne 0) then begin
    catch, /cancel
    ok = Error_Message()
    return
  end

  on_ioerror, read_fail


if (N_Elements(path) ne 0) then begin
  if (path ne '') then cd, path
end else path = ''

; get header file filename

if (N_Elements(fheadername) eq 0) then begin
  fheadername = Dialog_Pickfile(GET_PATH = path, TITLE = 'Choose header file')
  if (fheadername eq '') then return
  cd, path
end

; prepare variables for reading the header file

nx = 0L
ny = 0L
nz = 0L
ndata = 0L
dataname = ''
dataname = strtrim(dataname, 2)

; read the header file
errmsg = fheadername+' , invalid header file.'
print, 'Header Filename : ',fheadername
OpenR, work_file_id, fheadername, /GET_LUN
ReadF, work_file_id, nx,ny,nz,ndata, dataname
close, work_file_id
Free_Lun, work_file_id

; get data file filename 

if (N_Elements(fdataname) eq 0) then begin
  fdataname = Dialog_Pickfile(GET_PATH = path, TITLE = 'Choose data file')
  if (fdataname eq '') then return
  cd, path
end

; prepare variable for reading the data file

;data = FltArr(nx,ny,nz,ndata)
data = FltArr(nx,ny,nz*ndata)

; read the data file

errmsg = fdataname+' , invalid data file.'
print, 'Data Filename : ', fdataname
OpenR, work_file_id, fdataname, /GET_LUN
ReadU, work_file_id, Data
close, work_file_id
Free_Lun, work_file_id

if (keyword_set(test_data)) then $
  if total(finite(data)) ne n_elements(data) then begin
  ok = Error_Message(['Invalid data values.',errmsg])
  return
end 

; If any plots available, check if any was done with this header file
; and if so close the window and remove that information from !read_beps_plots

t_plot_info = {t_plot_info, header_name:'',data_name:'',widget_ID:0L}
defsysv, '!read_beps_plots', EXISTS = var_exists

if (var_exists eq 1) then begin
  
  nmax = !read_beps_plots.n
  i = 0
  while i lt nmax do begin
    if (!read_beps_plots.plot_info[i].header_name eq fheadername) then begin

      print, 'Found widget, id = ',!read_beps_plots.plot_info[i].widget_id 
      
      ; Close the widget if it still exists
      valid_widget = widget_info(!read_beps_plots.plot_info[i].widget_id, /valid_id)
      if (valid_widget eq 1) then widget_control, !read_beps_plots.plot_info[i].widget_id, /destroy

      ; Delete the data file if it still exists
                  
      if (keyword_set(delete_old)) then begin
        print, 'Deleting the file ',!read_beps_plots.plot_info[i].data_name,', and emptying the trash...' 
        del,!read_beps_plots.plot_info[i].data_name
        empty_trash
        print, 'Done'
      end 
      
      ; remove data from !read_beps_plots
      
      if ((nmax eq 1) or (i eq nmax-1)) then begin
        !read_beps_plots.plot_info[0] = t_plot_info
      end else begin
        !read_beps_plots.plot_info[i] = !read_beps_plots.plot_info[nmax-1]
        !read_beps_plots.plot_info[nmax-1] = t_plot_info
      end
   
      !read_beps_plots.n = !read_beps_plots.n-1
      i = nmax    
    end 
    i = i+1   
  end
end

; plot the data

; ------------------------ Plotting routine ------------------------

pdata = ptr_new(data, /no_copy)

if (not Keyword_Set(slicer3D)) then begin
;  plot3d, pdata, windowtitle = fdataname, WIDGET_ID = wID, /povertrans
  plot3d, _EXTRA = extrakeys, pdata, windowtitle = fdataname, WIDGET_ID = wID, /noproj
  ptr_free, pdata
end else begin
  slicer3d, pdata, windowtitle = fdataname, WIDGET_ID = wID
end

; ---------------------- end plotting routine ----------------------


; add the plot information to the system variable !read_beps_plots so the plot
; can be closed later (and the data file deleted)

plot_info = t_plot_info
plot_info.header_name = fheadername
plot_info.widget_ID = wID
;plot_info.data_name = fdataname
plot_info.data_name = path+fdataname

if (var_exists eq 1) then begin
  !read_beps_plots.plot_info[!read_beps_plots.n] = plot_info
  !read_beps_plots.n = !read_beps_plots.n+1
end else begin
  beps_plots = { n:1L, plot_info:replicate(plot_info,128)}
  defsysv, '!read_beps_plots', beps_plots       
end

return


read_fail:
  
  error_text = [!ERROR_STATE.MSG , errmsg]  
  error = Error_Message(error_text)
end
