Pro GetOsirisMovieData2D, _EXTRA=extrakeys, DIRECTORY = DirName, EXTENSION = fnameextension, INFOFILE = infofilename, GENERATE = generatedata, $
                        TIMES = Datatimes, ITERS = DataIters, DATANAME = datanames, FILENAME = DataFIleNames, DIMN = N, $
                        NFRAMES = NFrames, ORIGIN = origin, DELTA = delta,$
                        DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax, DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0, $
                        MAX = Max, MIN = Min, ABSMAX = AbsMax, ABSMIN = fAbsMin, NON0ABSMIN = AbsMin_Non0, $
                        TIMEMIN = timemin, TIMEMAX = timemax, SILENT = silent, XAXIS = XAxis, YAXIS = Yaxis, $
                        DX = UseDx
                        
  if N_Elements(DirName) eq 0 then begin  
    DirName = Dialog_PickFile(/Directory)
    if (DirName eq '') then return
  end

  CD, DirName

  if N_Elements(infofilename) eq 0 then infofilename = "OsirisMovieData.dat"
  
  if not Keyword_Set(generatedata) then begin
    test = FindFile(infofilename, Count = file_exists)
    if (file_exists gt 0) then generatedata = 0 $
    else generatedata = 1  
  end else generatedata = 1

  ; Generate Data
  if (generatedata gt 0) then begin
    filter = '*.hdf'
    if Keyword_set(UseDx) then filter = '*.dx'

    dxFiles = FindFile(filter, Count = NFrames)
    
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
    fAbsMin = DblArr(NFrames)
    AbsMin_Non0 = DblArr(NFrames)

    print, " Analising Data files..."
    oProgressBar = Obj_New("SHOWPROGRESS", $
                        /cancelbutton, $
                        TITLE = 'Movie Data', $
                        MESSAGE = 'Analysing Files...')
    oProgressBar -> Start
   
    for i=0, NFrames -1 do begin
      print, " File : ", dxFiles[i]
      label = 'Analysing File '+strtrim(string(i+1),1)+'/'+$
                strtrim(string(NFrames),1)
  
      oProgressBar -> SetLabel, label 
      if (oProgressBar -> CheckCancel()) then goto, abort
  
      Osiris_Open_Data, pData0,  FILE = dxFiles[i], EXTENSION = fnameextension, PATH = DirName, DATATITLE = DataName, N = dxN, ORIGIN = dxOrigin, $
                 DELTA = dxDelta,  TIMEPHYS = time, TIMESTEP = step, /IGNORE_TIME

      if (pData0[0] eq ptr_new()) or (not ptr_valid(pData0[0])) then begin
        oProgressBar -> Destroy
        Obj_Destroy, oProgressBar
        return
      end
       
      if (oProgressBar -> CheckCancel()) then goto, abort
   
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
      
      ptr_free, pData0
      
      Min[i] = LocalMin
      Max[i] = LocalMax
      fAbsMin[i] = LocalAbsMin
      AbsMax[i] = LocalAbsMax
      AbsMin_Non0[i] = LocalAbsMin_Non0       
 
      if (oProgressBar -> CheckCancel()) then goto, abort
      oProgressBar -> Update, (100.0*i)/(NFrames-1)
    end
    
    ptr_free, pData0
    oProgressBar -> Destroy
    Obj_Destroy, oProgressBar
  
    ; Global Data

    TimeMin = Min(DataTimes, MAX = TimeMax)
         
    DataMax = Max(Max)
    DataMin = Min(Min)    
       
    DataAbsMax = Max(AbsMax)
    DataAbsMin = Min(fAbsMin)

    dummy = AbsMin(AbsMin_Non0, MINN0 =DataAbsMin_Non0)
    
    ; Saves infofile
    
    OpenW, info_id, infofilename, /Get_Lun
    
    Printf, info_id, DirName
    Printf, info_id, NFrames

    printf, info_id, DataMax, DataMin
    printf, info_id, DataAbsMax, DataAbsMin, DataAbsMin_Non0

    
    for i=0, NFrames-1 do begin
      printf, info_id, i
      printf, info_id, Datatimes[i]
      printf, info_id, Datatimes[i]
      printf, info_id, DataIters[i]
      printf, info_id, DataFileNames[i] 
      printf, info_id, N[i,*]
      printf, info_id, Origin[i,*] 
      printf, info_id, Delta[i,0,0], Delta[i,0,1]    
      printf, info_id, Delta[i,1,0], Delta[i,1,1]        

      printf, info_id, Max[i], Min[i]
      printf, info_id, AbsMax[i], fAbsMin[i], AbsMin_Non0[i]

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
    fAbsMin = DblArr(NFrames)
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
      Readf, info_id, temp
      Readf, info_id, tempdbl1
      Datatimes[i]=tempdbl1
      Readf, info_id, tempi1
      DataIters[i] = tempi1
      Readf, info_id, temp
      DataNames[i]=temp
      Readf, info_id, temp
      DataFileNames[i]=temp  
      Readf, info_id, tempi1,tempi2
      N[i,*]=[tempi1,tempi2]
      Readf, info_id, tempdbl1,tempdbl2
      Origin[i,*]=[tempdbl1,tempdbl2] 
      Readf, info_id, tempdbl1,tempdbl2  
      Delta[i,0,*] = [tempdbl1,tempdbl2] 
      Readf, info_id, tempdbl1,tempdbl2  
      Delta[i,1,*] = [tempdbl1,tempdbl2] 
           
      Readf, info_id, tempdbl1, tempdbl2 
      Max[i] = tempdbl1
      Min[i] = tempdbl2
           
      Readf, info_id, tempdbl1,tempdbl2,tempdbl3     
      AbsMax[i]=tempdbl1
      fAbsMin[i]=tempdbl2
      AbsMin_Non0[i]=tempdbl3

    endfor   

    Close, info_id
    Free_Lun, info_id 
    print, " Done."  
  endelse   

  ; Calculate Axis

  print, 'Generating axis...'  
  XAxis = Findgen(N[0,0])*Delta[0,0,0] + Origin[0,0]
  YAxis = Findgen(N[0,1])*Delta[0,1,1] + Origin[0,1]



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
      print, "Iteration Number : ", DataIters[i]
      print, "Data Name : ", datanames[i]
      print, "Data File Names : ", DataFileNames[i] 
      print, "Dimensions : ", N[i,*]
      print, "Origin Vector : ", Origin[i,*] 
      print, "Delta Vector : ", Delta[i,*,*]        

      print, "Data Values in [", Min[i],",", Max[i],"]"
      print, "Absolute Data Values in [", fAbsMin[i], ",",AbsMax[i],"]"
      print, "Minimum non-zero absolute Data value : ", AbsMin_Non0[i]

    endfor   
    print, " "
    print, "***************** End Osiris Movie Data Info *****************"
  
  end
  
  DataIters = IndGen(NFrames)
  return
  
abort:
  ptr_free, pData0
  oProgressBar -> Destroy
  Obj_Destroy, oProgressBar
  print, 'OsirisMovieData2D, Aborted!'
  return  
END