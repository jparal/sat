Function AbsMin, Data, MAX = localabsmax, MINN0 = localabsmin_non0
   Data1 = Abs(Data)     
   LocalAbsMin = Min(Data1, MAX = LocalAbsMax)
   if ((LocalAbsMin eq 0.0) and (LocalAbsMax gt 0.0)) then begin    
       idx = Where(Data1 gt 0.0, count)
       if (count gt 0) then LocalAbsMin_Non0 = Min(Data1[idx])   $        
       else LocalAbsMin_Non0 = LocalAbsMin                 
   end else LocalAbsMin_Non0 = LocalAbsMin          
   Data1 = 0
   
   return, LocalAbsMin

end

Pro GetOsirisMovieData3D, DIRECTORY = DirName, INFOFILE = infofilename, GENERATE = generatedata, $
                        ; use old dx files
                        DX = UseDx, $
                        ; time and time-step information
                        TIMES = Datatimes, ITERS = DataIters, $
                        ; datanames, filenames and dimensions
                        DATANAME = datanames, FILENAME = DataFIleNames, DIMN = N, $
                        ; number of frames and axis information
                        NFRAMES = NFrames, ORIGIN = origin, DELTA = delta,$
                        XAXIS = XAxis, YAXIS = YAxis, ZAXIS = ZAxis,$
                        ; global data ranges
                        DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax, DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0, $
                        ; global data projection ranges
                        DATAPMAX = DATApMax, DATAPMIN = DATApMin, DATAPABSMAX = DATApAbsMax, DATAPABSMIN = DATApAbsMin, NON0DATAPABSMIN = DATApAbsMin_Non0, $
                        ; global data^2 projection ranges
                        DATAP2MAX = DATAp2Max, DATAP2MIN = DATAp2Min, NON0DATAP2MIN = DATAp2Min_Non0, $
                        ; global abs(data) projection ranges
                        DATAPABSDATAMAX = DATApABSDATAMax, DATAPABSDATAMIN = DATApABSDATAMin, NON0DATAPABSDATAMIN = DATApABSDATAMin_Non0, $
                        ; local data ranges
                        MAX = Max, MIN = Min, ABSMAX = AbsMax, ABSMIN = AbsMin, NON0ABSMIN = AbsMin_Non0, $
                        ; local data projection ranges
                        PMAX = pMax, PMIN = pMin, PABSMAX = pAbsMax, PABSMIN = pAbsMin, NON0PABSMIN = pAbsMin_Non0, $
                        ; local data^2 projection ranges
                        P2MAX = p2Max, P2MIN = p2Min, NON0P2MIN = p2Min_Non0, $
                        ; local abs(data) projection ranges
                        PABSDATAMAX = pABSDATAMax, PABSDATAMIN = pABSDATAMin, NON0PABSDATAMIN = pABSDATAMin_Non0, $
                        ; time limits
                        TIMEMIN = timemin, TIMEMAX = timemax, $
                        ; results display
                        SILENT = silent
                        
  ; Get Directory name

  if N_Elements(DirName) eq 0 then begin  
    DirName = Dialog_PickFile(/Directory)
    if (DirName eq '') then return
  end

  CD, DirName

  if N_Elements(infofilename) eq 0 then infofilename = "OsirisMovieData.dat"
  
  if N_Elements(generatedata) eq 0 then begin
    test = FindFile(infofilename, Count = file_exists)
    if (file_exists gt 0) then generatedata = 0 $
    else generatedata = 1  
  end

  

  ; Generate Data

  if (generatedata gt 0) then begin
    filter = '*.hdf'
    if Keyword_set(UseDx) then filter = '*.dx'

    dxFiles = FindFile(filter, Count = NFrames)
    
    DataNames = StrArr(NFrames)
    DataFileNames = StrArr(NFrames)
    DataTimes = DblArr(NFrames)
    DataIters = LonArr(NFrames)
    
    N = LonArr(NFrames,3)
    
    Origin = DblArr(NFrames,3)
    Delta = DblArr(NFrames,3,3)  
 
    Max = DblArr(NFrames)
    Min = DblArr(NFrames)
    AbsMax = DblArr(NFrames)
    AbsMin = DblArr(NFrames)
    AbsMin_Non0 = DblArr(NFrames)

    ; Local Projection Data

    pMax = DblArr(NFrames,3)
    pMin = DblArr(NFrames,3)
    pAbsMax = DblArr(NFrames,3)
    pAbsMin = DblArr(NFrames,3)
    pAbsMin_Non0 = DblArr(NFrames,3)
    p2Max = DblArr(NFrames,3)
    p2Min = DblArr(NFrames,3)
    p2Min_Non0 = DblArr(NFrames,3)
    pAbsDataMax = DblArr(NFrames,3)
    pAbsDataMin = DblArr(NFrames,3)
    pAbsDataMin_Non0 = DblArr(NFrames,3)

    ; Global Projection Data

    DatapMax = DblArr(3)
    DatapMin = DblArr(3)
    DatapAbsMax = DblArr(3)
    DatapAbsMin = DblArr(3)
    DatapAbsMin_Non0 = DblArr(3)
    Datap2Max = DblArr(3)
    Datap2Min = DblArr(3)
    Datap2Min_Non0 = DblArr(3)
    DatapAbsDataMax = DblArr(3)
    DatapAbsDataMin = DblArr(3)
    DatapAbsDataMin_Non0 = DblArr(3)

    print, " Analising Data files..."
       
    for i=0, NFrames -1 do begin
       print, " File : ", dxFiles[i]

       Osiris_Open_Data, pData0,  FILE = dxFiles[i] , PATH = DirName, DATATITLE = DataName, N = dxN, ORIGIN = dxOrigin, $
                 DELTA = dxDelta,  TIMEPHYS = time, TIMESTEP = step, /IGNORE_DIFF
     
       DataNames[i] = DataName
       DataTimes[i] = time
       DataIters[i] = step
       DataFileNames[i] = dxFiles[i]          
       
       N[i,*] = dxN[*]
       
       Origin[i,*] = dxOrigin
       Delta[i,*,*] = dxDelta       
     
       ; Volume data
     
       LocalMin = Min(*pData0, MAX = LocalMax)
       
       if (LocalMin gt 0.0) then begin
         LocalAbsMin = LocalMin
         LocalAbsMax = LocalMax
         LocalAbsMin_Non0 = LocalMin 
       end else begin
         LocalAbsMin= AbsMin(*pData0, MAX = LocalAbsMax, MINN0 = LocalAbsMin_Non0)
       end
       
       Min[i] = LocalMin
       Max[i] = LocalMax
       AbsMin[i] = LocalAbsMin
       AbsMax[i] = LocalAbsMax
       AbsMin_Non0[i] = LocalAbsMin_Non0       
       
       ; Data Projections (average value)
       
       for p=0,2 do begin
         proj = Total(*pData0,p+1) / N[i,p] 
         LocalMin = Min(proj, MAX = LocalMax)
       
         if (LocalMin gt 0.0) then begin
           LocalAbsMin = LocalMin
           LocalAbsMax = LocalMax
           LocalAbsMin_Non0 = LocalMin 
         end else begin
           LocalAbsMin= AbsMin(proj, MAX = LocalAbsMax, MINN0 = LocalAbsMin_Non0)
         end
       
         pMin[i,p] = LocalMin
         pMax[i,p] = LocalMax
         pAbsMin[i,p] = LocalAbsMin
         pAbsMax[i,p] = LocalAbsMax
         pAbsMin_Non0[i,p] = LocalAbsMin_Non0             
         
       endfor
       
       ; Data^2 Projection

       for p=0,2 do begin
         proj = Total(*pData0^2,p+1) / N[i,p] 
         LocalMin = Min(proj, MAX = LocalMax)
       
         if (LocalMin gt 0.0) then begin
           LocalAbsMin = LocalMin
           LocalAbsMax = LocalMax
           LocalAbsMin_Non0 = LocalMin 
         end else begin
           LocalAbsMin= AbsMin(proj, MAX = LocalAbsMax, MINN0 = LocalAbsMin_Non0)
         end
       
         p2Min[i,p] = LocalMin
         p2Max[i,p] = LocalMax
         p2Min_Non0[i,p] = LocalAbsMin_Non0             
         
       endfor
       
       ; Abs(Data) Projection

       for p=0,2 do begin
         proj = Total(Abs(*pData0),p+1) / N[i,p] 
         LocalMin = Min(proj, MAX = LocalMax)
       
         if (LocalMin gt 0.0) then begin
           LocalAbsMin = LocalMin
           LocalAbsMax = LocalMax
           LocalAbsMin_Non0 = LocalMin 
         end else begin
           LocalAbsMin= AbsMin(proj, MAX = LocalAbsMax, MINN0 = LocalAbsMin_Non0)
         end
       
         pAbsDataMin[i,p] = LocalMin
         pAbsDataMax[i,p] = LocalMax
         pAbsDataMin_Non0[i,p] = LocalAbsMin_Non0             
         
       endfor
       
       ptr_free, pData0
    end
    
    ; Global Data

    TimeMin = Min(DataTimes, MAX = TimeMax)
         
    DataMax = Max(Max)
    DataMin = Min(Min)    
       
    DataAbsMax = Max(AbsMax)
    DataAbsMin = Min(AbsMin)

    DataAbsMin_Non0 = Min(AbsMin_Non0)
    
    for p=0,2 do begin
      DatapMin[p] = Min(pMin[*,p])
      DatapMax[p] = Max(pMax[*,p])
      DatapAbsMin[p] = Min(pAbsMin[*,p])
      DatapAbsMax[p] = Max(pAbsMax[*,p])
      DatapAbsMin_Non0[p] = Min(pAbsMin_Non0[*,p])

      Datap2Min[p] = Min(p2Min[*,p])
      Datap2Max[p] = Max(p2Max[*,p])
      Datap2Min_Non0[p] = Min(p2Min_Non0[*,p])             

      DatapAbsDataMin[p] = Min(pAbsDataMin[*,p])
      DatapAbsDataMax[p] = Max(pAbsDataMax[*,p])
      DatapAbsDataMin_Non0[p] = Min(pAbsDataMin_Non0[*,p])             

    end

    ; Saves infofile
    
    OpenW, info_id, infofilename, /Get_Lun
    
    Printf, info_id, DirName
    Printf, info_id, NFrames

    printf, info_id, DataMax, DataMin
    printf, info_id, DataAbsMax, DataAbsMin, DataAbsMin_Non0

    ; Global Projection Data
   
    for p=0,2 do begin
       printf, info_id, DatapMax[p], DatapMin[p]    
       printf, info_id, DatapAbsMax[p], DatapAbsMin[p], DatapAbsMin_Non0[p]    
       printf, info_id, Datap2Max[p], Datap2Min[p], Datap2Min_Non0[p]
       printf, info_id, DatapAbsDataMax[p], DatapAbsDataMin[p], DatapAbsDataMin_Non0[p]
    endfor 
   
    ; Local Projection Data
    
    for i=0, NFrames-1 do begin
      printf, info_id, i
      printf, info_id, Datatimes[i]
      printf, info_id, DataIters[i]
      printf, info_id, DataNames[i]
      printf, info_id, DataFileNames[i] 
      printf, info_id, N[i,*]
      printf, info_id, Origin[i,*] 
      printf, info_id, Delta[i,0,0], Delta[i,0,1], Delta[i,0,2]        
      printf, info_id, Delta[i,1,0], Delta[i,1,1], Delta[i,1,2]        
      printf, info_id, Delta[i,2,0], Delta[i,2,1], Delta[i,2,2]        

      printf, info_id, Max[i], Min[i]
      printf, info_id, AbsMax[i], AbsMin[i], AbsMin_Non0[i]

      for p=0,2 do begin
         ; Data Projection
         printf, info_id, pMax[i,p], pMin[i,p]    
         printf, info_id, pAbsMax[i,p], pAbsMin[i,p], pAbsMin_Non0[i,p]    
         ; Data^2 Projection
         printf, info_id, p2Max[i,p], p2Min[i,p], p2Min_Non0[i,p]
         ; Abs(Data) Projection
         printf, info_id, pAbsDataMax[i,p], pAbsDataMin[i,p], pAbsDataMin_Non0[i,p]
      endfor 
    endfor   

    Close, info_id
    Free_Lun, info_id
    
    print, " Done."   
  endif else begin


    print, " Loading Information..."

    ; Loads infofile
    
    test = FindFile(infofilename, Count = file_exists)
    if (file_exists eq 0) then begin
        res = Dialog_Message("File not found, "+infofilename , /Error)
        return
    end
    
    OpenR, info_id, infofilename, /Get_Lun
    
    Readf, info_id, DirName
    NFrames  = 0
    Readf, info_id, NFrames

    DataNames = StrArr(NFrames)
    DataFileNames = StrArr(NFrames)
    DataTimes = DblArr(NFrames)
    DataIters = LonArr(NFrames)
        
    N = LonArr(NFrames,3)
    
    Origin = DblArr(NFrames,3)
    Delta = DblArr(NFrames,3,3)  
 
    Max = DblArr(NFrames)
    Min = DblArr(NFrames)
    AbsMax = DblArr(NFrames)
    AbsMin = DblArr(NFrames)
    AbsMin_Non0 = DblArr(NFrames)
   
    ; Local Projection Data

    pMax = DblArr(NFrames,3)
    pMin = DblArr(NFrames,3)
    pAbsMax = DblArr(NFrames,3)
    pAbsMin = DblArr(NFrames,3)
    pAbsMin_Non0 = DblArr(NFrames,3)
    p2Max = DblArr(NFrames,3)
    p2Min = DblArr(NFrames,3)
    p2Min_Non0 = DblArr(NFrames,3)
    pAbsDataMax = DblArr(NFrames,3)
    pAbsDataMin = DblArr(NFrames,3)
    pAbsDataMin_Non0 = DblArr(NFrames,3)

    ;Global Projection Data

    DatapMax = DblArr(3)
    DatapMin = DblArr(3)
    DatapAbsMax = DblArr(3)
    DatapAbsMin = DblArr(3)
    DatapAbsMin_Non0 = DblArr(3)
    Datap2Max = DblArr(3)
    Datap2Min = DblArr(3)
    Datap2Min_Non0 = DblArr(3)
    DatapAbsDataMax = DblArr(3)
    DatapAbsDataMin = DblArr(3)
    DatapAbsDataMin_Non0 = DblArr(3)

    Readf, info_id, DataMax, DataMin
    Readf, info_id, DataAbsMax, DataAbsMin, DataAbsMin_Non0

    tempdbl1 = 0.0D0
    tempdbl2 = 0.0D0
    tempdbl3 = 0.0D0

    for p=0,2 do begin
       Readf, info_id, tempdbl1, tempdbl2
       DatapMax[p] = tempdbl1
       DatapMin[p] = tempdbl2     
       Readf, info_id, tempdbl1, tempdbl2, tempdbl3 
       DatapAbsMax[p]=tempdbl1
       DatapAbsMin[p]=tempdbl2
       DatapAbsMin_Non0[p]=tempdbl3    
       Readf, info_id, tempdbl1, tempdbl2, tempdbl3 
       Datap2Max[p]=tempdbl1
       Datap2Min[p]=tempdbl2
       Datap2Min_Non0[p]=tempdbl3
       Readf, info_id, tempdbl1, tempdbl2, tempdbl3 
       DatapAbsDataMax[p]=tempdbl1
       DatapAbsDataMin[p]=tempdbl2
       DatapAbsDataMin_Non0[p]=tempdbl3
    endfor 
    
    
    temp = " "
    tempi1 =0
    tempi2=0
    tempi3=0
    tempdbl4=0
    tempdbl5=0
    tempdbl6=0
    tempdbl7=0
    tempdbl8=0
    tempdbl9=0
    
    for i=0, NFrames-1 do begin
      Readf, info_id, temp
      Readf, info_id, tempdbl1
      Datatimes[i]=tempdbl1
      Readf, info_id, tempi1
      DataIters[i] = tempi1
      Readf, info_id, temp
      DataNames[i]=temp
      Readf, info_id, temp
      DataFileNames[i]=temp  
      Readf, info_id, tempi1,tempi2,tempi3
      N[i,*]=[tempi1,tempi2,tempi3]
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3
      Origin[i,*]=[tempdbl1,tempdbl2,tempdbl3] 
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3  
      Delta[i,0,*] = [tempdbl1,tempdbl2,tempdbl3] 
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3  
      Delta[i,1,*] = [tempdbl1,tempdbl2,tempdbl3] 
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3  
      Delta[i,2,*] = [tempdbl1,tempdbl2,tempdbl3] 
           
      Readf, info_id, tempdbl1, tempdbl2 
      Max[i] = tempdbl1
      Min[i] = tempdbl2
           
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3     
      AbsMax[i]=tempdbl1
      AbsMin[i]=tempdbl2
      AbsMin_Non0[i]=tempdbl3


      for p=0,2 do begin
         Readf, info_id, tempdbl1, tempdbl2
         pMax[i,p]= tempdbl1
         pMin[i,p]= tempdbl2    
         Readf, info_id, tempdbl1, tempdbl2, tempdbl3
         pAbsMax[i,p]=tempdbl1
         pAbsMin[i,p]=tempdbl2
         pAbsMin_Non0[i,p]=tempdbl3
         Readf, info_id, tempdbl1, tempdbl2, tempdbl3   
         p2Max[i,p]=tempdbl1
         p2Min[i,p]=tempdbl2
         p2Min_Non0[i,p] = tempdbl3    
         Readf, info_id, tempdbl1, tempdbl2, tempdbl3   
         pAbsDataMax[i,p]=tempdbl1
         pAbsDataMin[i,p]=tempdbl2
         pAbsDataMin_Non0[i,p] = tempdbl3    
      endfor 
    endfor   

    Close, info_id
    Free_Lun, info_id 
    print, " Done."  
  endelse   
  
  ; Calculate Axis

  print, 'Generating axis...'  
  XAxis = Findgen(N[0,0])*Delta[0,0,0] + Origin[0,0]
  YAxis = Findgen(N[0,1])*Delta[0,1,1] + Origin[0,1]
  ZAxis = Findgen(N[0,2])*Delta[0,2,2] + Origin[0,2]
  

  ; Display Results

  if N_Elements(silent) eq 0 then silent = 0 
    
  if (silent eq 0) then begin
    
    print, " "
    print, "******************** Osiris Movie Data Info *******************"
    print, " "
    print, "Directory : ", DirName
    print, "Number of frames : ", NFrames
    print, " "      
    print, "************************* Global Data *************************"
    print, " "
    print, "Data values in [",DataMin,",", DataMax,"]"
    print, "Absolute Data values in [",DataAbsMin,",",DataAbsMax,"]"
    print, "Minimum non-zero Absolute Data Value : ", DataAbsMin_Non0


    for p=0,2 do begin
       print, " "
       print, " - Projection ",p," -"
       print, " "
       print, "Data values in [", DatapMin[p], ",", DatapMax[p],"]"    
       print, "Absolute Data values in [", DatapAbsMin[p],",", DatapAbsMax[p],"]"
       print, "Minimum non-zero Absolute Data value : ", DatapAbsMin_Non0[p]    
       print, " "
       print, " - Projection ",p," (Data^2) -"      
       print, " "
       print, "Data values in [", Datap2Min[p], ",", Datap2Max[p],"]"    
       print, "Minimum non-zero Data value : ", Datap2Min_Non0[p]
       print, " "
       print, " - Projection ",p," (ABS(Data)) -"      
       print, " "
       print, "Data values in [", DatapAbsDataMin[p], ",", DatapAbsDataMax[p],"]"    
       print, "Minimum non-zero Data value : ", DatapAbsDataMin_Non0[p]
           
    endfor 
          
    for i=0, NFrames-1 do begin
      print, " "
      print, "************************ Frame ",i," ************************"
      print, " "
      print, "Simulation Time : ", Datatimes[i]
      print, "Iteration Number : ", DataIters[i]
    
      print, "Data Name : ", datanames[i]
      print, "Data File Names : ", DataFileNames[i] 
      print, "Dimensions : ", N[i,*]
      print, "Origin Vector : ", Origin[i,*] 
      print, "Delta Vector : ", Delta[i,*,*]        

      print, "Data Values in [", Min[i],",", Max[i],"]"
      print, "Absolute Data Values in [", AbsMin[i], ",",AbsMax[i],"]"
      print, "Minimum non-zero absolute Data value : ", AbsMin_Non0[i]

      for p=0,2 do begin
         print, " "
         print, " - Projection ",p," -"
         print, " "
         print, "Data Values in [", pMin[i,p], ",",pMax[i,p],"]"    
         print, "Absolute Data values in [", pAbsMin[i,p],",", pAbsMax[i,p],"]"
         print, "Minimum non-zero absolute data value : ",  pAbsMin_Non0[i,p]    
         print, " "
         print, " - Projection ",p," (Data^2) -"      
         print, " "
         print, "Data Values in [", p2Min[i,p], ",",p2Max[i,p],"]"    
         print, "Minimum non-zero data value : ",  p2Min_Non0[i,p]
         print, " "
         print, " - Projection ",p," (ABS(Data)) -"      
         print, " "
         print, "Data Values in [", pAbsDataMin[i,p], ",",pAbsDataMax[i,p],"]"    
         print, "Minimum non-zero data value : ",  pAbsDataMin_Non0[i,p]
      endfor 
    endfor   
    print, " "
    print, "***************** End Osiris Movie Data Info *****************"
  
  end
END