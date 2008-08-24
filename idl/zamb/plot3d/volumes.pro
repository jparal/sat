;**********************************************************************
;************************************************** Volume Routines ***
;**********************************************************************

;----------------------------------------------------------- Volume ---
; Generates the IsoSurface model from the data in parameter 
; Data[NX,NY,NZ], using the isovalues specified in the isolevels param.
; Note that the IsoLevels are in absolute (not relative) values.
; outputs the result to the parameter oModelIsoSurf
;----------------------------------------------------------------------

pro Volumes, pData, oModelVolume, MAX = DataMax, MIN = DataMin, $
             DATA2 = pData2, D2CT = d2volCT, $
             CT = volCT, OPAC = volOpac, GLOBALOPAC = volGlobalOpac, $
             XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
             TRANSPVAL = transp_value, PWROPAC = pwr_opac 

   ; test validity of Data
    
   S = Size(*pData)
   
   If (S[0] ne 3) then begin
     print, 'Volume, pData must be a pointer to 3 Dimensional data.'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]

   ; Color Table
   
   if N_Elements(volCT) eq 0 then volCT = 33
   if N_Elements(d2volCT) eq 0 then d2volCT = -33
      
   ; Data Limits
   
   if N_Elements(DataMax) eq 0 then begin
     DataMax = Max(*pData)
   end

   if N_Elements(DataMin) eq 0 then begin
     DataMin = Min(*pData)
   end

   if N_Elements(transp_value) eq 0 then transp_value = 0.0
   
   if (DataMin lt 0) then begin
      if (DataMax le 0) then begin
        VolData = BytScl(-*pData, Min = 0, Max = Max(abs([DataMax,DataMin])))
        btransp_value = byte(255*float(-transp_value)/Max(abs([DataMax,DataMin])))
      end else begin
        print, 'Different sign volumes not implemented yet'
        return
      end
   end else begin
     VolData = BytScl(*pData, MIN = 0, MAX = DataMax)
     btransp_value = Byte(255*float(transp_value)/(DataMax))
   end

   help, DataMax
   help, transp_value
   help, btransp_value
   help, pwr_opac

   ; Opacity Table
   
   if N_Elements(volOpac) eq 0 then begin
     if (N_Elements(pwr_opac) eq 0) then pwr_opac = 4
     volOpac = BytArr(256)  
     opac = float(BIndGen(256-btransp_value)/float(256-btransp_value))^pwr_opac
     volOpac[btransp_value:*] = Byte(255*opac)
   end

   ; Global Opacity Value
   
   if N_Elements(volGlobalOpac) eq 0 then volGlobalOpac = 255b
 
   volOpac = byte((volOpac/255.) * volGlobalOpac)


   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'Volume, XAXIS must be a 1D array with NX elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'Volume, YAXIS must be a 1D array with NY elements.'
         print, '(*pData is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'Volume, ZAXIS must be a 1D array with NZ elements.'
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

   ; Volume Rendering

   oVolume = OBJ_NEW('IDLgrVolume', VolData)
   
   ccx = [XMin, Xrange/(NX*1.)]
   ccy = [YMin, Yrange/(NY*1.)]
   ccz = [ZMin, Zrange/(NZ*1.)]
   
   oVolume -> SetProperty, XCOORD_CONV = ccx, YCOORD_CONV = ccy, ZCOORD_CONV = ccz 
   oVolume -> SetProperty, /ZBUFFER,/ZERO_OPACITY_SKIP, /INTERPOLATE 
   oVolume -> SetProperty, RENDER_STEP =[1,1,0.5], COMPOSITE_FUNCTION = 0

    
   oVolume -> SetProperty, OPACITY_TABLE0 = volOpac
  
   rgbTable = BytArr(256,3)
   GetCTColors, volCT, RED = rr, GREEN = gg, BLUE = bb
      
   rgbTable[*,0] = rr[*]
   rgbTable[*,1] = gg[*]
   rgbTable[*,2] = bb[*]
   oVolume -> SetProperty, RGB_TABLE0 = rgbTable 
   oModelVolume -> ADD, oVolume                
   
   ; Data2

   if (N_Elements(pData2) gt 0) then begin   
     if (DataMin lt 0) then begin
        if (DataMax le 0) then begin
          VolData = BytScl(-*pData2, Min = 0, Max = Max(abs([DataMax,DataMin])))
        end else begin
          print, 'Different sign volumes not implemented yet'
          return
        end
     end else begin
       VolData = BytScl(*pData2, MIN = 0, MAX = DataMax)
     end
   
     oVolume = OBJ_NEW('IDLgrVolume', VolData)
   
     ccx = [XMin, Xrange/(NX*1.)]
     ccy = [YMin, Yrange/(NY*1.)]
     ccz = [ZMin, Zrange/(NZ*1.)]
   
     oVolume -> SetProperty, XCOORD_CONV = ccx, YCOORD_CONV = ccy, ZCOORD_CONV = ccz 
     oVolume -> SetProperty, /ZBUFFER,/ZERO_OPACITY_SKIP, /INTERPOLATE 
     oVolume -> SetProperty, RENDER_STEP =[1,1,0.5], COMPOSITE_FUNCTION = 0
    
     oVolume -> SetProperty, OPACITY_TABLE0 = volOpac
  
     GetCTColors, d2volCT, RED = rr, GREEN = gg, BLUE = bb
   
     rgbTable[*,0] = rr[*]
     rgbTable[*,1] = gg[*]
     rgbTable[*,2] = bb[*]
     oVolume -> SetProperty, RGB_TABLE0 = rgbTable 
     oModelVolume -> ADD, oVolume                
   end   
end

; ---------------------------------------------------------------------
