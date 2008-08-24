
;
;  Program:  
;
;  Osiris_Movie_3D
;
;  Description:
;
;  Opens data output from the osiris code (3D scalar field) and does a movie with it
;
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_3D, _EXTRA=extrakeys, $
                      ; Directory Information
                      DIRECTORY = DirName, DX = UseDx, $
                      ; Additional Datasets
                      DATA2 = UseData2, D2DIR = DirName2, $
                      ; Axis Ranges
                      XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                      ; Titles and Labels
                      XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                      TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units, $
                      ; Data Ranges
                      MAX = DataMax, MIN = DataMin,  PMIN = ProjMin, PMAX = ProjMax, $
                      ; Image options
                      SHOW = Show, RES = PlotRES, $
                      ; Use XInterAnimate
                      XANIMATE = XAnimate
      
; **************************************************************************************************** Parameters

; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'


if N_Elements(DataSmooth) eq 0 then DataSmooth = 0

; SHOW
;
; Set this keyword to show the frames while generating


if N_Elements(XAxisTitle) eq 0 then XAxisTitle = ''
if N_Elements(YAxisTitle) eq 0 then YAxisTitle = ''
if N_Elements(ZAxisTitle) eq 0 then ZAxisTitle = ''

If N_Elements(UseDX) eq 0 then UseDX = 0

if N_Elements(PlotRES) eq 0 then PlotRES = [600,600]

   
; DIRECTORY
;
; The directory holding the data for the frames. If not specified prompts the user for one
;    

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory, TITLE = 'Select Data')
  if (DirName eq '') then return
end

; DATA2
;
; Set this keyword to use to different sets of data

if KeyWord_Set(UseData2) then UseData2 = 1 else UseData2 = 0

; D2DIR
;
; Directory with the second set of data. If not specified the user is prompted for it
; Ignored if Data2 is not set

if (UseData2 eq 1) then begin
  if N_Elements(DirName2) eq 0 then begin  
    DirName2 = Dialog_PickFile(/Directory, TITLE = 'Select 2nd set of Data')
    if (DirName2 eq '') then return
  end
end


; ################################################################################################


; Gets the information about the dataset

CD, DirName

GetOsirisMovieData3D, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAABSMAX = DATAAbsMax, DATAABSMIN = DATAAbsMin,$
                    DATAPABSMAX = DataPAbsMax, DATAPABSMIN = DATAPAbsMIN, $
                    DATAMAX = DataMax, DATAMIN = DataMin, $
                    DATAPMAX = DataPMax, DATAPMIN = DATAPMIN, DX = UseDX
                                          
DataName = DataNames[0]

; Determines the correct autoscaling for the plots

if (DataSquared eq 0) then begin
  if (DataAbs eq 0) then begin  ; Raw Data
      MinData = DataMin
      MaxData = DataMax
      ProjMax = DataPMax
      ProjMin = DataPMin 
  end else begin                ; Abs Data
      MinData = DataAbsMin
      MaxData = DataAbsMax
      ProjMax = DataPAbsMax
      ProjMin = DataPAbsMin 
      
  end
endif else begin                ; Square Data
  MinData = DataAbsMin^2
  MaxData = DataAbsMax^2
  ProjMax = DataP2Max
  ProjMin = DataP2Min  
endelse

ProjMin = Min(ProjMin)
ProjMax = Max(ProjMax)

; Gets the information about the second dataset

if (UseData2 eq 1) then begin
  CD, DirName2

  GetOsirisMovieData, DIRECTORY = DirName2, /Silent, DIMN = _N2, FILENAME = DataFileNames2, $
                      ORIGIN = origin2, DELTA = delta2,$
                    DATAABSMAX = DATAAbsMax2, DATAABSMIN = DATAAbsMin2,$
                    DATAPABSMAX = DataPAbsMax2, DATAPABSMIN = DATAPAbsMIN2, $
                    DATAMAX = DataMax2, DATAMIN = DataMin2, $
                    DATAPMAX = DataPMax2, DATAPMIN = DATAPMIN2
  
  ; Check for incompatibility
                      
  for i=0,2 do begin
     if ((origin[i] ne origin2[i]) or (delta[i,i] ne delta2[i,i])) then begin
       res = Error_Message('The axis information of 2nd Data set is '+$
                           'different from the 1st')
       return
     end
     if (_N[i] ne _N2[i]) then begin
       res = Error_Message('The dimension of the 2nd dataset is '+$
                           'different from the 1st')
       return
     end  
  end
  
  if (DataSquared eq 0) then begin
    if (DataAbs eq 0) then begin  ; Raw Data
      MinData2 = DataMin2
      MaxData2 = DataMax2
      ProjMax2 = DataPMax2
      ProjMin2 = DataPMin2 
    end else begin                ; Abs Data
      MinData2 = DataAbsMin2
      MaxData2 = DataAbsMax2
      ProjMax2 = DataPAbsMax2
      ProjMin2 = DataPAbsMin2 
      
    end
  endif else begin                ; Square Data
    MinData2 = DataAbsMin2^2
    MaxData2 = DataAbsMax2^2
    ProjMax2 = DataP2Max2
    ProjMin2 = DataP2Min2  
  endelse
  
  MinData = MIN([MinData,MinData2])
  MaxData = MAX([MaxData,MaxData2])
  ProjMin = MIN([ProjMin,ProjMin2])
  ProjMax = MAX([ProjMax,ProjMax2])

end

; Plot Titles

if N_Elements(PlotTitle) eq 0 then defTitle = 1 else defTitle = 0
if N_Elements(PlotSubTitle) eq 0 then defSubtitle = 1 else defSubtitle = 0

; Axis Titles

if N_Elements(XAxisTitle) eq 0 then $ 
   defXAxisTitle = 1 else defXAxisTitle = 0

if N_Elements(YAxisTitle) eq 0 then $
   defYAxisTitle = 1 else defYAxisTitle = 0

if N_Elements(ZAxisTitle) eq 0 then $
   defZAxisTitle = 1 else defZAxisTitle = 0


print, 'Data Limits, ', PlotTitle
print, '-----------------------------------'
print, 'Max   = ', MaxData
print, 'Min   = ', MinData
print, 'PMax  = ', ProjMax
print, 'PMin  = ', ProjMin


; Makes the frame list

framelist = GenFrameList(DirName, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                         FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes )

; Makes the frame list for the second dataset

if Keyword_Set(UseData2) then begin
  framelist2 = GenFrameList(DirName2, IT0 = t0, IT1 = t1, NFRAMES = NFrames2, $
                         FRAMEITERS = FrameIters2, FRAMETIMES = FrameTimes2 )
                         
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
end else framelist2 = framelist

; Creates a window for viewing the frames being generated

if KeyWord_Set(Show) then begin
  Window, /Free, TITLE = DirName, XSize=plotRES[0], YSize=plotRES[1]
  show_window = !D.Window
end 


framename = StrArr(NFrames)

for frame=0, NFrames-1 do begin
  print, ' Frame = ',frame

  framename[frame] =  "frame"+ String(byte([ byte('0') +  (frame/1000.0) mod 10 , $
                               byte('0') +  (frame/100.0)  mod 10 , $
                               byte('0') +  (frame/10.0)   mod 10 , $
                               byte('0') +  (frame/1.0)    mod 10 ])) + ".tiff" 

  img24 = 0
  
  if ((UseData2 eq 0) and (framelist[frame] ge 0)) or $   ; data exists (one dataset)
     ((UseData2 eq 1) and (framelist[frame] ge 0) and $   ; data exists (two datasets)
      (framelist2[frame] ge 0)) then begin 
  
    fname1 = DataFileNames[framelist[frame]] 
    print, ' File : ', fname1
   
    ; Gets the Data  

    Osiris_Open_Data, pData1, FILE = fname1, PATH = Dirname, TIMEPHYS = time, $
                      XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                      XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                      FORCEDIMS = 3, $
                      DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                      XLABEL = x1label, XUNITS = x1unit, $
                      YLABEL = x2label, YUNITS = x2unit, $
                      ZLABEL = x3label, ZUNITS = x3unit, /IGNORE_TIME
  

    analysis, _EXTRA = extrakeys, pData1, xaxisdata, yaxisdata, $
              DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
              XLABEL = x1label, YLABEL = x2label, ZLABEL = x3label, $
              XUNITS = x1unit, YUNITS = x2unit, ZUNITS = x3units, $
              CVERTS = pcverts, CPOINTS = pcpoints

    if (UseData2 eq 1) then begin
       fname2 = DataFileNames2[framelist2[frame]] 
       print, ' File : ', fname2

      Osiris_Open_Data, pData2, FILE = fname2, PATH = DirName2, $
                           XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                           XAXIS = d2XAxisData, YAXIS = d2YAxisData, ZAXIS = d2ZAxisData,  $
                           FORCEDIMS = 3, $
                           DATATITLE = d2DataName, DATALABEL = d2DataLabel, DATAUNITS = d2Units, $
                           XLABEL = d2x1label, XUNITS = d2x1unit, $
                           YLABEL = d2x2label, YUNITS = d2x2unit, $
                           ZLABEL = d2x3label, ZUNITS = d2x3unit
       cd, dirname[0]
       
       analysis, _EXTRA = extrakeys, pData2, d2xaxisdata, d2yaxisdata, $
             DATANAME = d2DataName, DATALABEL = d2datalabel,DATAUNITS = d2units,  $
             XLABEL = d2x1label, YLABEL = d2x2label, ZLABEL = d2x3label, $
             XUNITS = d2x1unit, YUNITS = d2x2unit, ZUNITS = d2x3unit, $
             CVERTS = d2pcverts, CPOINTS = d2pcpoints

    end
    
    if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
    if (x2unit ne '') then x2label = x2label +' ['+x2unit+']'
    if (x3unit ne '') then x3label = x3label +' ['+x3unit+']'
 
    if (defTitle eq 1) then $
       PlotTitle = DataName
    
    if (defSubtitle eq 1) then $
       PlotSubTitle = 'Time = ' + String( time ,Format='(f8.2)') + ' [ '+time_units+' ]'

 
    if (defXAxisTitle eq 1) then $
       XAxisTitle = x1label

    if (defYAxisTitle eq 1) then $
       YAxisTitle = x1label

    if (defZAxisTitle eq 1) then $
       ZAxisTitle = x1label

  
    _MinData = MinData
    _MaxData = MaxData

    if (n_elements(pcverts) ne 0) then cverts = *pcverts[0] else undefine, cverts
    if (n_elements(pcpoints) ne 0) then cpoints = *pcpoints[0] else undefine, cpoints
    if (n_elements(d2pcverts) ne 0) then d2cverts = *pcverts[0] else undefine, d2cverts
    if (n_elements(d2pcpoints) ne 0) then d2cpoints = *pcpoints[0] else undefine, d2cpoints

    Plot3D,      pData1, YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
                    TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, RES = PlotRES, $
                    _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                    MIN = _MinData, MAX = _MaxData, PMIN = ProjMin, PMAX = ProjMax, $
                    XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                    TRAJVERT = centroid_vert, TRAJPOINTS = cpoints, /TRAJPROJ,$
                    DATA2 = pData2, TRAJ2VERT = centroid2_vert, TRAJ2POINTS = cpoints2, /TRAJ2PROJ, $
                    FILEOUT = framename[frame],  IMAGE = img24

    if (n_elements(pcverts) ne 0) then ptr_free, pcverts
    if (n_elements(pcpoints) ne 0) then ptr_free, pcpoints
    if (n_elements(d2pcverts) ne 0) then ptr_free, d2pcverts
    if (n_elements(d2pcpoints) ne 0) then ptr_free, d2pcpoints

    ptr_free, pData1
    if (N_Elements(pData2) ne 0 ) then ptr_free, pData2 
  end else begin ; Missing Data
    print, 'Missing Data, writing blank frame'
    img24 = BytArr(3, plotRES[0], plotRES[1])
    WRITE_TIFF, framename[frame], img24
  end
 
  if KeyWord_Set(Show) then begin
    tvimage, img24
  end 

  img24 = 0
     
  print, "Finished frame ",frame 
end

;XINTERANIMATE

if Keyword_Set(XAnimate) then begin
  Frame2Movie, DIRECTORY = DirName, FILES = framename, /tiff
end


Print, " Done! "

END