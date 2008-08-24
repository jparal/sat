
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

PRO Osiris_Analysis_2D_VField,_EXTRA=extrakeys, FILE1 = FileName1, FILE2 = FileName2, $
                     SMOOTH = DataSmooth, RES = PlotRes, $
                     PSFILE = psfilename, $
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle, $
                     BACKDATA = backdata, BACKFILE = backfile, DX = useDX, CHARSIZE = Charsize, $
                     XRANGE = xrange, YRANGE = yrange, TIME_UNITS = time_units

; **************************************************************************************************** Parameters

; TIME_UNITS
;
; Units to display next to the time information

if N_Elements(time_units) eq 0 then time_units = '1 / !Mw!Dp!N'


if N_Elements(XAxisTitle) eq 0 then XAxisTitle = ''
if N_Elements(YAxisTitle) eq 0 then YAxisTitle = ''
if N_Elements(ZAxisTitle) eq 0 then ZAxisTitle = ''

if N_Elements(Charsize) eq 0 then Charsize = 1.2

; PSFILE
;
; Outputs the plot to a PS file
;
; Set this parameter to the name of the PS you want to output your data to
 
if N_Elements(psfilename) eq 0 then useps = 0 $
else useps = 1
                    
; SMOOTH
;
; Data Smoothing
; 
; By setting this keyword the data is smoothed using the SMOOTH function with a smoothing
; parameter equal to the one specified

if N_Elements(DataSmooth) eq 0 then DataSmooth = 0

; EXTENSION
;
; Data Filename Extension
;
; The data filename extension, for raw data dumps on a single processor run

if N_Elements(FileNameExtension) eq 0 then FIleNameExtension = ""

if (N_Elements(UseDX) eq 0) then UseDX = 0

if (UseDX gt 0) then filter = '*.dx' else filter = '*.hdf'

; FILENAME1
;
; Osiris '*.dx' file to open (1st vector component [x])
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename

if N_Elements(FileName1) eq 0 then begin  
  filename1=Dialog_Pickfile(FILTER=filter, TITLE = 'First Field Component', GET_PATH = path1)
  if (filename1 eq '') then return
end

; FILENAME2
;
; Osiris '*.dx' file to open (2st vector component [y])
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename

if N_Elements(FileName2) eq 0 then begin  
  filename2=Dialog_Pickfile(FILTER=filter, TITLE = 'Second Field Component', GET_PATH = path2)
  if (filename2 eq '') then return
end

; BACKDATA
;
; Use a third dataset for the background color plot, instead of the modulus of the vectors

if N_Elements(BackData) eq 0 then BackData = 0 

; BACKFILE
;
; Osiris '*.dx' file to open (background data)
;
; If not specified, the program will automatically open a file select dialog box to prompt the
; user for this filename

if (N_Elements(BackFile) eq 0) and (BackData gt 0) then begin  
  BackFile=Dialog_Pickfile(FILTER=filter, TITLE = 'Background data', GET_PATH = path0)
  if (BackFile eq '') then return
end

; RES
;
; Plot Resolution
;
; This parameter sets the resolution for the window with the plot. The default
; resolution is 640 x 480

if N_Elements(PlotRes) eq 0 then PlotRes = [640,480]

; **************************************************************************************************** Main Code

; Check to see if files are different

if ((path1 eq path2) and (filename1 eq filename2)) then begin
  newres = Dialog_Message(" Dataset 1 is the same as Dataset 2! ", /Error)
  return
end

; Open the two data sets

Osiris_Open_Data, pData1, FILE = filename1, DIM = Dims1, DATATITLE = DataName1, TIMEPHYS = time1, $
                         XAXIS = XAxisData1, YAXIS = YAxisData1, PATH = path1, EXTENSION = FileNameExtension,$
                         N = n1, DX = UseDX

Osiris_Open_Data, pData2, FILE = filename2, DIM = Dims2, DATATITLE = DataName2, TIMEPHYS = time2, $
                         XAXIS = XAxisData2, YAXIS = YAxisData2, PATH = path2, EXTENSION = FileNameExtension, $
                         N = n2, DX = UseDX

; Test yhe validity of the files

if ((Dims1 ne 2) or (Dims2 ne 2)) then begin
  newres = Dialog_Message('The two datasets must be 2D!', /Error)
  return
end

if ((n1[0] ne n2[0]) or (n1[1] ne n2[1])) then begin
  newres = Dialog_Message('The two datsets must have the same dimensions!', /Error)
  return
end

for i = 0, n1[0]-1 do begin
  if (XAxisData1[i] ne XAxisData2[i]) then begin
    newres = Dialog_Message('The axis for the two datsets must be equal!', /Error)
    return
  end
end

for i = 0, n1[1]-1 do begin
  if (YAxisData1[i] ne YAxisData2[i]) then begin
    newres = Dialog_Message('The axis for the two datsets must be equal!', /Error)
    return
  end
end

if (time1 ne time2) then begin
  newres = Dialog_Message('The two datasets must correspond to the same simulation time!', /Error)
  return
end



; Third (optional) dataset

if (BackData gt 0) then begin
  Osiris_Open_Data, pData0, FILE = BackFile, DIM = Dims0, DATATITLE = DataName0, TIMEPHYS = time0, $
                           XAXIS = XAxisData0, YAXIS = YAxisData0, PATH = path0, EXTENSION = FileNameExtension,$
                           N = n0, DX = UseDX

  if (Dims0 ne 2) then begin
    newres = Dialog_Message('The background datasets must be 2D!', /Error)
    return
  end

  if ((n0[0] ne n2[0]) or (n1[1] ne n2[1])) then begin
    newres = Dialog_Message('The background datsets must have the same dimensions!', /Error)
    return
  end

  for i = 0, n1[0]-1 do begin
    if (XAxisData0[i] ne XAxisData2[i]) then begin
      newres = Dialog_Message('The axis for the background datset must be equal!', /Error)
      return
    end
  end

  for i = 0, n1[1]-1 do begin
    if (YAxisData0[i] ne YAxisData2[i]) then begin
      newres = Dialog_Message('The axis for the background datset must be equal!', /Error)
      return
    end
  end

  if (time0 ne time2) then begin
    newres = Dialog_Message('The background dataset must correspond to the same simulation time!', /Error)
    return
  end  
end

; Returns to the first dataset's dir
; help, path1
cd, path1[0]

; Graphic display Initialization

Device, Get_Visual_Depth = thisDepth
If (thisDepth GT 8) Then Device, Decomposed = 0

; Smooths Data

if (DataSmooth gt 0) then begin
   if (DataSmooth lt 2) then DataSmooth = 2
   print, " Smoothing data, window size of", DataSmooth
   *pData1 = Smooth(*pData1, DataSmooth,/Edge_Truncate)
   *pData2 = Smooth(*pData2, DataSmooth,/Edge_Truncate)   
end

; Calculates the modulus of the field (if necessary)

if (BackData eq 0) then pData0 = ptr_new(sqrt((*pData1)^2 + (*pData2) ^2))

; Defines Titles 

if N_Elements(PlotTitle) eq 0 then PlotTitle = '('+DataName1+','+DataName2+')'

if (BackData gt 0) then PlotTitle = PlotTitle + ';' + DataName0

if N_Elements(PlotSubTitle) eq 0 then $
     PlotSubTitle = 'Time = ' + String(Time1,Format='(f7.2)') + ' [ '+time_units+' ]'

; Opens new graphics window or PS file

if (useps eq 0) then begin
   WindowTitle = filename1
   Window, /Free, Title = WindowTitle, Xsize = PlotRes[0], Ysize =PlotRes[1]
end else begin
   thisDevice = !D.Name
   Set_Plot, 'PS'

   print, ' About to configure PS device '
   
   Device, /helvetica, Color=1, Bits_per_Pixel=8, File= psfilename, Xsize = PlotRes[0], Ysize =PlotRes[1]
end

!P.Charsize =  CharSize


; Plots Data0 (background scalar information)

Print, " Plotting 2D Data..."

Plot2D,        pData0, YAXIS = YAxisData1, XAXIS = XAxisData1, /dg, $
               TITLE = PlotTitle, SUBTITLE = PlotSubTitle, $
               _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
               XRANGE = xrange, YRANGE = yrange

print, 'Data Range Used      '
print, '---------------------'
print, 'xrange = ', xrange
print, 'yrange = ', yrange
               
; gets the new range

n11 = long((xrange[0] - XAxisData1[0])/(XAxisData1[1]-XAxisData1[0]))
n12 = long((xrange[1] - XAxisData1[0])/(XAxisData1[1]-XAxisData1[0]))

n21 = long((yrange[0] - YAxisData1[0])/(YAxisData1[1]-YAxisData1[0]))
n22 = long((yrange[1] - YAxisData1[0])/(YAxisData1[1]-YAxisData1[0]))

print, 'n11, n12', n11, n12
print, 'n21, n22', n21, n22

;*pData1 = (*pData1)[n11:n12, n21:n22]
;*pData2 = (*pData2)[n21:n22, n21:n22]

; Overplots the vectors (Data1, Data2) 

LoadCT, 0
oPlot2DVector, pData1, pData2, ScaleType = 1, _EXTRA=extrakeys, COLOR = -1

; Closes the PS file

if (useps eq 1) then begin
   Device, /Close_File
   Set_Plot, thisDevice
end

ptr_free, pData1, pData2, pData0

Print, "Plot Concluded"


END