;
;  Program:
;
;  Plot2D
;
;  Description:
;
;  Opens data output from the osiris code and plots it
;
;  Current Version: (4 - Feb -2000)
;
;    0.6 : Added PROFILE and fixed minor log autoscaling bug. Reversed the background and label color for PS
;          Plots
;
;  History:
;
;    0.5 : Added TYPE functionality, changed LOG to ZLOG and PLOTTITLE to TITLE for coherence with 1D plots.
;          Added XRANGE and YRANGE functionality
;
;    0.4 : Added SAVEGIF functionality (moved in from Osiris_Movie)
;
;    0.3 : Added LOG functionality (this includes the LOG autoscaling)
;
;    0.2 : Added titling (PLOTTILE and SUBTITLE)
;
;    0.1 : Moved in the data plotting routine from the Osiris_Analysis_Procedures.
;
;  Known bugs:
;
;    All bugs detected so far have been corrected
;
; *****************************************************************************************************************
;
; Parameter list:
;
; TYPE
;
; Type of plot
;
; This specifies the type of plot to be used. 0 (default) is a color density plot, 1 is a surface plot,
; 2 is a shade_surf, and 3 is a shade_surf with value indexed color
;
; PROFILE
;
; Plots 2 one-dimensional profiles
;
; Setting this keyword makes the program wait for the user to click on the plot area using the mouse
; and then plots the two 1-D data profiles passing through the point where the user clicked
;
; XAXIS
;
; X Axis Data
;
; Use this parameter to provide the X Axis Data. The default is just the data col number
;
; YAXIS
;
; Y Axis Data
;
; Use this parameter to provide the X Axis Data. The default is just the data row number
;
; XRANGE
;
; Range of data to plotted (X Axis)
;
; Use this parameter to specify the range of data to be plotted, refering to the X Axis. The default
; option is to print the whole axis
;
; YRANGE
;
; Range of data to plotted (X Axis)
;
; Use this parameter to specify the range of data to be plotted, refering to the X Axis. The default
; option is to print the whole axis
;
; ZLOG
;
; Uses a log scale for the Z axis
;
; Set this keyword to use a log scale for the Z Axis. The default is to use a linear scale.
;
; ZMIN
;
; Minimum value of z to be plotted
;
; Use this parameter to set the minimum value of Z to be plotted. The default is to use an autoscale value
;
; ZMAX
;
; Maximum value of z to be plotted
;
; Use this parameter to set the maximum value of Z to be plotted. The default is to use an autoscale value
;
; TITLE
;
; Plot Title
;
; Use this parameter to set the plot Title. The default is no plot title
;
; SUBTITLE
;
; Plot Sub Title
;
; Use this parameter to set the plot Sub Title. The default is no plot title
;
; CT
;
; Color Table
;
; use this parameter to set the Color Table for the plots. Note that for plots of type 2 (shade_surf) the color
; is not indexed to the data values. The default color tables for the different types are 0 -> MacStyle,
; 1 -> MacStyle, 2 -> RedTemperature, and 3 -> MacStyle


Pro Plot2D_old, pData, _EXTRA=extrakeys, $
                   ; Data Ranges
                   ZMIN = DataMin, ZMAX = DataMax, XRANGE = _xrange, YRANGE = _yrange, $
                   ; Axis Data and information
                   XAXIS =  XAxisDataOrg, YAXIS = YAxisDataOrg, ZLOG = UseLogScale, $
                   ; Titles and labels
                   TITLE = Title1, SUBTITLE = Title2, $
                   XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                   ; Plot options
                   CT = ColorTable, TYPE = PlotType, FONT = FontType, INTERP = Interp, $
                   ; Additional contour plot
                   ADDCONTOUR = AddContourPlot, CONTOURLEVELS = ContourLevels, $
                   ; Profile options
                   PROFILE = doProfile, $
                   ; Output gif filr
                   SAVEGIF = fname,    $
                   ; Trajectories
                   TRAJVERT = TrajVert, TRAJPOINTS = TrajPoints, TRAJCOLOR = TrajColor, TRAJTHICK = TrajThick

 if N_Elements(pData) ne 0 then begin
   
   
   type = size(pData, /type)
   
   if (type eq 10) then begin       ; Pointer
     not_pointer = 0b
     if not ptr_valid(pData) then begin
       res = Error_Message('Invalid Pointer, pData')
       return
     end
     type = size(*pData, /type)
   end else not_pointer =1b
   
   if (type lt 1) or (type gt 5) then begin
     res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                         'Precision Floating Point')
     return
   end

   if (not_pointer eq 0) then Data = *pData $
   else Data = pData
   
   S = Size(Data)
   if (S[0] ne 2) then begin
      res = Dialog_Message("Data must be a 2D array", /Error)
      return
   end
   NX = S[1]
   NY = S[2]

   ; TRAJVERT
   ;
   ; Adds a trajectory to the plot passing trough the points specified

   If N_elements(TrajVert) eq 0 then AddTrajectory = 0 $
   else AddTrajectory = 1

   ; TRAJPOINTS
   ;
   ; Conections for the trajectory (optional)


   ; ADDCONTOUR
   ;
   ; Adds a Contour plot in top of a color density plot
   ;
   ; Set this keyword to add a contour plot on top of a color density plot. This keyword only works with
   ; color density plots

   if N_Elements(AddContourPlot) eq 0 then AddContourPlot = 0

   ; FONT
   ;
   ; Font selection
   ;
   ; Set this parameter to -1 (default), 0 or 1 to use Hershey, Hardware or true Type fonts

   if N_Elements(FontType) eq 0 then FontType = 1

   if (FontType eq 1) then Charsize = 2.0 else Charsize = 1.0

   ; [XYZ]TITLE
   ;
   ; X,Y and Z axis titles
   ;
   ; Set these parameters to the string you want to use as axis title

   if N_Elements(XAxisTitle) eq 0 then XAxisTitle = ''
   if N_Elements(YAxisTitle) eq 0 then YAxisTitle = ''
   if N_Elements(ZAxisTitle) eq 0 then ZAxisTitle = ''

   ; TYPE
   ;
   ; Type of plot
   ;
   ; This specifies the type of plot to be used. 0 (default) is a color density plot, 1 is a surface plot,
   ; 2 is a shade_surf, and 3 is a shade_surf with value indexed color

   if N_Elements(PlotType) eq 0 then PlotType = 0


   ; PROFILE
   ;
   ; Plots 2 one-dimensional profiles
   ;
   ; Setting this keyword makes the program wait for the user to click on the plot area using the mouse
   ; and then plots the two 1-D data profiles passing through the point where the user clicked

   if N_Elements(doProfile) eq 0 then doProfile = 0

   ; XAXIS
   ;
   ; X Axis Data
   ;
   ; Use this parameter to provide the X Axis Data. The default is just the data col number

   if N_Elements(XAxisDataOrg) eq 0 then Begin
         XAxisData = IndGen(NX)
   end else XAxisData = XAxisDataOrg

   ; YAXIS
   ;
   ; Y Axis Data
   ;
   ; Use this parameter to provide the X Axis Data. The default is just the data row number

   if N_Elements(YAxisDataOrg) eq 0 then Begin
         YAxisData = IndGen(NY)
   end else YAxisData = YAxisDataOrg

   ; XRANGE
   ;
   ; Range of data to plotted (X Axis)
   ;
   ; Use this parameter to specify the range of data to be plotted, refering to the X Axis. The default
   ; option is to print the whole axis

   if N_Elements(_xrange) eq 0 then _xrange = [Min(XAxisData), Max(XAxisData)]

   ; YRANGE
   ;
   ; Range of data to plotted (X Axis)
   ;
   ; Use this parameter to specify the range of data to be plotted, refering to the X Axis. The default
   ; option is to print the whole axis

   if N_Elements(_yrange) eq 0 then _yrange = [Min(YAxisData), Max(YAxisData)]

   ; Sub-samples Data and Axis to Reflect XRANGE and YRANGE

   n11 = long((_xrange[0] - XAxisData[0])/(XAxisData[1]-XAxisData[0]))
   n12 = long((_xrange[1] - XAxisData[0])/(XAxisData[1]-XAxisData[0]))

   if (n11 lt 0) then n11 = 0
   if (n11 gt NX-2) then n11 = NX-2

   if (n12 lt 1) then n12 = 1
   if (n12 gt NX-1) then n12 = NX-1

   _xrange = [XAxisData[n11], XAxisData[n12]] ; Rounds off _xrange

   n21 = long((_yrange[0] - YAxisData[0])/(YAxisData[1]-YAxisData[0]))
   n22 = long((_yrange[1] - YAxisData[0])/(YAxisData[1]-YAxisData[0]))

   if (n21 lt 0) then n21 = 0
   if (n21 gt NY-2) then n21 = NY-2

   if (n22 lt 1) then n22 = 1
   if (n22 gt NY-1) then n22 = NY-1

   _yrange = [YAxisData[n21], YAxisData[n22]] ; Rounds off _yrange

   ; Compensates for half cell size

   cell_X = XAxisData[1] - XAxisData[0]
   cell_Y = YAxisData[1] - YAxisData[0]
   _xrange = _xrange + 0.5*[-cell_X,cell_X]
   _yrange = _yrange + 0.5*[-cell_Y,cell_Y]

   print, 'Cell Size X ', cell_X
   print, 'Cell Size Y ', cell_Y
   


   XAxisData = XAxisData(n11:n12)
   YAxisData = YAxisData(n21:n22)
   Data = Data(n11:n12,n21:n22)

   print, 'Data Range to be plotted'
   print, '------------------------'
   print, 'NX,NY,  ', NX, NY
   print, 'xrange, ', _xrange
   print, '[i1,i2] ', n11, n12
   print, 'yrange, ', _yrange
   print, '[j1,j2] ', n21, n22

   NX = n12-n11+1
   NY = n22-n21+1

   ; ZLOG
   ;
   ; Uses a log scale for the Z axis
   ;
   ; Set this keyword to use a log scale for the Z Axis. The default is to use a linear scale.

   if N_Elements(UseLogScale) eq 0 then UseLogScale = 0

   ; ZMIN
   ;
   ; Minimum value of z to be plotted
   ;
   ; Use this parameter to set the minimum value of Z to be plotted. The default is to use an autoscale value

   ; ZMAX
   ;
   ; Maximum value of z to be plotted
   ;
   ; Use this parameter to set the maximum value of Z to be plotted. The default is to use an autoscale value

   ; Z Autoscaling

   if (UseLogScale eq 0) then begin
      ; Unless specified, autoscale DataMin

      if N_Elements(DataMin) eq 0 then begin
         DataMin = Min(Data)
;         print, " Autoscaled DataMin to ", DataMin
      end

      ; Unless specified, autoscale DataMax

      if N_Elements(DataMax) eq 0 then begin
         DataMax = Max(Data)
;         print, " Autoscaled DataMax to ", DataMax
      end

   endif else begin
     ; For Log scale use abs(Data)
     Data = abs(temporary(Data))

     if N_Elements(DataMax) eq 0 then DataMax = Max(Data)

     if (DataMax eq 0.0) then DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.

     if N_Elements(DataMin) eq 0 then begin       ; Autoscales min for the log plot
         DataMin = Min(Data)
;         print, " Initial Data Min: ", DataMin
         if (DataMin eq 0.0) then begin
             idx = Where(Data gt 0.0, count)
             if (count gt 0) then begin
               DataMin = Min(Data[idx])
;               print, " Intermediate Data Min: ", DataMin
               logScale = DataMax/DataMin
               DataMin = DataMax/(2.0*logScale)
             end else DataMin = DataMax / 10.0
         end
;         print, " Final Data Min: ", DataMin
     end
   end



   ; TITLE
   ;
   ; Plot Title
   ;
   ; Use this parameter to set the plot Title. The default is no plot title

   if N_Elements(Title1) eq 0 then Title1 = ''

   ; SUBTITLE
   ;
   ; Plot Sub Title
   ;
   ; Use this parameter to set the plot Sub Title. The default is no plot title

   if N_Elements(Title2) eq 0 then Title2 = ''

   ; CT
   ;
   ; Color Table
   ;
   ; use this parameter to set the Color Table for the plots. Note that for plots of type 2 (shade_surf) the color
   ; is not indexed to the data values. The default color tables for the different types are 0 -> MacStyle,
   ; 1 -> MacStyle, 2 -> RedTemperature, and 3 -> MacStyle

   ; Default Color Table

   if N_Elements(ColorTable) eq 0 then begin
      case PlotType of
         1: ColorTable = 25       ; Surface plot, value color indexed (Macstyle)
         2: ColorTable = 3        ; Shade_surf plot, lighting indexed (Macstyle)
         3: ColorTable = 25       ; Shade_surf plot, value color indexed (Red Temperature)
      else:ColorTable = 25        ; Default, colormap plot (Macstyle)
      endcase
   end
   ; Initializes local variables

   MaxColor = !D.Table_Size
   ImagePosition = [0.15,0.15,0.80,0.85]
   BarPosition = [0.85,0.15,0.90,0.85]
   ScaleBarPosition = [0.40,0.15,0.90,0.85]
   SurfacePosition = [0.15,0.15,0.90,0.85]

   numcolors = MaxColor - 9

   ; Compensates for uniform plot

   If (DataMin EQ DataMax) then begin
      DataMax=DataMax+0.5
      DataMin=DataMin-0.5
   End

   ; Initializes the Display to work with 8 bit colors
   truecol = 0


   case !D.Name of
    'PS' : begin
             device, Bits_per_Pixel=8
             defcolor = MaxColor - 8
             truecol = 0
           end
    'MAC': begin
            defcolor = MaxColor - 1
            device, get_visual_depth = thisDepth
            if thisDepth gt 8 then begin
              device, decomposed = 0
              truecol = 1
            end
           end
    'WIN': begin
            defcolor = MaxColor - 1
            device, get_visual_depth = thisDepth
            if thisDepth gt 8 then begin
              device, decomposed = 0
              truecol = 1
            end
           end
     else: begin
            truecol = 0 ; Assume truecol = false
             defcolor = MaxColor - 1
           end
   endcase

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

   case PlotType of

   0: begin ;************************************* ColorMap

       if (UseLogScale gt 0) then begin
          tempdata =  ALog10(temporary(Data) > 1e-37)     
          tempmin = (Alog10(DataMin) - 1.0) 
          idx = where(tempdata eq -37.0, count)
          if (count gt 0) then tempdata[temporary(idx)] = tempmin
          BytData = BytScl(temporary(tempdata), Max = Alog10(DataMax), Min = Alog10(DataMin), Top = numcolors-1)
       end else begin
          BytData = BytScl(Data, Max = DataMax, Min = DataMin, Top = numcolors-1)
       end


       ; Creates Color Scale

       colorbar = BytScl(Replicate(1B,20) # BIndGen(256), Top = numcolors-1)


       ; Displays the image and the colorbar at the appropriate positions

       TVImage, BytData, Position = ImagePosition, /Normal, INTERP = interp
       TVImage , colorbar, Position = BarPosition, /Normal, /INTERP

       ; Adds contour lines

       if (AddContourPlot NE 0) then begin

;          ContourData = Smooth(Data,3)
          if (UseLogScale gt 0) then begin
             ContourData = ALog10(Data > 0) + (DataMin - 1.0)*(Data LE 0.)
             ContourLevels = ALog10(ContourLevels > 0) + (DataMin - 1.0)*(ContourLevels LE 0.)
          end else begin
             ContourData = Data
          end


          If N_Elements(ContourLevels) eq 0 then begin
            Contour, ContourData, XAxisData, YAxisData, /overplot, NLEVELS = 7, $
                     Min_Value = DataMin, Max_Value = DataMAx, XRANGE = _xrange, YRANGE = _yrange,$
                     Position = imageposition, XStyle = 1, YStyle = 1,$
                     _EXTRA=extrakeys, FONT = FontType, Color = MaxColor - 8
          end else begin
                Contour, ContourData, XAxisData, YAxisData, /overplot, $
                     Position = imageposition, XStyle = 1, YStyle = 1,XRANGE = _xrange, YRANGE = _yrange,$
                    _EXTRA=extrakeys, FONT = FontType, Color = MaxColor - 8, $
                    LEVELS = ContourLevels
          end
          ContourData = 0
       end


       ; Displays the color Axis Information
       Plot, [0,1], [0,1], /NoData, Position = ScaleBarPosition, /noerase,  $
            XStyle = 4, YStyle = 4, Color = defcolor, Charsize = Charsize

       if (UseLogScale EQ 0) then begin
            Axis, YAxis=1, YRange = [DataMin,DataMax], YStyle = 1, Color = defcolor, $
                  YTITLE = ZAxisTitle, FONT = FontType, Charsize = Charsize
       end else begin
            Axis, YAxis=1, YRange = [DataMin,DataMax], YStyle = 1, /YLOG, Color = defcolor, $
                  YTITLE = ZAxisTitle, FONT = FontType, Charsize = Charsize
       end

       ; Displays the spatial axis Information

       Plot, XAxisData,YAxisData, xrange=_xrange,yrange=_yrange, $
             /NoData, XStyle = 1, YStyle = 1,$
             Position = ImagePosition, /noerase, Color = defcolor, $
             XTITLE = XAxisTitle, YTITLE = YAxisTitle, FONT = FontType, Charsize = Charsize

       ; Add Trajectories
       
       if (AddTrajectory gt 0) then polyline,TrajVert, POLY = TrajPoints, THICK = TrajThick, COLOR = MaxColor - 8 

     end


   1: begin ;************************************* Surface

        TvLCT, 0, 0, 0, 0
        if (UseLogScale EQ 0) then begin
          Surface, Data, XAxisData, YAxisData, ZRANGE = [Datamin, DataMax], Position = SurfacePosition, $
                 Shades = BytScl(Data, Max = DataMax, Min = DataMin, Top = numcolors-1), $
                 /noerase, _EXTRA=extrakeys, FONT = FontType, Charsize = Charsize
        end else begin
          Surface, Data, XAxisData, YAxisData, ZRANGE = [Datamin, DataMax], Position = SurfacePosition, $
                 Shades = BytScl(ALog10(Data > 0) + (DataMin - 1.0)*(Data LE 0),$
                             Max = Alog10(DataMax), Min = Alog10(DataMin), Top = numcolors-1),$
                 /noerase, _EXTRA=extrakeys , /zlog, FONT = FontType, Charsize = Charsize
        end
      end

   2: begin ;************************************* Shade Surface

         TvLCT, 0, 0, 0, 0
         if (UseLogScale eq 0) then begin
           Shade_surf, Data, XAxisData, YAxisData, ZRANGE = [Datamin, DataMax], Position = SurfacePosition, $
                    /noerase, _EXTRA=extrakeys, FONT = FontType, Charsize = Charsize
         end else begin
           Shade_surf, Data, XAxisData, YAxisData, ZRANGE = [Datamin, DataMax], Position = SurfacePosition, $
                    /noerase, _EXTRA=extrakeys, /zlog, FONT = FontType, Charsize = Charsize

         end

      end

   3: begin ;************************************* Shade Surface with color

         TvLCT, 0, 0, 0, 0
         if (UseLogScale eq 0) then begin
            Shade_surf, Data, XAxisData, YAxisData, ZRANGE = [Datamin, DataMax], Position = SurfacePosition, $
                 Shades = BytScl(Data, Max = DataMax, Min = DataMin - (DataMax-DataMin)/(numcolors-2), Top = numcolors-1), $
                 /noerase, _EXTRA=extrakeys, FONT = FontType, Charsize = Charsize
         end else begin

            Shade_surf, Data, XAxisData, YAxisData, ZRANGE = [Datamin, DataMax], Position = SurfacePosition, $
                 Shades = BytScl(ALog10(Data > 0) + (DataMin - 1.0)*(Data LE 0),$
                             Max = Alog10(DataMax), Min = Alog10(DataMin)-0.01, Top = numcolors-1), $
                 /noerase, _EXTRA=extrakeys, /zlog, FONT = FontType, Charsize = Charsize
         end
      end

     4: begin ;************************************* Contour

         TvLCT, 0, 0, 0, 0

            Contour, Data, XAxisData, YAxisData, Min_Value = Datamin, Max_Value = DataMax, Position = SurfacePosition, $
                    /noerase, _EXTRA=extrakeys, FONT = FontType, Charsize = Charsize
      end

   endcase     ; case PlotType of

   ; Prints the Labels

   Label = Title1
   XYOutS, 0.5,0.95, /Normal, Label, Alignment = 0.5, Color = defcolor, Charsize = 1.5*Charsize, FONT = FontType
   Label = Title2
   XYOutS, 0.95,0.90, /Normal, Label, Alignment = 1.0, CharSize=1.1*Charsize, Color = defcolor, FONT = FontType

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
      print, " Saved file ", fname
      frame = 0
   end

   ; Profile

   if (doProfile gt 0) then begin
       print, 'Select point of profiles intersection using the mouse...'

       Cursor, x, y

       npx = long((x - XAxisData[0])/(XAxisData[1]-XAxisData[0]) +0.5)
       npy = long((y - YAxisData[0])/(YAxisData[1]-YAxisData[0]) +0.5)

       if (npx lt 0) then npx = 0
       if (npx gt NX-1) then npx = NX-1

       if (npy lt 0) then npy = 0
       if (npy gt NY-1) then npy = NY-1


       Window, /free, XSize = 800, YSize = 480
       !P.Multi = [0,2,1]
       if (UseLogScale eq 0) then begin
         Plot, XAxisData,Data[*,npy], Title = 'Y = '+ string(YAxisData[npy]), xstyle = 1,YRANGE = [Datamin, DataMax], FONT = FontType
         Plot, YAxisData,Data[npx,*], Title = 'X = '+ string(XAxisData[npx]), xstyle = 1,YRANGE = [Datamin, DataMax], FONT = FontType
       end else begin
         Plot, XAxisData,Data[*,npy], Title = 'Y = '+ string(YAxisData[npy]), xstyle = 1, /ylog,YRANGE = [Datamin, DataMax], FONT = FontType
         Plot, YAxisData,Data[npx,*], Title = 'X = '+ string(XAxisData[npx]), xstyle = 1, /ylog,YRANGE = [Datamin, DataMax], FONT = FontType
       end
       !P.Multi = 0
       print, 'Completed profiles.'
   end

  End

End