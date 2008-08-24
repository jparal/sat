Pro PlotColorData, DataOrg, MIN = DataMin, MAX = DataMax, XAXIS =  XAxisData, YAXIS = YAxisData, $
                   PLOTTITLE = Title1, SUBTITLE = Title2, CT = ColorTable, LOG = UseLogScale


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

   numcolors = !D.Table_Size
   ImagePosition = [0.15,0.15,0.80,0.85]
   BarPosition = [0.85,0.15,0.90,0.85] 
   ScaleBarPosition = [0.40,0.15,0.90,0.85]
 
   ; Compensates for uniform plot 
    
   If (DataMin EQ DataMax) then begin 
      DataMax=DataMax+0.5
      DataMin=DataMin-0.5
   End
      
   ; Initializes the Display
   
   TVLCT, _tr, _tg, _tb, /Get
   Erase
   
   ; Converts Data to Byte Values

   BytData = BytScl(Data, Max = DataMax, Min = DataMin, Top = numcolors-2)

   ; Creates Color Scale

   colorbar = BytScl(Replicate(1B,20) # BIndGen(256), Top = numcolors-2)

   ; Loads Appropriate Color Table
   
   LoadCT, ColorTable, NColors = numcolors -1, /Silent

   ; Displays the image and the colorbar at the appropriate positions

   TVImage, BytData, Position = ImagePosition
   TVImage , colorbar, Position = BarPosition

   
   ; Restores Original Color Table
   
   TVLCT, _tr, _tg, _tb

   ; Displays the Axis Information

;   Print, " X Axis "
;   Print, XAxisData
;   Print, " Y Axis "
;   Print, YAxisData

   Plot, XAxisData,YAxisData,/NoData,Position = ImagePosition, /noerase 

   ; Displays the color Axis Information

   Plot, [0,1], [0,1], /NoData, Position = ScaleBarPosition, /noerase,  $
        XStyle = 4, YStyle = 4
   
   ; Axis, YAxis=1, YRange = [DataMin,DataMax], YStyle = 1
    
   if (UseLogScale EQ 0) then Axis, YAxis=1, YRange = [DataMin,DataMax], YStyle = 1 $
   else Axis, YAxis=1, YRange = [10.0^DataMin,10.0^DataMax], YStyle = 1, /YLOG

   ; Prints the Labels
   
   Label = Title1
   XYOutS, 0.5,0.95, /Normal, Label, Alignment = 0.5, CharSize=1.5
   Label = Title2
   XYOutS, 0.95,0.90, /Normal, Label, Alignment = 1.0, CharSize=1.0

  End
  
End