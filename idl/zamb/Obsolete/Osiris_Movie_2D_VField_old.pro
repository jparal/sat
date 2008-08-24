
;
;  Program:  
;
;  Osiris_Movie_2D_VField
;
;  Description:
;
;  Opens data output from the osiris code (2D vector field) and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_2D_vfield, _EXTRA=extrakeys, $
              ; Directory and file information
              DIRECTORY1 = DirName1, DIRECTORY2 = DirName2, EXTENSION = FileNameExtension, $
              ; Data operations
              FACTOR = DimFactor, SMOOTH = DataSmooth, $
              ; Titles and labels 
              XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, TIME_UNITS = time_units, $
              ; Data Ranges
              ZMAX = _zmax, ZMIN = _zmin, $
              ; Visualization options
              RES = winRes, XANIMATE = XAnimate        

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
      newres = Dialog_Message("FACTOR must be either a scalar or a two element vector! ", /Error)
      return
    end
  end
end


; Size

if N_Elements(winRes) eq 0 then winRes = [600,450]


; Call XAnimate
   
if N_Elements(noXAnimate) eq 0 then noXAnimate = 0
   
    
if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""


if N_Elements(DirName1) eq 0 then begin  
  DirName1 = Dialog_PickFile(/Directory, TITLE = 'Select First Vector Component')
  if (DirName1 eq '') then return
end

if N_Elements(DirName2) eq 0 then begin  
  DirName2 = Dialog_PickFile(/Directory, TITLE = 'Select Second Vector Component')
  if (DirName2 eq '') then return
end

; ------------------------ Get Movie Data -----------------------------------------

CD, DirName1

GetOsirisMovieData2D, DIRECTORY = DirName1, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames1, FILENAME = DataFileNames1,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAABSMAX = DATAMax1, DATAABSMIN = DATAMin1
                    
CD, DirName2

GetOsirisMovieData2D, DIRECTORY = DirName2, /Silent,$
                      DATANAME = datanames2, FILENAME = DataFileNames2,$
                      DATAABSMAX = DATAMax2, DATAABSMIN = DATAMin2
                      
DataName = '('+DataNames1[0]+','+DataNames2[0]+')'

Print, " Output Data         = ", DataName

;NX = _N[0,0]
;NY = _N[0,1]

;print, "Dimensions ",NX, NY
;Data1=FltArr(NX,NY) 
;Data2=FltArr(NX,NY) 


;XAxisData = FIndGen(NX)*(NX*Delta[0,0,0])/(NX-1)+Origin[0,0]
;YAxisData = FIndGen(NY)*(NY*Delta[0,1,1])/(NY-1)+Origin[0,1]

; ------------------------ Set Reference Values -----------------------------------


; Finds autoscale values

MinData = Min([DataMin1, DataMin2])
MaxData = Max([ DataMax1, DataMax2])
Lref = MaxData

; Doesn't use autoscale if limit values are supplied 

if N_Elements(_zmax) ne 0 then MaxData = _zmax
if N_Elements(_zmin) ne 0 then MinData = _zmin
if N_Elements(_Lref) ne 0 then lref = _lref

print, 'Data Limits :'
print, '-----------------------------------'
print, 'Max  = ', MaxData
print, 'Min  = ', MinData
print, 'LREF = ', lref

; Generate the frame lists

framelist1 = GenFrameList(DirName1, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                          FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes, DIMS = 2 )

framelist2 = GenFrameList(DirName2, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                          FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes, DIMS = 2 )

; Create a window for showing the frames

Window, /Free, XSize = winRes[0], YSize = winRes[1], Title = DirName

; Checks the number of colors

device, get_visual_depth = thisDepth
if thisDepth gt 8 then truecol = 1 else truecol = 0

framename = StrArr(NFrames)

for frame=0, NFrames-1 do begin

  framename[frame] =  "frame"+ String(byte([ byte('0') +  (frame/1000.0) mod 10 , $
                               byte('0') +  (frame/100.0)  mod 10 , $
                               byte('0') +  (frame/10.0)   mod 10 , $
                               byte('0') +  (frame/1.0)    mod 10 ])) + ".gif" 

  ; If both datasets exist for this time
  
  if (framelist1[frame] ge 0) and $
     (framelist2[frame] ge 0) then begin

    print, 'Reading Data...'

    fname1 = DataFileNames1[framelist1[frame]] 
    fname2 = DataFileNames2[framelist2[frame]] 

    Osiris_Open_Data, pData, DATASETSNUMBER = 2, $
                        FILE = [fname1,fname2], $
                        PATH = [Dirname1,Dirname2], $
                        DIM = Dims, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData,  $
                        N = N, FORCEDIMS = 2, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, /IGNORE_DIFF
    print, 'done'
    
    ; Resizes the matrix

    if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1))  then begin
  
      n1[0] = n1[0] / DimFactor[0]
      n1[1] = n1[1] / DimFactor[1]
  
      *(pData[0]) = Rebin(*(pData[0]), n1[0],n1[1],n1[2])
      *(pData[1]) = Rebin(*(pData[1]), n1[0],n1[1],n1[2])
  
      XAxisData = Rebin(XAxisData, n1[0])
      YAxisData = Rebin(YAxisData, n1[1])  

    end

    ; Smooths the data

    if (DataSmooth ge 2) then begin
       *(pData[0]) = Smooth(*(pData[0]),DataSmooth,/Edge_Truncate)
       *(pData[1]) = Smooth(*(pData[1]),DataSmooth,/Edge_Truncate)
    end

  
    PlotSubTitle = 'Time = ' + String( time ,Format='(f7.2)') + ' [ '+time_units+' ]'

    if N_Elements(XAxisTitle) eq 0 then begin
       XAxisTitle = x1label
       if (x1unit ne '') then XAxisTitle = XAxisTitle +' ['+x1unit+']'
    end

    if N_Elements(YAxisTitle) eq 0 then begin
       YAxisTitle = x2label
       if (x2unit ne '') then YAxisTitle = YAxisTitle+' ['+x2unit+']'
    end

    ; Return to first dir

    cd, dirname1
  
    _MinData = MinData
    _MaxData = MaxData
    _LReference = Lref

    pData0 = ptr_new(sqrt((*pData[0])^2+(*pData[1])^2))
 
    Plot2D, pData0,_EXTRA=extrakeys, YAXIS = YAxisData, XAXIS = XAxisData, $
                   TITLE = PlotTitle, SubTitle = PlotSubTitle, $
                   ZMIN = _MinData, ZMAX = _MaxData, $
                   XTITLE = XAxisTitle, YTITLE = YAxisTitle,$
                   ZTITLE = ZAxisTitle
     
    ; Overplots the vectors 

    LoadCT, 0
    oPlot2DVector, pData[0], pData[1], ScaleType = 1, _EXTRA=extrakeys, $
                   COLOR = -1, LREF = _LReference               

    ptr_free, pData0, pData
  
  end else begin
    LoadCT, 0
    erase, 0    
  end

  ; Saves the frame
  
  if (truecol eq 1) then begin
     gifframe24 = TVRD(True = 1)
     gifframe = Color_Quan(gifframe24, 1, r, g, b)
     gifframe24 = 0
  endif else begin
     gifframe = TVRD()
     TVLCT, r, g, b, /get 
  endelse

  Write_GIF, framename[frame], gifframe, r, g, b
  print, " Saved file ", framename[frame]
  gifframe = 0

  print, "Finished frame ",frame 
end

;XINTERANIMATE

if Keyword_Set(XAnimate) then begin
  Frame2Movie, DIRECTORY = DirName1, FILES = framename, /gif
end

Print, " Done! "

; This cleans up any pallete problems

loadct, 0, /silent

END