
;
;  Program:  
;
;  Osiris_Movie_2D
;
;  Description:
;
;  Opens data output from the osiris code and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_2D, _EXTRA=extrakeys, $
                     ; Directory and file information
                     DIRECTORY = DirName, EXTENSION = FileNameExtension, $
                     ; Data operations
                     FFT = DoFFT, SQUARED = DataSquared, ABS = DataAbs, BACKGROUND = _background, $
                     SMOOTH = DataSmooth,_SMOOTHFFT = FFTDataSmooth,FACTOR = DimFactor,$
                     ; Titles and labels
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units,  $
                     ; Data Ranges
                     ZMAX = _zmax, ZMIN = _zmin, ZLOG = zlog, $
                     ; Safety precautions
                     PROFILE = dummy, $
                     ; Laser Operation
                     ENVELOPE = doEnvelope, $
                     ; Centroid Operation
                     CENTROIDS = CentroidDir, CENTMINVAL = CentroidMinVal, $
                     ; Visualization options
                     SHOW = Show, RES = PlotRes, XANIMATE = XAnimate
                     
; **************************************************************************************************** Parameters
                      
; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'

; ENVELOPE
;
; Plots the envelope of the data. Also see keywords KMIN and LASERK in envelope.pro

if N_Elements(doEnvelope) eq 0 then begin
     doEnvelope = 0
end else begin
     doEnvelope = 1
end

; CENTROIDS
;
; Calculate a mass centroid. Set this parameter to the direction of the centroid (0, or 1)
; When looking at laser fields this algorithm is only effective with laser envelopes. If the data
; is not already an envelope you should use the ENVELOPE keyword. Also see Osiris_Gen_Envelope.pro
; and envelope.pro

if N_Elements(CentroidDir) eq 0 then begin
  iAddCentroid = 0
end else begin
  n_centroids = N_Elements(CentroidDir)
  iAddCentroid = 1 
end

; SMOOTH
;
; Data Smoothing
; 
; By setting this keyword the data is smoothed using the SMOOTH function with a smoothing
; parameter equal to the one specified

if N_Elements(DataSmooth) eq 0 then DataSmooth = 0

if ((DataSmooth gt 0) and (DataSmooth lt 2)) then DataSmooth = 2

; BACKGROUND
;
; Background density (for removal)
;
; This value is subtracted from the data

if N_Elements(_background) eq 0 then _background = 0.0


; FFT
;
; Displays Data FFT
;
; By setting this keyword (/fft) the fast fourier transform of the data is displayed
; instead of the actual data

if N_Elements(DoFFT) eq 0 then DoFFT = 0

; _SMOOTHFFT
;
; FFT Data Smoothing
;
; By setting this keyword the fft data is smoothed using the SMOOTH function with a smoothing
; parameter equal to the one specified

if N_Elements(FFTDataSmooth) eq 0 then FFTDataSmooth = 0


; FACTOR
;
; [XF,YF] Dimension reduction factor
;
; The data array dimensions are reduced by the values specified using the REBIN
; function

if N_Elements(DimFactor) eq 0 then begin
       DimFactor = [1,1]
end else begin
  s = Size(DimFactor)

  if (s[0] eq 0) then begin
    DimFactor = [DimFactor, DimFactor]
  end else begin
    if ((s[0] ne 1) or (s[1] ne 2)) then begin
      newres = Dialog_Message("Factor must be either a scalar or a two element vector! ", /Error)
      return
    end
  end
end

; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 600 x 400

if N_Elements(PlotRes) eq 0 then PlotRes = [600,400]

; Log Scale

if N_Elements(zlog) eq 0 then zlog = 0
   

; SQUARED
;
; Data^2
;
; If this keyword is set the data is squared ( Data = Data^2 )

if N_Elements(DataSquared) eq 0 then DataSquared = 0

; ABS
;
; Abs(Data)
;
; If this keyword is set the data is set to its absolute value ( Data = Abs(Data) )

if N_Elements(DataAbs) eq 0 then DataAbs = 0

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory)
  if (DirName eq '') then return
end

CD, DirName

If N_Elements(PlotTitle) eq 0 then deftitle = 1 else deftitle = 0
If N_Elements(PlotSubTitle) eq 0 then defsubtitle = 1 else defsubtitle = 0

GetOsirisMovieData2D, _EXTRA=extrakeys, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    ORIGIN = origin, DELTA = delta, EXTENSION = FIleNameExtension, $
                    DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax, $
                    DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0

; Determines the correct autoscaling for the plots

if (DataSquared le 0) then begin
  MinData = DataMin
  MaxData = DataMax
  
  if (zlog gt 0) then begin
    MinData = DataAbsMin_Non0
    MaxData = DataAbsMax  
  end else if (DataAbs gt 0) then begin
    MinData = DataAbsMin
    MaxData = DataAbsMax   
  end
  
endif else begin
  MinData = DataAbsMin^2
  MaxData = DataAbsMax^2

  if (zlog gt 0) then begin
    MinData = DataAbsMin_Non0^2
    MaxData = DataAbsMax^2  
  end
endelse

;print, 'zlog ', zlog
;print, 'AutoScaled zmax to ', MaxData
;print, 'AutoScaled zmin to ', MinData
;print, 'DataAbsMin_non0 ', DATAAbsMin_Non0
;stop

; Plot Title

if N_Elements(PlotTitle) eq 0 then deftitle = 1 else deftitle = 0
if N_Elements(PlotSubTitle) eq 0 then defSubtitle = 1 else defSubtitle = 0


; Doesn't use autoscale if limit values are supplied 

if N_Elements(_zmax) ne 0 then MaxData = _zmax
if N_Elements(_zmin) ne 0 then MinData = _zmin

; Makes the frame list

framelist = GenFrameList(DirName, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                         FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes, Dims = 2 )

framename = StrArr(NFrames)

oProgressBar = Obj_New("SHOWPROGRESS", $
                        /cancelbutton, $
                        TITLE = 'Movie', $
                        MESSAGE = 'Generating Frames...')
oProgressBar -> Start
normal_termination = 0b

; Creates a window for viewing the frames being generated

if KeyWord_Set(Show) then begin
  Window, /Free, TITLE = DirName, XSize=plotRES[0], YSize=plotRES[1]
  show_window = !D.Window
end 


for frame=0, NFrames-1 do begin
  if (oProgressBar -> CheckCancel()) then goto, end_loop

  print, ' Frame = ',frame
  
  label = 'Generating Frame '+strtrim(string(frame+1),1)+'/'+$
                strtrim(string(NFrames),1)
  
  oProgressBar -> SetLabel, label 

  framename[frame] =  "frame"+ String(byte([ byte('0') +  (frame/1000.0) mod 10 , $
                               byte('0') +  (frame/100.0)  mod 10 , $
                               byte('0') +  (frame/10.0)   mod 10 , $
                               byte('0') +  (frame/1.0)    mod 10 ])) + ".tif" 

  if (framelist[frame] ge 0) then begin
    fname1 = DataFileNames[framelist[frame]] 
    print, ' File : ', fname1
   
    ; Gets the Data  

    Osiris_Open_Data, pData1, FILE = fname1, PATH = Dirname, EXTENSION = FIleNameExtension, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData,  $
                        N = N , FORCEDIMS = 2, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, $
                        /IGNORE_DIFF

    if (oProgressBar -> CheckCancel()) then goto, end_loop
                        
    n1 = N

    ; Resizes the matrix

    if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1))  then begin

      n1[0] = n1[0] / DimFactor[0]
      n1[1] = n1[1] / DimFactor[1]

      *pData1 = Rebin(temporary(*pData1), n1[0],n1[1])
  
      XAxisData = Rebin(temporary(XAxisData), n1[0])
      YAxisData = Rebin(temporary(YAxisData), n1[1])  
    end

    ; Calculates the square and the absolute value for the data

    if (DataSquared gt 0) then begin
       *pData1 = Temporary(*pData1)^2
       Dataname = '|'+Dataname+'|^2'
    end else if (DataAbs gt 0) then begin
       *pData1 = Abs(Temporary(*pData1))
       Dataname = '|'+Dataname+'|'
    end
    
    ; Smooths the data

    if (DataSmooth ge 2) then begin
       *pData1 = Smooth(*pData1,DataSmooth,/Edge_Truncate)
    end

    if (oProgressBar -> CheckCancel()) then goto, end_loop

    ; Takes the envelope of the data

    if (doEnvelope eq 1) then begin
      envelope, pDATA, _EXTRA=extrakeys
      DataName = 'Envelope '+DataName
    end
    
    if (oProgressBar -> CheckCancel()) then goto, end_loop

    ; Calculates the FFT

    if (DoFFT gt 0) then begin
      DataName = 'FFT ('+ Dataname+')'

      deltaX = XAxisData[1]-XAxisData[0]
  
      N21x = n1[0]/2 + 1
      XAxisData = IndGen(dxN[0])
      XAxisData[N21x] = N21x - dxN[0] + FINDGEN(N21x - 2)
      XAxisData = XAxisData/(dxN[0]*deltaX)
      XAxisData = Shift(XAxisData, - N21x) 
  
      deltaY = YAxisData[1]-YAxisData[0]
      
      N21y = n1[1]/2 + 1
      YAxisData = IndGen(dxN[1])
      YAxisData[N21y] = N21y - dxN[1] + FINDGEN(N21y - 2)
      YAxisData = YAxisData/(dxN[1]*deltaY)
      YAxisData = Shift(YAxisData, - N21y) 
 
      Print, " Calculating FFT..."
      *pData1 = FFT(temporary(*pData1))
      *pData1 = Abs(temporary(*pData1))
      *pData1 = Shift(temporary(*pData1), -N21x, -N21y)  

      if (FFTDataSmooth gt 0) then begin
         if (FFTDataSmooth lt 2) then FFTDataSmooth = 2
         print, " Smoothing FFT data, window size of", FFTDataSmooth
         *pData1 = Smooth(temporary(*pData1), FFTDataSmooth,/Edge_Truncate) 
      end
    end else if (iAddCentroid) then begin ; Centroids
      print, 'Calculating ', strtrim(n_centroids, 1), ' Centroids...'
      Centroid, *pData1, centroid_vert, cpoints, DIRECTION = CentroidDir[0], MINVAL = CentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData
      for i=1, n_centroids-1 do begin
        Centroid, *pData1, centroid_vert2, cpoints2, DIRECTION = CentroidDir[i], MINVAL = CentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData
        combine_polyline, centroid_vert, cpoints, centroid_vert2, cpoints2
      end
      print, 'Done'
    end
    
    if (oProgressBar -> CheckCancel()) then goto, end_loop

    if (deftitle eq 1) then $
       PlotTitle = DataName

    if (defSubtitle eq 1) then $
       PlotSubTitle = 'Time = ' + String( time ,Format='(f8.2)') + ' [ '+time_units+' ]'

    XAxisTitle = x1label
    if (x1unit ne '') then XAxisTitle = XAxisTitle +' ['+x1unit+']'

    YAxisTitle = x2label
    if (x2unit ne '') then YAxisTitle = YAxisTitle+' ['+x2unit+']'

    _MinData = MinData
    _MaxData = MaxData

    if ((DoFFT eq 0) and (iAddCentroid)) then begin

        Plot2D,      pData1, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     ZMIN = _MinData, ZMAX = _MaxData, ZLOG = zlog, $
                     XRANGE = _xrange, YRANGE = _yrange, $
                     TRAJVERT = centroid_vert, TRAJPOINTS = cpoints, $
                     FILEOUT = framename[frame],  IMAGE = img24


     end else begin

        Plot2D,      pData1, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     ZMIN = _MinData, ZMAX = _MaxData, ZLOG = zlog, $
                     XRANGE = _xrange, YRANGE = _yrange, $
                     FILEOUT = framename[frame],  IMAGE = img24

    end
 
    ; Free pointer
    
    ptr_free, pData1 
        
  end else begin
    print, 'Missing Data, writing blank frame'
    img24 = BytArr(3, plotRES[0], plotRES[1])
    WRITE_TIFF, framename[frame], img24
  end

  if KeyWord_Set(Show) then begin
    tvimage, img24
  end 

  img24 = 0b
                 
  print, "Finished frame ",frame  
    
  if (oProgressBar -> CheckCancel()) then goto, end_loop
  oProgressBar -> Update, (100.0*frame)/(NFrames-1)
end

normal_termination = 1b

end_loop:

; free pointer in case we got here without through termination
ptr_free, pData1 

oProgressBar -> Destroy
Obj_Destroy, oProgressBar

if KeyWord_Set(Show) then begin
  wdelete, show_window
end 

if (normal_termination eq 1b) then begin

  ;XINTERANIMATE

  if Keyword_Set(XAnimate) then begin
    Frame2Movie, DIRECTORY = DirName, FILES = framename, /tiff
  end

  Print, " Done! "
end else begin
  Print, 'Interrupted!'
end


END