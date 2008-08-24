Pro PlotColorData2D, DataOrg, ZMIN = DataMin, ZMAX = DataMax, XAXIS =  XAxisData, YAXIS = YAxisData, $
                   PLOTTITLE = Title1, SUBTITLE = Title2, CT = ColorTable, ZLOG = UseLogScale, SAVEGIF = fname


 if Arg_Present(DataOrg) then Begin

    Data = DataOrg
    S = Size(Data)
        
   ; Default X Axis
   
   if N_Elements(XAxisData) eq 0 then Begin
         NX = S[2]
         XAxisData = IndGen(NX)
   end 

   ; Default Y Axis
   
   if N_Elements(YAxisData) eq 0 then Begin
         NY = S[1]
         YAxisData = IndGen(NY)
   end 

   ; Log Scale
   
   if N_Elements(UseLogScale) eq 0 then UseLogScale = 0
   
   if (UseLogScale eq 0) then begin
      ; Unless specified, autoscale DataMin
   
      if N_Elements(DataMin) eq 0 then begin
         DataMin = Min(Data)  
         print, " Autoscaled DataMin to ", DataMin
      end
   
      ; Unless specified, autoscale DataMax
   
      if N_Elements(DataMax) eq 0 then begin
         DataMax = Max(Data)  
         print, " Autoscaled DataMax to ", DataMax
      end 
   
   endif else begin
     ; For Log scale use abs(Data)
     Data = abs(Data)
     
     if N_Elements(DataMax) eq 0 then DataMax = Max(Data)  
    
     if (DataMax eq 0.0) then DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.
      
     if N_Elements(DataMin) eq 0 then begin       ; Autoscales min for the log plot     
;         print, Format = '($,A)', " Autoscaling for log plot"
         DataMin = Min(Data)
         if (DataMin eq 0.0) then begin
           idx = Where(abs(Data) gt 0.0, count)
           if (count gt 0) then begin
               logScale = DataMax/Min(Data[idx])           
               DataMin = DataMax/(2.0*logScale)
           endif else begin
               DataMin = DataMax / 10.0
           end
         end     
;           print, "!"
;           print, "DataMin for Log plot ", DataMin    
     end    

     DataMin = ALog10(DataMin)
     DataMax = ALog10(DataMAx)

     idx = Where(Data gt 0.0, count)    
     if (count gt 0) then Data[idx] = ALog10(Data[idx])
     idx = Where(Data eq 0.0, count)
     if (count gt 0) then Data[idx] = DataMin - 1.0
       
   end
     
   ; Default Plot Title 
   
   if N_Elements(Title1) eq 0 then Title1 = ''

   ; Default Plot Sub Title
   
   if N_Elements(Title2) eq 0 then Title2 = ''

   ; Default Color Table
   
   if N_Elements(ColorTable) eq 0 then ColorTable = 25
     
   ; Initializes local variables

   MaxColor = !D.Table_Size
   ImagePosition = [0.15,0.15,0.80,0.85]
   BarPosition = [0.85,0.15,0.90,0.85] 
   ScaleBarPosition = [0.40,0.15,0.90,0.85]
 
   numcolors = MaxColor - 9  
 
   ; Compensates for uniform plot 
    
   If (DataMin EQ DataMax) then begin 
      DataMax=DataMax+0.5
      DataMin=DataMin-0.5
   End

   ; Initializes the Display
   truecol = 0 
   device, get_visual_depth = thisDepth
   if thisDepth gt 8 then begin
      device, decomposed = 0
      truecol = 1
   end
   !P.Charsize = 1.4

   ; Loads Appropriate Color Table and cleans the display
   
   LoadCT, 0, /Silent
 
   LoadCT, ColorTable, NColors = numcolors, /Silent
   
   color_white  = LONG([255, 255, 255])
   color_yellow = LONG([255, 255,   0])
   color_cyan   = LONG([  0, 255, 255])
   color_purple = LONG([191,   0, 191])
   color_red    = LONG([255,   0,   0])
   color_green  = LONG([  0, 255,   0])
   color_blue   = LONG([ 63,  63, 255])
   color_black  = LONG([  0,   0,   0])

   TvLCT, color_white[0], color_white[1], color_white[2], MaxColor - 1
   TvLCT, color_yellow[0],color_yellow[1],color_yellow[2], MaxColor - 2
   TvLCT, color_cyan[0], color_cyan[1], color_cyan[2], MaxColor - 3
   TvLCT, color_purple[0],color_purple[1],color_purple[2], MaxColor - 4
   TvLCT, color_red[0],color_red[1],color_red[2], MaxColor - 5
   TvLCT, color_green[0],color_green[1],color_green[2], MaxColor - 6
   TvLCT, color_blue[0],color_blue[1],color_blue[2], MaxColor - 7
   TvLCT, color_black[0],color_black[1],color_black[2], MaxColor - 8
      
   Erase, MaxColor - 8
   
   ; Converts Data to Byte Values

   BytData = BytScl(Data, Max = DataMax, Min = DataMin, Top = numcolors-1)

   ; Creates Color Scale

   colorbar = BytScl(Replicate(1B,20) # BIndGen(256), Top = numcolors-1)


   ; Displays the image and the colorbar at the appropriate positions

  ; TVImage, BytData, Position = ImagePosition
  ; TVImage , colorbar, Position = BarPosition
   
   IMDISP, BytData, Position = ImagePosition
   IMDISP, colorbar, Position = BarPosition
   
   

   ; Displays the Axis Information

   Plot, XAxisData,YAxisData,/NoData,Position = ImagePosition, /noerase, Color = MaxColor - 1

   ; Displays the color Axis Information

   Plot, [0,1], [0,1], /NoData, Position = ScaleBarPosition, /noerase,  $
        XStyle = 4, YStyle = 4, Color = MaxColor - 1
   
   ; Axis, YAxis=1, YRange = [DataMin,DataMax], YStyle = 1
    
   if (UseLogScale EQ 0) then Axis, YAxis=1, YRange = [DataMin,DataMax], YStyle = 1, Color = MaxColor - 1 $
   else Axis, YAxis=1, YRange = [10.0^DataMin,10.0^DataMax], YStyle = 1, /YLOG, Color = MaxColor - 1

   ; Prints the Labels
   
   Label = Title1
   XYOutS, 0.5,0.95, /Normal, Label, Alignment = 0.5, CharSize=1.5, Color = MaxColor - 1
   Label = Title2
   XYOutS, 0.95,0.90, /Normal, Label, Alignment = 1.0, CharSize=1.0, Color = MaxColor - 1

   LoadCT, 0, /Silent
  
   if N_Elements(fname) gt 0 then begin

      if (truecol eq 1) then begin
        frame24 = TVRD(True = 1)
        frame = Color_Quan(frame24, 1, r, g, b)
        frame24 = 0
      endif else begin
        frame = TVRD()
        TVLCT, r, g, b, /get 
      endelse

      Write_GIF, fname, frame, r, g, b
      print, "Saved file ", fname
      frame = 0  
   end

  End
  
End