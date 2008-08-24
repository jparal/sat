
;
;  Program:  
;
;  Osiris_Movie_3D
;
;  Description:
;
;  Opens data output from the osiris code and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_3D, _EXTRA=extrakeys, DIRECTORY = DirName, SQUARED = DataSquared, EXTENSION = FileNameExtension, $
                      SAVEFRAMES = SaveFrames, NOXANIMATE = noXAnimate, LOG = UseLogScale, $
                      RES = winRES, BORDER = bordercells
                      
; BORDER

if N_Elements(bordercells) eq 0 then bordercells = 0                      


; Frame resolution

if N_Elements(winRES) eq 0 then winRES = [500,500]

; Log Scale

if N_Elements(UseLogScale) eq 0 then UseLogScale = 0

; Call XAnimate
   
if N_Elements(noXAnimate) eq 0 then noXAnimate = 0
   
; Save Frames
    
if N_Elements(SaveFrames) eq 0 then SaveFrames = 0

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

if N_Elements(DataSquared) eq 0 then DataSquared = 0

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory)
  if (DirName eq '') then return
end

if N_Elements(SmoothFact) eq 0 then begin 
  SmoothFact = 0  
end else if (SmoothFact lt 2) then SmoothFact = 2 

CD, DirName

GetOsirisMovieData, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax,  DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0,$
                    DATAPMAX = DATApMax, DATAPMIN = DATApMin, DATAPABSMAX = DATApAbsMax, DATAPABSMIN = DATApAbsMin, NON0DATAPABSMIN = DATApAbsMin_Non0, $
                    DATAP2MAX = DATAp2Max, DATAP2MIN = DATAp2Min, DATAP2ABSMAX = DATAp2AbsMax, DATAP2ABSMIN = DATAp2AbsMin, NON0DATAP2ABSMIN= DATAp2AbsMin_Non0


DataName = DataNames[0]
if (DataSquared ne 0) then DataName = "|"+DataName+"|^2"
Print, " Output Data         = ", DataName

NX = _N[0,0]
NY = _N[0,1]
NZ = _N[0,2]

print, NX, NY, NZ

XAxisData = FIndGen(NX)*(NX*Delta[0,0,0])/(NX-1)+Origin[0,0]
YAxisData = FIndGen(NY)*(NY*Delta[0,1,1])/(NY-1)+Origin[0,1]
ZAxisData = FIndGen(NZ)*(NZ*Delta[0,2,2])/(NZ-1)+Origin[0,2]


XAxisData = XAxisData[bordercells : NX - 1 - bordercells]
YAxisData = YAxisData[bordercells : NY - 1 - bordercells]
ZAxisData = ZAxisData[bordercells : NZ - 1 - bordercells]

; Makes the frames

;Window, /Free
;device, decomposed = 0 


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

framename = StrArr(NFrames)

window, /free, xsize = winRES[0], ysize = winRES[1]

for i=0, NFrames-1 do begin

  Data0=FltArr(NX,NY,NZ) 
  
  ; Reads data for this frame
 
  OpenR, work_file_id, DataFileNames[i], /Get_Lun 
  ReadU, work_file_id, Header 
  ReadU, work_file_id, Data0
  Close, work_file_id
  Free_Lun, work_file_id

  Data0 = Data0[bordercells : NX - 1 - bordercells, bordercells : NY - 1 - bordercells, bordercells : NZ - 1 - bordercells ]
  
  if (DataSquared ne 0) then Data0 = Temporary(Data0^2) 
  
  frame = 0
  
  timelabel = "Time = " + String(DataTimes[i],Format='(f7.2)') + " [1/!4x!X!Ip!N]"

  _MinData = MinData
  _MaxData = MaxData

  Plot3D, Data0, _EXTRA = extrakeys, MIN = _MinData, MAX = _MaxData, Image = frame, $
                   PMAX = ProjMax, PMIN = ProjMin, TITLE = DataName, SUBTITLE = timelabel, LOG = UseLogScale, $
                   RES = winRES

  
  Data0 = 0

  
  framename[i] =  "frame"+ String(byte([ byte('0') +  (i/1000.0) mod 10 , $
                               byte('0') +  (i/100.0)  mod 10 , $
                               byte('0') +  (i/10.0)   mod 10 , $
                               byte('0') +  (i/1.0)    mod 10 ])) + ".gif" 

;    print, framename
  
    TVLCT, r,g,b, /Get
    Write_GIF, framename[i], frame, r, g, b
    print, "Saved file ", framename[i]
    TV, frame
  end
  
  print, "Finished frame ",i 
end

if (noXAnimate eq 0) then begin
  Frame2Movie, DIRECTORY = DirName, FILES = framename
end

Print, " Done! "

END