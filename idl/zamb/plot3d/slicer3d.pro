; ------------------------------------- Slicer3D_Update_SliderLabel ---
;  Updates the slicer label
; ---------------------------------------------------------------------

pro Slicer3D_Update_SliderLabel, sState
  case (sState.iSlicePlane) of
    0: begin
         label = 'X = '+strtrim(sState.XAxisData[sState.iSliceXPos],1)
       end
    1: begin
         label = 'Y = '+strtrim(sState.YAxisData[sState.iSliceYPos],1)
       end
    2: begin
         label = 'Z = '+strtrim(sState.ZAxisData[sState.iSliceZPos],1)
       end
  endcase 
  
  widget_control, sState.wSliderLabelID, Set_Value = label
end

; ---------------------------------------------------------------------

; ---------------------------------------- Slicer3D_UpdatePlotImage ---
;  Updates the image with the proper slice
; ---------------------------------------------------------------------

pro Slicer3D_UpdatePlotImage, sState
  case (sState.iSlicePlane) of
     0 : $; YZ
         begin
           Data = reform((*(sState.pData))[sState.iSliceXpos,*,*])
           x = sState.XAxisData[sState.iSliceXpos]
           y0 = sState.YAxisData[0]
           y1 = sState.YAxisData[sState.NY-1]
           z0 = sState.ZAxisData[0]
           z1 = sState.ZAxisData[sState.NZ-1]
           sState.oSlicePlane -> SetProperty, Data = [[x,y0,z0],[x,y1,z0],[x,y1,z1],[x,y0,z1],[x,y0,z0]] 
         end 
     1 : $; XZ
         begin
           Data = reform((*(sState.pData))[*,sState.iSliceYpos,*])
           y = sState.YAxisData[sState.iSliceYpos]
           x0 = sState.XAxisData[0]
           x1 = sState.XAxisData[sState.NX-1]
           z0 = sState.ZAxisData[0]
           z1 = sState.ZAxisData[sState.NZ-1]
           sState.oSlicePlane -> SetProperty, Data = [[x0,y,z0],[x1,y,z0],[x1,y,z1],[x0,y,z1],[x0,y,z0]] 
         end 
     2 : $; XY
         begin
           Data = reform((*(sState.pData))[*,*,sState.iSliceZpos])
           z = sState.ZAxisData[sState.iSliceZpos]
           y0 = sState.YAxisData[0]
           y1 = sState.YAxisData[sState.NY-1]
           x0 = sState.XAxisData[0]
           x1 = sState.XAxisData[sState.NX-1]
           sState.oSlicePlane -> SetProperty, Data = [[x0,y0,z],[x1,y0,z],[x1,y1,z],[x0,y1,z],[x0,y0,z]] 
         end 
  end

  ;
  
  ptr_free, sState.ByteData
  
  if (sState.UseLog gt 0) then begin

      Data = Alog10(Abs(temporary(Data)) > 1e-37)
      tempmin = (Alog10(sState.DataMin) - 1.0) 
      idx = where(Data eq -37.0, count)
      if (count ne 0) then Data[idx] = tempmin
      
      sState.ByteData = ptr_new( BytScl( temporary(Data) ,$
                                 Max = Alog10(sState.DataMax), Min = Alog10(sState.DataMin)), $
                                 /no_copy)
  end else begin
      sState.ByteData = ptr_new(BytScl(temporary(Data), $
                                       Max = sState.DataMax,$
                                       Min = sState.DataMin), /no_copy)
  end

  ; Reset Zoom Factors

  s = size(*(sState.ByteData), /dimensions)

  sState.viewX[0] = 0
  sState.viewX[1] = s[0]-1
  sState.viewY[0] = 0
  sState.viewY[1] = s[1]-1
  
;  print, 'Updating oImage'
  sState.oImage -> SetProperty, Data = *(sState.ByteData)
  
end
; ---------------------------------------------------------------------


pro Slicer3D_UpdatePlotAxis, sState

   ImagePosition = [0.15,0.15,0.79,0.85]
   BarPosition = [0.82,0.15,0.85,0.85]
   SurfacePosition = [0.15,0.15,0.90,0.85]

   dimension = [ ImagePosition[2] - ImagePosition[0], ImagePosition[3] - ImagePosition[1] ]
   location = [ ImagePosition[0], ImagePosition[1] ] 


  case (sState.iSlicePlane) of
    0: begin
         
         ; Hide and show proper axis
         
         sState.xAxis   -> SetProperty, HIDE = 1
         sState.xAxisOp -> SetProperty, HIDE = 1
         sState.yAxis   -> SetProperty, HIDE = 0
         sState.yAxisOp -> SetProperty, HIDE = 0
         sState.zAxis   -> SetProperty, HIDE = 0
         sState.zAxisOp -> SetProperty, HIDE = 0
         
         ; Set Proper orientation
         
         sState.yAxis   -> SetProperty, Direction = 0
         sState.yAxisOp -> SetProperty, Direction = 0
         sState.zAxis   -> SetProperty, Direction = 1
         sState.zAxisOp -> SetProperty, Direction = 1

          
         ; Set Ranges and location
                  
         NZ = sState.NZ         
         NY = sState.NY
         
         DeltaY = sState.YAxisData[1] - sState.YAxisData[0]         
         YMin = sState.YAxisData[0] - DeltaY/2.0
         YMax = sState.YAxisData[NY-1] + DeltaY/2.0  

         DeltaZ = sState.ZAxisData[1] - sState.ZAxisData[0]
         ZMin = sState.ZAxisData[0] - DeltaZ/2.0
         ZMax = sState.ZAxisData[NZ-1] + DeltaZ/2.0  

         xcoord_conv = [location[0]-YMin*dimension[0]/(YMax-YMin), dimension[0]/(YMax-YMin)]
         ycoord_conv = [location[1]-ZMin*dimension[1]/(ZMax-ZMin), dimension[1]/(ZMax-ZMin)]


         sState.yAxis-> SetProperty,  Range = [YMin,YMax], /Exact, $
                    LOCATION = [YMin,ZMin,0]
         ytl = 0.04 *(ZMax-Zmin)

         sState.yAxis -> SetProperty, TICKLEN = ytl
   
         sState.yAxis -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.yAxis -> SetProperty, XCOORD_CONV = xcoord_conv

         sState.yAxisOp -> SetProperty, Range = [YMin,YMax], /Exact, $
                           LOCATION = [YMin,ZMax,0],  TICKDIR = 1
         sState.yAxisOp -> SetProperty, TICKLEN = ytl
         sState.yAxisop -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.yAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
   
         sState.zAxis -> SetProperty, Range = [ZMin,ZMax], /Exact, $
                           LOCATION = [YMin,ZMin,0]
         ztl = 0.04 *(YMax-Ymin)

         sState.zAxis -> SetProperty, TICKLEN = ztl

         sState.zAxis -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.zAxis -> SetProperty, XCOORD_CONV = xcoord_conv

  
         sState.zAxisOp -> SetProperty, Range = [ZMin,ZMax], /Exact, $
                           LOCATION = [YMax,ZMin,0], TICKDIR = 1
         sState.zAxisOp -> SetProperty, TICKLEN = ztl
         sState.zAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.zAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
         
       end
    1: begin
         
         ; Hide and show proper axis
         
         sState.xAxis   -> SetProperty, HIDE = 0
         sState.xAxisOp -> SetProperty, HIDE = 0
         sState.yAxis   -> SetProperty, HIDE = 1
         sState.yAxisOp -> SetProperty, HIDE = 1
         sState.zAxis   -> SetProperty, HIDE = 0
         sState.zAxisOp -> SetProperty, HIDE = 0
         
         ; Set Proper orientation
         
         sState.xAxis   -> SetProperty, Direction = 0
         sState.xAxisOp -> SetProperty, Direction = 0
         sState.zAxis   -> SetProperty, Direction = 1
         sState.zAxisOp -> SetProperty, Direction = 1

          
         ; Set Ranges and location
                  
         NX = sState.NX         
         NZ = sState.NZ

         DeltaX = sState.XAxisData[1] - sState.XAxisData[0]                  
         XMin = sState.XAxisData[0] - DeltaX/2.0
         XMax = sState.XAxisData[NX-1] + DeltaX/2.0  

         DeltaZ = sState.ZAxisData[1] - sState.ZAxisData[0]
         ZMin = sState.ZAxisData[0] - DeltaZ/2.0
         ZMax = sState.ZAxisData[NZ-1] + DeltaZ/2.0  

         xcoord_conv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
         ycoord_conv = [location[1]-ZMin*dimension[1]/(ZMax-ZMin), dimension[1]/(ZMax-ZMin)]


         sState.xAxis-> SetProperty,  Range = [XMin,XMax], /Exact, $
                    LOCATION = [XMin,ZMin,0]
         xtl = 0.04 *(ZMax-Zmin)

         sState.xAxis -> SetProperty, TICKLEN = xtl
   
         sState.xAxis -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.xAxis -> SetProperty, XCOORD_CONV = xcoord_conv

         sState.xAxisOp -> SetProperty, Range = [XMin,XMax], /Exact, $
                           LOCATION = [XMin,ZMax,0],  TICKDIR = 1
         sState.xAxisOp -> SetProperty, TICKLEN = xtl
         sState.xAxisop -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.xAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
   
         sState.zAxis -> SetProperty, Range = [ZMin,ZMax], /Exact, $
                           LOCATION = [XMin,ZMin,0]
         ztl = 0.04 *(XMax-Xmin)

         sState.zAxis -> SetProperty, TICKLEN = ztl

         sState.zAxis -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.zAxis -> SetProperty, XCOORD_CONV = xcoord_conv

  
         sState.zAxisOp -> SetProperty, Range = [ZMin,ZMax], /Exact, $
                           LOCATION = [XMax,ZMin,0], TICKDIR = 1
         sState.zAxisOp -> SetProperty, TICKLEN = ztl
         sState.zAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.zAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv

       end
    2: begin
         
         ; Hide and show proper axis
         
         sState.xAxis   -> SetProperty, HIDE = 0
         sState.xAxisOp -> SetProperty, HIDE = 0
         sState.yAxis   -> SetProperty, HIDE = 0
         sState.yAxisOp -> SetProperty, HIDE = 0
         sState.zAxis   -> SetProperty, HIDE = 1
         sState.zAxisOp -> SetProperty, HIDE = 1
         
         ; Set Proper orientation
         
         sState.xAxis   -> SetProperty, Direction = 0
         sState.xAxisOp -> SetProperty, Direction = 0
         sState.yAxis   -> SetProperty, Direction = 1
         sState.yAxisOp -> SetProperty, Direction = 1

          
         ; Set Ranges and location
                  
         NX = sState.NX         
         NY = sState.NY

         DeltaX = sState.XAxisData[1] - sState.XAxisData[0]                  
         XMin = sState.XAxisData[0] - DeltaX/2.0
         XMax = sState.XAxisData[NX-1] + DeltaX/2.0  

         DeltaY = sState.YAxisData[1] - sState.YAxisData[0]
         YMin = sState.YAxisData[0] - DeltaY/2.0
         YMax = sState.YAxisData[NY-1] + DeltaY/2.0  

         xcoord_conv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
         ycoord_conv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]

         sState.xAxis-> SetProperty,  Range = [XMin,XMax], /Exact, $
                    LOCATION = [XMin,YMin,0]
         xtl = 0.04 *(YMax-Ymin)

         sState.xAxis -> SetProperty, TICKLEN = xtl
   
         sState.xAxis -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.xAxis -> SetProperty, XCOORD_CONV = xcoord_conv

         sState.xAxisOp -> SetProperty, Range = [XMin,XMax], /Exact, $
                           LOCATION = [XMin,YMax,0],  TICKDIR = 1
         sState.xAxisOp -> SetProperty, TICKLEN = xtl
         sState.xAxisop -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.xAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
   
         sState.yAxis -> SetProperty, Range = [YMin,YMax], /Exact, $
                           LOCATION = [XMin,YMin,0]
         ytl = 0.04 *(XMax-Xmin)

         sState.yAxis -> SetProperty, TICKLEN = ytl

         sState.yAxis -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.yAxis -> SetProperty, XCOORD_CONV = xcoord_conv

  
         sState.yAxisOp -> SetProperty, Range = [YMin,YMax], /Exact, $
                           LOCATION = [XMax,YMin,0], TICKDIR = 1
         sState.yAxisOp -> SetProperty, TICKLEN = ytl
         sState.yAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
         sState.yAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv         
       end

  endcase  

end

; ------------------------------------- Slicer3D_UpdatePlotDataAxis ---
;  Generates Plot
; ---------------------------------------------------------------------


pro Slicer3D_UpdatePlotDataAxis, sState
   ImagePosition = [0.15,0.15,0.79,0.85]
   BarPosition = [0.82,0.15,0.85,0.85]
   SurfacePosition = [0.15,0.15,0.90,0.85]

   dimension = [ BarPosition[2] - BarPosition[0], BarPosition[3] - BarPosition[1] ]
   location = [ BarPosition[0], BarPosition[1],0 ] 

   DataMin = sState.DataMin
   DataMax = sState.DataMax

   if (sState.UseLog eq 0) then begin
     ycconv = [location[1]-DataMin*dimension[1]/(DataMax-DataMin), dimension[1]/(DataMax-DataMin)] 
   endif else begin
     ycconv = [location[1]-Alog10(DataMin)*dimension[1]/(Alog10(DataMax/DataMin)), $
               dimension[1]/(Alog10(DataMax/DataMin))] 
   endelse  

   sState.DataAxis -> SetProperty, YCOORD_CONV = ycconv 
   sState.DataAxisOp -> SetProperty, YCOORD_CONV = ycconv

   sState.DataAxis -> SetProperty, Range = [DataMin,DataMax], LOG = sState.UseLog
   sState.DataAxisOp -> SetProperty, Range = [DataMin,DataMax], LOG = sState.UseLog

end


; ------------------------------------------- Slicer3D_GeneratePlot ---
;  Generates Plot
; ---------------------------------------------------------------------

pro Slicer3D_GeneratePlot, sState

   ; The view is set to be the same as normal coordinates in direct graphics

   sState.oView -> SetProperty, VIEW = [0,0,1.,1.], PROJECTION = 1, TRANSPARENT = 0

   ; Initializes local variables

   ImagePosition = [0.15,0.15,0.79,0.85]
   BarPosition = [0.82,0.15,0.85,0.85]
   SurfacePosition = [0.15,0.15,0.90,0.85]
  
   NX = sState.NX
   NY = sState.NY
   NZ = sState.NZ
   
   XMin = sState.XAxisData[0]
   XMax = sState.XAxisData[NX-1]   

   YMin = sState.YAxisData[0]
   YMax = sState.YAxisData[NY-1]   

   DataMin = sState.DataMin
   DataMax = sState.DataMax
   
   dimension = [ ImagePosition[2] - ImagePosition[0], ImagePosition[3] - ImagePosition[1] ]
   location = [ ImagePosition[0], ImagePosition[1] ] 
   

   
   ;--------------------------- Axis and Axis Labels ----------------------------------------

   sState.oImage =  OBJ_NEW('IDLgrImage')  
   sState.oImage -> SetProperty, PALETTE = sState.oPalette
   sState.oImage -> SetProperty, Dimensions = [ImagePosition[2]-ImagePosition[0], ImagePosition[3]-ImagePosition[1]]
   sState.oImage -> SetProperty, Location = [ImagePosition[0],ImagePosition[1]] 

   sState.oModel -> Add, sState.oImage


   Slicer3D_UpdatePlotAxis, sState

   Slicer3D_UpdatePlotImage, sState


   ; Adds Spatial Axis
 
   sState.oModelAxis -> Add, sState.xAxis
   sState.oModelAxis -> Add, sState.xAxisOp   
   sState.oModelAxis -> Add, sState.yAxis
   sState.oModelAxis -> Add, sState.yAxisOp
   sState.oModelAxis -> Add, sState.zAxis
   sState.oModelAxis -> Add, sState.zAxisOp


   ; Add ColorBar
   
   bar = REPLICATE(1B,10) # BINDGEN(256) 
   dimension = [ BarPosition[2] - BarPosition[0], BarPosition[3] - BarPosition[1] ]
   location = [ BarPosition[0], BarPosition[1],0 ] 

   sState.oBar = Obj_New('IDLgrImage', bar, Palette = sState.oPalette )

   sState.oBar -> SetProperty, Dimensions = dimension
   sState.oBar -> SetProperty, Location = location

                  
   sState.DataAxis -> SetProperty, /Exact, TEXTPOS = 1, Direction = 2

   sState.DataAxis -> SetProperty, Location = location + [dimension[0],0,0]
   sState.DataAxis -> SetProperty, XCOORD_CONV = [0.0,1.0]
   sState.DataAxis -> SetProperty, TICKLEN = 0.3*dimension[0]
   sState.DataAxis -> SetProperty, TICKDIR = 1
   sState.DataAxis -> SetProperty, DIRECTION = 1
   sState.oModelAxis -> Add, sState.DataAxis
               
   sState.DataAxisOp -> SetProperty, /Exact, /notext
   sState.DataAxisOp -> SetProperty, Location = location 
   sState.DataAxisOp -> SetProperty, XCOORD_CONV = [0.0,1.0]
   sState.DataAxisOp -> SetProperty, TICKLEN = 0.3*dimension[0]
   sState.oModelAxis -> Add, sState.DataAxisOp
   
   Slicer3D_UpdatePlotDataAxis, sState
   
   sState.DataAxis -> GetProperty, COLOR = axisColor 
                             
   sState.oBoxBar1 = Obj_New('IDLgrPolyline', [location[0], location[0]+ dimension[0]], $
                                       [location[1], location[1]])
   sState.oBoxBar1 -> SetProperty, Color = axisColor
               
   sState.oBoxBar2 = Obj_New('IDLgrPolyline', [location[0], location[0]+dimension[0]], $
                                       [location[1], location[1]]+ dimension[1])
   sState.oBoxBar2 -> SetProperty, Color = axisColor
               
               
   sState.oModel -> Add, sState.oBar
   sState.oModelAxis -> Add, sState.oBoxBar1
   sState.oModelAxis -> Add, sState.oBoxBar2

   ; Update Data Position for tools

   sState.DataPosition = ImagePosition

end

; ---------------------------------------------------------------------

pro Update_Slider_Position_Slicer3D, sState

   case (sState.iSlicePlane) of
     0: begin
          widget_control, sState.wSliderID, Set_Value = sState.iSliceXPos
          widget_control, sState.wSliderID, Set_Slider_Max = sState.NX-1
        end
     1: begin
          widget_control, sState.wSliderID, Set_Value = sState.iSliceYPos
          widget_control, sState.wSliderID, Set_Slider_Max = sState.NY-1
        end
     2: begin
          widget_control, sState.wSliderID, Set_Value = sState.iSliceZPos
          widget_control, sState.wSliderID, Set_Slider_Max = sState.NZ-1
        end
   endcase

end

; ---------------------------------- UpdateDirection_Slicer3D_Event ---
;  Updates the slice plane direction
; ---------------------------------------------------------------------

pro UpdateDirection_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  value = Widget_Info(sEvent.id, /droplist_select)
 
  print, sState.iSliceXPos
  print, sState.iSliceYPos
  print, sState.iSliceZPos
  
  
  case (value) of
    0: begin
         sState.iSlicePlane = 2
       end
    1: begin
          sState.iSlicePlane = 1
       end
    2: begin
         sState.iSlicePlane = 0
       end
  endcase
  
  Slicer3D_Update_SliderLabel, sState
  Slicer3D_UpdatePlotAxis, sState
  Slicer3D_UpdatePlotImage, sState

  sState.oWindow->Draw, sState.oView                    
  sState.oSliceWindow -> Draw, sState.oSliceView
  
  Update_Slider_Position_Slicer3D, sState

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end

; ---------------------------------------------------------------------


; ----------------------------------------- Slicer3D_ZoomUpdateAxis ---
;  Updates the axis after zoom changes
; ---------------------------------------------------------------------

pro Slicer3D_ZoomUpdateAxis, sState

  x0 = sState.viewX[0]
  x1 = sState.viewX[1]
  y0 = sState.viewY[0]
  y1 = sState.viewY[1]
           
  ; Update Image
           
  sState.oImage -> SetProperty, DATA = (*(sState.ByteData))[x0:x1,y0:y1]
           
  ; Update Axis
  dimension = [ sState.DataPosition[2] - sState.DataPosition[0], $
                sState.DataPosition[3] - sState.DataPosition[1] ]
  location = [ sState.DataPosition[0], sState.DataPosition[1] ] 


  case (sState.iSlicePlane) of 
     2: begin
          DeltaX = sState.XAxisData[1] - sState.XAxisData[0] 
          XMin = sState.XAxisData[x0] - DeltaX/2.0
          XMax = sState.XAxisData[x1] + DeltaX/2.0
          DeltaY = sState.YAxisData[1] - sState.YAxisData[0]
          YMin = sState.YAxisData[y0] - DeltaY/2.0
          YMax = sState.YAxisData[y1] + DeltaY/2.0
       
          xcoord_conv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
          ycoord_conv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
        
          sState.xAxis -> SetProperty, RANGE = [XMin, XMax]
          sState.xAxis -> SetProperty, LOCATION = [XMin,YMin]
          xtl = 0.04 *(YMax-Ymin)
          sState.xAxis -> SetProperty, TICKLEN = xtl
          sState.xAxis -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.xAxis -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.xAxisOp -> SetProperty, RANGE = [XMin, XMax]
          sState.xAxisOp -> SetProperty, LOCATION = [XMin,YMax]
          sState.xAxisOp -> SetProperty, TICKLEN = xtl
          sState.xAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.xAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.yAxis -> SetProperty, RANGE = [YMin, YMax]
          sState.yAxis -> SetProperty, LOCATION = [XMin,YMin]
          ytl = 0.04 *(XMax-Xmin)
          sState.yAxis -> SetProperty, TICKLEN = ytl
          sState.yAxis -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.yAxis -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.yAxisOp -> SetProperty, RANGE = [YMin, YMax]
          sState.yAxisOp -> SetProperty, LOCATION = [XMax,YMin]
          sState.yAxisOp -> SetProperty, TICKLEN = ytl
          sState.yAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.yAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
        end
     1: begin
          DeltaX = sState.XAxisData[1] - sState.XAxisData[0]
          XMin = sState.XAxisData[x0] - DeltaX/2.0
          XMax = sState.XAxisData[x1] + DeltaX/2.0
          DeltaZ = sState.YAxisData[1] - sState.ZAxisData[0]
          ZMin = sState.ZAxisData[y0] - DeltaZ/2.0 
          ZMax = sState.ZAxisData[y1] + DeltaZ/2.0
       
          xcoord_conv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
          ycoord_conv = [location[1]-ZMin*dimension[1]/(ZMax-ZMin), dimension[1]/(ZMax-ZMin)]
        
          sState.xAxis -> SetProperty, RANGE = [XMin, XMax]
          sState.xAxis -> SetProperty, LOCATION = [XMin,ZMin]
          xtl = 0.04 *(ZMax-Zmin)
          sState.xAxis -> SetProperty, TICKLEN = xtl
          sState.xAxis -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.xAxis -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.xAxisOp -> SetProperty, RANGE = [XMin, XMax]
          sState.xAxisOp -> SetProperty, LOCATION = [XMin,ZMax]
          sState.xAxisOp -> SetProperty, TICKLEN = xtl
          sState.xAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.xAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.zAxis -> SetProperty, RANGE = [ZMin, ZMax]
          sState.zAxis -> SetProperty, LOCATION = [XMin,ZMin]
          ztl = 0.04 *(XMax-Xmin)
          sState.zAxis -> SetProperty, TICKLEN = ztl
          sState.zAxis -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.zAxis -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.zAxisOp -> SetProperty, RANGE = [ZMin, ZMax]
          sState.zAxisOp -> SetProperty, LOCATION = [XMax,ZMin]
          sState.zAxisOp -> SetProperty, TICKLEN = ztl
          sState.zAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.zAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
        end
     0: begin
          DeltaY = sState.YAxisData[1] - sState.YAxisData[0]
          YMin = sState.YAxisData[x0] - DeltaY/2.0
          YMax = sState.YAxisData[x1] + DeltaY/2.0
          DeltaZ = sState.ZAxisData[1] - sState.ZAxisData[0]
          ZMin = sState.ZAxisData[y0] - DeltaZ/2.0
          ZMax = sState.ZAxisData[y1] + DeltaZ/2.0
       
          xcoord_conv = [location[0]-YMin*dimension[0]/(YMax-YMin), dimension[0]/(YMax-YMin)]
          ycoord_conv = [location[1]-ZMin*dimension[1]/(ZMax-ZMin), dimension[1]/(ZMax-ZMin)]
        
          sState.yAxis -> SetProperty, RANGE = [YMin, YMax]
          sState.yAxis -> SetProperty, LOCATION = [YMin,ZMin]
          ytl = 0.04 *(ZMax-Zmin)
          sState.yAxis -> SetProperty, TICKLEN = ytl
          sState.yAxis -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.yAxis -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.yAxisOp -> SetProperty, RANGE = [YMin, YMax]
          sState.yAxisOp -> SetProperty, LOCATION = [YMin,ZMax]
          sState.yAxisOp -> SetProperty, TICKLEN = ytl
          sState.yAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.yAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.zAxis -> SetProperty, RANGE = [ZMin, ZMax]
          sState.zAxis -> SetProperty, LOCATION = [YMin,ZMin]
          ztl = 0.04 *(YMax-Ymin)
          sState.zAxis -> SetProperty, TICKLEN = ztl
          sState.zAxis -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.zAxis -> SetProperty, XCOORD_CONV = xcoord_conv

          sState.zAxisOp -> SetProperty, RANGE = [ZMin, ZMax]
          sState.zAxisOp -> SetProperty, LOCATION = [YMax,ZMin]
          sState.zAxisOp -> SetProperty, TICKLEN = ztl
          sState.zAxisOp -> SetProperty, YCOORD_CONV = ycoord_conv
          sState.zAxisOp -> SetProperty, XCOORD_CONV = xcoord_conv
        end

  endcase
       
end

; ---------------------------------------------------------------------

; ---------------------------------------- SaveSlice_Slicer3D_Event ---
;  Handles SaveSlice events
; ---------------------------------------------------------------------

pro SaveSlice_Slicer3D_Event, sEvent

   fileout = Dialog_PickFile(/write, FILTER = '*.hdf',$
                        TITLE = 'Save slice as...', GET_PATH = filepath)
   if (fileout ne '') then begin
     cd, filepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     case (sState.iSlicePlane) of
       0 : $; YZ
          begin
            Data = reform((*(sState.pData))[sState.iSliceXpos,*,*])
            axis1 = sState.YAxisData
            axis2 = sState.ZAxisData
;            label1 = sState.ytitle
;            label2 = sState.ztitle
            axname1 = sState.sInfo.x2name
            axformat1 = sState.sInfo.x2format
            axlabel1 = sState.sInfo.x2label
            axunits1 = sState.sInfo.x2units
            axname2 = sState.sInfo.x3name
            axformat2 = sState.sInfo.x3format
            axlabel2 = sState.sInfo.x3label
            axunits2 = sState.sInfo.x3units
            slicepos = sState.xAxisData[sState.iSliceXpos]
          end
       1 : $; XZ
          begin
            Data = reform((*(sState.pData))[*,sState.iSliceYpos,*])
            axis1 = sState.XAxisData
            axis2 = sState.ZAxisData
;            label1 = sState.xtitle
;            label2 = sState.ztitle
            axname1 = sState.sInfo.x1name
            axformat1 = sState.sInfo.x1format
            axlabel1 = sState.sInfo.x1label
            axunits1 = sState.sInfo.x1units
            axname2 = sState.sInfo.x3name
            axformat2 = sState.sInfo.x3format
            axlabel2 = sState.sInfo.x3label
            axunits2 = sState.sInfo.x3units
            slicepos = sState.yAxisData[sState.iSliceYpos]
          end
       2 : $; XY
          begin
            Data = reform((*(sState.pData))[*,*,sState.iSliceZpos])
            axis1 = sState.XAxisData
            axis2 = sState.YAxisData
;            label1 = sState.xtitle
;            label2 = sState.ytitle
            axname1 = sState.sInfo.x1name
            axformat1 = sState.sInfo.x1format
            axlabel1 = sState.sInfo.x1label
            axunits1 = sState.sInfo.x1units
            axname2 = sState.sInfo.x2name
            axformat2 = sState.sInfo.x2format
            axlabel2 = sState.sInfo.x2label
            axunits2 = sState.sInfo.x2units
            slicepos = sState.zAxisData[sState.iSliceZpos]
          end
     endcase
     
     sExtra_Attr = { SLICE_PLANE : sState.iSlicePlane, $
                     SLICE_POS : slicepos }
     
     pData = ptr_new(Data, /no_copy)
     
     osiris_save_data, pData, FILE = fileout, PATH = filepath, $
          TIMEPHYS = sState.sInfo.time, TIMESTEP = sState.sInfo.timestep, $
          DATATITLE = sState.sInfo.name, DATAFORMAT= sState.sInfo.format, $
          DATALABEL = sState.sInfo.label, DATAUNITS = sState.sInfo.units, $        
          XAXIS = axis1, YAXIS = axis2, $
          XNAME = axname1, XFORMAT = axformat1, XLABEL = axlabel1, XUNITS = axunits1, $
          YNAME = axname2, YFORMAT = axformat2, YLABEL = axlabel2, YUNITS = axunits2, $
          EXTRA_ATTR = sExtra_Attr
     
     ptr_free, pData
              
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end

; ---------------------------------------------------------------------

; ------------------------------------ SaveImageTIFF_Slicer3D_Event ---
;  Handles SaveImageTIFF events
; ---------------------------------------------------------------------

pro SaveImageTIFF_Slicer3D_Event, sEvent

   tifffileout = Dialog_PickFile(/write, FILTER = '*.tif',$
                        TITLE = 'Save image TIFF file as...', GET_PATH = tifffilepath)
   if (tifffileout ne '') then begin
     cd, tifffilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oImage -> GetProperty, DATA = imageout
     
     ; imageout is an 8-bit image
     
     sState.oPalette -> GetProperty, RED_VALUES = r
     sState.oPalette -> GetProperty, GREEN_VALUES = g
     sState.oPalette -> GetProperty, BLUE_VALUES = b
     
        
     imageout = reverse(imageout,0)
     WRITE_TIFF, tifffileout, imageout, RED = r, GREEN = g, BLUE = b, 1
         
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end

; ---------------------------------------------------------------------


; ------------------------------------- SavePlotTIFF_Slicer3D_Event ---
;  Handles SavePlotTIFF events
; ---------------------------------------------------------------------

pro SavePlotTIFF_Slicer3D_Event, sEvent

   tifffileout = Dialog_PickFile(/write, FILTER = '*.tif',$
                        TITLE = 'Save TIFF file as...', GET_PATH = tifffilepath)
   if (tifffileout ne '') then begin
     cd, tifffilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oWindow -> GetProperty, Dimension = ImageResolution
             
     myimage = sState.oWindow -> Read()
     myimage -> GetProperty, DATA = imageout
     Obj_Destroy, myimage
        
     imageout = reverse(imageout,3)
     WRITE_TIFF, tifffileout, imageout, 1
         
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end

; ---------------------------------------------------------------------

; --------------------------------------- PageSetup_Slicer3D_Event ---
;  Handles Page Setup events
; ---------------------------------------------------------------------

pro PageSetup_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  res = Dialog_PrinterSetup(sState.oPrinter) 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ------------------------------------------- Print_Slicer3D_Event ---
;  Handles Print events
; ---------------------------------------------------------------------

pro Print_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  res = Dialog_PrintJob(sState.oPrinter) 
  if (res ne 0) then begin
    sState.oPrinter -> SetProperty, Units = 2
    sState.oPrinter -> GetProperty, Dimensions = DimPrinter
;    print, 'Printer Dimensions [cm]: ', DimPrinter

    ; Get the correct aspect ratio
    sState.oWindow -> GetProperty, Dimension = DimImage
    ratios = float(DimImage)/DimPrinter
    NewViewDimensions = ratios/Max(Ratios)
    sState.oView -> Getproperty, UNITS = ViewUnits
    sState.oView -> Getproperty, DIMENSIONS = ViewDimensions
    sState.OView -> SetProperty, UNITS = 3
    sState.oView -> SetProperty, DIMENSIONS = NewViewDimensions   
    
    ; Draw the view
    sState.oPrinter-> Draw, sState.oView
    
    ; Restore the view
    sState.oView -> Setproperty, UNITS = ViewUnits
    sState.oView -> Setproperty, DIMENSIONS = ViewDimensions
    
    ; Start the printing job
    sState.oPrinter-> NewDocument
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; ------------------------------------- ClipCopyPlot_Slicer3D_Event ---
;  Handles Copy Plot events
; ---------------------------------------------------------------------

pro ClipCopyPlot_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oWindow -> GetProperty, Dimension = ImageResolution
             
  oClipboard = obj_new('IDLgrClipboard',DIMENSIONS=ImageResolution)
  oClipboard-> Draw, sState.oView
  Obj_Destroy, oClipboard

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end

; ---------------------------------------------------------------------

; ------------------------------------ ClipCopyImage_Slicer3D_Event ---
;  Handles Copy Image events
; ---------------------------------------------------------------------

pro ClipCopyImage_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oImage -> GetProperty, DATA = data
  
  ImageResolution = size(data, /dimensions)
  
  oImage = obj_new('IDLgrImage', data, PALETTE = sState.oPalette, DIMENSIONS = [1,1])
  
  oModel = obj_new('IDLgrModel')
  oView = obj_new('IDLgrView', Dimensions = ImageResolution, VIEWPLANE_RECT = [0,0,1,1])
  oModel -> Add, oImage
  oView -> Add, oModel           

  oClipboard = obj_new('IDLgrClipboard',DIMENSIONS=ImageResolution)
  oClipboard-> Draw, oView
  
  Obj_Destroy, oClipboard
  Obj_Destroy, oView
  Obj_Destroy, oModel

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end

; ---------------------------------------------------------------------


; --------------------------------- Slicer3D_UpdateInvColors_Event ---
;  Handles Changes to the Invert Color setting
; ---------------------------------------------------------------------

pro Slicer3D_UpdateInvColors_Event, sEvent

  clWhite = [255b,255b,255b]
  clBlack = [0b,0b,0b]

  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  sState.iInvColors = Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))
  
  if (sState.iInvColors eq 1) then begin
    oObjects = sState.oModelAxis -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    oObjects = sState.oModelTitles -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    sState.oView -> SetProperty, COLOR = clWhite
  end else begin
    oObjects = sState.oModelAxis -> Get(/ALL, COUNT = nObjects)    
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clWhite
    end
    oObjects = sState.oModelTitles -> Get(/ALL, COUNT = nObjects)    
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clWhite
    end
    sState.oView -> SetProperty, COLOR = clBlack
  end

  sState.oWindow->Draw, sState.oView                    
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------

; ------------------------------------ ChangePallete_Slicer3D_Event ---
;  Handles palette change events
; ---------------------------------------------------------------------

pro ChangePallete_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oPalette-> SetProperty, RED_VALUES = sEvent.R
  sState.oPalette-> SetProperty, GREEN_VALUES = sEvent.G
  sState.oPalette-> SetProperty, BLUE_VALUES = sEvent.B
  
  sState.oWindow->Draw, sState.oView                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------


; -------------------------------------------- Palette_Slicer3D_Event ---
;  Opens the Palette Dialog Box
; ---------------------------------------------------------------------

pro Palette_Slicer3D_Event, sEvent

  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oPalette-> GetProperty, RED_VALUES = R
  sState.oPalette-> GetProperty, GREEN_VALUES = G
  sState.oPalette-> GetProperty, BLUE_VALUES = B

  TVLCT, R, G, B
  XColors, NColors=256, Bottom=0, Group_Leader=sEvent.top, NotifyID=[sEvent.id, sEvent.top]
  R = 0
  G = 0
  B = 0

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------


; ---------------------------------------- ZoomReset_Slicer3D_Event ---
;  Handles zoom reset events
; ---------------------------------------------------------------------

pro ZoomReset_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  s = size(*(sState.ByteData), /dimensions)

  sState.viewX[0] = 0
  sState.viewX[1] = s[0]-1
  sState.viewY[0] = 0
  sState.viewY[1] = s[1]-1

  Slicer3D_ZoomUpdateAxis, sState
  
  sState.oWindow->Draw, sState.oView                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end
; ---------------------------------------------------------------------

; ------------------------------------------- ZoomIn_Slicer3D_Event ---
;  Handles zoom in events
; ---------------------------------------------------------------------

pro ZoomIn_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  s = size(*(sState.ByteData), /dimensions)

  lx = long(double(sState.viewX[1]-sState.viewX[0])/4.)
  ly = long(double(sState.viewY[1]-sState.viewY[0])/4.)
  
  sState.viewX[0] = sState.viewX[0] + lx
  sState.viewX[1] = sState.viewX[1] - lx
  sState.viewY[0] = sState.viewY[0] + ly
  sState.viewY[1] = sState.viewY[1] - ly

  Slicer3D_ZoomUpdateAxis, sState
  
  sState.oWindow->Draw, sState.oView                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------


; ------------------------------------------ ZoomOut_Slicer3D_Event ---
;  Handles zoom out events
; ---------------------------------------------------------------------

pro ZoomOut_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  s = size(*(sState.ByteData), /dimensions)

  lx = long(double(sState.viewX[1]-sState.viewX[0])/2.)
  ly = long(double(sState.viewY[1]-sState.viewY[0])/2.)
  
  sState.viewX[0] = Max([0,sState.viewX[0] - lx])
  sState.viewX[1] = Min([s[0]-1,sState.viewX[1] + lx])
  sState.viewY[0] = Max([0,sState.viewY[0] - ly])
  sState.viewY[1] = Min([s[1]-1,sState.viewY[1] + ly])

  Slicer3D_ZoomUpdateAxis, sState
  
  sState.oWindow->Draw, sState.oView                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------

; --------------------------------------- Oversample_Slicer3D_Event ---
;  Handles oversample events
; ---------------------------------------------------------------------

pro Oversample_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
    sState.oWindow -> GetProperty, Units = Units
    sState.oWindow -> SetProperty, Units = 0
    sState.oWindow -> GetProperty, Dimensions = dims
    sState.oWindow -> SetProperty, Units = Units

    dims[0] = dims[0]*(sState.DataPosition[2] - sState.DataPosition[0])
    dims[1] = dims[1]*(sState.DataPosition[3] - sState.DataPosition[1])

    sState.oImage -> GetProperty, Data = Data
    
    Data = Congrid(Data, dims[0], dims[1], CUBIC = -0.5)
    sState.oImage -> SetProperty, DATA = Data
    sState.oWindow->Draw, sState.oView                    
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------

; ----------------------------------------- DataAxis_Slicer3D_Event ---
;  Handles changes to the Data Axis
; ---------------------------------------------------------------------

pro DataAxis_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  Autoscale = 0b
  
  data = { $
           Autoscale : 0b, $
           Logarithmic : Byte(sState.UseLog), $
           Minimum : double(sState.DataMin), $
           Maximum : double(sState.DataMax) $
           }           
           
  labels = [ $
           'Autoscale', $
           'Use Log Scale', $
           'Minimum', $
           'Maximum' $
           ]  

  res = InputValues( data, $
                     labels = labels, $
                     Title = 'Data Axis', $
                     group_leader = sEvent.top )
  
  if (res eq 1) then begin
     sState.UseLog = data.Logarithmic
 
     if (data.Autoscale eq 0) then begin
        sState.DataMin = data.Minimum
        sState.DataMax = data.Maximum 
        
        if (sState.UseLog eq 1) then begin
          sState.DataMin = abs(sState.DataMin)
          sState.DataMax = abs(sState.DataMax)
          
          if (sState.DataMin gt sState.DataMax) then begin
            temp = sState.DataMax
            sState.DataMax = sState.DataMin
            sState.DataMin = temp
          end
        end
           
     end else begin
        if (sState.UseLog eq 0) then begin
           sState.DataMin = Min(*sState.pData, Max = DataMax)
           sState.DataMax = DataMax
        end else begin
          temp = AbsMin(*sState.pData, Max = Max, MINN0 = MinN0)
          sState.DataMax = Max
          sState.DataMin = MinN0
          if (sState.DataMax eq 0.0) then sState.DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.
          if (sState.DataMin eq 0.0) then sState.DataMin = sState.DataMax/10.0            
        end
           
     end

     s = size((*sState.ByteData), /dimensions)
     sState.viewX[0] = 0
     sState.viewX[1] = s[0]-1
     sState.viewY[0] = 0
     sState.viewY[1] = s[1]-1

     Slicer3D_ZoomUpdateAxis, sState
     Slicer3D_UpdatePlotAxis, sState
     Slicer3D_UpdatePlotImage, sState
     Slicer3D_UpdatePlotDataAxis, sState

     sState.oWindow->Draw, sState.oView 
  end
                     
 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------


; -------------------------------------- UpdatePlane_Slicer3D_Event ---
;  Handles changes to the Plane Slider
; ---------------------------------------------------------------------

pro UpdatePlane_Slicer3D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  slider = sEvent.id
  Widget_Control, slider, Get_Value = value
  
  case (sState.iSlicePlane) of
    0: sState.iSliceXPos = value
    1: sState.iSliceYPos = value
    2: sState.iSliceZPos = value
  endcase 

  Slicer3D_Update_SliderLabel, sState
  Slicer3D_UpdatePlotImage, sState
 
  ; Reset Zoom
  Slicer3D_ZoomUpdateAxis, sState

  sState.oWindow->Draw, sState.oView                    
  sState.oSliceWindow -> Draw, sState.oSliceView

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; ------------------------------------------------ Slicer3D_Profile ---
;  Generates Profile
; ---------------------------------------------------------------------

pro Slicer3D_Profile, x1, y1, sState
 
  
  case (sState.iSlicePlane) of
    2: begin
         window_title = 'Z = '+string(sState.ZAxisData[sState.iSliceZPos])
         axis1 = sState.XAxisData
         data1 = reform((*(sState.pData))[*, y1, sState.iSliceZPos])
         title1 = 'Y = '+string(sState.YAxisData[y1])
         xlabel1 = sState.XTitle
         axis2 = sState.YAxisData
         data2 = reform((*(sState.pData))[x1, *, sState.iSliceZPos])
         title2 = 'X = '+string(sState.XAxisData[x1])
         xlabel2 = sState.YTitle
       end
    1: begin
         window_title = 'Y = '+string(sState.YAxisData[sState.iSliceYPos])
         axis1 = sState.XAxisData
         data1 = reform((*(sState.pData))[*, sState.iSliceYPos, y1])
         title1 = 'Z = '+string(sState.ZAxisData[y1])
         xlabel1 = sState.XTitle

         axis2 = sState.ZAxisData
         data2 = reform((*(sState.pData))[x1,sState.iSliceYPos, *])
         title2 = 'X = '+string(sState.XAxisData[x1])
         xlabel1 = sState.ZTitle

       end
    0: begin
         window_title = 'X = '+string(sState.XAxisData[sState.iSliceXPos])
         axis1 = sState.YAxisData
         data1 = reform((*(sState.pData))[sState.iSliceXPos, *, y1])
         title1 = 'Z = '+string(sState.ZAxisData[y1])
         xlabel1 = sState.YTitle

         axis2 = sState.ZAxisData
         data2 = reform((*(sState.pData))[sState.iSliceXPos, x1, *])
         title2 = 'Y = '+string(sState.YAxisData[x1])
         xlabel1 = sState.ZTitle

       end
       
  endcase

  ; Old style
  
  ; Window, /free, XSize = 500, YSize = 250, Title = window_title
  ; !P.Multi = [0,2,1]

  ; Plot, axis1, data1, xstyle = 1, YRANGE = [sState.Datamin, sState.DataMax], $
  ;             TITLE = title1, xtitle = xlabel1 ;, FONT = 1, CHARSIZE = 1.5
  ; Plot, axis2, data2, xstyle = 1, YRANGE = [sState.Datamin, sState.DataMax], $
  ;         TITLE = title2, xtitle = xlabel2 ;, FONT = 1, CHARSIZE = 1.5
 
  ; !P.Multi = 0
  
  ; New Style
  
  plot1d, axis1, data1, /no_copy, WINDOWTITLE = windowtitle, TITLE = title1, $
     RES = [400,300],  YRANGE = [sState.Datamin, sState.DataMax], xtitle = xlabel1, $
     XOFFSET = sState.window_size[0]/3.0, YOFFSET = sState.window_size[1]/3.0  

  plot1d, axis2, data2, /no_copy, WINDOWTITLE = windowtitle, TITLE = title2, $
     RES = [400,300],  YRANGE = [sState.Datamin, sState.DataMax], xtitle = xlabel2, $
     XOFFSET = 2.0*sState.window_size[0]/3.0, YOFFSET = 2.0*sState.window_size[1]/3.0  

end
; ---------------------------------------------------------------------

; -------------------------------------------- Draw_Visualize_Event ---
;  Handles draw widget events
; ---------------------------------------------------------------------

pro Slicer3D_Draw_Visualize_Event, sEvent
  
    ; Get sState structure from base widget
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /No_Copy
  
    ; Meaning of sEvent.type
    ; from the WIDGET_DRAW help
    ;
    ; 0 - Button Press
    ; 1 - Button Release
    ; 2 - Motion
    ; 3 - ViewPort Moved (Scrollbars)
    ; 4 - Visibility Changed (Exposed)

    ; Expose (first draw of window)
    IF (sEvent.type EQ 4) THEN BEGIN
           print, 'Rendering Image...'
           sState.oWindow->Draw, sState.oView
           sState.oSliceWindow -> Draw, sState.oSliceView 

           print, 'Done'
    ENDIF

    ; Button press
    IF (sEvent.type EQ 0) THEN BEGIN
        sState.tool_pos0 = double([ sEvent.x ,sEvent.y])/(sState.window_size) 
        x0 = sState.tool_pos0[0]
        y0 = sState.tool_pos0[1]

        if ((x0 ge sState.DataPosition[0]) and $
            (x0 le sState.DataPosition[2]) and $
            (y0 ge sState.DataPosition[1]) and $
            (y0 le sState.DataPosition[3])) then begin

          sState.btndown = 1b

          case (sState.iTool) of 
            0: $ ; Zoom
              begin
                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                sState.oZoomBox -> SetProperty, Hide = 0
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x0,y0]] 
      
                clWhite = [255b,255b,255b]
                clBlack = [0b,0b,0b]
                if (sState.iInvColors eq 1) then begin
                  sState.oZoomBox -> SetProperty, COLOR = clBlack
                end else begin
                  sState.oZoomBox -> SetProperty, COLOR = clWhite
                end
                sState.oWindow->Draw, sState.oViewTools, /CREATE_INSTANCE
              end
            1: ; Profile
          else:
          endcase
        end
    end

    ; Motion with button pressed
    if (sEvent.type EQ 2) and (sState.btndown EQ 1b) then begin
       tool_pos1 = double([ sEvent.x ,sEvent.y])/(sState.window_size)
       x0 = sState.tool_pos0[0]
       y0 = sState.tool_pos0[1]
       x1 = tool_pos1[0]
       y1 = tool_pos1[1]

       case (sState.iTool) of 

         0: $ ; Zoom
              begin
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x1,y0], [x1,y1], [x0,y1], [x0,y0] ] 
                sState.oWindow->Draw, sState.oViewTools, /DRAW_INSTANCE
              end
         1: ; Profile
       else:
       endcase
    end

    ; Button Release
    IF (sEvent.type EQ 1) THEN BEGIN
        IF (sState.btndown EQ 1b) THEN BEGIN
           tool_pos1 = double([ sEvent.x,sEvent.y])/(sState.window_size ) 

           dataXL = double(sState.DataPosition[2]-sState.DataPosition[0])
           dataYL = double(sState.DataPosition[3]-sState.DataPosition[1])
           dataXmin = double(sState.DataPosition[0])
           dataYmin = double(sState.DataPosition[1])

           viewXL = sState.viewX[1] - sState.viewX[0]
           viewYL = sState.viewY[1] - sState.viewY[0]

           x0 = sState.viewX[0] +  long((sState.tool_pos0[0]-dataXmin)/dataXL * viewXL +0.5)
           y0 = sState.viewY[0] +  long((sState.tool_pos0[1]-dataYmin)/dataYL * viewYL +0.5)
           x1 = sState.viewX[0] +  long((tool_pos1[0]-dataXmin)/dataXL * viewXL +0.5 )
           y1 = sState.viewY[0] +  long((tool_pos1[1]-dataYmin)/dataYL * viewYL +0.5 )

           print, ' x1, y1 -> ', x1, y1
           
           case (sState.iTool) of 
              0: $ ; Zoom
                 begin

                   sState.oZoomBox -> SetProperty, Hide = 1
           
           
                   if ((x0 ne x1) and (y0 ne y1)) then begin
           
                     if (x0 gt x1) then begin
                        t = x1
                        x1 = x0
                        x0 = t
                     end

                     if (y0 gt y1) then begin
                       t = y1
                       y1 = y0
                       y0 = t
                     end
           
                     sState.viewX = [x0,x1]
                     sState.viewY = [y0,y1]

                     Slicer3D_ZoomUpdateAxis, sState
            
                     sState.oWindow->Draw, sState.oView
                   end
                 end
               1: $; Profile
                  Slicer3D_Profile, x1, y1, sState
             else:
           endcase
         ENDIF
         sState.btndown = 0b
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF
    
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        
end
; ---------------------------------------------------------------------

; --------------------------------- Resize_Slicer3D_Visualize_Event ---
;  Handles resize events
; ---------------------------------------------------------------------

pro Resize_Slicer3D_Visualize_Event, sEvent
    ; Get sState structure from base widget
    Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

    wsx =  sEvent.x - 160
    wsy =  sEvent.y - 30 
        
    ; Resize the draw widget.
        
    sState.oWindow->SetProperty, Dimensions=[wsx, wsy]
    sState.window_size = [wsx, wsy]
        
    ; Resize the fonts
    maxRES = MAX(sState.window_size)
    SizeFontAxis = float(sState.FontSize*0.022*maxRES)
    sState.oFontAxis -> SetProperty, SIZE = SizeFontAxis
    SizeFontTitle = float(sState.FontSize*0.025*maxRES)
    SizeFontSubTitle = float(sState.FontSize*0.022*maxRES)
    sState.oFontTitle -> SetProperty, SIZE = SizeFontTitle
    sState.oFontSubTitle -> SetProperty, SIZE = SizeFontSubTitle
        
    ; Redisplay the graphics
    sState.oWindow->Draw, sState.oView
       
    ;Put the info structure back.
    Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; -------------------------------------------- Base_Visualize_Event ---
;  Handles base events
; ---------------------------------------------------------------------

pro Slicer3D_Base_Visualize_Event, sEvent

 eventName = TAG_NAMES(sEvent, /STRUCTURE_NAME) 

; print, 'Event Structure, ', TAG_NAMES(sEvent)

 case eventName of
  'WIDGET_BASE'  : Resize_Slicer3D_Visualize_Event, sEvent  ; Note: Only resize events are caught here
  
  'WIDGET_BUTTON': begin
       
     WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue ; Menu events
     case eventUValue of
       ; Menu Options
       '|File|Save Slice...'		: SaveSlice_Slicer3D_Event, sEvent 
       '|File|Save Plot Tiff...'	: SavePlotTIFF_Slicer3D_Event, sEvent
       '|File|Save Image Tiff...'	: SaveImageTIFF_Slicer3D_Event, sEvent
       '|File|Page Setup...'		: PageSetup_Slicer3D_Event, sEvent
       '|File|Print...'			: Print_Slicer3D_Event, sEvent
       '|File|Quit'				: WIDGET_CONTROL, sEvent.top, /DESTROY
       '|Edit|Copy Image'			: ClipCopyImage_Slicer3D_Event, sEvent
       '|Edit|Copy Plot'			: ClipCopyPlot_Slicer3D_Event, sEvent
       '|Slice|Palette...'    		: Palette_Slicer3D_Event, sEvent
       '|Slice|Invert Colors|On'	: Slicer3D_UpdateInvColors_Event, sEvent
       '|Slice|Invert Colors|Off'	: Slicer3D_UpdateInvColors_Event, sEvent
       '|Slice|Data Axis'			: DataAxis_Slicer3D_Event, sEvent     
       
       ; Color Map Plot
       '|Slice|Oversample'           	: Oversample_Slicer3D_Event, sEvent
       '|Slice|Zoom|In'			: ZoomIn_Slicer3D_Event, sEvent
       '|Slice|Zoom|Out'			: ZoomOut_Slicer3D_Event, sEvent
       '|Slice|Zoom|Reset'			: ZoomReset_Slicer3D_Event, sEvent
              
       '|About|About Slicer 3D'	: XDisplayFile, /MODAL, $
                                       TITLE = 'About Slicer 3D', Text = $
                                       'About Slicer 3D not implemented yet'     

       ; Tool Selection
       '|Tool|Zoom'		: begin
       				    widget_control, sEvent.top, Get_UValue = sState, /no_copy
       				    sState.iTool = 0
       				    widget_control, sEvent.top, Set_UValue = sState, /no_copy
       				  end 

       '|Tool|Profile'	: begin
       				    ; Reset the zoom for profiles
       				    ZoomReset_Slicer3D_Event, sEvent
       				    widget_control, sEvent.top, Get_UValue = sState, /no_copy
       				    sState.iTool = 1
       				    widget_control, sEvent.top, Set_UValue = sState, /no_copy
       				  end 
        
       else: begin
               print, "'"+eventUvalue+"'"+' not found, returning'
               print, 'Widget_Button Event'
               print, 'id      = ', sEvent.id
               print, 'top     = ', sEvent.top
               print, 'handler = ', sEvent.Handler
               print, 'select  = ', sEvent.Select
             end             
     endcase
     end
  
  
  ; Palette Changes   
  'XCOLORS_LOAD' : ChangePallete_Slicer3D_Event, sEvent
  
  ; Choose plane direction
  'WIDGET_DROPLIST' : UpdateDirection_Slicer3D_Event, sEvent
  'WIDGET_SLIDER'   : UpdatePlane_Slicer3D_Event, sEvent
  
  else: begin
          print, 'Event structure name: "',eventName,'" not found'
        end
 endcase
                    
end

; ---------------------------------------------------------------------

; ----------------------------------------------- Visualize_Cleanup ---
;  Handles cleanup events. Called when window is closed
; ---------------------------------------------------------------------

PRO Slicer3D_Visualize_Cleanup, tlb


   ; Come here when program dies. Free all created objects.

   Widget_Control, tlb, Get_UValue=sState, /No_Copy
   if N_Elements(sState) ne 0 then begin     
          
     ; Destroy Models and Views         
     OBJ_DESTROY, sState.oModelTitles
     Obj_Destroy, sState.oModelAxis
     Obj_Destroy, sState.oModel
     Obj_Destroy, sState.oModelTools

     Obj_Destroy, sState.oView
     Obj_Destroy, sState.oViewTools

     ; Destroy remaining objects
     Obj_Destroy, sState.oContainer

     ; Free Menu Data
     ptr_free, sState.pMenuItems
     ptr_free, sState.pMenuButtons

     ; Free Data
     ptr_free, sState.ByteData
     ptr_free, sState.pData
     
     print, 'Cleaning up Done!'
      
   end
END

; ---------------------------------------------------------------------

pro Slicer3D, pData, _EXTRA = extrakeys,$
            XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
            XTITLE = XTitle, YTITLE = YTitle, ZTITLE = ZTitle, $
            TITLE = Title1, SUBTITLE = Title2, INFO_STRUCT = sInfo, $
            ; Scale
            MIN = DataMin, MAX = DataMax, LOG = UseLog, CT = CT, $
            ; Visualization
            RES = ImageResolution, WINDOWTITLE = windowTitle, $
            FONTSIZE = fontsize, INVCOLORS = inverse_colors, $
            ; Widget
            WIDGET_ID = widget_id
            
if N_Elements(pData) ne 0 then Begin
   
   ; Main Data
   S = Size(*pData)

   if (S[0] ne 3) then begin
     res = Dialog_Message("Data must be a 3D array", /Error)
     return
   end
   NX = S[1]
   NY = S[2]
   NZ = S[3]

   ; Font size

   if N_Elements(fontsize) eq 0 then fontsize = 1.0

   ; The resolution for the image. Default is [600,600]
   
   if (N_Elements(ImageResolution) eq 0) then begin
     ImageResolution = [600,600]
   end else begin
     s = size(ImageResolution)
     if (s[0] ne 1) or (s[1] ne 2) then begin
       print, 'Visualize, RES must be a 1D 2 element array with the dimension of the image to display'
       return
     end
   end

   maxRes = Max(ImageResolution)
   xdim = ImageResolution[0]
   ydim = ImageResolution[1]
   

   ; Window Title

   if N_Elements(windowTitle) eq 0 then windowTitle = 'Slicer3D'
   if N_Elements(XTitle) eq 0 then XTitle = 'X1'
   if N_Elements(YTitle) eq 0 then YTitle = 'X2'
   if N_Elements(ZTitle) eq 0 then ZTitle = 'X3'
   
   ; Default Axis

   If N_Elements(XAxisData) eq 0 then XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   If N_Elements(YAxisData) eq 0 then YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   If N_Elements(ZAxisData) eq 0 then ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)

   ; Spatial Range

   XMax = XAxisData[NX-1]
   XMin = XAxisData[0]
   YMax = YAxisData[NY-1]
   YMin = YAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZMin = ZAxisData[0]
           
   ; Default Plot Title

   if N_Elements(Title1) eq 0 then Title1 = ''
   ; Default Plot Sub Title

   if N_Elements(Title2) eq 0 then Title2 = ''

   ; Default Color Table

   if N_Elements(CT) eq 0 then begin
     CT = 13
   end

   ; Info Structure

   if N_Elements(sInfo) eq 0 then begin
           sInfo = { time:0.0, $
                     timestep:0, $
                     name:Title1, $
                     format:'', $
                     label:'', $
                     units:'', $
                     x1name:XTitle, $
                     x1format:'', $
                     x1label:XTitle, $
                     x1units:'', $
                     x2name:YTitle, $
                     x2format:'', $
                     x2label:YTitle, $
                     x2units:'', $
                     x3name:ZTitle, $
                     x3format:'', $
                     x3label:ZTitle, $
                     x3units:'' }
   end else begin
     def_Info_tag_names = strupcase(['time', 'timestep', 'name', 'format', 'label', 'units', $
                        'x1name', 'x1format', 'x1label', 'x1units', $
                        'x2name', 'x2format', 'x2label', 'x2units', $
                        'x3name', 'x3format', 'x3label', 'x3units' ])
                        
     Info_tag_names = tag_names(sInfo)
     num_tags = N_Elements(Info_tag_names)
     
     if num_tags ne N_Elements( def_Info_tag_names) then begin
       res = Error_Message('Invalid number of tags in INFO_STRUCT')
       return
     end 
    
     for i=0, num_tags-1 do begin
       idx = where(def_Info_tag_names eq Info_tag_names[i], count) 
       if (count ne 1) then begin
         res = Error_Message('Invalid tags or tags missing in INFO_STRUCT')
         return
       end    
     end
   end
   
   ; ------------------------------------------------------ Data Values Ranging ---
            
   if N_Elements(UseLog) eq 0 then begin
     UseLog = 0
   end               

   if (UseLog eq 0) then begin
      ; Unless specified, autoscale DataMin

      if N_Elements(DataMin) eq 0 then begin
         DataMin = Min(*pData)
      end

      ; Unless specified, autoscale DataMax

      if N_Elements(DataMax) eq 0 then begin
         DataMax = Max(*pData)
      end

   endif else begin
     temp = AbsMin(*pData, Max = tMax, MinN0 = tMinN0)

     if N_Elements(DataMax) eq 0 then DataMax = tMax

     if (DataMax eq 0.0) then DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.

     if N_Elements(DataMin) eq 0 then begin       ; Autoscales min for the log plot
         DataMin = tMinN0
         if (DataMin eq 0.0) then  DataMin = DataMax / 10.0
     end
   end

   ; -------------------------------------------------------- Create the Objects ---
   
   ;----------------------------- Container ----------------------------------------
 
   oContainer = OBJ_NEW('IDLgrContainer')
   
   ;------------------------------ Palettes ----------------------------------------

   oPalette = OBJ_NEW('IDLgrPalette')
   oPalette -> LoadCT, CT

   oContainer -> Add, oPalette

   ;------------------------------ Fonts -------------------------------------------

   SizeFontTitle = float(FontSize*0.025*maxRES)
   SizeFontSubTitle = float(FontSize*0.022*maxRES)
   SizeFontAxis = float(FontSize*0.022*maxRES)

   oFontTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontTitle)
   oContainer -> Add, oFontTitle

   oFontSubTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontSubTitle)
   oContainer -> Add, oFontSubTitle

   oFontAxis =  OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontAxis)
   oContainer -> Add, oFontAxis
 
   ;--------------------------- Axis and Axis Labels ----------------------------------------

   axisColor = [255b,255b,255b]


   xAxis = OBJ_NEW('IDLgrAxis',0, COLOR = axisColor)
   xAxisOp = OBJ_NEW('IDLgrAxis',0, /notext, COLOR = axisColor)

   xLabel = OBJ_NEW('IDLgrText', XTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   xLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   xAxis -> SetProperty, TITLE = xLabel
   oContainer -> Add, xLabel
   xAxis -> GetProperty, TICKTEXT = xAxistickLabels
   xAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   xAxisTickLabels -> SetProperty, FONT = oFontAxis

   yAxis = OBJ_NEW('IDLgrAxis',1, COLOR = axisColor)
   yAxisOp = OBJ_NEW('IDLgrAxis',1, /notext, COLOR = axisColor)

   yLabel = OBJ_NEW('IDLgrText', YTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   yLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   yAxis -> SetProperty, TITLE = yLabel
   oContainer -> Add, yLabel
   yAxis -> GetProperty, TICKTEXT = yAxistickLabels
   yAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   yAxisTickLabels -> SetProperty, FONT = oFontAxis

   zAxis = Obj_New('IDLgrAxis', 1, COLOR = axisColor)
   zAxisOp = OBJ_NEW('IDLgrAxis',1, /notext, COLOR = axisColor)

   zLabel = OBJ_NEW('IDLgrText', ZTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   zLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   zAxis -> SetProperty, TITLE = zLabel
   oContainer -> Add, zLabel
   zAxis -> GetProperty, TICKTEXT = zAxistickLabels
   zAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   zAxisTickLabels -> SetProperty, FONT = oFontAxis

   DataAxis = Obj_New('IDLgrAxis', 1, COLOR = axisColor)
   DataAxis -> GetProperty, TickText = DataAxisTickLabels
   DataAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   DataAxisTickLabels -> SetProperty, FONT = oFontAxis
     
   DataAxisOp = OBJ_NEW('IDLgrAxis',1, /notext, COLOR = axisColor)

   ;--------------------------- Plot Labels ----------------------------------------

   oModelTitles = Obj_New('IDLgrModel')

   axisColor = [255b,255b,255b] 

   oTitle = Obj_New('IDLgrText', Title1, Alignment = 0.5, Color = axisColor, Location = [0.5,0.95], /ENABLE_FORMATTING)
   oTitle-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   oTitle->SetProperty, FONT = oFontTitle
  
   oSubTitle = Obj_New('IDLgrText', Title2, Alignment = 1.0, Color = axisColor, Location = [0.95,0.90], /ENABLE_FORMATTING)
   oSubTitle-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   oSubTitle->SetProperty, FONT = oFontSubTitle
 
   oModelTitles -> Add, oTitle
   oModelTitles -> Add, oSubTitle
          
   ; Create the view
   oView = OBJ_NEW('IDLgrView', COLOR = [0,0,0])

   ; Create the Plot Model
   oModel = OBJ_NEW('IDLgrModel')   

   ; Create the Axis Model
   oModelAxis =  OBJ_NEW('IDLgrModel')
   
   ; Add all models to the view
   oView -> Add, oModel
   oView -> Add, oModelAxis
   oView -> Add, oModelTitles

   ; Create the tools objects  
   oModelTools = OBJ_NEW('IDLgrModel')
   oZoomBox = OBJ_NEW('IDLgrPolyline', HIDE = 1, THICK = 2, LINESTYLE = 2)
   oModelTools -> Add, oZoomBox

   oViewTools = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0], /Transparent)
   oViewTools -> Add, oModelTools


   ; ------------------------------------------- Create the widgets ---
            
   ; Create Base Widget
   
   wBase = Widget_Base(TITLE = WindowTitle, /TLB_Size_Events, APP_MBAR = menuBase, $
                            XPAD = 5, YPAD = 5, /Row, scroll = 0)

   ; Create the tools panel
   
   wToolsBase = Widget_Base(wBase,/Column, xpad = 5, ypad = 5)

   ; Slice Position Draw widget

   wSubBase1 = Widget_Base(wToolsBase,/frame, /Column, xpad = 5, ypad = 5)
   
   wModelDraw = Widget_Draw(wSubBase1, SCR_XSIZE = 100, SCR_YSIZE = 100, $
                       Graphics_Level = 2, Retain = 0, /ALIGN_CENTER)

   oSliceView = OBJ_NEW('IDLgrView', COLOR = [0,0,0])
   
   oSliceModel  = Obj_New('IDLgrModel')
   oSliceLabelModel = Obj_New('IDLgrModel')

   solid, vert, poly, [-0.5, -0.5, -0.5], [0.5, 0.5, 0.5]
   oSliceCube = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 1, $
                       COLOR = [255,255,255])

   oSlicePlane = Obj_New('IDLgrPolygon', COLOR = [255,0,0] )   
   oSlicePlane -> SetProperty, XCOORD_CONV = [-0.5-1.0*XMin/(XMax-XMin), 1.0/(XMax-XMin)]  
   oSlicePlane -> SetProperty, YCOORD_CONV = [-0.5-1.0*YMin/(YMax-YMin), 1.0/(YMax-YMin)]  
   oSlicePlane -> SetProperty, ZCOORD_CONV = [-0.5-1.0*ZMin/(ZMax-ZMin), 1.0/(ZMax-ZMin)]  

   oSliceModel -> ADD, oSliceCube
   oSliceModel -> ADD, oSlicePlane

   oSliceModel -> Rotate, [1,0,0], -90
   oSliceModel -> Rotate, [0,1,0], 30
   oSliceModel -> Rotate, [1,0,0], 30

   oSliceView -> Add, oSliceModel
   
   sxl = OBJ_NEW('IDLgrText', 'X', Location = [0.45,-0.9], COLOR = [255,255,255])
   syl = OBJ_NEW('IDLgrText', 'Y', Location = [-0.7,-0.8], COLOR = [255,255,255])
   szl = OBJ_NEW('IDLgrText', 'Z', Location = [-0.95,0.25], COLOR = [255,255,255])
   
   oSliceLabelModel -> Add, sxl
   oSliceLabelModel -> Add, syl
   oSliceLabelModel -> Add, szl
   
   oSliceView -> Add, oSliceLabelModel

   ; Add slice position objects to container for later destruction

   oContainer -> Add, oSliceView

   ; Slice Tools
   
   wSubBase2 = Widget_Base(wToolsBase,/frame, /Column, XPAD = 5, ypad = 5, /base_align_left)
   
   wSliceLabel = Widget_Label(wSubBase2, Value = 'Plane')
   wSliceList = Widget_DropList(wSubBase2, Value = ['XY','XZ','YZ'], $
                           SCR_YSIZE = 20) 
   wLabelSlider = Widget_Label(wSubBase2, Value = 'Z = 0.0', scr_xsize = 100, Units = 0, /align_left)    
   wPosSlider = Widget_Slider(wSubBase2, Minimum = 0, Maximum = NZ-1, $
                              SCR_XSIZE = 100, Units = 0 )
   
   ; Create the tool selection radio buttons
   
   wSubBase3 = Widget_Base(wToolsBase,/frame, /Column, XPAD = 5, ypad = 5, /base_align_left)
   wToolsLabel = Widget_Label(wSubBase3, Value = 'Tool')
   
   wRadioBase = Widget_Base(wSubBase3, /exclusive)
   wZoomButton = Widget_Button(wRadioBase, Value = 'Zoom', UValue = '|Tool|Zoom')
   widget_control, wZoomButton, /set_button 
   wProfileButton = Widget_Button(wRadioBase, Value = 'Profile', UValue = '|Tool|Profile')
      
   ; Create the button Shortcuts 
   
   wSubBase4 = Widget_Base(wToolsBase,/frame, /Column, XPAD = 5, ypad = 5)
   wPalButton = Widget_Button(wSubBase4, Value = 'Palette', UValue = '|Slice|Palette...', $
                              /Align_Center, Scr_XSize = 80)
   wAxisButton = Widget_Button(wSubBase4, Value = 'Data Axis', UValue = '|Slice|Data Axis', $
                              /Align_Center, Scr_XSize = 80)
      
   ; Create the Main Draw Widget

   wDrawBase = Widget_Base(wBase, xpad = 5, ypad = 5, /frame)
          
   wDraw = Widget_Draw(wDrawBase, SCR_XSIZE = xdim, SCR_YSIZE = ydim, $
                       Graphics_Level = 2, /Button_Events, $
                       /Motion_Events, /Expose_Events, /viewport_events, Retain = 0, $
                       EVENT_PRO = 'Slicer3D_Draw_Visualize_Event', /ALIGN_CENTER)

   ; Create the menu
  
   MenuItemsFile = [ $
             '1File', $
                '0Save Slice...',$
                '8Save Plot Tiff...', $
                '0Save Image Tiff...',$
                '8Page Setup...',$
                '0Print...',$
                'AQuit',$
              '1Edit',$
                '0Copy Plot', $
                '2Copy Image']
                
   MenuItemsSlice = [ $
               '1Slice',$
                '0Data Axis',$
                '0Palette...',$
                '9Zoom', $
                   '0In','0Out','2Reset', $
                '8Oversample',$
                '3Invert Colors', $
                   '4Off', '2On' ]
   
   MenuItemsAbout = [ $
             '1About', $
                '2About Slicer 3D' $
              ]
   
   sOnOff=['On','Off']
  
 
   MenuItems = [MenuItemsFile, MenuItemsSlice, MenuItemsAbout]              

   ; Create Menu

   Create_Menu, MenuItems, MenuButtons, menuBase
   
   ; Create the printer object

   oPrinter = OBJ_NEW('IDLgrPrinter')
   if (oPrinter ne Obj_New()) then begin
      oContainer -> ADD, oPrinter
   end else begin
      Disable_Menu_Choice, '|File|Print...', MenuItems, MenuButtons 
      Disable_Menu_Choice, '|File|Page Setup...', MenuItems, MenuButtons 
   end

   ; Disable Copy Image (routine not implemented yet)
   
 ;  Disable_Menu_Choice, '|Edit|Copy Image', MenuItems, MenuButtons      

   ; Realize the widget
   Widget_Control, wBase, /REALIZE
       
   ; Create the window objects
   Widget_Control, wDraw, Get_Value = oWindow
   Widget_Control, wModelDraw, Get_Value = oSliceWindow

  
   iInvColors = 0b
   iSlicePlane = 2
   iSliceXPos = NX/2 - 1
   iSliceYPos = NY/2 - 1
   iSliceZPos = NZ/2 - 1
        
   sState = { $
              ; Plot Data
              pData            :pData, $				; Data for plotting
              XAxisData        :XAxisData, $			; Axis Data for X
              YAxisData        :YAxisData, $			; Axis Data for Y
              ZAxisData        :ZAxisData, $			; Axis Data for Y
              NX               :NX, $					; Number of elements along x
              NY               :NY, $					; Number of elements along y
              NZ               :NZ, $					; Number of elements along z
              sInfo            :sInfo, $				; Additional data information (for saving data to file) 
              

              ; Plot Options
              iInvColors       :iInvColors, $			; Inverted Colors
              oPalette         :oPalette, $			; Palette object for the plot
              DataMin          :DataMin, $				; Max value for plot range
              DataMax          :DataMax, $				; Min value for plot range              
              UseLog           :UseLog, $				; Use Log Scale for the plot
 
              ; Slice Options
              iSlicePlane      :iSlicePlane, $
              iSliceXPos       :iSliceXPos, $
              iSliceYPos       :iSliceYPos, $
              iSliceZPos       :iSliceZPos, $
              
              ; Plot Axis
              xAxis            :xAxis, $				; Axis object for X 
              yAxis            :yAxis, $				; Axis object for Y 
              zAxis            :zAxis, $				; Axis object for Z
              xAxisOp          :xAxisOp, $				; Oposing Axis object for X 
              yAxisOp          :yAxisOp, $				; Oposing Axis object for Y
              zAxisOp          :zAxisOp, $				; Oposing Axis object for Z  
              DataAxis         :DataAxis, $			; Axis for Values
              DataAxisOp       :DataAxisOp, $			; Oposing Axis for Values
              xtitle           :xtitle, $
              ytitle           :ytitle, $
              ztitle           :ztitle, $
              
              
              ; ColorMap Plot related variables
              ByteData         :ptr_new(), $			; Byte scaled data (for zooming)
              viewX            :[0,NX-1], $			; Visible data for X (for zooming)
              viewY            :[0,NY-1], $			; Visible data for Y (for zooming)
              oImage           :Obj_New(), $			; Color-mapped Image object (for zooming)
              oBar             :Obj_New(), $
              oBoxBar1         :Obj_New(), $
              oBoxBar2         :Obj_New(), $
                 
              ; Tools related variables
              iTool            :0b, $					; Active Tool
              btndown          :0b,$					; button 1 down
              window_size      :[xdim,ydim], $			; window size
              oViewTools       :oViewTools, $			; View object for tools
              oModelTools      :oModelTools, $
              DataPosition     :FltArr(4), $			; Screen position of data region
              Tool_Pos0        :[0.,0.], $				; position of initial button press
              oZoomBox         :oZoomBox, $			; Zoom Box object
              
              ; Widget variables
              wDraw            :wDraw,$				; Draw widget
              oWindow          :oWindow,$				; Window Object
              oView            :oView,$				; View Object                   
              oContainer       :oContainer, $			; Container for object destruction
              oPrinter         :oPrinter, $			; Printer Object
              pMenuItems       :ptr_new(MenuItems),$		; Menu Items
              pMenuButtons     :ptr_new(MenuButtons),$	; Menu Buttons
              wSliderID        :wPosSlider, $       
              wSliderLabelID   :wLabelSlider, $          
              oSliceWindow     :oSliceWindow,$			; Slice Window Object
              oSliceView       :oSliceView,$			; Slice View Object    
              oSliceCube       :oSliceCube, $
              oSlicePlane      :oSlicePlane, $               
              
              ; Models
              oModelAxis       :oModelAxis,$			; Axis Models 
              oModelTitles     :oModelTitles, $			; Axis Models 
              oModel           :oModel, $				; Plot Model  
              
              ; Font Variables
              FontSize         :FontSize, $			; Font size
              oFontTitle       :oFontTitle, $			; Title Font object
              oFontSubTitle    :oFontSubTitle, $		; Sub-Title Font object
              oFontAxis        :oFontAxis $			; Axis Font object
            }

   Update_Slider_Position_Slicer3D, sState
   
   Slicer3D_Update_SliderLabel, sState 
   
   Slicer3D_GeneratePlot, sState

   
   ; Save state to widget
   Widget_Control, wBase, SET_UVALUE=sState, /No_Copy
   
   XManager, 'Slicer3D_Visualize', Event_Handler='Slicer3D_Base_Visualize_event', $
                              Cleanup ='Slicer3D_Visualize_Cleanup', $
                              wBase, /NO_BLOCK
   
   widget_id = wBase         
end            
end