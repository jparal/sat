;
;  Program:
;
;  Plot3D
;
;  Description:
;
;  Opens a 3D array of 3D scalar data and plots it using object graphics
;**********************************************************************
;************************************** Auxiliary Graphics Routines ***
;**********************************************************************
; --------------------------------------------------- Event control ---
;  Handles events
; ---------------------------------------------------------------------
pro Base_Plot3D_Event, sEvent
  ;print, 'Base_Plot3D_Event'

  ; Note: Only resize events are caught here

  ; Get sState structure from base widget
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  ; Resize the draw widget.
  sState.oWindow->SetProperty, Dimension=[sEvent.x, sEvent.y]
  ; Redisplay the graphic.
  sState.oWindow->Draw, sState.oView
  ; Update the trackball objects location in the center of the
  ; window.
  sState.oTrack->Reset, [sEvent.x/2., sEvent.y/2.], $
    (sEvent.y/2.) < (sEvent.x/2.)
  ;Put the info structure back.
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
pro Draw_Plot3D_Event, sEvent
  ;print, 'Draw_Plot3D_Event'
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
;           print, 'Expose'
           print, 'Rendering Image...'
           sState.oWindow->Draw, sState.oView
           WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
           print, 'Done'
           RETURN
    ENDIF
    ; Button press
    IF (sEvent.type EQ 0) THEN BEGIN
;        print, 'Button Press'
;        print, 'Button pressed ', sEvent.Press
        sState.btndown = 1b
        sState.oWindow->SetProperty, QUALITY=2
        sState.oModelIsoSurf->SetProperty, HIDE =1
        sState.oModelSlice->SetProperty, HIDE =1
        sState.oModelProj->SetProperty, HIDE =1
        sState.oModelVolume->SetProperty, HIDE =1
        sState.oModelTrajectory->SetProperty, HIDE =1

        WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
        sState.oWindow->Draw, sState.oView

        ; If second button pressed, Zoom control
        if (sEvent.Press eq 2) then begin
            sState.btndown2 = 1b
            sState.zoom0 =[sEvent.x,sEvent.y] - sState.window_size/2.
            ;print, 'zoom0 ', sState.zoom0
        end
    end
    ; Handle trackball updates.

    bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat, MOUSE = 1b )
    IF (bHaveTransform NE 0) THEN BEGIN
         sState.oModel->GetProperty, TRANSFORM=t
         sState.oModel->SetProperty, TRANSFORM=t#qmat
         sState.oModelIsoSurf->GetProperty, TRANSFORM=t
         sState.oModelIsoSurf->SetProperty, TRANSFORM=t#qmat
         sState.oModelSlice->GetProperty, TRANSFORM=t
         sState.oModelSlice->SetProperty, TRANSFORM=t#qmat
         sState.oModelProj->GetProperty, TRANSFORM=t
         sState.oModelProj->SetProperty, TRANSFORM=t#qmat
         sState.oModelVolume->GetProperty, TRANSFORM=t
         sState.oModelVolume->SetProperty, TRANSFORM=t#qmat
         sState.oModelTrajectory->GetProperty, TRANSFORM=t
         sState.oModelTrajectory->SetProperty, TRANSFORM=t#qmat
         sState.oWindow->Draw, sState.oView
    ENDIF

    ; Motion

    ; Handle zoom

    IF ((sEvent.type EQ 2) and (sState.btndown2 eq 1)) then begin
      ; Check if its inside the box
      ; if ((sEvent.x ge 0) and (sEvent.x lt sState.window_size[0])) and $
      ;    ((sEvent.y ge 0) and (sEvent.y lt sState.window_size[1])) then begin
           zoom1 = [sEvent.x,sEvent.y] - sState.window_size/2.
           ;print, 'zoom1 ', zoom1

           lz0 = sqrt(total(sState.zoom0 *sState.zoom0 ))
           ;print, ' lz0 = ', lz0
           if (lz0 gt 0.) then begin
             lz1 = sqrt(total(zoom1 * zoom1 ))
             s = lz1/lz0
             ;print, ' Scale = ',s
             s1 = s/sState.scale0
             sState.oModel-> scale, s1, s1, s1
             sState.oModelIsoSurf->scale, s1, s1, s1
             sState.oModelSlice->scale, s1, s1, s1
             sState.oModelProj->scale, s1, s1, s1
             sState.oModelVolume->scale, s1, s1, s1
             sState.oModelTrajectory->scale, s1, s1, s1
             sState.oWindow->Draw, sState.oView
             sState.scale0 = s
           end
     ;  end
    end
    ; Button release.
    IF (sEvent.type EQ 1) THEN BEGIN
;        print, 'Button Release'
;        print, 'Button Released ', sEvent.Press
        IF (sState.btndown EQ 1b) THEN BEGIN
             print, 'Rendering Image...'
             sState.oModelIsoSurf->SetProperty, HIDE =0
             sState.oModelSlice->SetProperty, HIDE =0
             sState.oModelProj->SetProperty, HIDE =0
             sState.oModelVolume->SetProperty, HIDE =0
             sState.oModelTrajectory->SetProperty, HIDE =0
             sState.oWindow->SetProperty, QUALITY=2
             sState.oWindow->Draw, sState.oView
                print, 'Done'
         ENDIF
         sState.btndown = 0b
         sState.btndown2 = 0b
         sState.scale0 = 1.
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF

    ; Re-copy sState structure to base widget

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
end
; ---------------------------------------------------------------------
;**********************************************************************
;******************************************************** Main Code ***
;**********************************************************************
Pro Plot3D, pData, _EXTRA = extrakeys,$
            XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
            XTITLE = XTitle, YTITLE = YTitle, ZTITLE = ZTitle, $
            TITLE = Title1, SUBTITLE = Title2, $
            ; Projections
            NOPROJ = noProjections, PMAX = ProjMax, PMIN = ProjMin,$
            PROJCT = projCT, POVERTRANS = POverTrans, $
            ; IsoLevel
            MIN = DataMin, MAX = DataMax, $
            ISOLEVELS = isolevels, ABSISOLEVELS = absisolevels, NOISOLEVELS = noisolevels, LOW = lows, $
            COLOR = Colors, BOTTOM = BottomColors, $
            ;Slices
            SLICES = SlicePos, SLICECT = sliceCT, $
            ; Volume Rendering
            RENDER_VOLUME = Render_Volume, VOLCT = volCT, VOLOPAC = volOpac, $
            ; Visualization
            AX = angleAX, AY = angleAY, AZ = angleAZ, RATIO = AxisScale, $
            SCALE = PlotScale, TRACK = UseTrackBall, PERSPECTIVE = perspective, $
            ANTIALIAS = AntiAlias, RES = ImageResolution, IMAGE = imageout, FILEOUT = imagefile, $
            WINDOWTITLE = windowTitle, VRMLFILEOUT = vrmlfileout, FONTSIZE = fontsize, INVCOLORS = inverse_colors,$
            ; Second Data Set
            DATA2 = pPlotData2, D2COLOR = Colors2, D2BOTTOM = BottomColors2, D2PROJCT = ProjCT2, $
            ; Trajectories
            TRAJVERT = TrajVert, TRAJPOINTS = TrajPoints, TRAJCOLOR = TrajColor, $ ;TRAJVCOLOR = TrajVColor,
            TRAJUSELINES = TrajUseLines, TRAJPROJ = TrajDoProjection, TRAJRAD = TrajRadius, TRAJTHICK = TrajThick, $
            ; Trajectories (2nd set)
            TRAJ2VERT = Traj2Vert, TRAJ2POINTS = Traj2Points, TRAJ2COLOR = Traj2Color, $ ;TRAJ2VCOLOR = Traj2VColor,
            TRAJ2USELINES = Traj2UseLines, TRAJ2PROJ = Traj2DoProjection, TRAJ2RAD = Traj2Radius, TRAJ2THICK = Traj2Thick

if Arg_Present(pData) then Begin
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

   ; Window Title

   if N_Elements(windowTitle) eq 0 then windowTitle = 'Plot3D'
   if N_Elements(XTitle) eq 0 then XTitle = 'X1'
   if N_Elements(YTitle) eq 0 then YTitle = 'X2'
   if N_Elements(ZTitle) eq 0 then ZTitle = 'X3'

   ; PERSPECTIVE
   ;
   ; This parameter specifies the type of perspective to use, 1 - Orthogonal, 2 - Perspective (default)
   ; See IDL help, for IDLgrView , Projection for further details.

   if N_Elements(perspective) eq 0 then perspective = 2
   if (perspective lt 1) or (perspective gt 2) then perspective = 2

   ; Projections Over-Transparency
   ;
   ; Setting this keyword will draw the projections before everything else so
   ; that translucent/transparent objects will show the projections behind them

   If N_Elements(POverTrans) eq 0 then POverTrans = 0

   ; Anti-Aliasing

   if N_Elements(AntiAlias) eq 0 then AntiAlias = 0
   ; TrackBall

   if N_Elements(UseTrackBall) eq 0 then UseTrackBall = 0

   ; Vertex shading (vertex shading is currently disabled)

   if N_Elements(vshades) eq 0 then vshades = -1

   ; Ratio for the Axis

   if N_Elements(AxisScale) eq 0 then AxisScale = [1,1,1]

    AxisScale = Abs(AxisScale)/float(Max(Abs(AxisScale)))

   ; Angles of rotation for 3D view

   If N_Elements(angleAX) eq 0 then angleAX = 0
   If N_Elements(angleAY) eq 0 then angleAY = 0
   If N_Elements(angleAZ) eq 0 then angleAZ = 0

   ; Image Resolution

   if N_Elements(ImageResolution) ne 0 then begin
       S = Size(ImageResolution)
       if ((S[0] ne 1) or (S[1] ne 2)) then begin
          res = Dialog_Message("The RES keyword must be in the form [X resolution, Y Resolution]", /Error)
          return
       end

   end else begin
       ImageResolution = [600,600]
   end


   ; Projections

   if N_Elements(noProjections) eq 0 then begin
     noProjections = 0
   endif
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

   oModel = OBJ_NEW('IDLgrModel')                    ; box and axis
   oModelIsoSurf = OBJ_NEW('IDLgrModel')             ; IsoSurfaces
   oModelVolume = OBJ_NEW('IDLgrModel')              ; Volume Rendering
   oModelProj = OBJ_NEW('IDLgrModel')                ; Projections
   oModelSlice = OBJ_NEW('IDLgrModel')               ; Slices
   oModelLabels = OBJ_NEW('IDLgrModel')              ; Labels
   oModelTrajectory = OBJ_NEW('IDLgrModel')          ; Trajectory

   ; -------------------------------------------------- Isosurfaces ---
   if not Keyword_Set(noisolevels) then begin
     if N_Elements(isolevels) eq 0 then begin
       isolevels = [0.75, 0.5, 0.25]
       isolevels = DataMin + (DataMax - DataMin)*isolevels
     end else if not Keyword_Set(absisolevels) then $
       isolevels = DataMin + (DataMax - DataMin)*isolevels
     print, 'Isolevels ', isolevels
     GenIsoSurface, pData, isolevels, oModelIsoSurf, COLOR = Colors, BOTTOM = BottomColors, $
                          LOW = lows, $
                          XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                          DATA2 = pPlotData2, D2COLOR = Colors2, D2BOTTOM = BottomColors2

     print, 'done'
   end

     ; Isosurface lighting
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1])
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1])
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2)
   oModelIsoSurf -> ADD, oLightIsoSurf

   ; --------------------------------------------- Volume Rendering ---
   if Keyword_Set(Render_Volume) then begin
     print, 'Rendering Volume '

     Volumes, pData, oModelVolume, MAX = DataMax, MIN = DataMin, $
                    CT = volCT, OPAC = volOpac, $
                    XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData

     print, 'Done'
   end

   ; -------------------------------------------------- Projections ---

   if (noProjections eq 0) then begin
     print, 'Generating projections...'
     Projections, pData, oModelProj, CT = projCT,$
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
               DATA2 = pPlotData2, D2CT = ProjCT2
     print, 'Done'
   end

   ; ------------------------------------------------------- Slices ---

   if N_Elements(SlicePos) ne 0 then begin
     print, 'Generating Slices...'

     Slices, pData, SlicePos,$
             oModelSlice, CT = SliceCT,$
             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
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

   ; ------------------------------------------- Visualisation Cube ---

   viscubeColor = [255b,255b,255b]
   if KeyWord_Set(inverse_colors) then viscubeColor = [0b,0b,0b]

   solid, vert, poly, [XMin, YMin, ZMin], [XMax, YMax, ZMax]
   oPolygonVisCube = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 1, $
                       COLOR = viscubeColor)
   oModel -> ADD, oPolygonVisCube
   ; -------------------------------------------------- Plot Labels ---
   labelColors = [255b,255b,255b]
   if KeyWord_Set(inverse_colors) then labelcolors = [0b,0b,0b]

   maxRES = MAX(ImageResolution)
;   print, 'FontSize         ', FontSize
;   print, 'MaxRes           ', maxRES

   SizeFontTitle = float(FontSize*0.025*maxRES)
   SizeFontSubTitle = float(FontSize*0.022*maxRES)
;   print, 'SizeFontTitle    ', SizeFontTitle
;   print, 'SizeFontSubTitle ', SizeFontSubTitle
   FontTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontTitle)

   PlotTitle    = OBJ_NEW('IDLgrText', Title1, Location=[0.9,0.9,0.0], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontTitle, /ENABLE_FORMATTING)
   FontSubTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontSubTitle )
   PlotSubTitle = OBJ_NEW('IDLgrText', Title2, Location=[0.9,0.8,0.0], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontSubTitle, /ENABLE_FORMATTING)


   oModelLabels -> ADD, PlotTitle
   oModelLabels -> ADD, PlotSubTitle
   oModelLabels -> SetProperty, LIGHTING = 0

   ; ----------------------------------------- Axis and Axis Labels ---
   axisColor = [255b,255b,255b]
   if KeyWord_Set(inverse_colors) then axisColor = [0b,0b,0b]
   SizeFontAxis = float(FontSize*0.022*maxRES)
;   print, 'SizeFontAxis     ', SizeFontAxis
   FontAxis =  OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontAxis)


   xAxis = OBJ_NEW('IDLgrAxis',0, Range = [XMin,XMax], /Exact, $
                    LOCATION = [XMin,YMin,ZMin], COLOR = axisColor)
   xtl = 0.04 *(YMax-Ymin)/AxisScale[1]

   xAxis -> SetProperty, TICKLEN = xtl
   xAxis -> GetProperty, TICKTEXT = xtickLabels
   xtickLabels -> SetProperty, FONT = FontAxis
   xAxis -> SetProperty, TICKTEXT = xtickLabels
   xLabel = OBJ_NEW('IDLgrText',XTITLE, FONT = FontAxis, /ENABLE_FORMATTING)
   xAxis -> SetProperty, TITLE = xLabel
   oModel -> Add, xAxis
   yAxis = OBJ_NEW('IDLgrAxis',1, Range = [YMin,YMax], /Exact, $
                    LOCATION = [XMin,YMin,ZMin], COLOR = axisColor)
   ytl = 0.04 *(XMax-Xmin)/AxisScale[0]

   yAxis -> SetProperty, TICKLEN = ytl
   yAxis -> GetProperty, TICKTEXT = ytickLabels
   ytickLabels -> SetProperty, FONT = FontAxis
   yAxis -> SetProperty, TICKTEXT = ytickLabels
   yLabel = OBJ_NEW('IDLgrText',YTITLE, FONT = FontAxis, /ENABLE_FORMATTING)
   yAxis -> SetProperty, TITLE = yLabel
   oModel -> Add, yAxis
   zAxis = OBJ_NEW('IDLgrAxis',2, Range = [ZMin,ZMax], /Exact, $
                    LOCATION = [XMin,YMax,ZMin], COLOR = axisColor)

   ztl = 0.04 *(XMax-Xmin)/AxisScale[0]
   zAxis -> SetProperty, TICKLEN = ztl
   zAxis -> GetProperty, TICKTEXT = ztickLabels
   ztickLabels -> SetProperty, FONT = FontAxis
   zAxis -> SetProperty, TICKTEXT = ztickLabels
   zLabel = OBJ_NEW('IDLgrText',ZTITLE, FONT = FontAxis, /ENABLE_FORMATTING)
   zAxis -> SetProperty, TITLE = zLabel
   oModel -> Add, zAxis

   oModel -> SetProperty, LIGHTING = 0

   ; --------------------------------------- Rotation and Rendering ---
   print, 'Scaling and Rotating Rotating Models...'
   ; Translates to the center of universe and scales to [-1,1]

   oModel -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2.
   oModel -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(ZMax-Zmin)
   
   oModelIsoSurf -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2.
   oModelIsoSurf -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(ZMax-Zmin)
   
   oModelProj -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2.
   oModelProj -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(ZMax-Zmin)
   
   oModelSlice -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2.
   oModelSlice -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(ZMax-Zmin)
   
   oModelVolume -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2.
   oModelVolume -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(ZMax-Zmin)
   
   oModelTrajectory -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2.
   oModelTrajectory -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(ZMax-Zmin)

   oModelProj -> Translate, 0.005, 0.005, -0.005 
    
   ; Rotates the Model
   oModel -> Rotate, [1,0,0], -90
   oModel -> Rotate, [0,1,0], 30
   oModel -> Rotate, [1,0,0], 30

   oModelIsoSurf -> Rotate, [1,0,0], -90
   oModelIsoSurf -> Rotate, [0,1,0], 30
   oModelIsoSurf -> Rotate, [1,0,0], 30

   oModelProj -> Rotate, [1,0,0], -90
   oModelProj -> Rotate, [0,1,0], 30
   oModelProj -> Rotate, [1,0,0], 30

   oModelSlice -> Rotate, [1,0,0], -90
   oModelSlice -> Rotate, [0,1,0], 30
   oModelSlice -> Rotate, [1,0,0], 30

   oModelVolume -> Rotate, [1,0,0], -90
   oModelVolume -> Rotate, [0,1,0], 30
   oModelVolume -> Rotate, [1,0,0], 30

   oModelTrajectory -> Rotate, [1,0,0], -90
   oModelTrajectory -> Rotate, [0,1,0], 30
   oModelTrajectory -> Rotate, [1,0,0], 30

   print, 'Adding Models to view...'
   viewColor = [0b,0b,0b]
   if KeyWord_Set(inverse_colors) then viewColor = [255b,255b,255b]
   oView = OBJ_NEW('IDLgrView', COLOR = viewColor, PROJECTION = perspective)
  ; oView -> SetProperty, ZCLIP = [1,-3]
   if (POverTrans eq 0) then begin
     oView -> ADD, oModelTrajectory
     oView -> ADD, oModel
     oView -> ADD, oModelLabels
     oView -> ADD, oModelSlice
     oView -> ADD, oModelIsoSurf
     oView -> ADD, oModelVolume
     oView -> ADD, oModelProj
   end else begin
     oView -> ADD, oModelTrajectory
     oView -> ADD, oModel
     oView -> ADD, oModelLabels
     oView -> ADD, oModelProj
     oView -> ADD, oModelSlice
     oView -> ADD, oModelIsoSurf
     oView -> ADD, oModelVolume
   end

   if (N_Elements(vrmlfileout) ne 0) then begin
    oVRML = obj_new('IDLgrVRML',DIMENSIONS=ImageResolution)
    oVRML-> SetProperty, FILENAME = vrmlfileout
    oVRML-> SetProperty, WORLDTITLE = Title1
    oVRML-> SetProperty, WORLDINFO = Title2
    oVRML-> Draw, oView
    Obj_Destroy, oVRML
   end
   if ((N_Elements(imageout) ne 0) or (N_Elements(imagefile) ne 0)) then begin
     print, 'Rendering image...'
     oBuffer = OBJ_NEW('IDLgrBuffer', DIMENSIONS = ImageResolution)
     oBuffer-> Draw, oView

     ; Anti-Aliasing

     if (AntiAlias gt 0) then begin
        print, 'Anti-Aliasing image...'
        SceneAntiAlias, oBuffer, oView, AntiAlias
     end

     ; Saves output image

     myimage = oBuffer -> Read()
     myimage -> GetProperty, DATA = imageout

     if (N_Elements(imagefile) ne 0) then begin
       imageout = reverse(imageout,3)
       WRITE_TIFF, imagefile, imageout, 1
       imageout = reverse(imageout,3)
     end

     OBJ_DESTROY, oModelSlice
     OBJ_DESTROY, oModelIsoSurf
     OBJ_DESTROY, oModelVolume
     OBJ_DESTROY, oModelProj
     OBJ_DESTROY, oModelLabels
     OBJ_DESTROY, oModel
     OBJ_DESTROY, oModelTrajectory

     OBJ_DESTROY, myimage
     OBJ_DESTROY, oView
     OBJ_DESTROY, oBuffer
   end else begin
     if (UseTrackBall eq 1) then begin
       xdim = ImageResolution[0]
       ydim = ImageResolution[1]
       wBase = Widget_Base(TITLE = windowTitle, /TLB_Size_Events)
       wDraw = Widget_Draw(wBase, XSIZE = xdim, YSIZE = ydim, $
                           Graphics_Level = 2, /Button_Events, $
                           /Motion_Events, /Expose_Events, /viewport_events, Retain = 0, $
                           EVENT_PRO = 'Draw_Plot3D_Event')
       Widget_Control, wBase, /REALIZE
       Widget_Control, wDraw, Get_Value = oWindow
       oTrack = OBJ_NEW('TrackBall', [xdim/2.,ydim/2.], ydim/2. < xdim/2.)


       ; Save state.
       sState = { btndown: 0b,$
                  btndown2: 0b,$
                  window_size:[xdim,ydim], $
                  zoom0:lonarr(2), $
                  scale0:1., $
                 dragq: 0,$
                  oTrack:oTrack,$
                  wDraw: wDraw,$
                  oWindow: oWindow,$
                  oView: oView,$
                  oModel: oModel,$
                  oModelSlice: oModelSlice,$
                  oModelVolume: oModelVolume,$
                  oModelProj:oModelProj,$
                  oModelTrajectory:oModelTrajectory,$
                  oModelIsoSurf: oModelIsoSurf $
                }
       Widget_Control, wBase, SET_UVALUE=sState, /No_Copy
       XManager, 'Plot3D', Event_Handler='Base_Plot3D_event', wBase, /NO_BLOCK
      end else begin
        print, 'Rendering image...'
        oWindow = OBJ_NEW('IDLgrWindow', TITLE = windowTitle, DIMENSIONS = ImageResolution)
        oWindow-> Draw, oView
       ; Anti-Aliasing

       if (AntiAlias gt 0) then begin
           print, 'Anti-Aliasing image...'
           SceneAntiAlias, oWindow, oView, AntiAlias
       end
      end
   end

   print, 'Done!'

 End else begin

   print, 'No data supplied!'

 end

End