
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
                     DX = useDX, $
                     RES = PlotRes,  FACTOR = DimFactor, $
                     PSFILE = psfilename, $
                     XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                     TITLE = PlotTitle, SUBTITLE = PlotSubTitle 

; **************************************************************************************************** Parameters


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

Osiris_Open_Data, Data1, FILE = filename1, DIM = Dims1, TIMEPHYS = time1, $
                        XAXIS = XAxisData1, YAXIS = YAxisData1, ZAXIS = ZAxisData1, PATH = path1, $
                        N = n1, $
                        DATATITLE = DataName1, DATALABEL = DataLabel1, DATAUNITS = Units1, $
                        XLABEL = x1label1, XUNITS = x1unit1, $
                        YLABEL = x2label1, YUNITS = x2unit1, $
                        ZLABEL = x3label1, ZUNITS = x3unit1

; Checks The Dimensions on the data

if (Dims1 ne 3) then begin
  newres = Dialog_Message(" Data is not 3-Dimensional! ", /Error)
  return
end

                        
Osiris_Open_Data, Data2, FILE = filename2, DIM = Dims2, TIMEPHYS = time2, $
                        XAXIS = XAxisData2, YAXIS = YAxisData2, ZAXIS = ZAxisData2, PATH = path2, $
                        N = n2, $
                        DATATITLE = DataName2, DATALABEL = DataLabel2, DATAUNITS = Units2, $
                        XLABEL = x1label2, XUNITS = x1unit2, $
                        YLABEL = x2label2, YUNITS = x2unit2, $
                        ZLABEL = x3label2, ZUNITS = x3unit2

; Checks The Dimensions on the data

if (Dims2 ne 3) then begin
  newres = Dialog_Message(" Data is not 3-Dimensional! ", /Error)
  return
end

; Checks the validity of the data

if ((n1[0] ne n2[0]) or (n1[1] ne n2[1]) or (n1[2] ne n2[2])) then begin
  newres = Dialog_Message('The datsets must have the same dimensions!', /Error)
  return
end

for i = 0, n1[0]-1 do begin
  if (XAxisData1[i] ne XAxisData2[i]) then begin
    newres = Dialog_Message('The axis for the datsets must be equal!', /Error)
    return
  end
end

for i = 0, n1[1]-1 do begin
  if (YAxisData1[i] ne YAxisData2[i]) then begin
    newres = Dialog_Message('The axis for the datsets must be equal!', /Error)
    return
  end
end

for i = 0, n1[2]-1 do begin
  if (ZAxisData1[i] ne ZAxisData2[i]) then begin
    newres = Dialog_Message('The axis for the datsets must be equal!', /Error)
    return
  end
end

if (time1 ne time2) then begin
  newres = Dialog_Message('The two datasets must correspond to the same simulation time!', /Error)
  return
end


Osiris_Open_Data, Data3, FILE = filename3, DIM = Dims3, TIMEPHYS = time3, $
                        XAXIS = XAxisData3, YAXIS = YAxisData3, ZAXIS = ZAxisData3, PATH = path3, $
                        N = n3, $
                        DATATITLE = DataName3, DATALABEL = DataLabel3, DATAUNITS = Units3, $
                        XLABEL = x1label3, XUNITS = x1unit3, $
                        YLABEL = x2label3, YUNITS = x2unit3, $
                        ZLABEL = x3label3, ZUNITS = x3unit3

; Checks The Dimensions on the data

if (Dims3 ne 3) then begin
  newres = Dialog_Message(" Data is not 3-Dimensional! ", /Error)
  return
end
                                               
; Checks the validity of the data

if ((n1[0] ne n3[0]) or (n1[1] ne n3[1]) or (n1[2] ne n3[2])) then begin
  newres = Dialog_Message('The datsets must have the same dimensions!', /Error)
  return
end

for i = 0, n1[0]-1 do begin
  if (XAxisData1[i] ne XAxisData3[i]) then begin
    newres = Dialog_Message('The axis for the datsets must be equal!', /Error)
    return
  end
end

for i = 0, n1[1]-1 do begin
  if (YAxisData1[i] ne YAxisData3[i]) then begin
    newres = Dialog_Message('The axis for the datsets must be equal!', /Error)
    return
  end
end

for i = 0, n1[2]-1 do begin
  if (ZAxisData1[i] ne ZAxisData3[i]) then begin
    newres = Dialog_Message('The axis for the datsets must be equal!', /Error)
    return
  end
end

if (time1 ne time3) then begin
  newres = Dialog_Message('The two datasets must correspond to the same simulation time!', /Error)
  return
end


; Resizes the matrix

if ((DimFactor[0] gt 1) or (DimFactor[1] gt 1) or (DimFactor[2] gt 1))  then begin

  n1[0] = n1[0] / DimFactor[0]
  n1[1] = n1[1] / DimFactor[1]
  n1[2] = n1[2] / DimFactor[2]

  Data1 = Rebin(Data1, n1[0],n1[1],n1[2])
  Data2 = Rebin(Data2, n1[0],n1[1],n1[2])
  Data3 = Rebin(Data3, n1[0],n1[1],n1[2])
  
  XAxisData1 = Rebin(XAxisData1, n1[0])
  YAxisData1 = Rebin(YAxisData1, n1[1])  
  ZAxisData1 = Rebin(ZAxisData1, n1[2])  

end

if N_Elements(PlotTitle) eq 0 then PlotTitle = DataName1

if N_Elements(PlotSubTitle) eq 0 then PlotSubTitle = 'Time = ' + String(Time1,Format='(f7.2)') + ' [ 1 / !Mw!Dp!N ]'

if N_Elements(XAxisTitle) eq 0 then begin
   XAxisTitle = x1label1
   if (x1unit1 ne '') then XAxisTitle = XAxisTitle +' ['+x1unit1+']'
end

if N_Elements(YAxisTitle) eq 0 then begin
   YAxisTitle = x2label1
   if (x2unit1 ne '') then YAxisTitle = YAxisTitle+' ['+x2unit1+']'
end

if N_Elements(ZAxisTitle) eq 0 then begin
   ZAxisTitle = x3Label1
   if (x3unit1 ne '') then ZAxisTitle = ZAxisTitle+' ['+x3unit1+']'
end

Print, " Plotting 3D Data..."

; Opens new PS file
;
;if (useps eq 1) then begin
;   thisDevice = !D.Name
;   Set_Plot, 'PS'
;
;   print, ' About to configure PS device '
;   
;   Device, /helvetica, Color=1, Bits_per_Pixel=8, File= psfilename
;end

; Plots the data (finally)

Data = FltArr(3,n1[0],n1[1],n1[2])
Data[0,*,*,*] = Data1
Data[1,*,*,*] = Data2
Data[2,*,*,*] = Data3

Data1 = 0
Data2 = 0
Data3 = 0

Plot3Dvector,  Data, YAXIS = YAxisData1, XAXIS = XAxisData1, ZAXIS = ZAxisData1, $
               TITLE = PlotTitle, SUBTITLE = PlotSubTitle, WINDOWTITLE = filename, $
               _EXTRA=extrakeys, XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
               RES = plotRES

; Closes the PS file
;
;if (useps eq 1) then begin
;   Device, /Close_File
;   Set_Plot, thisDevice
;end


Print, "Plot Concluded"


END
