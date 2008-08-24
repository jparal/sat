;**********************************************************************
;*************************************************** Slice Routines ***
;**********************************************************************

;----------------------------------------------------------- Slices ---
; Generates the Slice model from the data in parameter 
; Data[NX,NY,NZ]. The slices are specified by the SlicePos parameter
; outputs the result to the parameter oModelSlice
;----------------------------------------------------------------------

pro Slices, pData, SlicePos, oModelSlice, CT = sliceCT, MIN = DataMin, MAX = DataMax, $
                 XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                 SUPERSAMPLING = SuperSampling, $
                  CONTAINER = oContainer
                 
   ; test validity of Data
    
   S = Size(*pData)
   
   If (S[0] ne 3) then begin
     print, 'Slices, pData must be a pointer to 3 Dimensional Data.'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]                 

   ; slice positions
   
   S = Size(SlicePos)
   
   if ((S[0] eq 1) and (S[1] eq 2)) then begin
     NSlices = 1
   end else if ((S[0] ne 2) or (S[1] ne 2)) then begin
     print, 'Slices, SlicePos must be in the form [ [ axis1, pos1], [axis2, pos2], ..., [axisn, posn] ]'
     return
   end else NSlices = S[2]
                 
   ; Range of values

   if N_Elements(DataMin) eq 0 then begin
      DataMin = Min(*pData)  
   end
      
   if N_Elements(DataMax) eq 0 then begin
      DataMax = Max(*pData)  
   end 
                  
   ; SuperSampling
   
   if N_Elements(SuperSampling) eq 0 then SuperSampling = 5 
   SuperSampling = long(abs(SuperSampling))

   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'IsoSurface, XAXIS must be a 1D array with NX elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'IsoSurface, YAXIS must be a 1D array with NY elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'IsoSurface, ZAXIS must be a 1D array with NZ elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end     

   ; Color Scale
   
   if N_Elements(sliceCT) eq 0 then sliceCT = 25


   ; Spatial extents
       
   XMin = XAxisData[0]
   XMax = XAxisData[NX-1]
   XRange = XMax - XMin
   XDelta = XRange/NX

   YMin = YAxisData[0]
   YMax = YAxisData[NY-1]
   YRange = YMax - YMin
   YDelta = YRange/NY

   ZMin = ZAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZRange = ZMax - ZMin
   ZDelta = ZRange/NZ
   
   for s = 0, NSlices-1 do begin
      dir = SlicePos[0,s]
      pos = SlicePos[1,s]
      
      case dir of
          2: begin  ; XY slice
               p = long( (pos - ZMin) / ZDelta)
               if ((p lt 0) or (p gt NZ-1)) then begin
                  print, 'Slices, Invalid slice position, slice ignored'
               end else begin
                  pos = ZAxisData[p]
                  slice = Reform((*pData)[*,*,p])                 
                  if (SuperSampling gt 1) then begin
                     slice = Rebin(slice, NX * SuperSampling, NY * SuperSampling)                  
                  end
                  
                  slice = BytScl(slice, MIN = DataMin, MAX = DataMax)

                  oimgSlice = OBJ_NEW('IDLgrImage', image24(slice, sliceCT ))  
                  opolSlice = OBJ_NEW('IDLgrPolygon', $
                                       [[XMin, YMin, pos],[XMax, YMin, pos], $
                                        [XMax, YMax, pos],[XMin, YMax, pos]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgSlice, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    
                  If (N_Elements(oContainer) ne 0) then oContainer-> ADD,oimgSlice
                  oModelSlice -> ADD, opolSlice 
               end 
             end 
          1: begin  ; XZ slice
               p = long( (pos - YMin) / YDelta)
               if ((p lt 0) or (p gt NY-1)) then begin
                  print, 'Slices, Invalid slice position, slice ignored'
               end else begin
                  pos = YAxisData[p]                  
                  slice = Reform((*pData)[*,p,*])
                  if (SuperSampling gt 1) then begin
                     slice = Rebin(slice, NX * SuperSampling, NZ * SuperSampling)                  
                  end
                  slice = BytScl(slice, MIN = DataMin, MAX = DataMax)

                  oimgSlice = OBJ_NEW('IDLgrImage', image24(slice, sliceCT ))  
                  opolSlice = OBJ_NEW('IDLgrPolygon', $
                                       [[XMin, pos, ZMin],[XMax, pos, ZMin],$
                                        [XMax, pos, ZMax],[XMin, pos, ZMax]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgSlice, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    
                  If (N_Elements(oContainer) ne 0) then oContainer-> ADD,oimgSlice
                  oModelSlice -> ADD, opolSlice 
               end 
             end 
          0: begin  ; YZ slice
               p = long( (pos - XMin) / XDelta)
               if ((p lt 0) or (p gt NX-1)) then begin
                  print, 'Slices, Invalid slice position, slice ignored'
               end else begin
                  pos = XAxisData[p]
                  slice = Reform((*pData)[p,*,*])
                  if (SuperSampling gt 1) then begin
                     slice = Rebin(slice, NY * SuperSampling, NZ * SuperSampling)                  
                  end
                  slice = BytScl(slice, MIN = DataMin, MAX = DataMax)

                  oimgSlice = OBJ_NEW('IDLgrImage', image24(slice, sliceCT ))  
                  opolSlice = OBJ_NEW('IDLgrPolygon', $
                                       [[pos, YMin, ZMin], [pos, YMax, ZMin],$
                                        [pos, YMax, ZMax], [pos, YMin, ZMax]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgSlice, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    
                  If (N_Elements(oContainer) ne 0) then oContainer-> ADD,oimgSlice
                  oModelSlice -> ADD, opolSlice 
               end 
             end 
       else: begin
               print, 'Slices, Invalid slice direction, slice ignored'
             end        
      end
      slice = 0
   end                    

   oModelSlice -> SetProperty, LIGHTING = 0


end

; ---------------------------------------------------------------------
