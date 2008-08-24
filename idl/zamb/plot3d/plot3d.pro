;
;  Program:
;
;  Plot3D
;
;  Description:
;
;  Opens a 3D array of 3D scalar data and plots it using object graphics

;**********************************************************************
;******************************************************** Main Code ***
;**********************************************************************

Pro Plot3D, _EXTRA = extrakeys, pData, $ 
            XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
            ; Projections
            NOPROJ = noProjections, PMAX = ProjMax, PMIN = ProjMin,$
            PROJCT = projCT, POVERTRANS = POverTrans, SUPERSAMPLING = supersampling, INVCOLORS = inverse_colors, $
            ; IsoLevel
            MIN = DataMin, MAX = DataMax, $
            ISOLEVELS = isolevels, ABSISOLEVELS = absisolevels, NOISOLEVELS = noisolevels, LOW = lows, $
            COLOR = Colors, BOTTOM = BottomColors,  $
            D2ISOLEVELS = isolevels2, D2LOW = lows2, $
            ;Slices
            SLICES = SlicePos, SLICECT = sliceCT, RANGES = SliceRanges, $
            ; Volume Rendering
            RENDER_VOLUME = Render_Volume, VOLCT = volCT, VOLOPAC = volOpac, $
            VOLTRANSPVAL = transp_value, VOLPWROPAC = pwr_opac, D2VOLCT = d2volCT, $
            ; Visualization (parameters to visualize)
            WIDGET_ID = wBase_ID, IMAGE = image, IMAGEFILEOUT = imagefileout, $
            ; Models
            MODELOBJ = oVisualizeModels, $ MODELFILEOUT = modelfileout, $             
            ; Second Data Set
            DATA2 = pPlotData2, D2COLOR = Colors2, D2BOTTOM = BottomColors2, D2PROJCT = ProjCT2, $
            ; Trajectories
            TRAJVERT = TrajVert, TRAJPOINTS = TrajPoints, TRAJCOLOR = TrajColor, TRAJVCOLOR = TrajVColor, $
     ;       TRAJUSELINES = TrajUseLines, TRAJPROJ = TrajDoProjection, TRAJRAD = TrajRadius, TRAJTHICK = TrajThick, $
            ; Trajectories (2nd set)
            TRAJ2VERT = Traj2Vert, TRAJ2POINTS = Traj2Points, TRAJ2COLOR = Traj2Color, TRAJ2VCOLOR = Traj2VColor ;, $
     ;       TRAJ2USELINES = Traj2UseLines, TRAJ2PROJ = Traj2DoProjection, TRAJ2RAD = Traj2Radius, TRAJ2THICK = Traj2Thick

if N_Elements(pData) eq 1 then Begin
      
   
   ; -------------------------------------------------- Initialising

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

   ; Projections Over-Transparency
   ;
   ; Setting this keyword will draw the projections before everything else so
   ; that translucent/transparent objects will show the projections behind them

   If N_Elements(POverTrans) eq 0 then POverTrans = 0

   ; Vertex shading (vertex shading is currently disabled)

   if N_Elements(vshades) eq 0 then vshades = -1

   ; Projections

   if N_Elements(noProjections) eq 0 then begin
     noProjections = 0
   endif

   ; Default Axis

   If N_Elements(XAxisData) eq 0 then XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   If N_Elements(YAxisData) eq 0 then YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   If N_Elements(ZAxisData) eq 0 then ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)

   ; Spatial Range

;   XMax = XAxisData[NX-1]
;   XMin = XAxisData[0]
;   YMax = YAxisData[NY-1]
;   YMin = YAxisData[0]
;   ZMax = ZAxisData[NZ-1]
;   ZMin = ZAxisData[0]

   XMax = Max(XAxisData, MIN = Xmin)
   YMax = Max(YAxisData, Min = YMin)
   ZMAX = Max(ZAxisData, Min = ZMin)

   ; Ratio for the Axis
   
   if Keyword_Set(TrueRatio) then begin
     AxisScale = [XMax-XMin, YMax-YMin, ZMax-ZMin]
   end else if N_Elements(AxisScale) eq 0 then AxisScale = [1.0,1.0,1.0]
   
   AxisScale = Abs(AxisScale)/float(Max(Abs(AxisScale)))

   ; ------------------------------------------- Data Values Ranging ---
   ; Unless specified, autoscale DataMin

   if N_Elements(DataMin) eq 0 then begin
      DataMin = Min(*pData)
      print, " Autoscaled DataMin to ", DataMin
   end

   ; Unless specified, autoscale DataMax

   if N_Elements(DataMax) eq 0 then begin
      DataMax = Max(*pData)
      print, " Autoscaled DataMax to ", DataMax
   end
   ; ---------------------------------------------------- Plot Model ---

   oModelIsoSurf = OBJ_NEW('IDLgrModel',UVALUE = 'Iso-Surfaces') 	; IsoSurfaces
   oModelVolume = OBJ_NEW('IDLgrModel',UVALUE = 'Volume Rendering')	; Volume Rendering
   oModelProj = OBJ_NEW('IDLgrModel',UVALUE = 'Projections') 		; Projections
   oModelSlice = OBJ_NEW('IDLgrModel',UVALUE = 'Slices') 			; Slices
   oModelTrajectory = OBJ_NEW('IDLgrModel',UVALUE = 'Trajectory')	; Trajectory

   oContainer = Obj_New('IDLgrContainer')						; Container for non-graphics objects
 

   ; -------------------------------------------------- Isosurfaces ---
   if not Keyword_Set(noisolevels) then begin
      if N_Elements(isolevels) ne 0 then $
        if not Keyword_Set(absisolevels) then $
          isolevels = DataMin + (DataMax - DataMin)*isolevels

     GenIsoSurface, pData, oModelIsoSurf, ISOLEVELS = isolevels, COLOR = Colors, BOTTOM = BottomColors, $
                          LOW = lows, D2LOW = lows2, D2ISOLEVELS = isolevels2, $
                          XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                          DATA2 = pPlotData2, D2COLOR = Colors2, D2BOTTOM = BottomColors2, $
                          CONTAINER = oContainer, RANGES = SliceRanges, DATARANGE = [DataMin, DataMax]

     print, 'done'
   end

     ; Isosurface lighting
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1], UVALUE = 'Light 1')
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1], UVALUE = 'Light 2')
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2, UVALUE = 'Light 3')
   oModelIsoSurf -> ADD, oLightIsoSurf

   

   ; --------------------------------------------- Volume Rendering ---
   if Keyword_Set(Render_Volume) then begin
     print, 'Rendering Volume '
     help, pwr_opac
     print, 'Calling Volume'
     Volumes, pData, oModelVolume, MAX = DataMax, MIN = DataMin, $
                    CT = volCT, OPAC = volOpac, $
                    XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                    TRANSPVAL = transp_value, PWROPAC = pwr_opac, $
                    DATA2 = pPlotData2, D2CT = d2volCT

     print, 'Done'
   end

   ; -------------------------------------------------- Projections ---

   if (noProjections eq 0) then begin
     print, 'Generating projections...'
     Projections, pData, oModelProj, CT = projCT,PMAX = ProjMax, PMIN = ProjMin, $
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
               DATA2 = pPlotData2, D2CT = ProjCT2, $
               CONTAINER = oContainer, SUPERSAMPLING = supersampling
     print, 'Done'
   end


   ; ------------------------------------------------------- Slices ---

   if N_Elements(SlicePos) ne 0 then begin
     print, 'Generating Slices...'

     Slices, pData, SlicePos,$
             oModelSlice, CT = SliceCT,$
             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                  CONTAINER = oContainer
     print, 'Done'
   end
   ; ------------------------------------------------- Trajectories ---
   if N_Elements(TrajVert) ne 0 then begin
     print, 'Generating Trajectories...'

     Trajectory, TrajVert, oModelTrajectory, POINTS = TrajPoints, $
                 XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                 PROJ = TrajDoProjection, COLOR = TrajColor, VCOLOR = TrajVColor, LINE = TrajUseLines, $
                 RADIUS = TrajRadius, AXISRATIO = AxisScale, THICK = TrajThick

     print, 'Done'
   end

   if N_Elements(Traj2Vert) ne 0 then begin
     print, 'Generating Trajectories (2nd set)...'

     Trajectory, Traj2Vert, oModelTrajectory, POINTS = Traj2Points, $
                 XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                 PROJ = Traj2DoProjection, COLOR = Traj2Color, VCOLOR = Traj2VColor, LINE = Traj2UseLines, $
                 RADIUS = Traj2Radius, AXISRATIO = AxisScale, THICK = Traj2Thick

     print, 'Done'
   end


   ; ----------------------------------------- Call visualize procedure ---

   oVisualizeModels = OBJ_NEW('IDLgrModel')  ; models that can be transformed but are not visible
                                             ; during transformations  
   
   if (POverTrans eq 0) then begin
     oVisualizeModels -> ADD, oModelTrajectory
     oVisualizeModels -> ADD, oModelSlice
     oVisualizeModels -> ADD, oModelIsoSurf
     oVisualizeModels -> ADD, oModelVolume
     oVisualizeModels -> ADD, oModelProj
   end else begin
     oVisualizeModels -> ADD, oModelTrajectory
     oVisualizeModels -> ADD, oModelProj
     oVisualizeModels -> ADD, oModelSlice
     oVisualizeModels -> ADD, oModelIsoSurf
     oVisualizeModels -> ADD, oModelVolume
   end

   ;sModelInfo = { MODEL_INFO, $
   ;               Name  : Title1, $
   ;               XAxis : XAxisData, $
   ;               YAxis : YAxisData, $
   ;               ZAxis : ZAxisData $
   ;} 

;   oVisualizeModels -> SetProperty, UVALUE = sModelInfo

;   Save, oVisualizeModels, FILENAME = 'test.vmd', /verbose
   
   help, xmin
   help, xmax
   xrange = [Xmin, XMax]
   print, xrange
   
   Visualize, oVisualizeModels, CONTAINER = oContainer, WIDGET_ID = wBase_ID, $
              XRANGE = xrange, YRANGE = [Ymin, YMax], ZRANGE = [Zmin, ZMax], IMAGE = image, FILEOUT = imagefileout, INVCOLORS = inverse_colors, $
              _EXTRA = extrakeys
              ;AX = ax, AZ = az, $
              ;, $
              ;RATIO = AxisScale, WINDOWTITLE = WindowTitle,RES = ImageResolution, $
              ;ANTIALIAS = AntiAlias, VRMLFILEOUT = vrmlfileout, IMAGE = imageout, $
              ;FILEOUT = imagefile, , $
              ;XTITLE = XTitle, YTITLE = YTitle, ZTITLE = ZTitle, FONTSIZE = fontsize, $
              ;ZOOM = zoomfactor, 

   print, 'Done Plot3D!'

 End else begin

   print, 'Invalid data supplied!'

 end

End
