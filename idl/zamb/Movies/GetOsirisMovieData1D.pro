Function AbsMin, Data, MAX = localabsmax, MINN0 = localabsmin_non0
   Data1 = Abs(Data)     
   LocalAbsMin = Min(Data1, MAX = LocalAbsMax)
   LocalAbsMin_Non0 = LocalAbsMin + Min(Abs(Data)>0.0)  
   if ((LocalAbsMin eq 0.0) and (LocalAbsMax gt 0.0)) then begin    
       idx = Where(Data1 gt 0.0, count)
       if (count gt 0) then LocalAbsMin_Non0 = Min(Data1[idx])   $        
       else LocalAbsMin_Non0 = LocalAbsMin                 
   end else LocalAbsMin_Non0 = LocalAbsMin          
   Data1 = 0
   
   return, LocalAbsMin
end


Pro GetOsirisMovieData1D, DIRECTORY = DirName, INFOFILE = infofilename, GENERATE = generatedata, $
                        ; time and time-step information
                        TIMES = Datatimes, ITERS = DataIters,$
                        ; datanames, filenames and dimensions
                        DATANAME = datanames, FILENAME = DataFIleNames, DIMN = N, $
                        ; number of frames and axis information
                        NFRAMES = NFrames, ORIGIN = origin, DELTA = delta, XAXIS = xaxis,$
                        ; global data ranges
                        DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax, DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0, $
                        ; local data ranges
                        MAX = Max, MIN = Min, ABSMAX = AbsMax, ABSMIN = AbsMin, NON0ABSMIN = AbsMin_Non0, $
                        ; time limits
                        TIMEMIN = timemin, TIMEMAX = timemax, $
                        ; results display and dx file use
                        SILENT = silent, DX = UseDX
                        
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

  if (generatedata gt 0) then begin
    filter = '*.hdf'
    if Keyword_Set(UseDX) then filter = '*.dx'
    dxFiles = FindFile(filter, Count = NFrames)
    
    DataNames = StrArr(NFrames)
    DataFileNames = StrArr(NFrames)
    DataTimes = DblArr(NFrames)
;    DataIters = IndGen(NFrames)
    DataIters = LonArr(NFrames)    
    N = LonArr(NFrames,1)
    
    Origin = DblArr(NFrames,1)
    Delta = DblArr(NFrames,1,1)  
 
    Max = DblArr(NFrames)
    Min = DblArr(NFrames)
    AbsMax = DblArr(NFrames)
    AbsMin = DblArr(NFrames)
    AbsMin_Non0 = DblArr(NFrames)

    print, " Analising Data files..."
       
    for i=0, NFrames -1 do begin
       print, 'File : ', dxFiles[i]
       step=lonarr(1)
       Osiris_Open_Data, pData0, FILE = dxFiles[i], PATH = Dirname, DATATITLE = DataName, N = dxN, ORIGIN = dxOrigin, $
                 DELTA = dxDelta, TIMEPHYS = time, TIMESTEP = step[0], /IGNORE_ALL
     
       DataNames[i] = DataName
       DataTimes[i] = time
       DataIters[i] = step[0]
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
             
    end
    
    ; Global Data

    TimeMin = Min(DataTimes, MAX = TimeMax)
         
    DataMax = Max(Max)
    DataMin = Min(Min)    
       
    DataAbsMax = Max(AbsMax)
    DataAbsMin = Min(AbsMin)

    DataAbsMin_Non0 = Min(AbsMin_Non0)
    
    ; Saves infofile
    
    OpenW, info_id, infofilename, /Get_Lun
    
    Printf, info_id, DirName
    Printf, info_id, NFrames

    printf, info_id, DataMax, DataMin
    printf, info_id, DataAbsMax, DataAbsMin, DataAbsMin_Non0

    
    for i=0, NFrames-1 do begin
      printf, info_id, i
      printf, info_id, Datatimes[i]
      printf, info_id, DataIters[i]
      printf, info_id, DataNames[i]
      printf, info_id, DataFileNames[i] 
      printf, info_id, N[i,*]
      printf, info_id, Origin[i,*] 
      printf, info_id, Delta[i,0,0]        

      printf, info_id, Max[i], Min[i]
      printf, info_id, AbsMax[i], AbsMin[i], AbsMin_Non0[i]

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
    
    N = LonArr(NFrames,2)
    
    Origin = DblArr(NFrames,2)
    Delta = DblArr(NFrames,2,2)  
 
    Max = DblArr(NFrames)
    Min = DblArr(NFrames)
    AbsMax = DblArr(NFrames)
    AbsMin = DblArr(NFrames)
    AbsMin_Non0 = DblArr(NFrames)


    Readf, info_id, DataMax, DataMin
    Readf, info_id, DataAbsMax, DataAbsMin, DataAbsMin_Non0
  
    
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
      Readf, info_id, tempi1              ; i
;      print, tempi1
      Readf, info_id, tempdbl1            ; Datatimes
;      print, tempdbl1
      Datatimes[i]=tempdbl1
      Readf, info_id, templ1              ; DataIters
      DataIters[i] = templ1
      Readf, info_id, temp                ; DataNames
;      print, temp
      DataNames[i]=temp
      Readf, info_id, temp                ; DataFileNames
;      print, temp
      DataFileNames[i]=temp               
      Readf, info_id, tempi1              ; N
;      print, tempi1
      N[i,*]=[tempi1]
      Readf, info_id, tempdbl1
;      print, tempdbl1
      Origin[i,*]=[tempdbl1] 
      Readf, info_id, tempdbl1  
;      print, tempdbl1
      Delta[i,0,0] = tempdbl1           
      Readf, info_id, tempdbl1, tempdbl2 
      Max[i] = tempdbl1
      Min[i] = tempdbl2
           
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3     
      AbsMax[i]=tempdbl1
      AbsMin[i]=tempdbl2
      AbsMin_Non0[i]=tempdbl3

    endfor   

    Close, info_id
    Free_Lun, info_id 
    print, " Done."  
  endelse   

  ; Calculate Axis

  XAxis = Findgen(N[0,0])*Delta[0,0,0] + Origin[0,0]


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

    
    NFrames = 1
       
    for i=0, NFrames-1 do begin
      print, " "
      print, "************************ Frame ",i," ************************"
      print, " "
      print, "Simulation Time : ", Datatimes[i]
      print, "Timestep number : ", Dataiters[i]
      print, "Data Name : ", datanames[i]
      print, "Data File Names : ", DataFileNames[i] 
      print, "Dimensions : ", N[i,*]
      print, "Origin Vector : ", Origin[i,*] 
      print, "Delta Vector : ", Delta[i,*,*]        

      print, "Data Values in [", Min[i],",", Max[i],"]"
      print, "Absolute Data Values in [", AbsMin[i], ",",AbsMax[i],"]"
      print, "Minimum non-zero absolute Data value : ", AbsMin_Non0[i]

    endfor   
    print, " "
    print, "***************** End Osiris Movie Data Info *****************"
  
  end
END