;**********************************************************************
;********************************************** Projection Routines ***
;**********************************************************************

;------------------------------------------------------ Projections ---
; Generates the Projection model from the data in parameter 
; Data[NX,NY,NZ]
; outputs the result to the parameter oModelProj
;----------------------------------------------------------------------

pro Projections, pData, oModelProj, CT = projCT, PMIN = projmin, PMAX = projmax, $
                 XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                 SUPERSAMPLING = SuperSampling, $
                 DATA2 = pData2, D2CT = ProjCT2, $
                 CONTAINER = oContainer 
                 
   ; test validity of Data
    
   S = Size(*pData)
   
   If (S[0] ne 3) then begin
     print, 'Projections, pData must be a pointer to 3 Dimensional data.'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]                 

   if (N_Elements(pData2) ne 0) then begin
     s = size(*pData2)
     
     if (s[0] ne 3) then begin
       print, 'Projections, pData2 must be a pointer to 3 Dimensional data.'
       return
     end
   
     if (s[1] ne nx) or (s[2] ne ny) or (s[3] ne nz) then begin
       print, 'Projections, *pData2 must have the same dimensions as *pData'
       return
     end
   
   end
                 
   ; projections
                   
   p1image = Total(*pData,1) / NX 
   p2image = Total(*pData,2) / NY
   p3image = Total(*pData,3) / NZ

   if (N_Elements(pData2) ne 0) then begin
     p1image2 = Total(*pData2,1) / NX 
     p2image2 = Total(*pData2,2) / NY
     p3image2 = Total(*pData2,3) / NZ
   end

   ; SuperSampling
   
   if N_Elements(SuperSampling) eq 0 then SuperSampling = 0
   
   SuperSampling = long(SuperSampling)
 
   if (SuperSampling gt 1) then begin
     p1image = Rebin(p1image, NY * SuperSampling, NZ * SuperSampling)
     p2image = Rebin(p2image, NX * SuperSampling, NZ * SuperSampling)
     p3image = Rebin(p3image, NX * SuperSampling, NY * SuperSampling)

     if (N_Elements(pData2) ne 0) then begin
       p1image2 = Rebin(p1image2, NY * SuperSampling, NZ * SuperSampling)
       p2image2 = Rebin(p2image2, NX * SuperSampling, NZ * SuperSampling)
       p3image2 = Rebin(p3image2, NX * SuperSampling, NY * SuperSampling)
     end
   end
    
   ; Data ranging 
   ;
   ; Note: the autoscaling only works with the first dataset
     
   if N_Elements(ProjMax) eq 0 then begin
       print, 'Projections, Autoscaling pMAx'
       
       pMax = Max([Max(p1image),Max(p2image),Max(p3image)])
       ProjMax = [pMax,pMax,pMax]
   endif else begin
       S = Size(ProjMax)
       case S[0] of
           0 : ProjMax = [ProjMax, ProjMax, ProjMax]
           1 : if (S[1] ne 3) then begin
                res = Dialog_Message("Projections, PMAX must be either a scalar or a 3 element vector", /Error)
                return          
               end                  
         else: begin
                res = Dialog_Message("Projections, PMAX must be either a scalar or a 3 element vector", /Error)
                 return     
               end
       endcase
   endelse
   print, 'PMax = ', ProjMax
     
   if N_Elements(ProjMin) eq 0 then begin
       print, 'Projections, Autoscaling pMin'
       
       pMin = Min([Min(p1image),Min(p2image),Min(p3image)])
       ProjMin = [pMin,pMin,pMin]
   endif else begin
       S = Size(ProjMin)   
       case S[0] of
           0 : ProjMin = [ProjMin, ProjMin, ProjMin]
           1 : if (S[1] ne 3) then begin
                res = Dialog_Message("Projections, PMIN must be either a scalar or a 3 element vector", /Error)
                return          
               end    
         else: begin
                res = Dialog_Message("Projections, PMIN must be either a scalar or a 3 element vector", /Error)
                return     
               end
       endcase
   endelse


   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'Projections, XAXIS must be a 1D array with NX elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'Projections, YAXIS must be a 1D array with NY elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'Projections, ZAXIS must be a 1D array with NZ elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end     

   ; Spatial extents
       
   XMin = XAxisData[0]
   XMax = XAxisData[NX-1]
   XRange = XMax - XMin

   YMin = YAxisData[0]
   YMax = YAxisData[NY-1]
   YRange = YMax - YMin

   ZMin = ZAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZRange = ZMax - ZMin

   ; Color Table(s)
   
   if N_Elements(projCT) eq 0 then projCT = 1
   if N_Elements(projCT2) eq 0 then projCT2 = 3 
  
   ; Texture Interpolation
   
   If (SuperSampling gt 0) then texture_interp = 1 $
   else texture_interp = 0 
    
   ; X Projection

   p1image = image24(BytScl(temporary(p1image), Max = ProjMax[0], Min = ProjMin[0]),projCT)

   if (N_Elements(pData2) ne 0) then begin
      p1image2 = image24(BytScl(p1image2, Max = ProjMax[0], Min = ProjMin[0]),projCT2)
      p1image = combine_images(p1image,p1image2)
      p1image2 = 0   
   end
   
   nudge = 0.003*[Xrange, Yrange, -ZRange]
   nudge = [[nudge],[nudge],[nudge],[nudge]]
   
   oimgProj1 =  OBJ_NEW('IDLgrImage', p1image)  
   opolProj1 = OBJ_NEW('IDLgrPolygon', [[XMax, YMin, ZMin], [XMax, YMax, ZMin],$
                                        [XMax, YMax, ZMax], [XMax, YMin, ZMax]]+nudge, $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgProj1, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        Texture_Interp = texture_interp)           
                                                                 
   oPolProj1 -> SetProperty, UVALUE = 'X Projection'
   If (N_Elements(oContainer) ne 0) then oContainer-> ADD,oimgProj1
   
   p1image = 0
   
   ; Y Projection

   p2image = image24(BytScl(temporary(p2image), Max = ProjMax[1], Min = ProjMin[1]),ProjCT)

   if (N_Elements(pData2) ne 0) then begin
      p2image2 = image24(BytScl(p2image2, Max = ProjMax[0], Min = ProjMin[0]),projCT2)
      p2image = combine_images(p2image,p2image2)
      p2image2 = 0   
   end

   oimgProj2 =  OBJ_NEW('IDLgrImage', p2image)  
   opolProj2 = OBJ_NEW('IDLgrPolygon', [[XMin, YMax, ZMin],[XMax, YMax, ZMin],$
                                        [XMax, YMax, ZMax],[XMin, YMax, ZMax]]+nudge,$
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgProj2, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        Texture_Interp = texture_interp)                                    

   oPolProj2 -> SetProperty, UVALUE = 'Y Projection'
   If (N_Elements(oContainer) ne 0) then oContainer-> ADD,oimgProj2
   
   p2image = 0
   
   ; Z Projection
  
   p3image = image24(BytScl(temporary(p3image), Max = ProjMax[2], Min = ProjMin[2]), projCT)

   if (N_Elements(pData2) ne 0) then begin
      p3image2 = image24(BytScl(p3image2, Max = ProjMax[0], Min = ProjMin[0]),projCT2)
      p3image = combine_images(p3image,p3image2)
      p3image2 = 0   
   end

   oimgProj3 =  OBJ_NEW('IDLgrImage', p3image)  
   opolProj3 = OBJ_NEW('IDLgrPolygon', [[XMin, YMin, ZMin],[XMax, YMin, ZMin], $
                                        [XMax, YMax, ZMin],[XMin, YMax, ZMin]]+nudge, $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgProj3, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]],$
                                        Texture_Interp = texture_interp)                                    

   oPolProj3 -> SetProperty, UVALUE = 'Z Projection'
   If (N_Elements(oContainer) ne 0) then oContainer-> ADD,oimgProj3
   

   p3image = 0

   oModelProj -> ADD, opolProj1 
   oModelProj -> ADD, opolProj2 
   oModelProj -> ADD, opolProj3   
   
   oModelProj -> SetProperty, LIGHTING = 0
                 

end

; ---------------------------------------------------------------------
