
;
;  Program:
;
;  Osiris_Analysis_3D
;
;  Description:
;
;  Opens data output from the osiris code and plots it
;
;  Current Version:
;
;  History:
;
;
;  Known bugs:
;
;    All bugs detected so far have been corrected
;

PRO Osiris_Analysis_3D, _EXTRA=extrakeys, $
                     ; File information
                     FILE = filename, PATH = filepath, DX = useDX, $
                     ; Data Operations
                     SQUARED = DataSquared, SMOOTH = DataSmooth, RES = PlotRes, $
                     FFT = DoFFT,  FACTOR = DimFactor, ABS = DataAbs, BACKGROUND = _background, $
                     _SMOOTHFFT = FFTDataSmooth, BORDER = borderCells, $
             ;        SMOOTHDIR = smoothdir, $
                     ; Additional Datasets
                     ADDDATASETS = AddData, ADDFILENAMES = AddFilenames, $
                     DATA2 = UseData2, D2FILE = filename2, $
                     ; Axis Ranges
                     XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                     ; Titles and Labels
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle,  TIME_UNITS = time_units, $
                     ; Data Ranges
                     MIN = DataMin, MAX = DataMax, PMIN = ProjMin, PMAX = ProjMax,  $
                     ; Laser Operation
                     ENVELOPE = doEnvelope, $
                     ; Centroid Operation
                     CENTROIDS = CentroidDir, CENTMINVAL = CentroidMinVal, $
                     ; Slicer Operation
                     SLICER = SLICER

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
; Calculate a mass centroid. Set this parameter to the direction of the centroid (0,1 or 2)
; When looking at laser fields this algorithm is only effective with laser envelopes. If the data
; is not already an envelope you should use the ENVELOPE keyword. Also see Osiris_Gen_Envelope.pro
; and envelope.pro

if N_Elements(CentroidDir) eq 0 then begin
     CentroidDir = -1
end else begin
     if N_Elements(xrange) ne 0 or N_Elements(yrange) ne 0 or N_Elements(zrange) ne 0 then begin
       print, 'WARNING, Osiris_Analysis_3D, Taking a centroid of a subrange of data may give erroneous results'
     end
end

; BORDER
;
; number of border cells to remove

if N_Elements(borderCells) eq 0 then borderCells = 0

; BACKGROUND
;
; Background density (for removal)
;
; This value is subtracted from the data

if N_Elements(_background) eq 0 then _background = 0.0

; FACTOR
;
; [XF,YF,ZF] Dimension reduction factor
;
; The data array dimensions are reduced by the values specified using the REBIN
; function

if N_Elements(DimFactor) eq 0 then begin
       DimFactor = [1,1,1]
end else begin
  s = Size(DimFactor)

  if (s[0] eq 0) then begin
    DimFactor = [DimFactor, DimFactor, DimFactor]
  end else begin
    if ((s[0] ne 1) or (s[1] ne 3)) then begin
      newres = Dialog_Message("Factor must be either a scalar or a three element vector! ", /Error)
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

; FILENAME
;
; Osiris '*.dx, *.hdf' file to open
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename

if Keyword_Set(UseDX) then filter = '*.dx' else filter = '*.hdf'

if N_Elements(FileName) eq 0 then begin
  filename=Dialog_Pickfile(FILTER=filter, GET_PATH = filepath)
  if (filename eq '') then return
end

; DATA2
;
; Plot 2 datasets

if KeyWord_Set(UseData2) then UseData2 = 1 else UseData2 = 0

; D2FILENAME
;
; filename of the second dataset to open. Note, if specified there is no need to set the DATA2 keyword

if N_Elements(FileName2) eq 0 then begin
  if (UseData2 eq 1) then begin
    filename2=Dialog_Pickfile(TITLE = 'Choose 2nd DataSet',FILTER=filter, GET_PATH = filepath2)
    if (filename2 eq '') then return
  end
end else UseData2 = 1

; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 600 x 600

if N_Elements(PlotRes) eq 0 then PlotRes = [600,600]

; ADDDATA
;
; Adds other datasets
;
; Set this parameter to the number of other datasets to add do the main data set

if N_Elements(AddData) eq 0 then AddData = 0

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
      DialogTitle = 'Select Additonal Dataset ' + String(i+1,Format='(I1)')
      AddFileNames[i] = Dialog_Pickfile(FILTER=filter, TITLE = DialogTitle, GET_PATH = temp)
      if (AddFilenames[i] eq '') then return
      AddPaths[i] = temp
    end
  end
endif else begin
  s = size(AddFilenames)
  AddPaths =Make_Array(s[1],/string, Value = ' ')
endelse

; **************************************************************************************************** Main Code

; Gets the Data

Osiris_Open_Data, pData, FILE = filename, DIM = Dims, TIMEPHYS = time, $
                        XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, PATH = filepath, $
                        N = dxN, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, $
                        ZLABEL = x3label, ZUNITS = x3unit

; Checks The Dimensions on the data

if (Dims ne 3) then begin
  newres = Dialog_Message(" Data is not 3-Dimensional! ", /Error)
  return
end

; Reads Additional Data

if (UseData2 eq 1) then begin

  Osiris_Open_Data, pData2, FILE = filename2, N = dxN2, DATATITLE = dataname2, PATH = filepath2, $
                           XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange

    if ( (dxN[0] ne dxN2[0]) or $
         (dxN[1] ne dxN2[1]) or $
         (dxN[2] ne dxN2[2]) ) then begin

      newres = Dialog_Message('2nd dataset must have the same dimensions as the original data ', /Error)
      print, 'dxN' , dxN
      print, 'dxN2' , dxN2

      return

    end

end else if (AddData gt 0) then begin
  pData_Add = PtrArr(AddData)
  Data_Add_Names = StrArr(AddData)
  for i=0, AddData - 1 do begin

    Osiris_Open_Data, pData0, FILE = AddFilenames[i], DIM = Dims, DATATITLE = tempname, PATH = AddPaths[i], $
                             EXTENSION = FileNameExtension, N = dxNAdd, $
                             XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange

    Data_Add_Names[i] = tempname

    ; Checks The Dimensions on the data

    if (Dims ne 3) then begin
      newres = Dialog_Message(" Data is not 3-Dimensional! ", /Error)
      return
    end

    if ( (dxN[0] ne dxNAdd[0]) or $
         (dxN[1] ne dxNAdd[1]) or $
         (dxN[2] ne dxNAdd[2]) ) then begin

      newres = Dialog_Message(" Data to be added must have the same dimensions as the original data ", /Error)
      return

    end

    pData_Add[i] = pData0


  end
  ;help, filepath
  cd, filepath[0]
endif

; Removes Border Cells

if (BorderCells gt 0) then begin
    i = BorderCells
    *pData = temporary( (*pData)[i:dxN[0]-1-i,i:dxN[1]-1-i,i:dxN[2]-1-i] )
    XAxisData = XAxisData[i:dxN[0]-1-i]
    YAxisData = YAxisData[i:dxN[1]-1-i]
    ZAxisData = ZAxisData[i:dxN[2]-1-i]

    if (UseData2 eq 1) then  *pData2 = temporary((*pData2)[i:dxN[0]-1-i,i:dxN[1]-1-i,i:dxN[2]-1-i])
    if (AddData gt 0) then *pData_Add[*] = temporary( (*(pData_Add[*]))[i:dxN[0]-1-i,i:dxN[1]-1-i,i:dxN[2]-1-i])

    dxN = dxN - 2* BorderCells
end


; Resizes the matrix

if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1) or (DimFactor[2] gt 1))  then begin

  dxN[0] = dxN[0] / DimFactor[0]
  dxN[1] = dxN[1] / DimFactor[1]
  dxN[2] = dxN[2] / DimFactor[2]

  print, 'New Dimensions, ',dxN

  *pData = Rebin(temporary(*pData), dxN[0],dxN[1],dxN[2])
  XAxisData = Rebin(XAxisData, dxN[0])
  YAxisData = Rebin(YAxisData, dxN[1])
  ZAxisData = Rebin(ZAxisData, dxN[2])

  if (UseData2 eq 1) then  *pData2 = Rebin(temporary(*pData2), dxN[0],dxN[1],dxN[2])
  if (AddData gt 0) then *(pData_Add[*]) = Rebin(temporary(*(pData_Add[*])), dxN[0],dxN[1],dxN[2])

end

; Removes the background

if (_background ne 0.0) then begin
  print, 'Removing a background value of ', _background
  *pData = temporary(*pData) - _background
end

if (UseData2 eq 1) then  *pData2 = temporary(*pData2) - _background
if (AddData gt 0) then *pData_Add = temporary(*pData_Add) - _background

; Data Smoothing

if N_Elements(DataSmooth) eq 0 then DataSmooth = 0
if (DataSmooth eq 1) then DataSmooth = 2

if (DataSmooth ge 2) then begin
   print, 'Osiris_Analysis_3D, smoothing data, window ',DataSmooth
   *pData = Smooth(*pData,DataSmooth,/Edge_Truncate)

   if (UseData2 eq 1) then  *pData2 = Smooth(*pData2,DataSmooth,/Edge_Truncate)
   if (AddData gt 0) then begin
     for i= 0, AddData -1 do *pData_Add[i] = Smooth(*(pData_Add[i]),DataSmooth,/Edge_Truncate)
   end

end

; If necessary abs or ^2 data

if (DataSquared gt 0) then begin
   *pData = temporary(*pData)^2
   DataName = "|"+DataName+"|^2"

   if (UseData2 eq 1) then begin
     *pData2 = temporary(*pData2) ^2
     *pDataName2 = "|"+DataName2+"|^2"
   end

   if (AddData gt 0) then begin
       *pData_Add[*] = temporary(*pData_Add[*]) ^ 2
       Data_Add_Names = "|"+Data_Add_Names+"|^2"
   end
endif else if (DataAbs gt 0) then begin
   *pData = Abs(temporary(*pData))
   DataName = "|"+DataName+"|"

   if (UseData2 eq 1) then begin
     *pData2 = abs(temporary(*pData2))
     DataName2 = "|"+DataName2+"|"
   end

   if (AddData gt 0) then begin
       *pData_Add[*] = abs(temporary(*pData_Add[*]))
       Data_Add_Names = "|"+Data_Add_Names+"|"
   end

endif

; Sums over all the datasets

if (AddData gt 0) then begin
  for i= 0, AddData -1 do begin
    *pData = temporary(*pData) + *pData_Add[i]
    Ptr_Free,pData_Add[i]
    DataName = DataName + '+' + Data_Add_Names
  end
  Data_Add_Names = 0
end

; Takes the envelope of the data

if (doEnvelope eq 1) then begin
    envelope, pDATA, _EXTRA=extrakeys
    DataName = 'Envelope '+DataName
    if (UseData2 eq 1) then begin
       envelope, pDATA2, _EXTRA=extrakeys
    end
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

  deltaZ = ZAxisData[1]-ZAxisData[0]

  N21z = dxN[2]/2 + 1
  ZAxisData = IndGen(dxN[2])
  ZAxisData[N21z] = N21z - dxN[2] + FINDGEN(N21z - 2)
  ZAxisData = 2.0*!PI*ZAxisData/(dxN[2]*deltaZ)
  ZAxisData = Shift(ZAxisData, - N21z)


  Print, " Calculating FFT..."

  *pData = FFT(*pData, /overwrite)
  *pData = Abs(temporary(*pData))
  *pData = Shift(*pData, -N21x, -N21y, -N21z)

  if (UseData2 eq 1) then begin
    *pData2 = Abs(FFT(*pData2, /overwrite))
    *pData2 = Shift(*pData2, -N21x, -N21y, -N21z)
  end

  if (FFTDataSmooth gt 0) then begin
     if (FFTDataSmooth lt 2) then FFTDataSmooth = 2
     print, " Smoothing FFT data, window size of", FFTDataSmooth
     *pData = Smooth(*pData, FFTDataSmooth,/Edge_Truncate)
     if (UseData2 eq 1) then begin
       *pData2 = Smooth(*pData2, FFTDataSmooth,/Edge_Truncate)
     end
  end

end else if (CentroidDir ge 0) and (CentroidDir le 2) then begin ; Centroids

  print, 'Calculating Centroids...'
  Centroid, *pData, centroid_vert, cpoints, DIRECTION = CentroidDir, MINVAL = LaserCentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData

  if (UseData2 eq 1) then begin
     Centroid, *pData2, centroid2_vert, cpoints2, DIRECTION = CentroidDir, MINVAL = LaserCentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData

  end


  print, 'Done'
end

if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName

if N_Elements(PlotSubTitle) eq 0 then PlotSubTitle = 'Time = ' + String(Time,Format='(f7.2)') + ' [ '+time_units+' ]'

if N_Elements(XAxisTitle) eq 0 then begin
   XAxisTitle = x1label
   if (x1unit ne '') then XAxisTitle = XAxisTitle +' ['+x1unit+']'
end

if N_Elements(YAxisTitle) eq 0 then begin
   YAxisTitle = x2label
   if (x2unit ne '') then YAxisTitle = YAxisTitle+' ['+x2unit+']'
end

if N_Elements(ZAxisTitle) eq 0 then begin
   ZAxisTitle = x3Label
   if (x3unit ne '') then ZAxisTitle = ZAxisTitle+' ['+x3unit+']'
end

Print, " Plotting 3D Data..."

; Plots the data (finally)

if (Keyword_Set(Slicer)) then begin
  
    Slicer3D,   _EXTRA=extrakeys, pData, YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
                 TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, RES = PlotRES, $
                 XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                 MIN = DataMin, MAX = DataMax

end else begin

if ((DoFFT eq 0) and (CentroidDir ge 0) and (CentroidDir le 2)) then begin
 
    Plot3D,      pData, YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
                 TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, RES = PlotRES, $
                 _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                 MIN = DataMin, MAX = DataMax, PMIN = ProjMin, PMAX = ProjMax ,  $
                 XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                 TRAJVERT = centroid_vert, TRAJPOINTS = cpoints, /TRAJPROJ,$
                 DATA2 = pData2, TRAJ2VERT = centroid2_vert, TRAJ2POINTS = cpoints2, /TRAJ2PROJ


end else begin

    Plot3D,      pData, YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
                 TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, RES = PlotRES, $
                 _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                 MIN = DataMin, MAX = DataMax, PMIN = ProjMin, PMAX = ProjMax , $
                 XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, DATA2 = pData2

end
ptr_free, pData

end

if (UseData2 eq 1) then ptr_free, pData2

Print, "Plot Concluded"


END
