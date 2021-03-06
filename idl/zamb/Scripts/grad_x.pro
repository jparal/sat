pro grad_x, DIRNAME = DirName, _EXTRA = extrakeys, DX = UseDX, FILTER = filter

  ; DIRNAME
  ;
  ; Directory name to analyse. If not specified the routine prompts the user for one

  if N_Elements(DirName) eq 0 then begin  
    DirName = Dialog_PickFile(/Directory)
    if (DirName eq '') then return
  end
  
  cd, dirname

  ; FILTER
  ;
  ; File filter to use, without extension. If not specified all files will be analysed

  If (N_Elements(filter) eq 0) then filter = '*'

  ; DX
  ;
  ; Set this keyword to use the old osiris data explorer files (extension'.dx'). The 
  ; default is to use HDF files (extension '.hdf')

  if KeyWord_Set(UseDX) then begin
    filter = filter+'.dx'
  end else begin
    filter = filter+'.hdf'
  end

  Files = FindFile(filter, Count = NFiles)
  
  if (NFiles le 0) then res = Error_Message('no files found, "'+dirname+filter+'"')

  for i=0, NFiles -1 do begin
    print, 'Opening file ', Files[i]

   Osiris_Open_Data, pData,  PATH = dirname, FILE = files[i], /IGNORE_DIFF, $
                          XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                          TIMEPHYS = time, TIMESTEP = timestep, $
                          DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                          XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                          YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                          ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit, $
                          ; Additional information needed for the resample operation
                          N = n
   
   ; Process the data 
   
   print, 'Processing data...'
  
   ; Get the gradient along x
      
   deltax = XAxisData[1] - XAxisData[0]
   *pData = (Shift(*pData,1,0,0) - Shift(*pData,-1,0,0)) / (2.0 * delta_x)
   Units = 'grad('+Units+')'
   
   ; Create filename

   filesave = 'gradx_'+files[i] 

   s = strlen(filesave)
   ext = strmid(filesave,s-2,2)
   if ((ext eq 'dx') or (ext eq 'DX')) then begin
      filesave = strmid(filesave,0,s-2) + 'hdf'
   end

   print, 'Saving file ',filesave

   Osiris_Save_Data, pData,  FILE = filesave, $
                          PATH = dirname, $
                          XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                          TIMEPHYS = time, TIMESTEP = timestep, $
                          DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                          XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                          YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                          ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit

   ptr_free, pData
end

end