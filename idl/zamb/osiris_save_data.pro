pro Osiris_Save_Data, pData, FILE=FileName, PATH = filepath, DIALOGTITLE = DialogTitle, $
                            XAXIS = XAxis, YAXIS = YAxis, ZAXIS = ZAxis, $
                            TIMEPHYS = time, TIMESTEP = iter, $
                            DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                            XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                            YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                            ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit, $
                            EXTRA_ATTR = sExtra_Attr

  ; DIALOGTITLE
  ;
  ; The title for the dialog box that chooses a file

  if N_Elements(DialogTitle) eq 0 then DialogTitle = 'Choose file'

  ; PATH
  ;
  ; Path for the file
  
  if N_Elements(filepath) eq 0 then filepath = '' 
 
  ; FILE
  ;
  ; filename to write. If not specified the routine prompts the user for the filename
  
  if N_Elements(FileName) eq 0 then begin  
     filename = Dialog_PickFile(/write, FILTER = '*.hdf', TITLE = DialogTitle)
     if (filename eq '') then return
     cd, current = filepath
  end

  S = Size(*pData)
  Dims = S[0]
  
  if ((Dims lt 1) or (Dims gt 3)) then begin
    print, 'Osiris_Save_Data, pData must be pointer to a 1, 2 or 3 Dimensional array'
    return
  end

  dxN = LonArr(Dims)
  for i=0, Dims-1 do begin
    dxN[i] = S[i+1] 
;    print, 'Array Dimension',i,dxN[i]
  end
  

  ; XAXIS
  ;
  ; X Axis for the data
  
  if (N_Elements(XAxis) eq 0) then XAxis = FIndGen(dxN[0])

  ; YAXIS
  ;
  ; Y Axis for the data
  
  if (Dims ge 2) and (N_Elements(XAxis) eq 0) then YAxis = FIndGen(dxN[1])

  ; ZAXIS
  ;
  ; Y Axis for the data
  
  if (Dims eq 3) and (N_Elements(ZAxis) eq 0) then ZAxis = FIndGen(dxN[2])

  ; TIMEPHYS
  ;
  ; Physical time to save on the file
  
  if (N_Elements(time) eq 0) then time = 0.
  
  ; TIMESTEP
  ;
  ; Timestep to save on the file
  
  if (N_Elements(iter) eq 0) then iter = 0
  
  ; DATATITLE
  ;
  ; DataTitle to save on the file
  
  if N_Elements(DataName) eq 0 then DataName = 'Osiris Data'
  
  ; DATAFORMAT
  ;
  ; Data format to save on the file
  
  if N_Elements(format) eq 0 then format = 'F5.2'
  
  ; DATALABEL
  ;
  ; Data Label
  
  if N_Elements(Label) eq 0 then Label = 'Data'
  
  ; DATAUNITS
  ;
  ; Units for the data
  
  If N_Elements(Units) eq 0 then units = 'a.u.'
  
  ; [XYZ]NAME
  ;
  ; Axis Name
  
  if N_Elements(x1name) eq 0 then x1name = 'x1 axis'
  if N_Elements(x2name) eq 0 then x2name = 'x2 axis'
  if N_Elements(x3name) eq 0 then x3name = 'x3 axis'
  
  ; [XYZ]FORMAT
  ;
  ; Axis Number format
  
  if N_Elements(x1format) eq 0 then x1format = 'F5.2'
  if N_Elements(x2format) eq 0 then x2format = 'F5.2'
  if N_Elements(x3format) eq 0 then x3format = 'F5.2'
  
  ; [XYZ]LABEL
  ;
  ; Axis Labels
  
  if N_Elements(x1label) eq 0 then x1label = 'x1'
  if N_Elements(x2label) eq 0 then x2label = 'x2'
  if N_Elements(x3label) eq 0 then x3label = 'x3'
  
  ; [XYZ}UNITS
  
  if N_Elements(x1unit) eq 0 then x1unit = 'a.u.'
  if N_Elements(x2unit) eq 0 then x2unit = 'a.u.'
  if N_Elements(x3unit) eq 0 then x3unit = 'a.u.'
  

  ;-------------------------------------------- Write HDF File -----------------------------



  ; Create HDF_SD file

  sdfileID = HDF_SD_Start(filename, /create)

  ; Add Data

  sdsID = HDF_SD_Create(sdFileID, DataName, dxN, /DFNT_FLOAT32)

  HDF_SD_AddData, sdsID, *pData

  ; Add User defined Attributes to the sds

  HDF_SD_AttrSet, sdsID, 'ITER', iter

  HDF_SD_AttrSet, sdsID, 'TIME', time

  ; Add predefined attributes to the sds

  HDF_SD_SetInfo, sdsID, UNIT = units, LABEL = label, FORMAT = format 

  ; Add x-axis information

  dim0ID = HDF_SD_DimGetID(sdsID, 0)

  HDF_SD_DimSet, dim0ID, $
               Label = x1label, $
               Name = x1name, $
               Scale = XAxis, $
               Unit = x1unit, $
               Format = x1format 
 
  ; Add y-axis information

  if (Dims ge 2) then begin
    dim1ID = HDF_SD_DimGetID(sdsID, 1)

    HDF_SD_DimSet, dim1ID, $
               Label = x2label, $
               Name = x2name, $
               Scale = YAxis, $
               Unit = x2unit, $
               Format = x2format 
  
  end

  ; Add z-axis information

  if (Dims eq 3) then begin
    dim2ID = HDF_SD_DimGetID(sdsID, 2)

    HDF_SD_DimSet, dim2ID, $
               Label = x3label, $
               Name = x3name, $
               Scale = ZAxis, $
               Unit = x3unit, $
               Format = x3format 
  
  end

  ; Close the file

  HDF_SD_End, sdfileID
  
  
end
