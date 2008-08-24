
PRO Osiris_Analysis_3HALVES,_EXTRA=extrakeys, OLD = old, $
                     ; Directory and file information
                     FILE = FileName, PATH = filepath, EXTENSION = FileNameExtension, DX = useDX, $
                     ; Data operations
                     NDATASETS = n_datasets, $
                     ; Axis Ranges
                     XRANGE = xrange, YRANGE = yrange, $
                     ; Plot options
                     RES = PlotRes,  PSFILE = psfilename, $
                     ; Titles and labels
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units
                     

; **************************************************************************************** Parameters

; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'

; PSFILE
;
; Outputs the plot to a PS file
;
; Set this parameter to the name of the PS you want to output your data to

if N_Elements(psfilename) eq 0 then useps = 0 $
else useps = 1

; EXTENSION
;
; Data Filename Extension (obsolete, kept for compatibility with old osiris output)
;
; The data

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 640 x 480

if N_Elements(PlotRes) eq 0 then begin
;   if (usePS eq 0) then PlotRes = [600,400] $
;   else PlotRes = [10,10]
   if keyword_set(usePS) then PlotRes = [10,10]
end

; NDATASETS
;
; Number of datasets to analyse
;
; Set this parameter to the number of datasets to analyse. The default is 1

if N_Elements(n_datasets) eq 0 then n_datasets = 1 $
else if (n_datasets lt 1) then n_datasets = 1


; ****************************************************************************************** Main Code

; Graphic display Initialization

Device, Get_Visual_Depth = thisDepth
If (thisDepth GT 8) Then Device, Decomposed = 0

; Gets the Data

Osiris_Open_Data, pData, FORCEDIMS = 2, DATASETSNUMBER = n_datasets, $
                  FILE = filename, PATH = filepath, DX = UseDX, EXTENSION = FileNameExtension, $                      
                  TIMEPHYS = time, $
                  DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                  XAXIS = XAxisData, XLABEL = x1label, XUNITS = x1unit, $
                  YAXIS = YAxisData, YLABEL = x2label, YUNITS = x2unit, INFO_STRUCT = sDataInfo

if (pData[0] eq PTR_NEW()) then return

; Analyse the data (INFO_STRUCT NOT YET IMPLEMENTED IN ANALYSIS!!!)

analysis, _EXTRA = extrakeys, pData, xaxisdata, yaxisdata, $
          DATANAME = DataName, DATALABEL = datalabel,DATAUNITS = units,  $
          XLABEL = x1label, YLABEL = x2label, $
          XUNITS = x1unit, YUNITS = x2unit, $
          CVERTS = pcverts, CPOINTS = pcpoints,/fft

n_datasets = N_Elements(pData)

; Add units to labels

if (x1unit ne '') then x1label = x1label +' ['+x1unit+']'
if (x2unit ne '') then x2label = x2label +' ['+x2unit+']'
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
   ZAxisTitle = DataLabel
   
Print, " Plotting 2D Data..."

; Opens new graphics window or PS file


if (useps eq 0) then begin
   if (Keyword_Set(old)) then Window, /Free, Title = filename[0], Xsize = PlotRes[0], Ysize =PlotRes[1]
end else begin
   thisDevice = !D.Name
   Set_Plot, 'PS'
   print, ' About to configure PS device '
   Device, Color=1, Bits_per_Pixel=8, File= psfilename, Xsize = PlotRes[0], Ysize = PlotRes[1]
end

resu = size(*pData[0],/dimensions)
;print,resu[2], resu
LineAve=fltarr(resu[0])


if(N_Elements(nk) eq 0) then $
    nkr= 100
if(N_Elements(npoints) eq 0) then $
    npoints = 360

LineAve=fltarr(nkr)

max1=max(xaxisdata)
max2=max(yaxisdata)
if(max1 ge max2) then kmax=max2 else kmax=max1
kraxis=fltarr(nkr)
kraxis=kmax*findgen(nkr)/nkr

dkx = xaxisdata[2]-xaxisdata[1]
dky = yaxisdata[2]-yaxisdata[1]
iarea = 1.0/(dkx*dky)

dkr = 1/nkr*kmax
for i = 0,nkr-1 do begin
    kr = i*dkr
    LineAve[i]=0.0
    for j=0,npoints-1 do begin
        theta=2*!pi*j/npoints
        kx=kr*cos(theta)
        ky=kr*sin(theta)
        ndx=(kx-xaxisdata[0])/dkx
        ndy=(ky-yaxisdata[0])/dky
        
        indx=fix(ndx)
        indy=fix(ndy)
        deltax=ndx-indx
        deltay=ndy-indy
        weighted=(deltax*deltay)*(*pData)[indx+1,indy+1] + $
        ((1.0-deltax) * deltay) *(*pData)[indx,  indy+1] + $
        (deltax * (1.0-deltay)) *(*pData)[indx+1,  indy] + $
        ((1.0-deltax) * (1.0-deltay)) *(*pData)[indx,  indy]
        
        LineAve[i]=LineAve[i]+weighted
        
        
        
        
        
    end
        LineAve[i]=i*LineAve[i]
end
        
print,max1,max2    

  for i=0, n_datasets-1 do begin
      if (n_elements(pcverts) ne 0) then cverts = *pcverts[i] else undefine, cverts
      if (n_elements(pcpoints) ne 0) then cpoints = *pcpoints[i] else undefine, cpoints
datatemp=*pData[i]
LineAve=total(datatemp,2)
LineAve=LineAve/resu[0]
      Plot1D,      XaxisData,LineAve,$
                   TITLE = PlotTitle[i], SUBTITLE = PlotSubTitle, RES = PlotRES, $
                   _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = ZAxisTitle[i], $
                   WINDOWTITLE = filename[i], $
                   /no_share, INFO_STRUCT = sDataInfo
  end



; Closes the PS file if necessary

if (useps eq 1) then begin
   Device, /Close_File
   Set_Plot, thisDevice
end

Print, "Plot Concluded"


END
