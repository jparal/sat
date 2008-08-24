Pro PlotColorData3D, PlotData, MIN = DataMin, MAX = DataMax, XAXIS =  XAxisData, YAXIS = YAxisData, $
                   PLOTTITLE = Title1, SUBTITLE = Title2, LOG = UseLogScale, SMOOTH = SmoothFact, $
                   NOPROJ = noProjections, IMAGE = outimage, $
                   CUTPOS = cutpos, PMAX = ProjMax, PMIN = ProjMin, $
                   RES = ImageResolution, ISOLEVEL = isolevel, SLICESMOOTH = slicesmoothfact


 if Arg_Present(PlotData) then Begin


   ; ******************************************************************** Initialising
    
   Data = PlotData
   S = Size(Data)
   
   if (S[0] ne 3) then begin
     res = Dialog_Message("Data must be a 3D array", /Error)
     return     
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]

   ; Slice Cube position
   
   if N_Elements(cutpos) eq 0 then begin
       xpos = NX/2
       ypos = NY/2
       zpos = NZ/2
   end else begin
       S = size(cutpos)
       if ((S[0] ne 1) and (S[1] ne 3)) then begin
         res = Dialog_Message("CUTPOS Keyword must be in the form [xpos,ypos,zpos]", /Error)
         return     
       end
       xpos = cutpos[0]
       ypos = cutpos[1]
       zpos = cutpos[2]          
   end

   if N_Elements(slicesmoothfact) eq 0 then begin
      slicesmoothfact=5
   end 
   ; Isosurface level

   if N_Elements(isolevel) eq 0 then begin
     print, "Using default isolevel"
     isolevel = 0.5
   end

   ; Image Resolution
   
   if N_Elements(ImageResolution) ne 0 then begin
       S = Size(ImageResolution)
       if ((S[0] ne 1) or (S[1] ne 2)) then begin
          res = Dialog_Message("The RES keyword must be in the form [X resolution, Y Resolution]", /Error)
          return           
       end
   
   end else begin
        ImageResolution = [600,450]  
   end
   
  
   ; Data Smoothing
  
   if N_Elements(SmoothFact) eq 0 then SmoothFact = 0
   if (SmoothFact eq 1) then SmoothFact = 2
   
   if (SmoothFact ge 2) then Data = Temporary(Smooth(Data,SmoothFact,/Edge_Truncate))
  
   ; Projections
   
   if N_Elements(noProjections) eq 0 then begin
     noProjections = 0
     
     p1image = Total(Data,1) / NX 
     p2image = Total(Data,2) / NY
     p3image = Total(Data,3) / NZ
  
     if N_Elements(ProjMax) eq 0 then begin
       ProjMax = [Max(p1image),Max(p2image),Max(p3image)]
     endif else begin
       S = Size(ProjMax)
       case S[0] of
           0 : ProjMax = [ProjMax, ProjMax, ProjMax]
           1 : if (S[1] ne 3) then begin
                res = Dialog_Message("PMAX must be either a scalar or a 3 element vector", /Error)
                return          
               end                  
         else: begin
                res = Dialog_Message("PMAX must be either a scalar or a 3 element vector", /Error)
                return     
               end
       endcase
     endelse
     
     if N_Elements(ProjMin) eq 0 then begin
       ProjMin = [Min(p1image),Min(p2image),Min(p3image)]
     endif else begin
       S = Size(ProjMin)
     
     
       case S[0] of
           0 : ProjMin = [ProjMin, ProjMin, ProjMin]
           1 : if (S[1] ne 3) then begin
                res = Dialog_Message("PMIN must be either a scalar or a 3 element vector", /Error)
                return          
               end    
         else: begin
                res = Dialog_Message("PMIN must be either a scalar or a 3 element vector", /Error)
                return     
               end
       endcase
     endelse
   endif
   
   
   ; Default X Axis
   
   if N_Elements(XAxisData) eq 0 then Begin
         XAxisData = IndGen(NX)*1.0
   end 

   ; Default Y Axis
   
   if N_Elements(YAxisData) eq 0 then Begin
         YAxisData = IndGen(NY)*1.0
   end 

   ; Default Z Axis
   
   if N_Elements(ZAxisData) eq 0 then Begin
         ZAxisData = IndGen(NZ)*1.0
   end 

   ; Log Scale
   
   if N_Elements(UseLogScale) eq 0 then UseLogScale = 0
   

    
  
   ; Default Plot Title 
   
   if N_Elements(Title1) eq 0 then Title1 = ''

   ; Default Plot Sub Title
   
   if N_Elements(Title2) eq 0 then Title2 = ''


   ; ******************************************************************** Plotting


   if N_Elements(outimage) eq 0 then Window, /Free, XSize = ImageResolution[0], YSize = ImageResolution[1]

   device, decomposed = 0
   oldDevice = !D.Name

   ColorTab = [1,25,8]
   MaxColor = !D.Table_Size
   
   NTables = 3
   
   print, "Number of colors on present device ", MaxColor

   nColor = (MaxColor - 9)/NTables
   
   ; Loads the  color tables 

   for i = 0,NTables-1 do begin
     LoadCT, ColorTab[i], NColors = nColor, Bottom = i*nColor
   end

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

   sliceCT = 1 
   projCT = 2


   ; Initializes the ZBuffer

   Set_Plot, 'Z', /Copy
   !P.Charsize = 1.4
   Device, Set_Resolution = ImageResolution, Set_Colors = MaxColor - 1
 
   ; Clears the output

   Erase, Color = MaxColor - 8 
  

   ; **************************************************** Scaling
  
   ; Sets the scaling to the dimensions of the data volume for the slices/projections

   MinX = Min(XAxisData, MAX = MaxX)
   MinY = Min(YAxisData, MAX = MaxY)
   MinZ = Min(ZAxisData, MAX = MaxZ)
 
   Scale3, XRange = [MinX,MaxX], YRange = [MinY,MaxY], ZRange = [MinZ,MaxZ] 


   ; **************************************************** Projections

   if (noProjections eq 0) then begin

 
     ; X-Plane
 
     p1 = [ [MaxX, MinY, MinZ], [MaxX, MinY, MaxZ], [MaxX, MaxY, MaxZ], [ MaxX, MaxY, MinZ] ]

     p1image = BytScl(p1image, Max = ProjMax[0], Min = ProjMin[0], Top = nColor - 1)+projCT*nColor

     PolyFill, p1, /T3D, Pattern = p1image, /Image_Interp, $
              Image_Coord = [ [0,0], [0,NZ-1], [NY-1, NZ-1], [NY-1,0]]
     
     p1image = 0
 
     ; Y-Plane

     p2 = [ [ MinX, MaxY, MinZ], [MinX, MaxY,  MaxZ], [ MaxX,  MaxY,  MaxZ], [  MaxX,  MaxY, MinZ] ]

     p2image = BytScl(p2image, Max = ProjMax[1], Min = ProjMin[1], Top = nColor - 1)+projCT*nColor

     PolyFill, p2, /T3D, Pattern = p2image, /Image_Interp, $
               Image_Coord = [ [0,0], [0,NZ-1], [NX-1, NZ-1], [NX-1,0]]

     p2image = 0

     ; Z-Plane

     p3 = [ [MinX, MinY, MinZ], [MinX, MaxX, MinZ], [MaxX, MaxY, MinZ], [ MaxX, MinY, MinZ] ]
 
     p3image = BytScl(p3image, Max = ProjMax[2], Min = ProjMin[2], Top = nColor - 1)+projCT*nColor

     PolyFill, p3, /T3D, Pattern = p3image, /Image_Interp, $
               Image_Coord = [ [0,0], [0,NY-1], [NX-1, NY-1], [NX-1,0]]

     p3image = 0
     
   endif

   ; **************************************************** Volume Data values Scaling

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
     
     if N_Elements(DataMax) eq 0 then begin
        DataMax = Max(Data)
        print, " Autoscaled DataMax for Log Plot"  
     end
     
     if (DataMax eq 0.0) then DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.

     idx = Where(Data gt 0.0, count)
      
     if N_Elements(DataMin) eq 0 then begin       ; Autoscales min for the log plot     

          DataMin = Min(Data)
          if (DataMin eq 0.0) then begin
            if (count gt 0) then begin
                 logScale = DataMax/Min(Data[idx])           
                 DataMin = DataMax/(2.0*logScale)
            endif else begin
                DataMin = DataMax / 10.0
            end
          endif 

          print, "Autoscaled DataMin for Log plot "     

     end else if (DataMin le 0.0) then DataMin = DataMax / 10.0    

     DataMin = ALog10(DataMin)
     DataMax = ALog10(DataMax)
     
     Print, "Log(Min, Max) for Log plot ", DataMin, DataMax
     
     if (count gt 0) then Data[idx] = ALog10(Data[idx])
     idx = Where(Data eq 0, count)
     if (count gt 0) then Data[idx] = DataMin - 1.0
       
   end


   ; **************************************************** Isosurface

   ; Sets the scaling to the dimensions of the data set because of the way shade_volume works
  
   isoval = DataMin + isolevel*(DataMax - DataMin) 
     
   Help, isoval

   Data1 = Data 
   
   Help, Data1
   
   if ((xpos gt 0) and (ypos gt 0) and (zpos lt NZ-1)) then $ 
         Data1[0:xpos,0:ypos,zpos:NZ-1] = DataMin-1.0 ; Removes the cube
   
   Scale3, XRange=[0,NX-1], YRange=[0,NY-1], ZRange=[0,NZ-1]   
   Shade_Volume, Data1, isoval, vertices, polygons, /verbose, /Low
   Data1 = 0  
   S = Size(polygons)
   if (S[1] gt 0) then dummy = PolyShade(vertices, polygons, /T3D, Top = nColor - 1)   


   ; **************************************************** Face Slices

   Scale3, XRange = [MinX,MaxX], YRange = [MinY,MaxY], ZRange = [MinZ,MaxZ] 

   transpcolor = Byte(isolevel*Float(nColor-1)) + sliceCT*nColor + 1
 
   dataxpos = XAxisData[xpos]
   dataypos = YAxisData[ypos]
   datazpos = ZAxisData[zpos] 
 
   if ((xpos gt 0) and (ypos gt 0) and (zpos lt NZ-1)) then begin
            
     if (zpos gt 0)  then begin
       p1 = [ [MinX, MinY, datazpos], [MinX, dataypos, datazpos], $
            [dataxpos, dataypos, datazpos], [ dataxpos, MinY, datazpos] ]

       xyslice = Reform(Data[   0:xpos  ,  0:ypos,    zpos])
       S = Size(xyslice)
       xyslice = Rebin(xyslice,slicesmoothfact*S[1],slicesmoothfact*S[2])
       xyslice = BytScl(xyslice, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor
       S = Size(xyslice)
       PolyFill, p1, /T3D, Pattern = xyslice, /Image_Interp, $
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
                Transparent = transpcolor
       xyslice = 0
     endif

     ; XZ - Plane face

     if (ypos lt NY-1) then begin
       xzslice = Reform(Data[     0:xpos,   ypos,   zpos:NZ-1])
       p2 = [ [MinX, dataypos, datazpos], [MinX, dataypos, MaxZ], $
            [dataxpos, dataypos, MaxZ], [ dataxpos, dataypos, datazpos] ]

       S = Size(xzslice)
       xzslice = Rebin(xzslice,slicesmoothfact*S[1],slicesmoothfact*S[2])

       xzslice = BytScl(xzslice, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor
       S = Size(xzslice)

       PolyFill, p2, /T3D, Pattern = xzslice, /Image_Interp, $
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

       xzslice = 0
     end
   
     ; YZ - Plane face
    
     if (xpos lt NX-1) then begin
       yzslice = Reform(Data[  xpos,      0:ypos,    zpos:NZ-1])
       p3 = [ [dataxpos, MinY, datazpos], [dataxpos, MinY, MaxZ], $
            [dataxpos, dataypos, MaxZ], [ dataxpos, dataypos, datazpos] ]

       S = Size(yzslice)
       yzslice = Rebin(yzslice,slicesmoothfact*S[1],slicesmoothfact*S[2])

       yzslice = BytScl(yzslice, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor

       S = Size(yzslice)

       PolyFill, p3, /T3D, Pattern = yzslice, /Image_Interp, $
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
              Transparent = transpcolor
       yzslice = 0
     
     endif

   endif

   ; **************************************************** Cube Face Slices

   ; XY - Plane face
  
   if (xpos lt NX-1) then begin  
     p1 = [ [dataxpos, MinY, MaxZ], [dataxpos, MaxY, MaxZ], [MaxX, MaxY, MaxZ], [ MaxX, MinY, MaxZ] ]

     xyslice1 = Reform(Data[ xpos:NX-1  ,         *,    NZ -1 ])

     S = Size(xyslice1)
     xyslice1 = Rebin(xyslice1,slicesmoothfact*S[1],slicesmoothfact*S[2])

     xyslice1 = BytScl(xyslice1, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor
     S = Size(xyslice1)
  
     PolyFill, p1, /T3D, Pattern = xyslice1, /Image_Interp, $
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

     xyslice1 = 0
   endif
   
   if (ypos lt NY-1) then begin
     p1 = [ [MinX, dataypos, MaxZ], [MinX, MaxY, MaxZ], [MaxX, MaxY, MaxZ], [ MaxX, dataypos, MaxZ] ]

     xyslice2 = Reform(Data[         *  , ypos:NY-1,    NZ -1 ])

     S = Size(xyslice2)
     xyslice2 = Rebin(xyslice2,slicesmoothfact*S[1],slicesmoothfact*S[2])
     S = Size(xyslice2)

     xyslice2 = BytScl(xyslice2, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor

     PolyFill, p1, /T3D, Pattern = xyslice2, /Image_Interp,$
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

     xyslice2 = 0
   endif
   
   ; XZ - Plane face
 
   if (xpos lt NX-1) then begin
     p2 = [ [dataxpos, MinY, MinZ], [dataxpos, MinY, MaxZ], [MaxX, MinY, MaxZ], [ MaxX, MinY, MinZ] ]
     xzslice1 = Reform(Data[ xpos:NX-1  ,  0 ,   * ])
   
     S = Size(xzslice1)
     xzslice1 = Rebin(xzslice1,slicesmoothfact*S[1],slicesmoothfact*S[2])
     S = Size(xzslice1)

     xzslice1 = BytScl(xzslice1, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor

     PolyFill, p2, /T3D, Pattern = xzslice1,  /Image_Interp,$
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

     xzslice1 = 0
   endif
   
   if (zpos gt 0) then begin
     p2 = [ [MinX, MinY, MinZ], [MinX, MinY, datazpos], [MaxX, MinY, datazpos], [ MaxX, MinY, MinZ] ]
     xzslice2 = Reform(Data[         *  ,  0 ,   0:zpos ])

     S = Size(xzslice2)
     xzslice2 = Rebin(xzslice2,slicesmoothfact*S[1],slicesmoothfact*S[2])
     S = Size(xzslice2)

     xzslice2 = BytScl(xzslice2, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor

     PolyFill, p2, /T3D, Pattern = xzslice2,  /Image_Interp,$
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

     xzslice2 = 0
   endif

   ; YZ - Plane face
    
   if (ypos lt NY-1) then begin
     p3 = [ [MinX, dataypos, MinZ], [MinX, dataypos, MaxZ], [MinX, MaxY, MaxZ], [ MinX, MaxY, MinZ] ]
     yzslice1 = Reform(Data[ 0  ,  ypos:NY-1 ,   * ])    

     S = Size(yzslice1)
     yzslice1 = Rebin(yzslice1,slicesmoothfact*S[1],slicesmoothfact*S[2])
     S = Size(yzslice1)

     yzslice1 = BytScl(yzslice1, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor

     PolyFill, p3, /T3D, Pattern = yzslice1,  /Image_Interp,$
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

     yzslice1 = 0
   endif
   
   if (zpos gt 0) then begin         
     p3 = [ [MinX, MinY, MinZ], [MinX, MinY, datazpos], [MinX, MaxY, datazpos], [ MinX, MaxY, MinZ] ]
     yzslice2 = Reform(Data[ 0  ,  *    ,   0:zpos ])
     S = Size(yzslice2)
     yzslice2 = Rebin(yzslice2,slicesmoothfact*S[1],slicesmoothfact*S[2])
     S = Size(yzslice2)

     yzslice2 = BytScl(yzslice2, Max = DataMax, Min = DataMin, Top = nColor - 1)+sliceCT*nColor

     PolyFill, p3, /T3D, Pattern = yzslice2, /Image_Interp,$
                Image_Coord = [ [0,0], [0,S[2]-1], [S[1]-1, S[2]-1], [S[1]-1,0]], $
               Transparent = transpcolor

     yzslice2 = 0
     
   endif

   ; ******************************************* Visualisation cube
  
   lstl = 1

   ; X Lines

   Plots, [MinX, MaxX], [MinY,MinY], [ MinZ,MinZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MinX, MaxX], [MaxY,MaxY], [ MinZ,MinZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MinX, MaxX], [MinY,MinY], [ MaxZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MinX, MaxX], [MaxY,MaxY], [ MaxZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
  
   ; Y Lines

   Plots, [MinX, MinX], [MinY,MaxY], [ MinZ,MinZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MaxX, MaxX], [MinY,MaxY], [ MinZ,MinZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MinX, MinX], [MinY,MaxY], [ MaxZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MaxX, MaxX], [MinY,MaxY], [ MaxZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
    
   ; Z Lines

   Plots, [MinX, MinX], [MinY,MinY], [ MinZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MaxX, MaxX], [MinY,MinY], [ MinZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MinX, MinX], [MaxY,MaxY], [ MinZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
   Plots, [MaxX, MaxX], [MaxY,MaxY], [ MinZ,MaxZ],$
           Color = MaxColor - 1, /T3D, Linestyle = lstl
     
   ; ******************************************* Cut Position Lines
  
   ; Note: the 1% offset in the lines is to make sure that they are visible  

   lstl = 3
   
   if ((xpos gt 0) and (ypos gt 0) and (zpos lt NZ-1)) then begin
 
     Plots, [MinX, MaxX], [dataypos*0.99,dataypos*0.99], [ datazpos*1.01,datazpos*1.01],$
             Color = MaxColor - 1, /T3D, Linestyle = lstl
     Plots, [dataxpos*0.99, dataxpos*0.99], [MinY,MaxY], [ datazpos*1.01,datazpos*1.01],$
              Color = MaxColor -1, /T3D, Linestyle = lstl
     Plots, [dataxpos*0.99, dataxpos*0.99], [dataypos*0.99,dataypos*0.99], [ MinZ,MaxZ],$
              Color = MaxColor -1, /T3D, Linestyle = lstl
 
   end

   ; ******************************************* Titles
 
   !P.Charsize = 1.0
 
   Label = Title1
   XYOutS, 0.95,0.95, /Normal, Label, Alignment = 1.0, CharSize=1.0
   Label = Title2
   XYOutS, 0.95,0.90, /Normal, Label, Alignment = 1.0, CharSize=0.75

 
   ; ******************************************* Render Image
  
   image = TVRD()

   ; ******************************************* Restore Old Device
    
   Set_Plot, OldDevice  

   if N_ELements(outimage) eq 0 then begin
     TV, image
   endif else begin
     outimage = image
   endelse

   ; Frees up Memory
   
   Data = 0

 End
  
End