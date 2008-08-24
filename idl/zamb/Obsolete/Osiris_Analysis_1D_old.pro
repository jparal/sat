
;
;  Program:
;
;  Osiris_Analysis_1D
;
;  Description:
;
;  Opens 1D data output from the osiris code and plots it


pro gamma_one, x, a, f, pder
  f = (x)*exp(-x/a[1])
  if (n_params() ge 4) then $
    pder = [ [f], $      ; partial derivative with regard to a[0]
             [x*a[0]*f/a[1]^2] ]              ; partial derivative with regard to a[1]
  f = a[0]*temporary(f)
end

PRO Osiris_Analysis_1D,_EXTRA=extrakeys, $
                     ; File Information
                     FILE = FileName, PATH = FilePath,  EXTENSION = FileNameExtension, DX = useDX,$
                     ; Data Operations
                     SQUARED = DataSquared, SMOOTH = DataSmooth, ABS = DataAbs, $
                     FACTOR = DimFactor, FFT = DoFFT, NORMALIZE = normalize, $
                     SPH_CORR = DoSpherCorr, $
                     ; Curve Fitting
                     CURVE_FIT = curve_fit, $
                     ; On screen scalings
                     SCALINGS = scalings,  $
                     ; Plot Scaling
                     YLOG = UseLogScale, YMIN = _ymin, YMAX = _ymax, $
                     ; Plot Options
                     TIME_UNITS = time_units, RES = PlotRes
                     
; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'


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

Osiris_Open_Data, pData, FILE = filename, DIM = Dims, DATATITLE = DataName, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData, PATH = filepath, EXTENSION = FileNameExtension,$
                        N = dxN, DX = useDX

print, 'Osiris_Analysis_1D'
help, pData
help, *pData


if (Dims ne 1) then begin
  newres = Dialog_Message(" Data is not 1-Dimensional! ", /Error)
  Ptr_Free,pData
  return
end

; Resizes the matrix

if (DimFactor gt 0) then begin
  dxN = dxN / DimFactor
  *pData = Rebin(*pData, dxN)
  XAxisData = Rebin(XAxisData, dxN)
end

if (DataSquared ne 0) then *pData = temporary(*pData)^2

if (DataAbs ne 0) then *pData = Abs(temporary(*pData))

if (DoSpherCorr ne 0) then begin
 ; Slow
 ;  for j=0, dxN[0]-1 do Data[j]=(XAxisData[j]^2)*Data[j]
 ; Fast

 *pData = (XAxisData^2)*(*pData)
end

; Smooths Data

if (DataSmooth gt 0) then begin
   if (DataSmooth lt 2) then DataSmooth = 2
   print, " Smoothing data, window size of", DataSmooth
   *pData = Smooth(*pData, DataSmooth, /edge_truncate)
end

; Finds autoscale values

LocalMin = Min(*pData, MAX = LocalMax)

if (LocalMin gt 0.0) then begin
    LocalAbsMin = LocalMin
    LocalAbsMax = LocalMax
    LocalAbsMin_Non0 = LocalMin
end else begin
    LocalAbsMin= AbsMin(pData, MAX = LocalAbsMax, MINN0 = LocalAbsMin_Non0)
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
  XAxisData = 2.0*!PI*XAxisData/(dxN[0]*dxDelta[0,0])
  XAxisData = Shift(XAxisData, - N21x)

  Print, " Calculating FFT..."

  *pData = FFT(*pData, /overwrite)
  *pData = Abs(temporary(*pData))
  *pData = Shift(temporary(*pData), -N21x)

end

; If necessary normalizes the data

if Keyword_Set(normalize) then begin
  max_val = max(abs(*pData))
  *pData = temporary(*pData) / max_val
end


Print, " Plotting Data ..."

; Opens new graphics window

WindowTitle = filename[0]
Window, /Free, Title = WindowTitle, Xsize = PlotRes[0], Ysize =PlotRes[1]
!P.FONT = 1
!P.CHARSIZE = 1.5
device, SET_FONT = 'Helvetica', /TT_FONT

; Plots the data (finally)

timelabel = 'Time = ' + String(time, Format='(f7.2)') + ' [ '+time_units+' ]'


if (UseLogScale eq 0) then begin

   Plot, XAxisData, (*pData), TITLE = DataName, SUBTITLE = timelabel ,$
         _EXTRA = extrakeys, yrange = [MinData, MaxData]

end else begin

   Plot, XAxisData, Abs(*pData), TITLE = DataName, SUBTITLE = timelabel,$
         _EXTRA = extrakeys, /ylog, yrange = [MinData, MaxData]

end

if (N_Elements(curve_fit) ne 0) then begin
  
  ; fit y = a0 * (x+1) * exp(-x/a1)
  
  x = xaxisdata
  weigths = replicate(1.0, N_Elements(x))
  a = [1.0,0.5]

  y = abs(*pData)

  weigths[where(y gt 0)] = 1.0/y[where(y gt 0)]

  res = curvefit(x, y, weigths, a, FUNCTION_NAME = 'gamma_one', ITMAX = 1000, /noderivative)

  print, 'Fitting concluded, result = ', a

  oplot, x, res  

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

ptr_free, pData

Print, "Plot Concluded"


END
