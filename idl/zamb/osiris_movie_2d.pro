
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

; BUG!, doesn't work with type = 1

PRO Osiris_Movie_2D, _EXTRA=extrakeys, $
                     ; Directory and file information
                     DIRECTORY = DirName, EXTENSION = FileNameExtension, $
                     ; Data Operations (for scaling)
                     SQUARED = DataSquared, ABS = DataAbs, $ 
                     ; Titles and labels
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units,  $
                     ; Data Ranges
                     ZMAX = _zmax, ZMIN = _zmin, ZLOG = zlog, $
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

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory)
  if (DirName eq '') then return
end

CD, DirName

If N_Elements(PlotTitle) eq 0 then deftitle = 1 else deftitle = 0
If N_Elements(PlotSubTitle) eq 0 then defsubtitle = 1 else defsubtitle = 0

; Get Data Ranges and filenames

GetOsirisMovieData2D, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    ORIGIN = origin, DELTA = delta, EXTENSION = FIleNameExtension, $
                    DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax, $
                    DATAABSMIN = DATAAbsMin, NON0DATAABSMIN = DATAAbsMin_Non0

; Determines the correct autoscaling for the plots

if not Keyword_Set(DataSquared) then begin
  MinData = DataMin
  MaxData = DataMax
  
  if Keyword_Set(zlog) then begin
    MinData = DataAbsMin_Non0
    MaxData = DataAbsMax  
  end else if Keyword_Set(DataAbs) then begin
    MinData = DataAbsMin
    MaxData = DataAbsMax   
  end
  
endif else begin
  MinData = DataAbsMin^2
  MaxData = DataAbsMax^2

  if Keyword_Set(zlog) then begin
    MinData = DataAbsMin_Non0^2
    MaxData = DataAbsMax^2  
  end
endelse

; Plot Titles

if N_Elements(PlotTitle) eq 0 then deftitle = 1 else deftitle = 0
if N_Elements(PlotSubTitle) eq 0 then defSubtitle = 1 else defSubtitle = 0
if N_Elements(XAxisTitle) eq 0 then defXAxisTitle = 1 else defXAxisTitle = 0
if N_Elements(YAxisTitle) eq 0 then defYAxisTitle = 1 else defYAxisTitle = 0
if N_Elements(ZAxisTitle) eq 0 then defZAxisTitle = 1 else defZAxisTitle = 0


; Doesn't use autoscale if limit values are supplied 

if N_Elements(_zmax) ne 0 then MaxData = _zmax
if N_Elements(_zmin) ne 0 then MinData = _zmin

; Makes the frame list

help, t1
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

ap = ptr_valid(COUNT = s)
print, s, ' leaks found'  


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
  
    if (oProgressBar -> CheckCancel()) then goto, end_loop

    Osiris_Open_Data, pData1, FILE = fname1, PATH = Dirname, EXTENSION = FIleNameExtension, TIMEPHYS = time, $
                        XAXIS = _XAxisData, YAXIS = _YAxisData,  $
                        N = N , FORCEDIMS = 2, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, $
                        /IGNORE_TIME

    if (oProgressBar -> CheckCancel()) then goto, end_loop

    XAxisData = _XAxisData
    YAxisData = _YAxisData
    
    ; Analyse the data
    
    analysis, _EXTRA = extrakeys, pData1, xaxisdata, yaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
          XLABEL = x1label, YLABEL = x2label, $
          XUNITS = x1unit, YUNITS = x2unit, $
          CVERTS = pcverts, CPOINTS = pcpoints, $
          SQUARED = DataSquared, ABS = DataAbs
    

    if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
    if (x2unit ne '') then x2label = x2label +' ['+x2unit+']'
    datalabel = datalabel[0]
    if (units[0] ne '') then datalabel = datalabel +' ['+units[0]+']'


    if (oProgressBar -> CheckCancel()) then goto, end_loop

    if (deftitle) then $
       PlotTitle = DataName

    if (defSubtitle) then $
       PlotSubTitle = 'Time = ' + String( time ,Format='(f8.2)') + ' [ '+time_units+' ]'

    if (defXAxisTitle) then XAxisTitle = x1label
    if (defYAxisTitle) then YAxisTitle = x2label
    if (defYAxisTitle) then ZAxisTitle = datalabel

    _MinData = MinData
    _MaxData = MaxData

    if (n_elements(pcverts) ne 0) then cverts = *pcverts[i] else undefine, cverts
    if (n_elements(pcpoints) ne 0) then cpoints = *pcpoints[i] else undefine, cpoints

    Plot2D,      pData1, YAXIS = YAxisData, XAXIS = XAxisData, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
                     _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     ZMIN = _MinData, ZMAX = _MaxData, ZLOG = zlog, $
                     TRAJVERT = centroid_vert, TRAJPOINTS = cpoints, $
                     FILEOUT = framename[frame],  IMAGE = img24
 
    ; Free pointer
    
    ptr_free, pData1
    
    ; Debug
    
    ap = ptr_valid(COUNT = s)
    print, s, ' leaks found'  
    if (s ne 0) then for _i=0, s-1 do begin
      help, *(ap[_i])
    end

        
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