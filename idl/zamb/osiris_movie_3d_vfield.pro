
;
;  Program:  
;
;  Osiris_Movie_3D_VField
;
;  Description:
;
;  Opens data output from the osiris code (3D vector field) and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_3D_vfield, _EXTRA=extrakeys, $
             ; Directory and file information
             DIRECTORY1 = DirName1, DIRECTORY2 = DirName2, DIRECTORY3 = DirName3, $
             ; Data operations
             FACTOR = DimFactor, SMOOTH = DataSmooth, $
             ; Data Ranges
             LREF = _lref, MAX = _Max, MIN = _Min, $
             ; Titles and Labels         
             XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
             ; Image options
             SHOW = Show, $
             ; Movie options
             IT0 = t0, IT1 = t1, $
             ; Use XInterAnimate
             XANIMATE = XAnimate
                      

; **************************************************************************************************** Parameters

; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'


if N_Elements(XAxisTitle) eq 0 then XAxisTitle = ''
if N_Elements(YAxisTitle) eq 0 then YAxisTitle = ''
if N_Elements(ZAxisTitle) eq 0 then ZAxisTitle = ''

; SMOOTH
;
; Smoothing factor for the data

if N_Elements(DataSmooth) eq 0 then DataSmooth = 0


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

; DIRNAME[123]
;
; Directory names for the field components. If not supplied the program prompts the user for 
; them  
    
if N_Elements(DirName1) eq 0 then begin  
  DirName1 = Dialog_PickFile(/Directory, TITLE = 'Select First Vector Component')
  if (DirName1 eq '') then return
end

if N_Elements(DirName2) eq 0 then begin  
  DirName2 = Dialog_PickFile(/Directory, TITLE = 'Select Second Vector Component')
  if (DirName2 eq '') then return
end

if N_Elements(DirName3) eq 0 then begin  
  DirName3 = Dialog_PickFile(/Directory, TITLE = 'Select Third Vector Component')
  if (DirName3 eq '') then return
end


; ------------------------ Get Movie Data -----------------------------------------

CD, DirName1

GetOsirisMovieData, DIRECTORY = DirName1, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames1, FILENAME = DataFileNames1,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAABSMAX = DATAMax1, DATAABSMIN = DATAMin1
                    
CD, DirName2

GetOsirisMovieData, DIRECTORY = DirName2, /Silent,$
                      DATANAME = datanames2, FILENAME = DataFileNames2,$
                      DATAABSMAX = DATAMax2, DATAABSMIN = DATAMin2

CD, DirName3

GetOsirisMovieData, DIRECTORY = DirName3, /Silent,$
                      DATANAME = datanames3, FILENAME = DataFileNames3,$
                      DATAABSMAX = DATAMax3, DATAABSMIN = DATAMin3

                      
DataName = '('+DataNames1[0]+','+DataNames2[0]+','+DataNames3[0]+')'

; ------------------------ Set Reference Values -----------------------------------

MinData = Min([DataMin1, DataMin2, DataMin3])
MaxData = Max([DataMax1, DataMax2, DataMax3])
Lref = MaxData

; Doesn't use autoscale if limit values are supplied 

if N_Elements(_Max) ne 0 then MaxData = _Max
if N_Elements(_Min) ne 0 then MinData = _Min
if N_Elements(_Lref) ne 0 then lref = _lref


print, 'Data Limits :'
print, '-----------------------------------'
print, 'Max  = ', MaxData
print, 'Min  = ', MinData
print, 'LREF = ', lref

; Generate the frame lists

framelist1 = GenFrameList(DirName1, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                          FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes )

framelist2 = GenFrameList(DirName2, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                          FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes )

framelist3 = GenFrameList(DirName3, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                          FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes )

; Creates a window for viewing the frames being generated

if KeyWord_Set(Show) then begin
  Window, /Free, TITLE = DirName, XSize=plotRES[0], YSize=plotRES[1]
end 


; Makes the frames

framename = StrArr(NFrames)

for frame=0, NFrames-1 do begin
  print, ' Frame = ',frame

  framename[frame] =  "frame"+ String(byte([ byte('0') +  (frame/1000.0) mod 10 , $
                               byte('0') +  (frame/100.0)  mod 10 , $
                               byte('0') +  (frame/10.0)   mod 10 , $
                               byte('0') +  (frame/1.0)    mod 10 ])) + ".tiff" 

  
  if (framelist1[frame] ge 0) and $
     (framelist2[frame] ge 0) and $
     (framelist3[frame] ge 0) then begin
  
    print, 'Reading Data...'

    fname1 = DataFileNames1[framelist1[frame]] 
    fname2 = DataFileNames2[framelist2[frame]] 
    fname3 = DataFileNames3[framelist3[frame]] 


    Osiris_Open_Data, pData, DATASETSNUMBER = 3, $
                        FILE = [fname1,fname2,fname3], $
                        PATH = [Dirname1,Dirname2,Dirname3], $
                        DIM = Dims, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData,  $
                        N = N, FORCEDIMS = 3, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, $
                        ZLABEL = x3label, ZUNITS = x3unit, /IGNORE_DIFF
    print, 'done'


    n1 = N
    
    ; Removes Border Cells
  
    if (BorderCells gt 0) then begin
      i = BorderCells
      *(pData[0])= temporary((*(pData[0]))[i:n1[0]-1-i,i:n1[1]-1-i,i:n1[2]-1-i])
      *(pData[1])= temporary((*(pData[1]))[i:n1[0]-1-i,i:n1[1]-1-i,i:n1[2]-1-i])
      *(pData[2])= temporary((*(pData[2]))[i:n1[0]-1-i,i:n1[1]-1-i,i:n1[2]-1-i])
      
      XAxisData = temporary(XAxisData[i:n1[0]-1-i])
      YAxisData = temporary(YAxisData[i:n1[1]-1-i])
      ZAxisData = temporary(ZAxisData[i:n1[2]-1-i])
      n1 = n1 - 2* BorderCells    
    end
  
    ; Resizes the matrix

    if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1) or (DimFactor[2] gt 1))  then begin
  
      n1[0] = n1[0] / DimFactor[0]
      n1[1] = n1[1] / DimFactor[1]
      n1[2] = n1[2] / DimFactor[2]

      *(pData[0]) = Rebin(*(pData[0]), n1[0],n1[1],n1[2])
      *(pData[1]) = Rebin(*(pData[1]), n1[0],n1[1],n1[2])
      *(pData[2]) = Rebin(*(pData[2]), n1[0],n1[1],n1[2])
 
      XAxisData = Rebin(XAxisData, n1[0])
      YAxisData = Rebin(YAxisData, n1[1])  
      ZAxisData = Rebin(ZAxisData, n1[2])  

    end

    ; Smooths the data

    if (DataSmooth ge 2) then begin
       *(pData[0]) = Smooth(*(pData[0]),DataSmooth,/Edge_Truncate)
       *(pData[1]) = Smooth(*(pData[1]),DataSmooth,/Edge_Truncate)
       *(pData[2]) = Smooth(*(pData[2]),DataSmooth,/Edge_Truncate)
    end

    if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName1

    PlotSubTitle = 'Time = ' + String( time ,Format='(f7.2)') + ' [ 1 / !Mw!Dp!N ]'

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

    ; Return to first dir

    cd, dirname1
  
    _MinData = MinData
    _MaxData = MaxData
    _LReference = Lref

    Plot3Dvector,  pData, FILEOUT = framename[frame] ,YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
               TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, $
               _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
               RES = plotRES, MAX = _MaxData, MIN = _MinData, Lref = _LREFERENCE, IMAGE = img24, $
               PMIN = ProjMin, PMAX = ProjMax 

    ptr_free, pData
     
    print, "Finished frame ",frame
  end else begin
    print, 'Missing Data, writing blank frame'
    img24 = BytArr(3, plotRES[0], plotRES[1])
    WRITE_TIFF, framename[frame], img24
  end 
  
  if KeyWord_Set(Show) then begin
    tvimage, img24
  end 

  img24 = 0
     
  print, "Finished frame ",frame 
  
  ; clear any memory leaks
  
  ptr_free, ptr_valid()
end


Print, " Done! "

END