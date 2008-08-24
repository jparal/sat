 
;
;  Program:  
;
;  Osiris_Analysis_3D_VField
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

PRO Osiris_Analysis_3D_VField,_EXTRA=extrakeys, FILE1 = filename1, FILE2 = filename2, FILE3 = filename3, $ 
                     DX = useDX,  IGNORE_DIFF = noCheck,$
                     RES = PlotRes,  FACTOR = DimFactor, $
                     PSFILE = psfilename, $
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, TIME_UNITS = time_units, $
                     XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange

; **************************************************************************************************** Parameters

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
                    
; BACKGROUND 
;
; Background density (for removal)
; 
; This value is subtracted from the data  

if N_Elements(_background) eq 0 then _background = 0.0
                     
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

; SMOOTH
;
; Data Smoothing
; 
; By setting this keyword the data is smoothed using the SMOOTH function with a smoothing
; parameter equal to the one specified

if N_Elements(DataSmooth) eq 0 then DataSmooth = 0


; FILENAME1
;
; Osiris '*.dx, *.hdf' file to open
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename

if Keyword_Set(UseDX) then filter = '*.dx' else filter = '*.hdf'

if N_Elements(FileName1) eq 0 then begin  
  filename1=Dialog_Pickfile(FILTER=filter, TITLE = 'First Field Component', GET_PATH = path1)
  if (filename1 eq '') then return
end

; FILENAME2
;
; Osiris '*.dx, *.hdf' file to open
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename


if N_Elements(FileName2) eq 0 then begin  
  filename2=Dialog_Pickfile(FILTER=filter, TITLE = 'Second Field Component', GET_PATH = path2)
  if (filename2 eq '') then return
end

; FILENAME3
;
; Osiris '*.dx, *.hdf' file to open
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename

if N_Elements(FileName3) eq 0 then begin  
  filename3=Dialog_Pickfile(FILTER=filter, TITLE = 'Third Field Component', GET_PATH = path3)
  if (filename3 eq '') then return
end
 
; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 600 x 600

if N_Elements(PlotRes) eq 0 then PlotRes = [600,600]


; **************************************************************************************************** Main Code

; Check to see if files are different

if ((path1 eq path2) and (filename1 eq filename2)) or $
   ((path1 eq path3) and (filename1 eq filename3)) or $
   ((path2 eq path3) and (filename2 eq filename3)) then begin
  newres = Dialog_Message(" The same dataset is being used for two field components! ", /Error)
  return
end

 
; Gets the Data  

print, 'Reading Data...'

Osiris_Open_Data, pData, DATASETSNUMBER = 3, FILE = [filename1,filename2,filename3], PATH = [path1,path2,path3], $
                        DIM = Dims, TIMEPHYS = time, $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData,  $
                        N = n, FORCEDIMS = 3, $
                        DATATITLE = DataName, DATALABEL = DataLabel, DATAUNITS = Units, $
                        XLABEL = x1label, XUNITS = x1unit, $
                        YLABEL = x2label, YUNITS = x2unit, $
                        ZLABEL = x3label, ZUNITS = x3unit, $
                        XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, /IGNORE_TIME

s = size(pData)
if (s[0] eq 0) then begin
  if (pData eq Ptr_New()) then return
end else begin
  for i=0,2 do begin
     if (pData[i] eq Ptr_New()) then begin
        ptr_free, pData
        return
     end
  end
end
; Resizes the matrix

if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1) or (DimFactor[2] gt 1))  then begin

  n = n / DimFactor

  for i=0,2 do begin
    *pData[i] = Rebin(temporary(*pData[i]),n[0],n[1],n[2])
  end
  
  XAxisData = Rebin(XAxisData, n[0])
  YAxisData = Rebin(YAxisData, n[1])  
  ZAxisData = Rebin(ZAxisData, n[2])  

end

DataName = '('+DataName[0]+','+DataName[1]+','+DataName[2]+')'

if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName

if N_Elements(PlotSubTitle) eq 0 then PlotSubTitle = 'Time = ' + String(Time,Format='(f7.2)') + ' [ '+time_units+' ]'

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

Print, " Plotting 3D Vector Data..."

; Plots the data (finally)


Plot3Dvector, pData, YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisData, $
               TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, $
               _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
               RES = plotRES


; Free the Memory

ptr_free, pData

Print, "Plot Concluded"


END