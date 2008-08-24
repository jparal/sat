
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
              ; Titles and labels
              XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
              TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units,  $
              ; Data Ranges
              ZMAX = _zmax, ZMIN = _zmin, $
              ; Visualization options
              SHOW = Show, RES = PlotRes, XANIMATE = XAnimate, $
              ; Frame Options
              IT0 = t0, IT1 = t1

; **************************************************************************************************** Parameters
                     
; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'

; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 600 x 400

if N_Elements(PlotRes) eq 0 then PlotRes = [600,400]
   
; DIRECTORY 1

if N_Elements(DirName1) eq 0 then begin  
  DirName1 = Dialog_PickFile(/Directory, TITLE = 'Select First Vector Component')
  if (DirName1 eq '') then return
end

; DIRECTORY 2

if N_Elements(DirName2) eq 0 then begin  
  DirName2 = Dialog_PickFile(/Directory, TITLE = 'Select Second Vector Component')
  if (DirName2 eq '') then return
end

; ------------------------ Get Movie Data -----------------------------------------

CD, DirName1

GetOsirisMovieData2D, DIRECTORY = DirName1, /Silent, NFRAMES = NFrames, DIMN = nx,$
                    TIMES = Datatimes, DATANAME = datanames1, FILENAME = DataFileNames1,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAABSMAX = DATAMax1, DATAABSMIN = DATAMin1
                    
if (N_Elements(DataMin1) eq 0) then return

CD, DirName2

GetOsirisMovieData2D, DIRECTORY = DirName2, /Silent, DIMN = nx2,$
                    DATANAME = datanames2, FILENAME = DataFileNames2,$
                    DATAABSMAX = DATAMax2, DATAABSMIN = DATAMin2, $
                    ORIGIN = origin2, DELTA = delta2

if (N_Elements(DataMin2) eq 0) then return
                
if (nx[0] ne nx2[0]) then begin
  res = Error_Message("The files on the two directories don't have the same dimension sizes") 
  return
end

if (origin[0] ne origin2[0]) or (origin[1] ne origin2[1]) then begin
  res = Error_Message("The files on the two directories don't have the same axis information") 
  return
end

if (delta[0,0] ne delta2[0,0]) or (delta[1,1] ne delta2[1,1]) then begin
  res = Error_Message("The files on the two directories don't have the same axis information") 
  return
end


; ------------------------ Set Reference Values -----------------------------------


; Finds autoscale values

MinData = 0.0
MaxData = Max([DataMax1, DataMax2])
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

; Plot Titles

if N_Elements(PlotTitle) eq 0 then deftitle = 1 else deftitle = 0
if N_Elements(PlotSubTitle) eq 0 then defSubtitle = 1 else defSubtitle = 0
if N_Elements(XAxisTitle) eq 0 then defXAxisTitle = 1 else defXAxisTitle = 0
if N_Elements(YAxisTitle) eq 0 then defYAxisTitle = 1 else defYAxisTitle = 0
if N_Elements(ZAxisTitle) eq 0 then defZAxisTitle = 1 else defZAxisTitle = 0

; Generate the frame lists

framelist1 = GenFrameList(DirName1, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                          FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes, DIMS = 2 )

framelist2 = GenFrameList(DirName2, IT0 = t0, IT1 = t1, NFRAMES = NFrames2, $
                          FRAMEITERS = FrameIters2, FRAMETIMES = FrameTimes, DIMS = 2 )

if (NFrames2 ne NFrames) then begin
   res = Error_Message('Number of frames of the 2nd Data set is not the same as the 1st')
   return   
end
  
for i=0, NFrames-1 do begin
  if (FrameIters[i] ne FrameIters2[i]) then begin
     res = Error_Message('The iteration numbers of the 2nd Data are different from the 1st')
     return
  end
end

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

  framename[frame] =  "frame"+ String(byte([ byte('0') +  (frame/1000.0) mod 10 , $
                               byte('0') +  (frame/100.0)  mod 10 , $
                               byte('0') +  (frame/10.0)   mod 10 , $
                               byte('0') +  (frame/1.0)    mod 10 ])) + ".tif" 

  ; If both datasets exist for this time
  
  if (framelist1[frame] ge 0) and $
     (framelist2[frame] ge 0) then begin

    print, 'Reading Data...'

    fname1 = DataFileNames1[framelist1[frame]] 
    fname2 = DataFileNames2[framelist2[frame]] 

    if (oProgressBar -> CheckCancel()) then goto, end_loop

    Osiris_Open_Data, pData, DATASETSNUMBER = 2, $
                        FILE = [fname1,fname2], $
                        PATH = [Dirname1,Dirname2], $
                        DIM = Dims, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData,  $
                        FORCEDIMS = 2, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, /IGNORE_TIME
    print, 'done'
    
    if (oProgressBar -> CheckCancel()) then goto, end_loop

    ; analyse the data                  

    analysis_vfield, _EXTRA = extrakeys, pData, xaxisdata, yaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
          XLABEL = x1label, YLABEL = x2label, $
          XUNITS = x1unit, YUNITS = x2unit

    if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
    if (x2unit ne '') then x2label = x2label +' ['+x2unit+']'
    datalabel = '('+datalabel[0]+','+datalabel[1]+')'
    if (units[0] ne '') then datalabel = datalabel +' ['+units[0]+']'

    if (oProgressBar -> CheckCancel()) then goto, end_loop

    if (deftitle) then $
       PlotTitle = '('+DataName[0]+','+DataName[1]+')'

    if (defSubtitle) then $
       PlotSubTitle = 'Time = ' + String( time ,Format='(f8.2)') + ' [ '+time_units+' ]'

    if (defXAxisTitle) then XAxisTitle = x1label
    if (defYAxisTitle) then YAxisTitle = x2label
    if (defZAxisTitle) then ZAxisTitle = datalabel


    ; Return to first dir

    cd, dirname1
  
    _MinData = MinData
    _MaxData = MaxData
    _LReference = Lref

    Plot2D, pData, /VECTOR, YAXIS = YAxisData, XAXIS = XAxisData, $
        TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
        _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
        FILEOUT = framename[frame],  IMAGE = img24, ZMIN = _MinData, ZMAX = _MaxData, $
        LREF = _LReference
    
    ptr_free, pData
  
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
ptr_free, pData 

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