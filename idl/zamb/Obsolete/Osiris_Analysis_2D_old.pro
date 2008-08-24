
;
;  Program:
;
;  Osiris_Analysis_2D
;
;  Description:
;
;  Opens data output from the osiris code and plots it
;
;  Current Version:
;
;    0.9 : Added BACKGROUND and _SMOOTHFFT functionality. The program now calls OsirisOpenData to get
;          the osiris data file
;
;  History:
;
;    0.8 : Added FACTOR and FFT functionality. The program now checks the dimensions of the data
;          from the output of AnaliseDx. Added automatic device decomposition selection.
;    0.7 : Added SMOOTH, SQUARED, ABS functionality. Added RES functionality
;    0.6 : Moved the data explorer analisis and plotting routines to their own files/procedures
;          Corrected minor bugs
;    0.5 : Major change in display routine. Now using TVImage for the output, for greater speed and
;          color depth
;    0.3 : Now opens '*.dx' files for information on data file, grid size, time information
;    0.2 : Added color scale
;    0.1 : Working, opens data file directly, plots using the contour function
;
;  Known bugs:
;
;    All bugs detected so far have been corrected
;

PRO Osiris_Analysis_2D,_EXTRA=extrakeys, OLD = old, $
                     ; Directory and file information
                     FILE = FileName, PATH = filepath, EXTENSION = FileNameExtension, DX = useDX, $
                     ; Data operations
                     FFT = DoFFT, SQUARED = DataSquared, ABS = DataAbs,  BACKGROUND = _background, $
                     SMOOTH = SmoothFact, _SMOOTHFFT = FFTDataSmooth, FACTOR = DimFactor, $
                     ADDDATASETS = AddData, ADDFILENAMES = AddFilenames, NORMALIZE = normalize, $
                     ; Axis Ranges
                     XRANGE = xrange, YRANGE = yrange, $
                     ; Plot options
                     RES = PlotRes,  PSFILE = psfilename, $
                     ; Titles and labels
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units, $
                     ; Laser Operation
                     ENVELOPE = doEnvelope, $
                     ; Centroid Operation
                     CENTROIDS = CentroidDir, CENTMINVAL = CentroidMinVal

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

; PSFILE
;
; Outputs the plot to a PS file
;
; Set this parameter to the name of the PS you want to output your data to

if N_Elements(psfilename) eq 0 then useps = 0 $
else useps = 1

; BACKGROUND
;
; Background density (for removal)
;
; This value is subtracted from the data

if N_Elements(_background) eq 0 then _background = 0.0

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
      newres = Dialog_Message('Factor must be either a scalar or a two element vector! ',$
                              TITLE = 'Osiris Analysis 2D', /Error)
      return
    end
  end
end

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

; EXTENSION
;
; Data Filename Extension
;
; The data

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

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


; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 640 x 480

if N_Elements(PlotRes) eq 0 then begin
;   if (usePS eq 0) then PlotRes = [600,400] $
;   else PlotRes = [10,10]
   if keyword_set(usePS) then PlotRes = [10,10]
end

; ADDDATA
;
; Adds other datasets
;
; Set this parameter to the number of other datasets to add do the main data set

if N_Elements(AddData) eq 0 then AddData = 0


; **************************************************************************************************** Main Code

; Graphic display Initialization

Device, Get_Visual_Depth = thisDepth
If (thisDepth GT 8) Then Device, Decomposed = 0

; Gets the Data

Osiris_Open_Data, pData, FILE = filename, DIM = Dims, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData, PATH = filepath, EXTENSION = FileNameExtension,$
                        N = dxN, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, DX = UseDX, FORCEDIMS = 2


if (pData eq PTR_NEW()) then return


; ADDFILENAMES
;
; Filenames of other datasets to add
;
; Set this parameter with the filenames of the datasets to add
; This parameter must be a 1D string array with a number of elements equal to the ADDDATA parameter

If N_Elements(AddFilenames) eq 0 then begin
  if (AddData gt 0) then begin
    AddFileNames = StrArr(AddData)
    AddPaths = StrArr(AddData)
    for i = 0, AddData - 1 do begin
      DialogTitle = "Select Additonal Dataset " + String(i+1,Format='(I1)')
      AddFileNames[i] = Dialog_Pickfile(FILTER='*.dx', TITLE = DialogTitle, GET_PATH = temp)
      if (AddFilenames[i] eq '') then return
      AddPaths[i] = temp
    end
  end
endif else begin
  s = size(AddFilenames)
  AddPaths =Make_Array(s[1],/string, Value = ' ')
endelse


; Reads Additional Data

if (AddData gt 0) then begin
  pData_Add = PtrArr(AddData)
  Data_Add_Names = StrArr(AddData)
  for i=0, AddData - 1 do begin

    Osiris_Open_Data, pData0, FILE = AddFilenames[i], DIM = Dims, DATATITLE = tempname, PATH = AddPaths[i], $
                             EXTENSION = FileNameExtension, N = dxN

    Data_Add_Names[i] = tempname

    ; Checks The Dimensions on the data

    if (Dims ne 2) then begin
      newres = Dialog_Message(" Data is not 2-Dimensional! ", /Error)
      return
    end

    pData_Add[i] = pData0

  end

  cd, filepath
endif

; Resizes the matrix

if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1))  then begin

  dxN[0] = dxN[0] / DimFactor[0]
  dxN[1] = dxN[1] / DimFactor[1]

  *pData = Rebin(*pData, dxN[0],dxN[1])
  XAxisData = Rebin(XAxisData, dxN[0])
  YAxisData = Rebin(YAxisData, dxN[1])

  if (AddData gt 0) then *pData_Add[*] = Rebin(*pData_Add[*], dxN[0],dxN[1])

end

; Removes the background

*pData = temporary(*pData) - _background

if (AddData gt 0) then *pData_Add[*] = temporary(*pData_Add[*]) - _background

; If necessary abs or ^2 data

if (DataSquared gt 0) then begin
   *pData = temporary(*pData)^2
   DataName = "|"+DataName+"|^2"
   if (AddData gt 0) then begin
       *pData_Add[*] = temporary(*pData_Add[*]) ^ 2
       Data_Add_Names = "|"+Data_Add_Names+"|^2"
   end
endif else if (DataAbs gt 0) then begin
   *pData = Abs(temporary(*pData))
   DataName = "|"+DataName+"|"
   if (AddData gt 0) then begin
       *pData_Add[*] = abs(temporary(*pData_Add[*]))
       Data_Add_Names = "|"+Data_Add_Names+"|"
   end

endif

; SMOOTH
;
; Data Smoothing

If N_Elements(SmoothFact) ne 0 then begin
     if (SmoothFact lt 3) then SmoothFact = 3
end else smoothfact = 0

if (smoothfact) gt 0 then *pData =  Smooth(*pData, SmoothFact,/Edge_Truncate)



; Sums over all the datasets

if (AddData gt 0) then begin
  for i= 0, AddData -1 do begin
    if (smoothfact) gt 0 then $
      *pData_Add[i] =  Smooth(*pData_Add[i], SmoothFact,/Edge_Truncate, /NAN)
    *pData = temporary(*pData) + *pData_Add[i]
    DataName = DataName + '+' + Data_Add_Names
  end
  Ptr_Free, pData_Add
  Data_Add_Names = 0
end

; Takes the envelope of the data

if (doEnvelope eq 1) then begin
      envelope, pDATA, _EXTRA=extrakeys
      DataName = 'Envelope '+DataName
end

; If necessary does an FFT of the data

if (DoFFT gt 0) then begin

  DataName = 'FFT ('+ Dataname+')'

  deltaX = XAxisData[1]-XAxisData[0]

  N21x = dxN[0]/2 + 1
  XAxisData = IndGen(dxN[0])
  XAxisData[N21x] = N21x - dxN[0] + FINDGEN(N21x - 2)
  XAxisData = 2.0*!PI*XAxisData/(dxN[0]*deltaX)
  XAxisData = Shift(XAxisData, - N21x)

  deltaY = YAxisData[1]-YAxisData[0]

  N21y = dxN[1]/2 + 1
  YAxisData = IndGen(dxN[1])
  YAxisData[N21y] = N21y - dxN[1] + FINDGEN(N21y - 2)
  YAxisData = 2.0*!PI*YAxisData/(dxN[1]*deltaY)
  YAxisData = Shift(YAxisData, - N21y)

  Print, " Calculating FFT..."

  *pData = FFT(*pData,/overwrite)
  *pData = Shift(*pData, -N21x, -N21y)
  *pData = Abs(temporary(*pData))

  if (FFTDataSmooth gt 0) then begin
     if (FFTDataSmooth lt 2) then FFTDataSmooth = 2
     print, " Smoothing FFT data, window size of", FFTDataSmooth
     *pData = Smooth(*pData, FFTDataSmooth,/Edge_Truncate)
  end

end else if (iAddCentroid) then begin ; Centroids

  print, 'Calculating ', strtrim(n_centroids, 1), ' Centroids...'
  Centroid, *pData, centroid_vert, cpoints, DIRECTION = CentroidDir[0], MINVAL = CentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData
  
  for i=1, n_centroids-1 do begin
    Centroid, *pData, centroid_vert2, cpoints2, DIRECTION = CentroidDir[i], MINVAL = CentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData
    combine_polyline, centroid_vert, cpoints, centroid_vert2, cpoints2
  end
                           
  print, 'Done'
end

; If necessary normalizes the data

if Keyword_Set(normalize) then begin
  max_val = max(abs(*pData))
  *pData = temporary(*pData) / max_val
end


if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName

if N_Elements(PlotSubTitle) eq 0 then $
   PlotSubTitle = "Time = " + String(Time,Format='(f8.2)') + ' [ '+time_units+' ]'

if N_Elements(XAxisTitle) eq 0 then begin
   XAxisTitle = x1label
   if (x1unit ne '') then XAxisTitle = XAxisTitle +' ['+x1unit+']'
end

if N_Elements(YAxisTitle) eq 0 then begin
   YAxisTitle = x2label
   if (x2unit ne '') then YAxisTitle = YAxisTitle+' ['+x2unit+']'
end

if N_Elements(ZAxisTitle) eq 0 then begin
   ZAxisTitle = DataLabel
   if (units ne '') then ZAxisTitle = ZAxisTitle+' ['+units+']'
end

Print, " Plotting 2D Data..."

; Opens new graphics window or PS file



if (useps eq 0) then begin
   if (Keyword_Set(old)) then Window, /Free, Title = filename[0], Xsize = PlotRes[0], Ysize =PlotRes[1]
end else begin
   thisDevice = !D.Name
   Set_Plot, 'PS'

   print, ' About to configure PS device '

   Device, Color=1, Bits_per_Pixel=8, File= psfilename, Xsize = PlotRes[0], Ysize =PlotRes[1]
end


; Plots the data (finally)


if ((DoFFT eq 0) and (iAddCentroid)) then begin

; Draw centroids
if (Keyword_Set(old)) then begin

        Plot2D_old,      pData, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     XRANGE = xrange, YRANGE = yrange, WINDOWTITLE = filename[0], $
                     TRAJVERT = centroid_vert, TRAJPOINTS = cpoints
end else begin

        Plot2D,      pData, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     XRANGE = xrange, YRANGE = yrange, WINDOWTITLE = filename[0], $
                     TRAJVERT = centroid_vert, TRAJPOINTS = cpoints, /no_share
end

end else begin

if (Keyword_Set(old)) then begin
        Plot2D_old,      pData, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     XRANGE = xrange, YRANGE = yrange, WINDOWTITLE = filename[0]
endif else begin
        Plot2D,      pData, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     XRANGE = xrange, YRANGE = yrange, WINDOWTITLE = filename[0], /no_share
endelse 

end


; Closes the PS file if necessary

if (useps eq 1) then begin
   Device, /Close_File
   Set_Plot, thisDevice
end

Print, "Plot Concluded"


END
