;  Osiris_Gen_Proj
; ----------------------------------------------------
;
;  Opens all the files of 3D-Data in a directory and generate the projections
;  on the three planes

pro osiris_gen_proj, DIRNAME = DirName, DX = UseDX

  if N_Elements(DirName) eq 0 then begin  
    DirName = Dialog_PickFile(/Directory)
    if (DirName eq '') then return
  end
  
  cd, dirname

  if KeyWord_Set(UseDX) then begin
    filter = '*.dx'
  end else begin
    filter = '*.hdf'
  end

  Files = FindFile(filter, Count = NFiles)
  
  if (NFiles le 0) then begin
     print, 'Osiris_Gen_Proj, no files found '
     return
  end

  for i=0, NFiles -1 do begin
 ;  for i=NFiles -1, NFiles -1 do begin
    print, 'Opening file ', Files[i]

    
    Osiris_Open_Data, pData,  FILE = Files[i], FORCEDIMS = 3, N = n,/IGNORE_DIFF, $
                             PATH = dirname, $
                             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                             TIMEPHYS = time, TIMESTEP = timestep,  $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                             YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                             ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit

    if (pData ne Ptr_New() ) then begin
       
       ; For the moment ignore units
       Units = ''

       ; X1X2 Projection
       
       pProjX1X2 = Ptr_New(FltArr(n[0], n[1]))
       (*pProjX1X2) = Total( (*pData), 3, /double) 

       filesave = 'ProjX1X2_'+files[i] 
 
       s = strlen(filesave)
       ext = strmid(filesave,s-2,2)
       if ((ext eq 'dx') or (ext eq 'DX')) then begin
         filesave = strmid(filesave,0,s-2) + 'hdf'
       end
       print, 'Saving file ',filesave

       Osiris_Save_Data, pProjX1X2,  FILE = filesave, $
                             PATH = dirname, $
                             XAXIS = XAxisData, YAXIS = YAxisData, $
                             TIMEPHYS = time, TIMESTEP = timestep, $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                             YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit

       ptr_free, pProjX1X2

       ; X1X3 Projection
       
       pProjX1X3 = Ptr_New(FltArr(n[0], n[2]))
       (*pProjX1X3) = Total( (*pData), 2, /double) 

       filesave = 'ProjX1X3_'+files[i] 
 
       s = strlen(filesave)
       ext = strmid(filesave,s-2,2)
       if ((ext eq 'dx') or (ext eq 'DX')) then begin
         filesave = strmid(filesave,0,s-2) + 'hdf'
       end
       print, 'Saving file ',filesave

       Osiris_Save_Data, pProjX1X3,  FILE = filesave, $
                             PATH = dirname, $
                             XAXIS = XAxisData, YAXIS = ZAxisData, $
                             TIMEPHYS = time, TIMESTEP = timestep, $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                             YNAME = x3name, YFORMAT = x3format, YLABEL = x3label, YUNITS = x3unit

       ptr_free, pProjX1X3

       ; X2X3 Projection
       
       pProjX2X3 = Ptr_New(FltArr(n[1], n[2]))
       (*pProjX2X3) = Total( (*pData), 1, /double) 

       filesave = 'ProjX2X3_'+files[i] 
 
       s = strlen(filesave)
       ext = strmid(filesave,s-2,2)
       if ((ext eq 'dx') or (ext eq 'DX')) then begin
         filesave = strmid(filesave,0,s-2) + 'hdf'
       end
       print, 'Saving file ',filesave

       Osiris_Save_Data, pProjX2X3,  FILE = filesave, $
                             PATH = dirname, $
                             XAXIS = YAxisData, YAXIS = ZAxisData, $
                             TIMEPHYS = time, TIMESTEP = timestep, $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x2name, XFORMAT = x2format, XLABEL = x2label, XUNITS = x2unit, $
                             YNAME = x3name, YFORMAT = x3format, YLABEL = x3label, YUNITS = x3unit

       ptr_free, pProjX2X3

   
    end 
        
  
  end
  
  print, 'Osiris_Gen_Proj, Done!'

end