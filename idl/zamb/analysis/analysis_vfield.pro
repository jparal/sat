pro analysis_vfield, pData, $							; (in/out) Vector Data to Analyse 
              DATANAME = DataName, $						; (in/out) Data Names
              DATALABEL = DataLabel, $					; (in/out) Data Labels
              DATAUNITS = DataUnits, $					; (in/out) Data Units
              Xaxisdata, Yaxisdata, Zaxisdata, $			; (in/out) Axis Data
              XLABEL = xaxislabel, $						; (in/out) X Axis Label
              YLABEL = yaxislabel, $						; (in/out) Y Axis Label
              ZLABEL = zaxislabel, $						; (in/out) Z Axis Label
              XUNITS = xunits, $						; (in/out) X Axis units
              YUNITS = yunits, $						; (in/out) Y Axis units
              ZUNITS = zunits, $						; (in/out) Z Axis units
              FACTOR = DimFactor, $						; (in) Data Reduction Factor
              BACKGROUND = BackGround, $					; (in) Background value
              SMOOTH = smoothfact, $						; (in) Smooth Data (smoothing window size)
              BORDER = n_bordercells, $					; (in) Border Cells to remove
              NORMALIZE = normalize						; (in) Normalize data to the maximum value

   ; Check if pData present
   
   n_data = N_Elements(pData)

   if (n_data lt 1) then begin
     res = Error_Message('pData not specified')
     return
   end

   if ((n_data lt 2) or (n_data gt 3)) then begin
     res = Error_Message('pData must be a two or three element pointer vector for two or three dimensional '+$
                         'vector fields.')
     return
   end

   ; Check pData type
     
   T_POINTER = 10
              
   if (size(pData, /type) ne T_POINTER) then begin       ; Data must be a Pointer
     res = Error_Message('pData must be an array of pointers')
     return
   end 

   if not ptr_valid(pData[0]) then begin
     res = Error_Message('Invalid Pointer, pData')
     return
   end
   
   type = size(*pData[0], /type)
     
   if (type lt 1) or (type gt 5) then begin
     res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                       'Precision Floating Point')
     return
   end

   ; Check Dimensions of data

   n = size(*pData[0], /N_DIMENSIONS)
   
   if ((n lt 2) or (n gt 3) or (n ne n_data)) then begin
     res = Error_Message('Data must be a 2 or 3 Dimensional array, for a 2 or 3 Dimensional vector field.')
     return
   end
  
   nx = size(*pData[0], /DIMENSIONS)
   
   for i = 1, n_data-1 do begin
     if not ptr_valid(pData[i]) then begin
       res = Error_Message('Invalid Pointer, pData')
       return
     end
     
     type = size(*pData[i], /type)
     
     if (type lt 1) or (type gt 5) then begin
       res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                         'Precision Floating Point')
       return
     end

     _n = size(*pData[i], /N_DIMENSIONS)

     if (_n ne n) then begin
       res = Error_Message('All Datasets pointed by pData must have the same number of dimensions')
       return
     end

     _nx = size(*pData[i], /DIMENSIONS)
     
     for j=0, n-1 do if (_nx[i] ne nx[i]) then begin
       res = Error_Message('All Datasets pointed by pData must have the same dimension sizes')
       return
     end
   end
   
   ;##########################################################################################################

   ; Check Parameters

   ; BORDER
   ; 
   ; Number of border cells to remove
   
   If N_Elements(n_bordercells) eq 0 then n_bordercells = 0 
         
   ; FACTOR
   ;
   ; [XF,YF, ZF] Dimension reduction factor
   ;
   ; The data array dimensions are reduced by the values specified using the REBIN
   ; function

   if N_Elements(DimFactor) eq 0 then begin
     DimFactor = LonArr(n) + 1
   end else begin
     s = Size(DimFactor)
     if (s[0] eq 0) then begin
       DimFactor = LonArr(n)+DimFactor
     end else begin
       if ((s[0] ne 1) or (s[1] ne n)) then begin
         res = Error_Message('FACTOR must be either a scalar or a N element vector,'+$
                             'with N equal to the number of dimensions of the dataset')
         return
       end
     end
   end

   ; BACKGROUND
   ;
   ; Background value (for removal)
   ;
   ; This value is subtracted from the data

   if N_Elements(background) eq 0 then background = 0.0

   ; SMOOTH  
   ;
   ; Data Smoothing

   If N_Elements(SmoothFact) ne 0 then begin
     if (SmoothFact lt 3) then SmoothFact = 3
   end else smoothfact = 0

   T_STRING = 7
  
   ; DATANAME
  
   if (N_Elements(DataName) eq 0) then begin
     DataName = StrArr(n)
     for i=0,n-1 do DataName[i] = 'Data '+strtrim(i+1,1)
   end else begin
     if (size(DataName, /type) ne T_STRING) then begin       ; DataName must be a string
       res = Error_Message('DATANAME must be a string or array of strings')
       return
     end
     if (N_Elements(DataName) ne n_data) then begin
       res = Error_Message('DATANAME must have the same number of elements as there are datasets')
       return
     end
   end 

   ; DATALABEL
  
   if (N_Elements(DataLabel) eq 0) then begin
     DataLabel = StrArr(n)
     for i=0,n-1 do DataLabel[i] = 'Data '+strtrim(i+1,1)
   end else begin
     if (size(DataLabel, /type) ne T_STRING) then begin       ; DataLabel must be a string
       res = Error_Message('DATALABEL must be a string or array of strings')
       return
     end
     if (N_Elements(DataLabel) ne n_data) then begin
       res = Error_Message('DATALABEL must have the same number of elements as there are datasets')
       return
     end
   end 

   ; DATAUNITS
  
   if (N_Elements(DataUnits) eq 0) then begin
     DataUnits = StrArr(n)
     for i=0,n-1 do DataLabel[i] = ''
   end else begin
     if (size(DataUnits, /type) ne T_STRING) then begin       ; DataUnits must be a string
       res = Error_Message('DATAUNITS must be a string or array of strings')
       return
     end
     if (N_Elements(DataUnits) ne n_data) then begin
       res = Error_Message('DATAUNITS must have the same number of elements as there are datasets')
       return
     end
   end 
  
   ; XLABEL
   
   if (N_Elements(xaxislabel) eq 0) then begin
     xaxislabel = 'x1'
   end else begin
     if (size(xaxislabel, /type) ne T_STRING) then begin       ; xaxislabel must be a string
       res = Error_Message('XLABEL must be a string')
       return
     end
   end      

   ; YLABEL
   
   if (N_Elements(yaxislabel) eq 0) then begin
     yaxislabel = 'x2'
   end else begin
     if (size(yaxislabel, /type) ne T_STRING) then begin       ; yaxislabel must be a string
       res = Error_Message('YLABEL must be a string')
       return
     end
   end      

   ; ZLABEL
   
   if (N_Elements(zaxislabel) eq 0) then begin
     zaxislabel = 'x3'
   end else begin
     if (size(zaxislabel, /type) ne T_STRING) then begin       ; zaxislabel must be a string
       res = Error_Message('ZLABEL must be a string')
       return
     end
   end      

   ; XUNITS
   
   if (N_Elements(xunits) eq 0) then begin
     xunits = ''
   end else begin
     if (size(xunits, /type) ne T_STRING) then begin
       res = Error_Message('XUNITS must be a string')
       return
     end
   end      

   ; YUNITS
   
   if (N_Elements(yunits) eq 0) then begin
     yunits = ''
   end else begin
     if (size(yunits, /type) ne T_STRING) then begin
       res = Error_Message('YUNITS must be a string')
       return
     end
   end      

   ; ZUNITS
   
   if (N_Elements(zunits) eq 0) then begin
     zunits = ''
   end else begin
     if (size(zunits, /type) ne T_STRING) then begin
       res = Error_Message('ZUNITS must be a string')
       return
     end
   end      
  
   ;#################################################################################################  

   ; Begin Calculation


   ; Removes Border Cells

   if (n_bordercells gt 0) then begin
      j = n_bordercells
      If (N_Elements(XAxisData) ne 0) then XAxisData = XAxisData[j:nx[0]-1-j]
      If (N_Elements(YAxisData) ne 0) and (n gt 1) then YAxisData = YAxisData[j:nx[1]-1-j]
      If (N_Elements(XAxisData) ne 0) and (n eq 3) then ZAxisData = ZAxisData[j:nx[2]-1-j]

      case n of 
        3:for i=0, n_data-1 do *pData[i] = (*pData[i])[j:nx[0]-1-j,j:nx[1]-1-j,j:nx[2]-1-j]
        2:for i=0, n_data-1 do *pData[i] = (*pData[i])[j:nx[0]-1-j,j:nx[1]-1-j]
        1:for i=0, n_data-1 do *pData[i] = (*pData[i])[j:nx[0]-1-j]
      end

      nx = nx - 2* n_bordercells
   end

   ; Resizes the data

   if (total(DimFactor) gt n)  then begin
      _nx = nx
      nx = nx / DimFactor 
      for j=0,n-1 do begin
        if (nx[j] ne _nx[j]*DimFactor[j]) then begin
          res = Error_Message('The dimension sizes must be divisible by FACTOR')
          return
        end
      end
      
      case n of
        1: for i=0, n_data-1 do *pData[i] = Rebin(*pData[i], nx[0])
        2: for i=0, n_data-1 do *pData[i] = Rebin(*pData[i], nx[0],nx[1])
        3: for i=0, n_data-1 do *pData[i] = Rebin(*pData[i], nx[0],nx[1], nx[2])
      endcase
    
      XAxisData = Rebin(XAxisData, nx[0])
      if (n gt 1) then YAxisData = Rebin(YAxisData, nx[1])
      if (n eq 3) then ZAxisData = Rebin(ZAxisData, nx[2])
   end

   ; Removes the background

   if (background ne 0.0) then $
     for i=0,n_data-1 do *pData[i] = temporary(*pData[i]) - background
    
   ; Smooth the data

   if (smoothfact) gt 0 then $
     for i=0, n_data-1 do *pData[i] =  Smooth(*pData[i], SmoothFact, /Edge_Truncate)

  ; If necessary normalizes the data

  if Keyword_Set(normalize) then begin
    max_val = max(abs(*pData[0]))
    for i=1,n_data-1 do max_val = max([max_val,max(abs(*pData[i]))]) 
    if (max_val gt 0) then for i=0,n_data-1 do begin
       *pData[i] = temporary(*pData[i]) / max_val
       dataunits[i] = 'a.u.'       
    end
  end
  
end