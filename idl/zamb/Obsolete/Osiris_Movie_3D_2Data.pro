
;
;  Program:  
;
;  Osiris_Movie_3D_2Data
;
;  Description:
;
;  Opens data output from the osiris code and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_3D_2data, _EXTRA=extrakeys, DIRECTORY = DirName, SQUARED = DataSquared, EXTENSION = FileNameExtension, $
                      NOXANIMATE = noXAnimate, LOG = UseLogScale, DIRECTORY2 = DirName2


MovieSizeX = 600
MovieSizeY = 450 

; Log Scale

if N_Elements(UseLogScale) eq 0 then UseLogScale = 0

; Call XAnimate
   
if N_Elements(noXAnimate) eq 0 then noXAnimate = 0
   
; Save Frames
    
if N_Elements(SaveFrames) eq 0 then SaveFrames = 0

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

if N_Elements(DataSquared) eq 0 then DataSquared = 0

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory, TITLE = 'First Data Set')
  if (DirName eq '') then return
end

if N_Elements(DirName2) eq 0 then begin  
  DirName2 = Dialog_PickFile(/Directory, TITLE = 'Second Data Set')
  if (DirName2 eq '') then return
end


if N_Elements(SmoothFact) eq 0 then begin 
  SmoothFact = 0  
end else if (SmoothFact lt 2) then SmoothFact = 2 



GetOsirisMovieData, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax,  DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0,$
                    DATAPMAX = DATApMax, DATAPMIN = DATApMin, DATAPABSMAX = DATApAbsMax, DATAPABSMIN = DATApAbsMin, NON0DATAPABSMIN = DATApAbsMin_Non0, $
                    DATAP2MAX = DATAp2Max, DATAP2MIN = DATAp2Min, DATAP2ABSMAX = DATAp2AbsMax, DATAP2ABSMIN = DATAp2AbsMin, NON0DATAP2ABSMIN= DATAp2AbsMin_Non0

GetOsirisMovieData, DIRECTORY = DirName2, /Silent, DATANAME = datanames2, FILENAME = DataFileNames2

DataName = DataNames[0]
if (DataSquared ne 0) then DataName = "|"+DataName+"|^2"

DataName2 = DataNames2[0]
if (DataSquared ne 0) then DataName2 = "|"+DataName2+"|^2"


Print, " Output Data 1       = ", DataName
Print, " Output Data 2       = ", DataName2

NX = _N[0,0]
NY = _N[0,1]
NZ = _N[0,2]

XAxisData = FIndGen(NX)*(NX*Delta[0,0,0])/(NX-1)+Origin[0,0]
YAxisData = FIndGen(NY)*(NY*Delta[0,1,1])/(NY-1)+Origin[0,1]
ZAxisData = FIndGen(NZ)*(NZ*Delta[0,2,2])/(NZ-1)+Origin[0,2]

winRes = [MovieSizeX,MovieSizeY]

; Makes the frames

;Window, /Free
;device, decomposed = 0 

Data0=FltArr(NX,NY,NZ) 
Data1=FltArr(NX,NY,NZ) 

if (DataSquared eq 0) then begin
  MinData = DataMin
  MaxData = DataMax
  
  if (UseLogScale gt 0) then begin
    MinData = DataAbsMin_Non0
    MaxData = DataAbsMax  
  end
  
  ProjMax = DataPMax
  ProjMin = DataPMin 
endif else begin
  MinData = DataAbsMin^2
  MaxData = DataAbsMax^2

  if (UseLogScale gt 0) then begin
    MinData = DataAbsMin_Non0^2
    MaxData = DataAbsMax^2  
  end

  ProjMax = DataP2Max
  ProjMin = DataP2Min  
endelse

for i=0, NFrames-1 do begin

  ; Reads data1 for this frame
  CD, DirName
  OpenR, work_file_id, DataFileNames[i], /Get_Lun 
  ReadU, work_file_id, Header 
  ReadU, work_file_id, Data0
  Close, work_file_id
  Free_Lun, work_file_id

  ; Reads data2 for this frame
  CD, DirName2 
  OpenR, work_file_id, DataFileNames2[i], /Get_Lun 
  ReadU, work_file_id, Header 
  ReadU, work_file_id, Data1
  Close, work_file_id
  Free_Lun, work_file_id

  
  if (DataSquared ne 0) then begin
      Data0 = Temporary(Data0^2) 
      Data1 = Temporary(Data1^2) 
  endif
 
  frame = 0
  
  timelabel = "Time = " + String(DataTimes[i],Format='(f7.2)') + " [1/!4x!X!Ip!N]"

  _MinData = MinData
  _MaxData = MaxData

  Plot3D, Data0, _EXTRA = extrakeys, MIN = _MinData, MAX = _MaxData, Image = frame, $
                 PMAX = ProjMax, PMIN = ProjMin, TITLE = DataName, SUBTITLE = timelabel, LOG = UseLogScale, $
                 DATA2 = Data1, DATATITLE2 = DataName2   

  framename =  "frame"+ String(byte([ byte('0') +  (i/1000.0) mod 10 , $
                               byte('0') +  (i/100.0)  mod 10 , $
                               byte('0') +  (i/10.0)   mod 10 , $
                               byte('0') +  (i/1.0)    mod 10 ])) + ".gif" 

  TVLCT, r,g,b, /Get
  CD, DirName
  Write_GIF, framename, frame, r, g, b
  print, "Saved file ", framename
  
  print, "Finished frame ",i 
end

;XINTERANIMATE

if (noXAnimate eq 0) then begin
  Frame2Movie, DIRECTORY = DirName, FILES = framename
end

Print, " Done! "

; This cleans up any pallete problems

loadct, 0, /silent

END