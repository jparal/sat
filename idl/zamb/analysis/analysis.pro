pro analysis, _EXTRA = extrakeys, $
              pData, $								; (in/out) Data to Analyse 
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
              SQUARED = DataSquared, $					; (in) Data = Data^2
              ABS = DataAbs, $							; (in) Data = |Data|
              SMOOTH = smoothfact, $						; (in) Smooth Data (smoothing window size)
              KFILTERVAL = kfilterval, $					; (in) value for filter position in k space
              HIGHPASS = kfilterhighpass, $				; (in) do a high pass filter instead of a low pass
              KFILTERRETTYPE = kfilterrettype, $			; (in) return type for k filter (0-abs, 1-real, 2-imaginary, else-complex)
              ADDDATA = AddData, $						; (in) Add Datasets
              ENVELOPE = doEnvelope, $					; (in) Get Envelope of the data
              FFT = doFFT, $							; (in) Does FFT of Data
              _SMOOTHFFT = smoothfftfact, $				; (in) Smooths FFT
              CENTROIDS = CentroidDir, $					; (in) Centroid Direction
              CENTMINVAL = CentroidMinVal, $				; (in) Minimum value for centroids
              CVERTS = pcent_verts, $						; (out) Centroid vertex coordinates
              CPOINTS = pcent_points, $					; (out) Centroid connectivity information
              BORDER = n_bordercells, $					; (in) Border Cells to remove
              NORMALIZE = normalize, $					; (in) Normalize data to the maximum value
              SCALE = scalefactor						; (in) adding a scale factor, in case you don't like 
                     									; the simulation units

   ; Check if pData present
   
   n_data = N_Elements(pData)

   if (n_data lt 1) then begin
     res = Error_Message('pData not specified')
     return
   end

   ; Check pData type
     
   T_POINTER = 10
              
   if (size(pData, /type) ne T_POINTER) then begin       ; Data must be a Pointer
     res = Error_Message('pData must be a pointer or array of pointers')
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
   
   if ((n lt 1) or (n gt 3)) then begin
     res = Error_Message('Data must be a 1, 2 or 3 Dimensional array')
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
     
     for i=0, n-1 do if (_nx[i] ne nx[i]) then begin
       res = Error_Message('All Datasets pointed by pData must have the same dimension sizes')
       return
     end
   end
   
   ;##########################################################################################################

   ; Check Parameters

   ; KFILTERVAL
   ;
   ; position of filter for k-space filtering
   
   If N_Elements(kfilterval) eq 0 then iKFiltering = 0 $
   else begin
     if (N_Elements(kfilterval) ne 1) and (N_Elements(kfilterval) ne n) then begin
       res = Error_Message('KFILTERVAL must either be a scalar or a vector with the same number of elements '+$
                           'as the number of dimensions of data')
       return
     end
     iKFiltering = 1     
   end

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

   ; SQUARED
   ;
   ; Data^2
   ;
   ; If this keyword is set the data is squared ( Data = Data^2 )

   ; SMOOTH  
   ;
   ; Data Smoothing

   If N_Elements(SmoothFact) ne 0 then begin
     if (SmoothFact lt 3) then SmoothFact = 3
   end else smoothfact = 0

   ; _SMOOTHFFT  
   ;
   ; Data Smoothing

   If N_Elements(SmoothFFTFact) ne 0 then begin
     if (SmoothFFTFact lt 3) then SmoothFFTFact = 3
   end else smoothfftfact = 0

   ; CENTROIDS
   ;
   ; Calculate a mass centroid. Set this parameter to the direction of the centroid (0, or 1)
   ; When looking at laser fields this algorithm is only effective with laser envelopes. If the data
   ; is not already an envelope you should use the ENVELOPE keyword. Also see Osiris_Gen_Envelope.pro
   ; and envelope.pro

   n_centroids = N_Elements(CentroidDir)
   
   if (n_centroids eq 0) then begin
     iAddCentroid = 0
   end else begin
     iAddCentroid = 1
     if (n eq 1) then begin	; Ignore Centroid if 1D
       iAddCentroid = 0
     end else if (not Arg_Present(pcent_verts)) or (not Arg_Present(pcent_points)) then begin
       print, 'WARNING, Analysis, CENTROIDS was specified but CVERTS or CPOINTS arent'
       print, 'valid arguments, ignoring CENTROIDS'
       iAddCentroid = 0
     end   
   end

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
        if (_nx[j] ne nx[j]*DimFactor[j]) then begin
          res = Error_Message('The dimension sizes must be divisible by FACTOR')
          print, nx
          print, _nx
          print, Factor
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

   ; Abs or ^2 data

   if Keyword_Set(DataSquared) then begin
     for i=0, n_data-1 do begin
       *pData[i] = temporary(*pData[i])^2
       DataName[i] = '|'+DataName[i]+'|!U2!N'
       DataLabel[i] = '|'+DataLabel[i]+'|!U2!N'
       DataUnits[i] = '('+DataUnits+')!U2!N'
     end
   end else if Keyword_Set(DataAbs) then begin
     for i=0, n_data-1 do begin
       *pData[i] = Abs(temporary(*pData[i]))
       DataName[i] = '|'+DataName[i]+'|'
       DataLabel[i] = '|'+DataLabel[i]+'|'
     end
   end

   ; Removes the background

   if (background ne 0.0) then $
     for i=0,n_data-1 do *pData[i] = temporary(*pData[i]) - background
    
   ; Smooth the data

   if (smoothfact) gt 0 then $
     for i=0, n_data-1 do *pData[i] =  Smooth(*pData[i], SmoothFact, /Edge_Truncate)

   ; Sums over all the datasets and delete all extra datasets

   if Keyword_Set(AddData) then begin
     for i=1,n_data-1 do begin
       *pData[0] = temporary(*pData[0]) + temporary(*pData[i])
       ptr_free, pData[i]
       DataName[0] = DataName[0] + '+' + DataName[i]
     end
     pData = pData[0]
     n = 1
   end

   ; Takes the envelope of the data
 
   if Keyword_Set(doEnvelope) then begin
     for i=0, n_data-1 do begin
       envelope, pData[i], _EXTRA=extrakeys
       DataName[i] = 'Envelope '+DataName[i]
     end
   end

   ; KFIltering 

   if Keyword_Set(iKFiltering) then begin
     
     help, kfilterrettype
     
     for i=0, n_data-1 do begin
       kfilter, pData[i], kfilterval, HIGHPASS = kfilterhighpass, RETTYPE = kfilterrettype, $
                xaxis = xaxisdata, yaxis = yaxisdata, zaxis = zaxisdata
                
       DataName[i] = 'Filter '+DataName[i]
     end
   end
   
   ; FFT of the data   
   if Keyword_Set(DoFFT) then begin

      if (N_Elements(XAxisData) ne 0) then begin
         deltaX = XAxisData[1]-XAxisData[0]

         N21x = nx[0]/2 + 1
         XAxisData = IndGen(nx[0])
         XAxisData[N21x] = N21x - nx[0] + FINDGEN(N21x - 2)
         XAxisData = 2.0*!PI*XAxisData/(nx[0]*deltaX)
         XAxisData = Shift(XAxisData, - N21x)
      
         xaxislabel = 'K('+xaxislabel+')'
         if (xunits ne '') then xunits = '1/('+xunits+')' 
      end
 
      if ((n gt 1) and (N_Elements(YAxisData) ne 0)) then begin
        deltaY = YAxisData[1]-YAxisData[0]

        N21y = nx[1]/2 + 1
        YAxisData = IndGen(nx[1])
        YAxisData[N21y] = N21y - nx[1] + FINDGEN(N21y - 2)
        YAxisData = 2.0*!PI*YAxisData/(nx[1]*deltaY)
        YAxisData = Shift(YAxisData, - N21y)
  
        yaxislabel = 'K('+yaxislabel+')' 
        if (yunits ne '') then yunits = '1/('+yunits+')' 
      end

      if ((n eq 3) and (N_Elements(ZAxisData) ne 0)) then begin
        deltaZ = ZAxisData[1]-ZAxisData[0]

        N21z = nx[2]/2 + 1
        ZAxisData = IndGen(nx[2])
        ZAxisData[N21z] = N21z - nx[2] + FINDGEN(N21z - 2)
        ZAxisData = 2.0*!PI*ZAxisData/(nx[2]*deltaZ)
        ZAxisData = Shift(ZAxisData, - N21z)
  
        zaxislabel = 'K('+zaxislabel+')' 
        if (zunits ne '') then zunits = '1/('+zunits+')' 
      end

      Print, " Calculating FFT(s)..."

      for i=0, n_data-1 do begin
        DataName[i] = 'FFT ('+ Dataname[i]+')'
        DataLabel[i] = 'FFT ('+DataLabel[i]+')'
        *pData[i] = FFT(temporary(*pData[i]))
        *pData[i] = Abs(temporary(*pData[i]))
        case n of
          1: *pData[i] = Shift(temporary(*pData[i]), -N21x)
          2: *pData[i] = Shift(temporary(*pData[i]), -N21x, -N21y)
          3: *pData[i] = Shift(temporary(*pData[i]), -N21x, -N21y, -N21z)
        endcase
        if (smoothfftfact) gt 0 then *pData[i] =  Smooth(*pData[i], SmoothFFTFact, /Edge_Truncate)
      end
  end

  ; If necessary normalizes the data

  if Keyword_Set(normalize) then begin
    max_val = max(abs(*pData[0]))
    for i=1,n_data-1 do max_val = max([max_val,max(abs(*pData[i]))]) 
    if (max_val gt 0) then for i=0,n_data-1 do begin
       *pData[i] = temporary(*pData[i]) / max_val
       dataunits[i] = 'a.u.'       
    end
  end
  
    if (N_Elements(scalefactor) ne 0) then begin
    if (scalefactor ne 0.0) then for i=0,n_data-1 do begin
       *pData[i] = temporary(*pData[i]) / scalefactor
       dataunits[i] = 'a.u.'       
    end
  end
  
  ; Find Centroids
  
  if (iAddCentroid) then begin 
    print, 'Calculating ', strtrim(n_centroids, 1), ' Centroid(s)...'
    pcent_verts = ptrarr(n)
    pcent_points = ptrarr(n)
    for i=0, n_data-1 do begin
       Centroid, *pData[i], centroid_vert, cpoints, DIRECTION = CentroidDir[0], MINVAL = CentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisDAta
      for k=1, n_centroids-1 do begin
        Centroid, *pData[i], centroid_vert2, cpoints2, DIRECTION = CentroidDir[k], MINVAL = CentroidMinVal, $
                           YAXIS = YAxisData, XAXIS = XAxisData, ZAXIS = ZAxisDATA
        combine_polyline, centroid_vert, cpoints, centroid_vert2, cpoints2
      end
      pcent_verts[i] = ptr_new(centroid_vert, /no_copy)
      pcent_points[i] = ptr_new(cpoints, /no_copy)
    end                          
    print, 'Done'
  end

end