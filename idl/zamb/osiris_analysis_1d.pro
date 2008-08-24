
;
;  Program:
;
;  Osiris_Analysis_1D
;
;  Description:
;
;  Opens 1D data output from the osiris code and plots it


pro gamma_one, x, a, f, pder
  f = (x)*exp(-x/a[1])
  if (n_params() ge 4) then $
    pder = [ [f], $      ; partial derivative with regard to a[0]
             [x*a[0]*f/a[1]^2] ]              ; partial derivative with regard to a[1]
  f = a[0]*temporary(f)
end

PRO Osiris_Analysis_1D,_EXTRA=extrakeys, $
                     ; File Information
                     FILE = FileName, PATH = FilePath,  EXTENSION = FileNameExtension, DX = useDX,$
                     ; Curve Fitting
                     ;CURVE_FIT = curve_fit, $
                     ; Plot Scaling
                     YLOG = UseLogScale, YRANGE = yrange, $
                     ; Plot Options
                     TIME_UNITS = time_units
                     
; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'


; Gets Data Information from the Data Explorer Header File

Osiris_Open_Data, pData, FORCEDIMS = 1, $
                  FILE = filename, PATH = filepath, DX = UseDX, EXTENSION = FileNameExtension, $                      
                  TIMEPHYS = time, $
                  DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                  XAXIS = XAxisData, XLABEL = x1label, XUNITS = x1unit

if (pData[0] eq ptr_new()) then return

; Analyse the data

analysis, _EXTRA = extrakeys, pData, xaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel, DATAUNITS = units,  $
          XLABEL = x1label, XUNITS = x1unit

n_datasets = N_Elements(pData)

; Add units to labels

if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
for i=0,n_datasets-1 do if (units[i] ne '') then datalabel[i] = datalabel[i] +' ['+units[i]+']'

if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName

if N_Elements(PlotSubTitle) eq 0 then $
   PlotSubTitle = "Time = " + String(Time,Format='(f8.2)') + ' [ '+time_units+' ]'

if N_Elements(XAxisTitle) eq 0 then $ 
   XAxisTitle = x1label

if N_Elements(YAxisTitle) eq 0 then $
   YAxisTitle = DataLabel

;###################################################################################################

; Plot the data

Print, " Plotting Data ..."

Plot1D, XAxisData, *pData[0], TITLE = PlotTitle, SUBTITLE = PlotSubTitle ,$
         _EXTRA = extrakeys, yrange = yrange, $
         xtitle = XAxisTitle, ytitle = YAxisTitle

; #############################################################################################

ptr_free, pData

Print, "Plot Concluded"


END
