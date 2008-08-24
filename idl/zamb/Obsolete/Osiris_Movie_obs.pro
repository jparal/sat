
;
;  Program:  
;
;  Osiris_Movie
;
;  Description:
;
;  Opens data output from the osiris code and does a movie with it
;
;  Current Version:
;  
;    0.3 - Implemented the procedure PlotColorData. Solved minor bugs. 
;
;  History:
; 
;    0.2 - Solved the colours problem
;
;    0.1 - Minimum working program but with wrong colours
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie, _EXTRA=extrakeys, DIRECTORY = DirName, SQUARED = DataSquared, EXTENSION = FileNameExtension

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

if N_Elements(DataSquared) eq 0 then DataSquared = 0

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory)
  if (DirName eq '') then return
end



CD, DirName

dxFiles = FindFile('*.dx', Count = numdxFiles)

Print, Dirname, " -> ", numdxFiles, " dx files"

if (numdxFiles le 1) then begin
  newres = Dialog_Message(" Insuficient *.dx files in the specified directory", /Error)
  return
end

Print, numdxFiles, " found"
DataFileNames = StrArr(numdxFiles)
DataTimes = DblArr(numdxFiles)


AnaliseDx, dxFiles[0], DATATITLE = DataName, NX = dxNX, NY = dxNY, ORIGIN1 = dxOrigin1, $
           ORIGIN2 = dxOrigin2, DELTA11 = dxDelta11, DELTA12 = dxDelta12, DELTA21 = dxDelta21, $
           DELTA22 = dxDelta22,  DATAFILE = tempfilename, TIMEPHYS = temptime
           
DataTimes[0] = temptime
DataFileNames[0] =tempfilename + FileNameExtension        


Print, " (NX,NY)             = ", dxNX, dxNY


Print, " Data File           = ", DataFileNames[0] 
Print, " Data Name           = ", DataName
Print, " Origin              = ", dxOrigin1, dxOrigin2
Print, " Delta1              = ", dxDelta12, dxDelta21
Print, " Delta2              = ", dxDelta21, dxDelta22


For i=1, numdxFiles-1 do begin
   AnaliseDx, dxFiles[i], DATATITLE = _DataName, NX = _dxNX, NY = _dxNY, ORIGIN1 = _dxOrigin1, $
              ORIGIN2 = _dxOrigin2, DELTA11 = _dxDelta11, DELTA12 = _dxDelta12, DELTA21 = _dxDelta21, $
              DELTA22 = _dxDelta22, DATAFILE = tempfilename, TIMEPHYS = temptime
   
   DataTimes[i] = temptime
   DataFileNames[i] =tempfilename + FileNameExtension
   flag = 1   
   
   if (_DataName ne Dataname) then flag = 0
   if (_dxNX ne dxNX) then flag = 0
   if (_dxNY ne dxNY) then flag = 0
   if (_dxOrigin1 ne dxOrigin1) then flag = 0
   if (_dxOrigin2 ne dxOrigin2) then flag = 0
   if (_dxDelta11 ne dxDelta11) then flag = 0
   if (_dxDelta12 ne dxDelta12) then flag = 0
   if (_dxDelta21 ne dxDelta21) then flag = 0
   if (_dxDelta22 ne dxDelta22) then flag = 0
    
   if (flag eq 0) then begin
     res = Dialog_Message(dxFiles[i]+" has incompatible data", /Error)
     return
   end
   
end

if (DataSquared ne 0) then DataName = "|"+DataName+"|^2"
Print, " Output Data         = ", DataName

NX = dxNX
NY = dxNy


NFrames = numdxFiles

Print, " Reading Data, " , NFrames, " frames ..."

totalmemory = NFrames*NX*NY*4

if (totalmemory lt 100000000) then begin

  Data=FltArr(NFrames,NX,NY)

  Data0=FltArr(NX,NY) 
  Header = FltArr(1)
  sTimes = StrArr(NFrames)
  work_file_id = 1

  Close, work_file_id
  OpenR, work_file_id, DataFileNames[0] 
  ReadU, work_file_id, Header
  ReadU, work_file_id, Data0
  if (DataSquared ne 0) then Data0 = Data0^2


  Data[0,*,*] = Data0
  Close, work_file_id

  sTimes[0] = "Time = " + String(DataTimes[0],Format='(f7.2)') + " [1/Wp]"

  Print, " ", DataFileNames[0]," ",sTimes[0] 
 
  For i=1,NFrames-1 do begin
    OpenR, work_file_id, DataFileNames[i] 
    ReadU, work_file_id, Header 
    ReadU, work_file_id, Data0
    if (DataSquared ne 0) then Data0 = Data0^2 
  
    Data[i,*,*] = Data0
    Close, work_file_id 
    sTimes[i] = "Time = " + String(DataTimes[i],Format='(f7.2)') + " [1/Wp]"
  
    Print, " ", DataFileNames[i]," ",sTimes[i] 
   
  end

  XAxisData = FIndGen(NX)*(NX*dxDelta21)/(NX-1)+dxOrigin1
  YAxisData = FIndGen(NY)*(NY*dxDelta12)/(NY-1)+dxOrigin2


  MovieColorData, Data, TITLE = DirName, XAXIS = XAxisData, YAXIS = YAxisData, $
                  PLOTTITLE = DataName, FRAMELABELS = sTimes, _EXTRA = extrakeys
                
end else begin
  print, "Insufficient memory to generate movie, generating individual frames"
  
  ; Gets limits 

  print, "Getting limits..."
 
  Data0=FltArr(NX,NY) 
  Header = FltArr(1)
  work_file_id = 1

  Close, work_file_id
  OpenR, work_file_id, DataFileNames[0] 
  ReadU, work_file_id, Header
  ReadU, work_file_id, Data0
  if (DataSquared ne 0) then Data0 = Data0^2
  Close, work_file_id

  print, "Frame ",0
  minData = Min(Data0, MAX = maxData)
  
  For i=1,NFrames-1 do begin
    OpenR, work_file_id, DataFileNames[i] 
    ReadU, work_file_id, Header 
    ReadU, work_file_id, Data0
    if (DataSquared ne 0) then Data0 = Data0^2  
    Close, work_file_id 
    print, "Frame ",i
  
    tminData = Min(Data0, MAX = tmaxData)
    if (tminData lt minData) then minData = tminData
    if (tmaxData gt maxData) then maxData = tmaxData    
  end
    
  ; Generates Frames
  
  print, "Generating frames..."
  Window, /Free
  device, decomposed = 0  
  For i=0,NFrames-1 do begin
    OpenR, work_file_id, DataFileNames[i] 
    ReadU, work_file_id, Header 
    ReadU, work_file_id, Data0
    if (DataSquared ne 0) then Data0 = Data0^2  
    Close, work_file_id 

    sTime = "Time = " + String(DataTimes[i],Format='(f7.2)') + " [1/Wp]"
       
    PlotColorData, Data0 ,_EXTRA=extrakeys, MIN = minData, MAX = maxData, SUBTITLE = sTime
 
    frame24 = TVRD(True = 1)
    frame = Color_Quan(frame24,1,r,g,b)
    
    framename =  "frame"+ String(byte([ byte('0') +  (i/1000.0) mod 10 , $
                           byte('0') +  (i/100.0)  mod 10 , $
                           byte('0') +  (i/10.0)   mod 10 , $
                           byte('0') +  (i/1.0)    mod 10 ])) + ".gif" 

;    print, framename
    Write_GIF, framename, frame, r, g, b
    print, "Saved file ", framename
 
  end
  
end


  Print, " Done! "

END