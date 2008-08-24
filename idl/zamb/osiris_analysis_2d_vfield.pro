
;
;  Program:  
;
;  Osiris_Analysis_2D_VField
;
;  Description:
;
;  Opens 2 sets of data output from the osiris code, corresponding to two components of a 2D vector
;  field and plots them
;
;  Current Version: (25 - Feb -2000)
;
;    0.3 : Added BACKDATA and BACKFILE parameters, to use a different scalar dataset for the background
;          color plot 
;
;  History:
;
;    0.2 : Started using the open_osiris_data routine and checking the validity of the two files 
;
;    0.1 : Basic working functionality
;
;  Known bugs:
;
;    All bugs detected so far have been corrected
;
; *****************************************************************************************************************
;
; Parameter list:
;
; TYPE
;
; Type of plot
;

PRO Osiris_Analysis_2D_VField,_EXTRA=extrakeys, DX = useDX, $
                FILE1 = FileName1, FILE2 = FileName2, $		; Files to Open
                PATH1 = FilePath1, PATH2 = FilePath2, $		; Path to files
                XTITLE = XAxisTitle, $					; X Axis Title 
                YTITLE = YAxisTitle, $					; Y Axis Title
                ZTITLE = ZAxisTitle, $					; Z Axis Title
                TITLE = PlotTitle, $						; Plot Title
                SUBTITLE = PlotSubTitle, $					; Plot Sub Title
                TIME_UNITS = time_units					; Time Units to use

; **************************************************************************************************** Parameters

; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'

; FILE(12)
;
; File to open (1st vector component [x] and 2nd vector component [y])

if (N_Elements(FileName1) + N_Elements(Filename2)) eq 2 then fnames = [FileName1,FileName2] $
else undefine, fnames

; PATH(12)
;
; Path to File to open (1st vector component [x] and 2nd vector component [y])

if (N_Elements(FilePath1) + N_Elements(FilePath2)) eq 2 then fpath = [FilePath1,FilePath2] $
else undefine, fpath


; **************************************************************************************************** Main Code

; Open the two data sets

Osiris_Open_Data, pData, DATASETSNUMBER = 2, FILE = fnames, PATH = fpath, $
                  TIMEPHYS = time, XAXIS = XAxisData, YAXIS = YAxisData,  $
                  FORCEDIMS = 2, $
                  DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                  XLABEL = x1label, XUNITS = x1unit, $
                  YLABEL = x2label, YUNITS = x2unit


if (not ptr_valid(pData[0])) or (pData[0] eq ptr_new()) then return                  

                  
; analyse the data                  

analysis_vfield, _EXTRA = extrakeys, pData, xaxisdata, yaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
          XLABEL = x1label, YLABEL = x2label, $
          XUNITS = x1unit, YUNITS = x2unit

; Add units to labels

if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
if (x2unit ne '') then x2label = x2label +' ['+x2unit+']'
datalabel = '('+datalabel[0]+','+datalabel[1]+')'
if (units[0] ne '') then datalabel = datalabel +' ['+units[0]+']'
                  
; Set Plot Titles

if N_Elements(PlotTitle) eq 0 then PlotTitle = '('+DataName[0]+','+DataName[1]+')'

if N_Elements(PlotSubTitle) eq 0 then $
   PlotSubTitle = "Time = " + String(Time,Format='(f8.2)') + ' [ '+time_units+' ]'

if N_Elements(XAxisTitle) eq 0 then $ 
   XAxisTitle = x1label

if N_Elements(YAxisTitle) eq 0 then $
   YAxisTitle = x2label

if N_Elements(ZAxisTitle) eq 0 then $
   ZAxisTitle = DataLabel

help, ZAxisTitle

window_title = '('+(strip_fname(fnames[0]))[0]+','+(strip_fname(fnames[1]))[0]+')'

Plot2D, pData, /VECTOR, YAXIS = YAxisData, XAXIS = XAxisData, $
        TITLE = PlotTitle, SUBTITLE = PlotSubTitle, RES = PlotRES, $
        _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
        XRANGE = xrange, YRANGE = yrange, WINDOWTITLE = window_title, $
        /no_share

END