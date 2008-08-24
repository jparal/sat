
;
;  Program:  
;
;  Osiris_Movie_1D
;
;  Description:
;
;  Opens data output from the osiris code and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_1D, _EXTRA=extrakeys, $
                      ; File and Directory Information
                      DIRECTORY = DirName, DX = useDX, EXTENSION = FileNameExtension, $
                      ; Visualization options
                      RES = winRes, PROFILE = dummy, $
                      ; Output File
                      OUTFILE = dataoutfile,$
                      ; Time Units
                      TIME_UNITS = time_units,$
                      ; Frame Options
                      IT0 = t0, IT1 = t1 


; **************************************************************************************************** Parameters
                     
; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'


; Size

if N_Elements(winRes) eq 0 then winRes = [600,450]


; Call XAnimate
   
if N_Elements(noXAnimate) eq 0 then noXAnimate = 0
   
; DirName

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory)
  if (DirName eq '') then return
end

cd, dirname

; Get Ranges and frames information

CD, DirName
_DirName = Dirname
GetOsirisMovieData1D, DIRECTORY = _DirName, /Silent, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    DATAMAX = DATAMax, DATAMIN = DATAMin, DATAABSMAX = DATAAbsMax,  DATAABSMIN = DATAAbsMin, $
                    NON0DATAABSMIN = DATAAbsMin_Non0
NX = _N[0,0]
DataName = DataNames[0]

; Generate frame list

framelist = GenFrameList(DirName, IT0 = t0, IT1 = t1, NFRAMES = NFrames, DIMS = 1,$
                                  FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes )

; Setup Progress Bar

oProgressBar = Obj_New("SHOWPROGRESS", $
                        /cancelbutton, $
                        TITLE = 'Movie', $
                        MESSAGE = 'Generating Frames...')
oProgressBar -> Start
normal_termination = 0b

; Creates Movie Data Array
MovieData = FltArr(NFrames, NX) 

for i=0, NFrames-1 do begin

  label = 'Generating Frame '+strtrim(string(i+1),1)+'/'+$
                strtrim(string(NFrames),1)
  
  oProgressBar -> SetLabel, label 
  
  if (framelist[i] ge 0) then begin ; Data Exists
    
     fname = DataFileNames[framelist[i]] 
    
     ; Opens the data
          
     Osiris_Open_Data, pData, FORCEDIMS = 1,  $
                  FILE = fname, PATH = dirname, $                      
                  TIMEPHYS = time, $
                  DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                  XAXIS = XAxisData, XLABEL = x1label, XUNITS = x1units, /ignore_time

     if (oProgressBar -> CheckCancel()) then goto, end_loop
 
     ; does calculations
     
     analysis, _EXTRA = extrakeys, pData, xaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
          XLABEL = x1label, XUNITS = x1units

     if (oProgressBar -> CheckCancel()) then goto, end_loop

     ; Adds data to Movie Data
     
     MovieData[i,*] = temporary(*pData)
     ptr_free, pData
   
     if (oProgressBar -> CheckCancel()) then goto, end_loop
     oProgressBar -> Update, (i*100.0)/(NFrames-1)
   end      

end

normal_termination = 1b

end_loop:

; free pointer in case we got here without through termination
ptr_free, pData 

; Close Progress Bar window
oProgressBar -> Destroy
Obj_Destroy, oProgressBar

if (normal_termination eq 1b) then begin
                     
  ; Plots the movie (literaly...)
  pMovieData = Ptr_New(MovieData, /no_copy)
  plot2D, _EXTRA=extrakeys, pMovieData, $
          TITLE = DataName, $
          XAXIS = FrameTimes, XTITLE = 'Time ['+time_units+']',$
          YAXIS = XAxisData, YTITLE = x1label+' ['+x1units+']', $
          ZTITLE = DataLabel + '['+units+']'


  ; Saves the data
  osiris_save_data, pMovieData, FILE = dataoutfile, DIALOGTITLE = DialogTitle, $
                            XAXIS = FrameTimes, YAXIS = XAxisData, $
                            DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                            XLABEL = 'Time', XUNITS = time_units, $
                            YLABEL = x1label, YUNITS = x1units

  ptr_free, pMovieData

  print, 'Done'

end else begin
  Print, 'Interrupted!'
end

end