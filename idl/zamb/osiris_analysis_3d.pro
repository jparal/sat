
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
                     ; Additional Datasets
                     NDATASETS = n_datasets, $
                     DATA2 = UseData2, D2FILE = filename2, $
                     ; Axis Ranges
                     XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                     ; Titles and Labels
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle,  TIME_UNITS = time_units, $
                     ; Data Ranges
                     MIN = DataMin, MAX = DataMax, PMIN = ProjMin, PMAX = ProjMax,  $
                     ; Slicer Operation
                     SLICER = use_slicer

; **************************************************************************************************** Parameters

; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'

; NDATASETS
;
; Number of datasets to analyse
;
; Set this parameter to the number of datasets to analyse. The default is 1

if N_Elements(n_datasets) eq 0 then n_datasets = 1 $
else if (n_datasets lt 1) then n_datasets = 1

; DATA2
;
; Plot 2 datasets

if KeyWord_Set(UseData2) then begin 
   UseData2 = 1
   n_datasets = 1
end else UseData2 = 0

; D2FILENAME
;
; filename of the second dataset to open. Note, if specified there is no need to set the DATA2 keyword

if N_Elements(FileName2) eq 0 then begin
  if (UseData2 eq 1) then begin
    filename2=Dialog_Pickfile(TITLE = 'Choose 2nd DataSet',FILTER=filter, GET_PATH = filepath2)
    if (filename2 eq '') then return
  end
end else UseData2 = 1


; **************************************************************************************************** Main Code

; Gets the Data

Osiris_Open_Data, pData, FILE = filename, TIMEPHYS = time, DATASETSNUMBER = n_datasets, $
                        XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, PATH = filepath, $
                        N = dxN, FORCEDIMS = 3, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, $
                        ZLABEL = x3label, ZUNITS = x3unit, INFO_STRUCT = sDataInfo
                        
help, sDataInfo

if (pData[0] eq ptr_new()) then return

; Reads Second Dataset

if Keyword_Set(UseData2) then begin
  
  ; this will automatically check for incompatibilities

  d2XAxisData = XAxisData
  d2YAxisData = YAxisData
  d2ZAxisData = ZAxisData
  d2dxN = dxN   
  d2time = time

  Osiris_Open_Data, pData2, FILE = filename2, TIMEPHYS = d2time, $
                           XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                           XAXIS = d2XAxisData, YAXIS = d2YAxisData, ZAXIS = d2ZAxisData, PATH = filepath2, $
                           N = dxN, FORCEDIMS = 3, $
                           DATATITLE = d2DataName, DATALABEL = d2DataLabel, DATAUNITS = d2Units, $
                           XLABEL = d2x1label, XUNITS = d2x1unit, $
                           YLABEL = d2x2label, YUNITS = d2x2unit, $
                           ZLABEL = d2x3label, ZUNITS = d2x3unit
   
  if (pData eq ptr_new()) then return

end

; Analyse the data

analysis, _EXTRA = extrakeys, pData, xaxisdata, yaxisdata,zaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
          XLABEL = x1label, YLABEL = x2label, ZLABEL = x3label, $
          XUNITS = x1unit, YUNITS = x2unit, ZUNITS = x3unit, $
          CVERTS = pcverts, CPOINTS = pcpoints

n_datasets = N_Elements(pData)

; Analyse data2

if (Keyword_Set(UseData2)) then $
   analysis, _EXTRA = extrakeys, pData2, d2xaxisdata, d2yaxisdata, d2zaxisdata, $
             DATANAME = d2DataName, DATALABEL = d2datalabel,DATAUNITS = d2units,  $
             XLABEL = d2x1label, YLABEL = d2x2label, ZLABEL = d2x3label, $
             XUNITS = d2x1unit, YUNITS = d2x2unit, ZUNITS = d2x3unit, $
             CVERTS = d2pcverts, CPOINTS = d2pcpoints

; Add units to labels

if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
if (x2unit ne '') then x2label = x2label +' ['+x2unit+']'
if (x3unit ne '') then x3label = x3label +' ['+x3unit+']'

for i=0,n_datasets-1 do if (units[i] ne '') then datalabel[i] = datalabel[i] +' ['+units[i]+']'

; Set Plot Titles

if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName

if N_Elements(PlotSubTitle) eq 0 then $
   PlotSubTitle = "Time = " + String(Time,Format='(f8.2)') + ' [ '+time_units+' ]'

if N_Elements(XAxisTitle) eq 0 then $ 
   XAxisTitle = x1label

if N_Elements(YAxisTitle) eq 0 then $
   YAxisTitle = x2label

if N_Elements(ZAxisTitle) eq 0 then $
   ZAxisTitle = x3label

Print, " Plotting 3D Data..."

; Plots the data (finally)

if (Keyword_Set(use_slicer)) then begin
   for i=0, n_datasets-1 do $
     Slicer3D,   _EXTRA=extrakeys, pData[i], YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
                  TITLE = PlotTitle[i], SUBTITLE = PlotSubTitle, WINDOWTITLE = filename[i],  $
                  XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                  MIN = DataMin, MAX = DataMax, INFO_STRUCT = sDataInfo

end else begin

  for i=0, n_datasets-1 do begin
     if (n_elements(pcverts) ne 0) then cverts = *pcverts[i] else undefine, cverts
     if (n_elements(pcpoints) ne 0) then cpoints = *pcpoints[i] else undefine, cpoints
     if (n_elements(d2pcverts) ne 0) then d2cverts = *pcverts[i] else undefine, d2cverts
     if (n_elements(d2pcpoints) ne 0) then d2cpoints = *pcpoints[i] else undefine, d2cpoints
      
     Plot3D,   pData[i], YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
               TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename[i],  $
               _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
               MIN = DataMin, MAX = DataMax, PMIN = ProjMin, PMAX = ProjMax ,  $
               TRAJVERT = cverts, TRAJPOINTS = cpoints, /TRAJPROJ,$
               DATA2 = pData2, TRAJ2VERT = d2cverts, TRAJ2POINTS = d2cpoints, /TRAJ2PROJ
  end

  if (n_elements(pcverts) ne 0) then ptr_free, pcverts
  if (n_elements(pcpoints) ne 0) then ptr_free, pcpoints
  if (n_elements(d2pcverts) ne 0) then ptr_free, d2pcverts
  if (n_elements(d2pcpoints) ne 0) then ptr_free, d2pcpoints
  
  ptr_free, pData
  if (N_Elements(pData2)) ne 0 then ptr_free, pData2

end

Print, "Plot Concluded"


END
