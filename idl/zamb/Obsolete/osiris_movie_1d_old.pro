
;
;  Program:  
;
;  Osiris_Analysis_1D
;
;  Description:
;
;  Opens 1D data output from the osiris code and plots it


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

PRO Osiris_Analysis_1D,_EXTRA=extrakeys, FILE = FileName, SQUARED = DataSquared, EXTENSION = FileNameExtension, $
                     SMOOTH = DataSmooth, RES = PlotRes, FACTOR = DimFactor, FFT = DoFFT, YLOG = UseLogScale, $
                     YMIN = _ymin, YMAX = _ymax, ABS = DataAbs, SPH_CORR = DoSpherCorr, SCALINGS = scalings
                     
if N_Elements(DoSpherCorr) eq 0 then DoSpherCorr=0

if N_Elements(UseLogScale) eq 0 then UseLogScale=0

if N_Elements(DoFFT) eq 0 then DoFFT = 0

if N_Elements(DimFactor) eq 0 then DimFactor = 0

if N_Elements(DataSmooth) eq 0 then DataSmooth = 0

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

if N_Elements(DataSquared) eq 0 then DataSquared = 0

if N_Elements(DataAbs) eq 0 then DataAbs = 0

if N_Elements(PlotRes) eq 0 then PlotRes = [600,450]

; Graphic display Initialization

Device, Get_Visual_Depth = thisDepth
If (thisDepth GT 8) Then Device, Decomposed = 0
 
; Gets Data Information from the Data Explorer Header File 

Osiris_Open_Data, Data, FILE = filename, DIM = Dims, DATATITLE = DataName, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData, PATH = path, EXTENSION = FileNameExtension,$
                        N = dxN

if (Dims ne 1) then begin
  newres = Dialog_Message(" Data is not 1-Dimensional! ", /Error)
  return
end

; Resizes the matrix

if (DimFactor gt 0) then begin
  dxN = dxN / DimFactor
  dxDelta = dxDelta * DimFactor
  Data = Rebin(Data, dxN[0])
  XAxisData = Rebin(XAxisData, dxN[0])
end

if (DataSquared ne 0) then Data = Data^2

if (DataAbs ne 0) then Data = Abs(Data)

if (DoSpherCorr ne 0) then begin
 ; Slow
 ;  for j=0, dxN[0]-1 do Data[j]=(XAxisData[j]^2)*Data[j]  
 ; Fast
 
 Data = (XAxisData^2)*Data
end 

; Smooths Data

if (DataSmooth gt 0) then begin
   if (DataSmooth lt 2) then DataSmooth = 2
   print, " Smoothing data, window size of", DataSmooth
   Data = Smooth(Data, DataSmooth) 
end

; Finds autoscale values

LocalMin = Min(Data, MAX = LocalMax)
       
if (LocalMin gt 0.0) then begin
    LocalAbsMin = LocalMin
    LocalAbsMax = LocalMax
    LocalAbsMin_Non0 = LocalMin 
end else begin
    LocalAbsMin= AbsMin(Data, MAX = LocalAbsMax, MINN0 = LocalAbsMin_Non0)
end

; Determines the correct autoscaling for the plots

MinData = LocalAbsMin
MaxData = LocalAbsMax

if (UseLogScale gt 0) then begin
    MinData = LocalAbsMin_Non0
    MaxData = LocalAbsMax  
  end else if (DataAbs gt 0) then begin
    MinData = LocalAbsMin
    MaxData = LocalAbsMax   
end
   
; Doesn't use autoscale if limit values are supplied 

if N_Elements(_ymax) ne 0 then MaxData = _ymax
if N_Elements(_ymin) ne 0 then MinData = _ymin

  
Print, " Values between ", MinData, " and ", MaxData


if (DoFFT gt 0) then begin
 
  DataName = 'FFT '+ Dataname
 
  N21x = dxN[0]/2 + 1
  XAxisData = IndGen(dxN[0])
  XAxisData[N21x] = N21x - dxN[0] + FINDGEN(N21x - 2)
  XAxisData = XAxisData/(dxN[0]*dxDelta[0,0])
  XAxisData = Shift(XAxisData, - N21x) 
    
  Print, " Calculating FFT..."
 
  Data = Abs(FFT(Data))
  Data = Shift(Data, -N21x)  
 
end

Print, " Plotting Data ..."

; Opens new graphics window

WindowTitle = filename[0]
Window, /Free, Title = WindowTitle, Xsize = PlotRes[0], Ysize =PlotRes[1]
!P.FONT = 1
!P.CHARSIZE = 1.5
device, SET_FONT = 'Helvetica', /TT_FONT

; Plots the data (finally)

timelabel = 'Time = ' + String(time, Format='(f7.2)') + ' [1/!4x!X!Ip!N]'

if (UseLogScale eq 0) then begin

   Plot, XAxisData, Data, TITLE = DataName, SUBTITLE = timelabel ,$
         _EXTRA = extrakeys, yrange = [MinData, MaxData]

end else begin
   
   Plot, XAxisData, Abs(Data), TITLE = DataName, SUBTITLE = timelabel,$
         _EXTRA = extrakeys, /ylog, yrange = [MinData, MaxData]

end

if Keyword_Set(Scalings) then begin

  oldx = 0
  oldy = 0
  first = 1

  print, "****************************************"
  print, " Press Apple Key + Mouse Button to quit "
  print, "****************************************"

  !mouse.button = 1
  Repeat begin
    Cursor, x, y, /down  
    if (first ne 1) then begin
       print, "(",oldx,",",oldy,") ->(",x,",",y,")"
       if (x ne oldx) then begin
          print, " Scalings "    
          print, " Linear : ", (y-oldy)/(x-oldx)
          if ((oldy gt 0) and (y gt 0) and (oldx gt 0) and (x gt 0)) then $
              print, " Log-Log : ", Alog10(y/oldy)/ALog10(x/oldx)   
       end  
    end else begin
     first = 0
     print, ' Cursor Position :',x,y
    end
    oldx = x
    oldy = y
  end until !mouse.button ne 1

end
                            
Print, "Plot Concluded"


END
