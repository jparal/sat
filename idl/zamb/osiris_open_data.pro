
;  Program:
;
;  Osiris_Open_Data
;
;  Description:
;
;  Opens data output from the osiris code, and generates the appropriate axis information
;
;  Current Version: (2 - Mar -2000)
;
;  0.4 : Added extra information from HDF files. Also generates this info automatically for dx files
;
;  History
;
;  0.3 : Added HDF support
;
;  0.2 : Added Extra information from AnaliseDX
;
;  0.1 : Basic version
;
; *****************************************************************************************************************
;
; Parameter list:
;
; EXTENSION (in)
;
; Data Filename Extension
;
; DIALOGTITLE (in)
;
; The title for the dialog box that opens a file
;
; PATH (in/out)
;
; Path for the file
;
; FILE (in/out)
;
; '*.hdf' or '*.dx' file to open
;
; DX (in)
;
; If set the extension in the open file dialog is '*.dx'. The default extension is '*.hdf'
; Has no effect if a filename is supplied
;
; DIM (out)
;
; Number of Dimensions of the dataset chosen
;
; N (out)
;
; Vector with DIM dimensions containing the dataset dimensions
;
; ORIGIN (out)
;
; Origin for the data axis
;
; DELTA (out)
;
; Increment for the data axis
;
; DATAFILE (out)
;
; The name of actual data file chosen
;
; TIMEPHYS (out)
;
; The simulation physical time corresponding to the dataset chosen
;
; TIMESTEP (out)
;
; The simulation timestep corresponding to the dataset chosen
;
; DATATITLE (out)
;
; Name of the dataset chosen
;
; DATALABEL (out)
;
; The label for the dataset chosen
;
; DATAFORMAT (out)
;
; The number format for this data
;
; DATAUNITS
;
; The units for this data
;
; [XYZ]NAME (out)
;
; Name of the axis chosen
;
; [XYZ]LABEL (out)
;
; The label for the axis chosen
;
; [XYZ]FORMAT (out)
;
; The number format for this axis
;
; [XYZ]UNITS (out)
;
; The units for this axis
;
; [XYZ]RANGE (in)
;
; The range of data to be opened. The routine also updates the axes accordingly

pro __get_subrange, pData, $                        ; Pointer to the Data
                    xrange, XAxisData, XIDX=xidx, XSUB = xsubrange,$
                    yrange, YAxisData, YIDX=yidx, YSUB = ysubrange,$
                    zrange, ZAxisData, ZIDX=zidx, ZSUB = zsubrange

 ; xsubrange = 0
 ; ysubrange = 0
 ; zsubrange = 0

 ; return

  Dims = 1
  if (N_Elements(YAxisData) ne 0) then Dims = 2
  if (N_Elements(ZAxisData) ne 0) then Dims = 3

  nx = N_Elements(XAxisData)

  ; Extracts the appropriate range (X axis)

  delx = XAxisData[1]-XAxisData[0]

  minx = XAxisData[0]

  n1x = floor((xrange[0] - minx)/delx)
  n2x = ceil((xrange[1] - minx)/delx)

;  print, 'xrange', xrange
;  print, 'Max(XaxisData)', Max(XAxisData)
;  print, 'n1x, n2x ', n1x, n2x

  ; Check if not outside the dataset

  if (n1x lt 0) then n1x = 0
  if (n2x gt nx-1) then n2x = nx-1

  ; Check if needs to get subset

  if (n1x eq 0 and n2x eq nx-1) then begin
    xsubrange = 0
  end else begin
    xsubrange = 1
    if (ptr_valid(pData)) then begin
      case (Dims) of
        3:  *pData = (temporary(*pData))[n1x:n2x,*,*]
        2:  *pData = (temporary(*pData))[n1x:n2x,*]
        1:  *pData = (temporary(*pData))[n1x:n2x]
      endcase
    end
    xidx = [n1x,n2x]
  end

  if (Dims ge 2) then begin
    ; Extracts the appropriate range (Y axis)
    ny = N_Elements(YAxisData)
    dely = YAxisData[1]-YAxisData[0]
    miny = YAxisData[0]

    n1y = floor((yrange[0] - miny)/dely)
    n2y = ceil((yrange[1] - miny)/dely)

;    print, 'n1y, n2y ', n1y, n2y

    ; Check if not outside the dataset

    if (n1y lt 0) then n1y = 0
    if (n2y gt ny-1) then n2y = ny-1

    ; Check if needs to get subset

    if (n1y eq 0 and n2y eq ny-1) then begin
      ysubrange = 0
    end else begin
      ysubrange = 1
      if (ptr_valid(pData)) then begin
        case (Dims) of
          3:  *pData = (temporary(*pData))[*,n1y:n2y,*]
          2:  *pData = (temporary(*pData))[*,n1y:n2y]
        endcase
      end
      yidx = [n1y,n2y]
    end

  end

  if (Dims eq 3) then begin
    ; Extracts the appropriate range (Z axis)
    nz = N_Elements(ZAxisData)
    delz = ZAxisData[1]-ZAxisData[0]
    minz = ZAxisData[0]

    n1z = floor((zrange[0] - minz)/delz)
    n2z = ceil((zrange[1] - minz)/delz)

;    print, 'n1z, n2z ', n1z, n2z

    ; Check if not outside the dataset

    if (n1z lt 0) then n1z = 0
    if (n2z gt nz-1) then n2z = nz-1

    ; Check if needs to get subset

    if (n1z eq 0 and n2z eq nz-1) then begin
      zsubrange = 0
    end else begin
      zsubrange = 1
      if (ptr_valid(pData)) then *pData = (temporary(*pData))[*,*,n1z:n2z]
      zidx = [n1z,n2z]
    end

  end


end

;--------------------------------------------------------------------------------------------------------------
;__open_data, FileName
;
;Opens the datafile specified by FileName, together with the additional info. If /INFO_ONLY is specified then
;no data is actually read, only the file information. Also if the dimensions axis and time information are
;specified, only opens a file that matches this information. (axis and time information can be ignored if the
; /IGNORE_DIFF is set)
;
;--------------------------------------------------------------------------------------------------------------


function __open_data, pData, FileName, XAXIS = XAxisData0, YAXIS = YAxisData0, ZAXIS = ZAxisData0, $
                      DIM = Dims0, N = dxN0, ORIGIN = dxOrigin, PATH = filepath,EXTENSION = FIleNameExtension,$
                      DELTA = dxDelta, TIMEPHYS = time0, TIMESTEP = timestep, $
                      DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                      XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                      YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                      ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit, $
                      INFO_ONLY = noData, IGNORE = noCheck  
  on_error, 2

  if N_Elements(filepath) ne 0 then begin
     if (filepath ne '') then cd, filepath
  end

  if N_Elements(noData) eq 0 then noData = 0

  filetype = 0 ; Data Explorer Format

  if (N_Elements(noCheck) eq 0) then noCheck = 0b

  ; The following code is for going arround a bug in HDF_isHDF
  ; that only allows the user to open files in the current directory
  ; specifying an additional path in the filename results in
  ; HDF_isHDF returning false
  ; the old path is restored at the end of the routine

  cd, current = oldpath
  pos = rstrpos(filename, ':')
  if (pos ne -1) then begin
    newpath = filename
    filename = strmid(newpath, pos+1, strlen(newpath) -1)
    newpath = strmid(newpath, 0, pos)
    cd, newpath
  end

  ; Checks if the file exists

  test = findfile(filename, COUNT = count)
  if (count eq 0) then begin
    res = Error_Message("File not found!")
    return, -1
  end
  

  if HDF_IsHDF(filename) then filetype = 1      ; HDF Format

  ; Gather Information

  case (filetype) of
    1: begin                                    ; HDF Format
         ; Open HDF File

         sdFileID = HDF_SD_Start(filename, /Read)

         ; Select dataset (first dataset)

         sdsID = HDF_SD_Select(sdFileID, 0)

         ; Get Dataset info (predefined attributes)

         HDF_SD_GetInfo, sdsID, COORDSYS = coordsys, DIMS = dxN, /NOREVERSE, FORMAT = format, LABEL = label, $
                            NAME = DataName, NDIMS = Dims, UNIT = Units

         dxN = reverse(dxN)

         ; Get iter num and simulation time
         timeidx = HDF_SD_AttrFind(sdsID, 'TIME')
         timestepidx = HDF_SD_AttrFind(sdsID, 'ITER')

         HDF_SD_AttrInfo, sdsID, timeidx, DATA = time
         HDF_SD_AttrInfo, sdsID, timestepidx, DATA = timestep

         ; Reads the axis information

         dimID0 = HDF_SD_DimGetID(sdsID, 0)  ; Xaxis
         HDF_SD_DimGet, dimID0, SCALE = XAxisData, FORMAT = x1format, LABEL = x1label, NAME = x1name, $
                            UNIT = x1unit

         if ((Dims ge 2)) then begin
           dimID1 = HDF_SD_DimGetID(sdsID, 1)  ; Yaxis
           HDF_SD_DimGet, dimID1, SCALE = YAxisData, FORMAT = x2format, LABEL = x2label, NAME = x2name, $
                              UNIT = x2unit
         end

         if ((Dims ge 3)) then begin
           dimID2 = HDF_SD_DimGetID(sdsID, 2)  ; Yaxis
           HDF_SD_DimGet, dimID2, SCALE = ZAxisData, FORMAT = x3format, LABEL = x3label, NAME = x3name, $
                              UNIT = x3unit
         end

         ; Close the dataset

         HDF_SD_EndAccess, sdsID

         ; Close the file

         HDF_SD_End, sdFileID

         ; Create obsolete information for compatibility

         dxOrigin = DBLARR(Dims)
         dxOrigin[0] = XAxisData[0]
         if (Dims ge 2) then dxOrigin[1] = YAxisData[0]
         if (Dims eq 3) then dxOrigin[2] = ZAxisData[0]

         dxDelta  = DblArr(Dims, Dims)
         dxDelta[0,0] = XAxisData[1] - XAxisData[0]
         if (Dims ge 2) then dxDelta[1,1] = YAxisData[1] - YAxisData[0]
         if (Dims eq 3) then dxDelta[2,2] = ZAxisData[1] - ZAxisData[0]

       end
    0: begin                                ; Data Explorer Format

         AnaliseDx,  FileName, DIM = Dims, DATATITLE = DataName, N = dxN, ORIGIN = dxOrigin, $
                 DELTA = dxDelta, DATAFILE = datafilename, TIMEPHYS = time, TIMESTEP = timestep
         DataFileName = datafilename + FileNameExtension

         ; Calculates Axis

         XAxisData = FIndGen(dxN[0])*(dxN[0]*dxDelta[0,0])/(dxN[0]-1) + dxOrigin[0]

         if ((Dims ge 2)) then $
            YAxisData = FIndGen(dxN[1])*(dxN[1]*dxDelta[1,1])/(dxN[1]-1) + dxOrigin[1]
         if ((Dims ge 3)) then $
            ZAxisData = FIndGen(dxN[2])*(dxN[2]*dxDelta[2,2])/(dxN[2]-1) + dxOrigin[2]
         format = 'F5.2'           ; default format
         Label = DataName          ; default label equal to dataname
         Units=''                  ; default units (none)

         ; Default axis info

         x1name = 'x1 axis'
         x1format = 'F5.2'
         x1label = 'x1'
         x1unit =''

         ; Default axis info

         x2name = 'x2 axis'
         x2format = 'F5.2'
         x2label = 'x2'
         x2unit =''

         ; Default axis info

         x3name = 'x3 axis'
         x3format = 'F5.2'
         x3label = 'x3'
         x3unit =''

       end
  end

  ; Test information for discrepancies
  
 ;  help, nocheck

  ; Checks the number of dimensions of the file
  if (N_Elements(Dims0) ne 0) then begin
       if (Dims0 ne Dims) then begin
         Dims0 = 0
         res = Error_Message("Number of dimensions doesn't match")
         return, -2
       end
  end

  ; Checks the dimensions of the data

;  if (N_Elements(dxN0) ne 0) then begin
;       for j = 0, Dims-1 do begin
;         if (dxN0[j] ne dxN[j]) then begin
;           Dims0 = 0
;           res = Error_Message('All files must have the same dimensions')
;           return, -3
;         end
 ;      end
;  end

  Dims0 = Dims
  dxN0 = dxN

  ; Check Axis information (unless specified otherwise)

  if not (noCheck and 2b) then begin

     ; Checks the XAxis

     if (N_Elements(XAxisData0) ne 0) then begin
         for j = 0, dxN[0]-1 do begin
           if (XAxisData0[j] ne XAxisData[j]) then begin
             Dims = 0
             res = Error_Message('The X-Axis for all the datasets must be equal')
             return, -4
           end
         end
     end

     ; Checks the YAxis (if necessary)

     if (N_Elements(YAxisData0) ne 0) then begin
         if (Dims ge 2) then for j = 0, dxN[1]-1 do begin
             if (YAxisData0[j] ne YAxisData[j]) then begin
               Dims = 0
               res = Error_Message('The Y-Axis for all the datasets must be equal')
               return, -5
             end
         end
     end

     ; Checks the ZAxis (if necessary)

     if (N_Elements(ZAxisData0) ne 0) then begin
         if (Dims eq 3) then for j = 0, dxN[2]-1 do begin
             if (ZAxisData0[j] ne ZAxisData[j]) then begin
               Dims = 0
               res = Error_Message('The Z-Axis for all the datasets must be equal')
               return, -6
             end
         end
     end
   
   end
      
   if not (noCheck and 1b) then $  
     ; Checks the simulation time

     if (N_Elements(time0) ne 0) then $
       if (time0[0] ne time[0]) then begin
              Dims = 0
              res = Error_Message('All datasets must correspond to the same simulation time!')
              return, -7
       end

  XAxisData0 = XAxisData
  if (Dims ge 2) then YAxisData0 = YAxisData
  if (Dims eq 3) then ZAxisData0 = ZAxisData
  time0 = time[0]

  ; Read the actual data

  if (noData) eq 0 then begin
    case (filetype) of
      1: begin                                    ; HDF File

           ; Open HDF File

           sdFileID = HDF_SD_Start(filename, /Read)

           ; Select dataset (first dataset)

           sdsID = HDF_SD_Select(sdFileID, 0)

           ; Read the Data

           HDF_SD_GetData, sdsID, Data

           ; Close the dataset

           HDF_SD_EndAccess, sdsID

           ; Close the file

           HDF_SD_End, sdFileID
         end

      0: begin
           ; Allocate memory
           case Dims of
             1: Data = FltArr(dxN[0], /NOZERO)
             2: Data = FltArr(dxN[0],dxN[1], /NOZERO)
             3: Data = FltArr(dxN[0],dxN[1],dxN[2], /NOZERO)
           else: begin
                  newres = Dialog_Message('Invalid number of dimensions in dataset', /Error)
                  return, 0
                 end
           endcase

           ; Read data
           ;
           ; Note: The dx file format uses big endian notation. On systems that use
           ; little endian notation (like Intel x86) the byte order must be swapped
           ; hence the /SWAP_IF_LITTLE_ENDIAN notation

           OpenR, work_file_id, DataFileName, /GET_LUN, /SWAP_IF_LITTLE_ENDIAN
           Header = BytArr(4)
           ReadU, work_file_id, Header
           ReadU, work_file_id, Data
           Free_Lun, work_file_id
         end
     endcase

     pData = PTR_NEW(Data, /NO_COPY)

  end else pData = PTR_NEW()

  cd, oldpath

  return, 0
end

;##############################################################################################################

PRO Osiris_Open_Data, pData,  FILE = FileName, EXTENSION = FIleNameExtension, $
                             DIALOGTITLE = DialogTitle, PATH = filepath, $
                             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                             DIM = Dims, N = dxN, ORIGIN = dxOrigin, $
                             DELTA = dxDelta, TIMEPHYS = time, TIMESTEP = timestep, $
                             DX = UseDX, $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                             YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                             ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit, $
                             DATASETSNUMBER = NumDataSets, SAME = nounique, FORCEDIMS = ForceN, $
                             XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $
                             INFO_STRUCT = sInfo_Struct, $
                             IGNORE_ALL = noCheckAll, $
                             IGNORE_TIME = noCheckTime, $
                             IGNORE_AXIS = noCheckAxis, $
                             VERBOSE = verbose

 ; on_error, 2
 
  if Arg_Present(pData) then begin
    noData = 0
    if N_Elements(pData) gt 0 then if  ptr_valid(pData[0]) then ptr_free, pData
  end else begin
   noData = 1
  end

  pData = ptr_new()
  
  ; VERBOSE
  ;
  ; Message level, 0 - silent, 1 - normal, 2 - full. default is 0 - silent
  
  if (N_Elements(verbose) eq 0) then verbose = 0

  ; FORCEDIMS
  ;
  ; Number of dimensions of the data file. Using this parameter forces the user to choose a file with the dimensions
  ; specified. Otherwise issues an error message and returns 0

  if (N_Elements(ForceN) eq 0) then ForceN = 0

  ; SAME
  ;
  ; Allow opening of the same file more than once. Set this keyword so that the program doesn't check if the files
  ; opened are all different

  if N_Elements(noUnique) eq 0 then noUnique = 1


  noCheck = 0b

  ; IGNORE_TIME
  
  if Keyword_Set(noCheckTime) then noCheck = noCheck + 1b
    
  ; IGNORE_AXIS
  
  if Keyword_Set(noCheckAxis) then noCheck = noCheck + 2b

  ; IGNORE_ALL
  ;
  ; Allow different files to have different axis and time information. Note that the number of dimensions of
  ; the files and dimension sizes must still be the same

  if Keyword_Set(noCheckAll) then noCheck = 255b

  ; EXTENSION
  ;
  ; Data Filename Extension
  ;
  ; The data filename extension for single processor raw data dumps. Has no effect on HDF files

  if N_Elements(FileNameExtension) eq 0 then FileNameExtension = ''

  ; DATASETSNUMBER
  ;
  ; Number of DataSets to open. All the datasets to open must have the sames dimensions, axis and timestep
  ; the default is to open a single file

  If N_Elements(NumDataSets) eq 0 then NumDataSets = 1

  ; DIALOGTITLE
  ;
  ; The title for the dialog box that opens a file

  if N_Elements(DialogTitle) eq 0 then begin
     temp = 'Please Select Osiris file'
     DialogTitle = strarr(NumDataSets)
     DialogTitle[*] = temp
     if (NumDataSets gt 1) then begin
       for i=0, NumDataSets -1 do begin
         DialogTitle[i] = DialogTitle[i] + ' ' + strtrim(i + 1,1)
       end
     end
  end else begin
    S = Size(DialogTitle)
    if (S[0] eq 0) then begin
      temp = DialogTitle
      DialogTitle = StrArr(NumDataSets)
      DialogTitle[*] = temp
    end else if (S[1] ne NumDataSets) then begin
      res = Error_Message(' DIALOGTITLE must be a scalar or a 1D array with DATASETSNUMBER values')
      return
    end
  end

  ; PATH
  ;
  ; Path for the file

  if N_Elements(filepath) eq 0 then filepath = ''
  S = Size(filepath)
  if (S[0] eq 0) then begin
    temp = filepath
    filepath = StrArr(NumDataSets)
    filepath[*] = temp
  end else if (S[1] ne NumDataSets) then begin
    res = Error_Message(' PATH must be a scalar or a 1D array with DATASETSNUMBER values')
    return
  end

  ; DX
  ;
  ; Filter for dialog boxes. If set uses '*.dx'. The default is to use '*.hdf'

  if Keyword_Set(UseDX) then filter = '*.dx' else filter = '*.hdf'

  ; FILE
  ;
  ; file(s) to open. If no files are specified the routine prompts the user for the files. In this case the path
  ; variable is overwritten with the file paths of the selected files

  if N_Elements(FileName) eq 0 then begin
    filename = StrArr(NumDataSets)
    filepath = StrArr(NumDataSets)
    for i=0, NumDataSets-1 do begin
      filen=Dialog_Pickfile(FILTER=filter, TITLE = DialogTitle[i])
      if (filen eq '') then begin
        pData = Ptr_New()
        return
      end
      cd, current = fpath

      ; Check if the file hasn't been selected before
      if (nounique gt 0) then begin
        for j=0, i-1 do begin
          if ((filename [j] eq filen) and (filepath[j] eq fpath)) then begin
            Dims = 0
            res  = Error_Message(' All files must be different. If you want to open the same file more than'+ $
                                 'once set the NOUNIQUE keyword')
            return
          end
        end
      end
     ; Store the path and filename

     filename[i] = filen
     filepath[i] = fpath
    end
  end else begin
    S = Size(filename)

    if (NumDataSets eq 1) then begin
      if (S[0] ne 0) then begin
        res = Error_Message('(a) FILE must be a 1D array with DATASETSNUMBER values')
        return
      end
    end else if ((S[0] ne 1) or (S[1] ne NumDataSets)) then begin
      res = Error_Message('(b) FILE must be a 1D array with DATASETSNUMBER values')
      return
    end
  end

  if (ForceN gt 0) then Dims = ForceN

  ; Opens the data

  res = __open_data(pData, FileName[0], PATH = filepath[0], XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                        DIM = Dims, N = dxN, ORIGIN = dxOrigin, EXTENSION = FIleNameExtension, $
                        DELTA = dxDelta, TIMEPHYS = time, TIMESTEP = timestep, $
                        DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                        XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                        YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                        ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit, INFO_ONLY = noData, IGNORE = noCheck)


  ; If no errors ocurred process the file
  if (res eq 0) then begin

    ; Extract Appropriate range

    if N_Elements(xrange) eq 0 then xrange = [Min(XAxisData),Max(XAxisData)]
    if (Dims ge 2) and N_Elements(yrange) eq 0 then yrange = [Min(YAxisData),Max(YAxisData)]
    if (Dims eq 3) and N_Elements(zrange) eq 0 then zrange = [Min(ZAxisData),Max(ZAxisData)]


    __get_subrange, pData, $
                    xrange, XAxisData, XIDX=xidx, XSUB = xsubrange,$
                    yrange, YAxisData, YIDX=yidx, YSUB = ysubrange,$
                    zrange, ZAxisData, ZIDX=zidx, ZSUB = zsubrange

 
    ; Opens additional datasets

    if (NumDataSets gt 1) then begin
      print, 'File ',1,' read'
      pData0 = pData
      pData = PtrArr(NumDataSets)
      pData[0]=pData0
      DataName0 = DataName
      format0 = format
      Label0 = label
      Units0 = units
      DataName = StrArr(NumDataSets)
      DataName[0] = DataName0
      format = StrArr(NumDataSets)
      format[0] = format0
      label = StrArr(NumDataSets)
      label[0] = label0
      units = StrArr(NumDataSets)
      units[0] = units0

      for i = 1, NumDataSets - 1 do begin
        res = __open_data( pData0, FileName[i], PATH = filepath[i], $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                        DIM = Dims, N = dxN,EXTENSION = FIleNameExtension,$
                        TIMEPHYS = time, INFO_ONLY = noData, IGNORE= noCheck, $
                        DATATITLE = DataName0, DATAFORMAT = format0, DATALABEL = Label0, DATAUNITS = Units0 )

        if (res ne 0) then begin
          print, 'Error, clearing memory...'
          Ptr_Free, pData, pData0
          return
        end

        __get_subrange, pData0, $
                    xrange, XAxisData, XIDX=xidx, XSUB = xsubrange,$
                    yrange, YAxisData, YIDX=yidx, YSUB = ysubrange,$
                    zrange, ZAxisData, ZIDX=zidx, ZSUB = zsubrange

         ; Saves Data
         pData[i] = pData0
         DataName[i] = DataName0
         format[i] = format0
         label[i] = label0
         units[i] = units0
         print, 'File ',i+1,' read'
      end
    end

    ; Changes dxN and the axis to reflect range changes

    if (xsubrange eq 1) then begin
      n1x = xidx[0]
      n2x = xidx[1]
      dxN[0] = n2x-n1x + 1
      XAxisData = XAxisData[n1x:n2x]
      xrange=[Min(XAxisData),Max(XAxisData)]
    end

    if (Dims ge 2) then if (ysubrange eq 1) then begin
      n1y = yidx[0]
      n2y = yidx[1]

      dxN[1] = n2y - n1y +1
      YAxisData = YAxisData[n1y:n2y]
      yrange=[Min(YAxisData),Max(YAxisData)]
    end

    if (Dims eq 3) then if (zsubrange eq 1)then begin
      n1z = zidx[0]
      n2z = zidx[1]

      dxN[2] = n2z - n1z +1
      ZAxisData = ZAxisData[n1z:n2z]
      zrange=[Min(ZAxisData),Max(ZAxisData)]
    end

    ; Store Info Structure if necessary
    
    if Arg_Present(sInfo_Struct) then begin
      case (Dims) of
        3: sInfo_Struct = { time:time, $
                            timestep:timestep, $
                            name:DataName, $
                            format:format, $
                            label:label, $
                            units:units, $
                            x1name:x1name, $
                            x1format:x1format, $
                            x1label:x1label, $
                            x1units:x1unit, $
                            x2name:x2name, $
                            x2format:x2format, $
                            x2label:x2label, $
                            x2units:x2unit, $
                            x3name:x3name, $
                            x3format:x3format, $
                            x3label:x3label, $
                            x3units:x3unit }
        2: sInfo_Struct = { time:time, $
                            timestep:timestep, $
                            name:DataName, $
                            format:format, $
                            label:label, $
                            units:units, $
                            x1name:x1name, $
                            x1format:x1format, $
                            x1label:x1label, $
                            x1units:x1unit, $
                            x2name:x2name, $
                            x2format:x2format, $
                            x2label:x2label, $
                            x2units:x2unit}
        1: sInfo_Struct = { time:time, $
                            timestep:timestep, $
                            name:DataName, $
                            format:format, $
                            label:label, $
                            units:units, $
                            x1name:x1name, $
                            x1format:x1format, $
                            x1label:x1label, $
                            x1units:x1unit}
      endcase    
    end
  
    ; Print Relevant information
  
    if (verbose gt 0) then begin
      Print, 'Data Information                     '
      print, '-------------------------------------'
      print, 'Filename	: ', FileName[0]
      print, 'Timestep 	: ', time 
      print, 'Name 		: ', DataName
      print, 'Dimensions	: ', Dims
      print, 'N		: ', dxN
      print, 'X Range		: ', xrange
      if (Dims ge 2) then print, 'Y Range		: ', yrange
      if (Dims eq 3) then print, 'Z Range		: ', zrange
    end
 
    ; Restore path information

  end 

  filepath = filepath[0]

end