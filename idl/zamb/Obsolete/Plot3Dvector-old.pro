;
;  Program:  
;
;  Plot3Dvector
;
;  Description:
;
;  Opens a 3D array of 3D vectors and plots it using object graphics


;**********************************************************************
;************************************** Auxiliary Graphics Routines ***
;**********************************************************************

; ----------------------------------------------- Trackball control ---
;  Handles Trackball events
; ---------------------------------------------------------------------

pro TrackEx_Event, sEvent 

    ; Get sState structure from base widget

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /No_Copy

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
        sState.btndown = 1b
        sState.oWindow->SetProperty, QUALITY=2
        sState.oModelIsoSurf->SetProperty, HIDE =1
        sState.oModelVectorField->SetProperty, HIDE =1
        sState.oModelProj->SetProperty, HIDE =1
        WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
        sState.oWindow->Draw, sState.oView
    end

    ; Handle trackball updates.
    bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
    IF (bHaveTransform NE 0) THEN BEGIN
         sState.oModel->GetProperty, TRANSFORM=t
         sState.oModel->SetProperty, TRANSFORM=t#qmat
         sState.oModelIsoSurf->GetProperty, TRANSFORM=t
         sState.oModelIsoSurf->SetProperty, TRANSFORM=t#qmat
         sState.oModelVectorField->GetProperty, TRANSFORM=t
         sState.oModelVectorField->SetProperty, TRANSFORM=t#qmat
         sState.oModelProj->GetProperty, TRANSFORM=t
         sState.oModelProj->SetProperty, TRANSFORM=t#qmat

         
         sState.oWindow->Draw, sState.oView
    ENDIF
  
    ; Button release.
    IF (sEvent.type EQ 1) THEN BEGIN
;        print, 'Button Release'

        IF (sState.btndown EQ 1b) THEN BEGIN
             print, 'Rendering Image...'
             sState.oModelIsoSurf->SetProperty, HIDE =0
             sState.oModelVectorField->SetProperty, HIDE =0
             sState.oModelProj->SetProperty, HIDE =0
             sState.oWindow->SetProperty, QUALITY=2
             sState.oWindow->Draw, sState.oView
     	        print, 'Done'
         ENDIF
         sState.btndown = 0b
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF
 
    ; Re-copy sState structure to base widget
 
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
end

; ---------------------------------------------------------------------



;**********************************************************************
;******************************************************** Main Code ***
;**********************************************************************

Pro Plot3Dvector, PlotData, _EXTRA = extrakeys,$
            XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
            TITLE = Title1, SUBTITLE = Title2,  SMOOTH = SmoothFact, $
            ; Projections
            NOPROJ = noProjections, PMAX = ProjMax, PMIN = ProjMin, PROJCT = projCT,$
            ; IsoLevel
            MIN = DataMin, MAX = DataMax, $
            ISOLEVELS = isolevels, ABSISOLEVEL = absisolevel, NOISOLEVELS = noisolevels, LOW = lows, $
            COLOR = Colors, BOTTOM = BottomColors, $
            ; Visualization
            AX = angleAX, AY = angleAY, AZ = angleAZ, RATIO = AxisScale, $
            SCALE = PlotScale, TRACK = UseTrackBall, $
            ANTIALIAS = AntiAlias, RES = ImageResolution, IMAGE = outimage, WINDOWTITLE = windowTitle


if Arg_Present(PlotData) then Begin

   ; -------------------------------------------------- Initialising
    
   Data = PlotData
   S = Size(Data)
   
   if ((S[0] ne 4) or (s[1] ne 3)) then begin
     res = Dialog_Message("Data must be a 3*3D array", /Error)
     return     
   end

   NX = S[2]
   NY = S[3]
   NZ = S[4]

   ; Window Title
   
   if N_Elements(windowTitle) eq 0 then windowTitle = 'Plot3D'

   ; Anti-Aliasing
   
   if N_Elements(AntiAlias) eq 0 then AntiAlias = 0  

   ; TrackBall
   
   if N_Elements(UseTrackBall) eq 0 then UseTrackBall = 0

   ; Isosurface normal direction
   
   If N_Elements(low) eq 0 then low = 0
   
   ; Vertex shading
   
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
  
   ; Data Smoothing
  
   if N_Elements(SmoothFact) eq 0 then SmoothFact = 0
   if (SmoothFact eq 1) then SmoothFact = 2
   
   if (SmoothFact ge 2) then begin
        Data[0,*,*,*] = Temporary(Smooth(Data[0,*,*,*],SmoothFact,/Edge_Truncate))
        Data[1,*,*,*] = Temporary(Smooth(Data[1,*,*,*],SmoothFact,/Edge_Truncate))
        Data[2,*,*,*] = Temporary(Smooth(Data[2,*,*,*],SmoothFact,/Edge_Truncate))
   end

   ; Modulus of vectors

   ModData = reform(sqrt(Data[0,*,*,*]^2+Data[1,*,*,*]^2+Data[2,*,*,*]^2))
 
   help, ModData
 
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
      DataMin = Min(ModData)  
      print, " Autoscaled DataMin to ", DataMin
   end
   
   ; Unless specified, autoscale DataMax
   
   if N_Elements(DataMax) eq 0 then begin
      DataMax = Max(ModData)  
      print, " Autoscaled DataMax to ", DataMax
   end 

   ; ---------------------------------------------------- Plot Model ---
   
   oModel = OBJ_NEW('IDLgrModel')                    ; box and axis
   oModelIsoSurf = OBJ_NEW('IDLgrModel')             ; IsoSurfaces
   oModelVectorField = OBJ_NEW('IDLgrModel')         ; VectorField
   oModelProj = OBJ_NEW('IDLgrModel')                ; Projections  
   oModelSlice = OBJ_NEW('IDLgrModel')               ; Slices  
   oModelLabels = OBJ_NEW('IDLgrModel')              ; Labels

   ; -------------------------------------------------- Isosurfaces ---

   if not Keyword_Set(noisolevels) then begin

     if N_Elements(isolevels) eq 0 then begin
       isolevels = [0.75, 0.5, 0.25] 
       isolevels = DataMin + (DataMax - DataMin)*isolevels
     end else if not Keyword_Set(absisolevels) then $
       isolevels = DataMin + (DataMax - DataMin)*isolevels 

     print, 'Generating IsoSurfaces...' 

     IsoSurface, ModData, isolevels, oModelIsoSurf, COLOR = Colors, BOTTOM = BottomColors, $
                          LOW = lows, $
                          XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData 
          
     print, 'done'
   end  
  
     ; Isosurface lighting

   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1]) 
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1]) 
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2) 
   oModelIsoSurf -> ADD, oLightIsoSurf

   ; ------------------------------------------------ Vector Field ---

   print, 'Generating Vector Field model...'
;   VectorField, Data, oModelVectorField, _EXTRA=extrakeys,$
;               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
   print, 'Done'

   ; -------------------------------------------------- Projections ---
   
   if (noProjections eq 0) then begin
     print, 'Generating projections...'

     Projections, ModData, oModelProj, CT = projCT,$
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData 
     print, 'Done'
   end
  

   ; ------------------------------------------------------- Slices ---

   print, 'Generating Slices...'
   
   print, ZAxisData[ 0.25*NZ], 0.25*NZ, NZ
   print, YAxisData[ 0.75*NY], 0.75*NY, NY
   print, XAxisData[ 0.75*NX], 0.75*NX, NX
   
   Slices, ModData, [[2,ZAxisData[0.25*NZ]],[1,YAxisData[0.75*NY]],[0,XAxisData[0.75*NX]]],$
           oModelSlice,$
           XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
   print, 'Done'

   ; ------------------------------------------- Visualisation Cube ---
  

   solid, vert, poly, [XMin, YMin, XMin], [XMax, YMax, ZMax]
   oPolygonVisCube = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 1, $
                       COLOR = [0,0,0])
   oModel -> ADD, oPolygonVisCube 

   ; ----------------------------------------- Axis and Axis Labels ---
 
   xAxis = OBJ_NEW('IDLgrAxis',0, Range = [XMin,XMax], /Exact, LOCATION = [XMin,YMin,ZMin])
   xtl = 0.05*(XMax-Xmin)
   xAxis -> SetProperty, TICKLEN = xtl
   xLabel = OBJ_NEW('IDLgrText','X1')
   xAxis -> SetProperty, TITLE = xLabel
   oModel -> Add, xAxis 

   yAxis = OBJ_NEW('IDLgrAxis',1, Range = [YMin,YMax], /Exact, LOCATION = [XMin,YMin,ZMin])
   ytl = 0.05*(YMax-Ymin)
   yAxis -> SetProperty, TICKLEN = ytl
   yLabel = OBJ_NEW('IDLgrText','X2')
   yAxis -> SetProperty, TITLE = yLabel
   oModel -> Add, yAxis 

   zAxis = OBJ_NEW('IDLgrAxis',2, Range = [ZMin,ZMax], /Exact, LOCATION = [XMin,YMax,ZMin])
   ztl = 0.05*(ZMax-Zmin)
   zAxis -> SetProperty, TICKLEN = ztl
   zLabel = OBJ_NEW('IDLgrText','X3')
   zAxis -> SetProperty, TITLE = zLabel
   oModel -> Add, zAxis 
   
   oModel -> SetProperty, LIGHTING = 0


   ; -------------------------------------------------- Plot Labels ---

   Font = OBJ_NEW('IDLgrFont','Helvetica')
     
   PlotTitle    = OBJ_NEW('IDLgrText', Title1, Location=[0.9,0.9,0.0], Alignment = 1.0, FONT = Font)
   PlotSubTitle = OBJ_NEW('IDLgrText', Title2, Location=[0.9,0.8,0.0], Alignment = 1.0, FONT = Font)
   
  
   oModelLabels -> ADD, PlotTitle  
   oModelLabels -> ADD, PlotSubTitle  
   oModelLabels -> SetProperty, LIGHTING = 0
  
   ; --------------------------------------- Rotation and Rendering ---

   print, 'Scaling and Rotating Rotating Models...'

   ; Translates to the center of universe and scales to [-1,1]
 
   oModel -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2. 
   oModel -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(YMax-Ymin) 

   oModelIsoSurf -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2. 
   oModelIsoSurf -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(YMax-Ymin) 

   oModelVectorField -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2. 
   oModelVectorField -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(YMax-Ymin) 

   oModelProj -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2. 
   oModelProj -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(YMax-Ymin) 

   oModelSlice -> Translate, - (XMax + XMin)/2., - (YMax + YMin)/2., - (ZMax + ZMin)/2. 
   oModelSlice -> Scale, 1.*AxisScale[0]/(XMax-Xmin), 1.*AxisScale[1]/(YMax-Ymin), 1.*AxisScale[2]/(YMax-Ymin) 


   ; Rotates the Model

   oModel -> Rotate, [1,0,0], -90
   oModel -> Rotate, [0,1,0], 30
   oModel -> Rotate, [1,0,0], 30

   oModelIsoSurf -> Rotate, [1,0,0], -90
   oModelIsoSurf -> Rotate, [0,1,0], 30
   oModelIsoSurf -> Rotate, [1,0,0], 30
  
   oModelVectorField -> Rotate, [1,0,0], -90
   oModelVectorField -> Rotate, [0,1,0], 30
   oModelVectorField -> Rotate, [1,0,0], 30


   oModelProj -> Rotate, [1,0,0], -90
   oModelProj -> Rotate, [0,1,0], 30
   oModelProj -> Rotate, [1,0,0], 30

   oModelSlice -> Rotate, [1,0,0], -90
   oModelSlice -> Rotate, [0,1,0], 30
   oModelSlice -> Rotate, [1,0,0], 30
  
   print, 'Adding Models to view...'

   oView = OBJ_NEW('IDLgrView', COLOR = [255,255,255], PROJECTION = 2)  

   oView -> ADD, oModelVectorField
   oView -> ADD, oModelSlice
   oView -> ADD, oModelIsoSurf
   oView -> ADD, oModelProj
   oView -> ADD, oModelLabels
   oView -> ADD, oModel

   print, 'Rendering and saving image...'

  ; get
     
   if (UseTrackBall eq 1) then begin

     xdim = ImageResolution[0]
     ydim = ImageResolution[1]
     wBase = Widget_Base(TITLE = windowTitle)
     wDraw = Widget_Draw(wBase, XSIZE = xdim, YSIZE = ydim, $
                         Graphics_Level = 2, /Button_Events, $
                         /Motion_Events, /Expose_Events, Retain = 0)
     Widget_Control, wBase, /REALIZE
     Widget_Control, wDraw, Get_Value = oWindow
     oTrack = OBJ_NEW('TrackBall', [xdim/2.,ydim/2.], xdim/2.)


     ; Save state.
     sState = { btndown: 0b,                    $ 
	          dragq: 0,		                $
               oTrack:oTrack,                   $ 
               wDraw: wDraw,                    $
               oWindow: oWindow,                $
               oView: oView,                    $
               oModel: oModel,                  $
               oModelVectorField: oModelVectorField,      $
               oModelProj:oModelProj, $
               oModelIsoSurf: oModelIsoSurf     $
             }  

;     set_view, oView, oWindow
   end else begin 
     oWindow = OBJ_NEW('IDLgrWindow', TITLE = windowTitle)
;     set_view, oView, oWindow
     oWindow-> Draw, oView      
   end



   print, 'Done!'

   ; Saves output image
   
   myimage = oWindow -> Read()
   myimage -> GetProperty, DATA = outimage
               
   ; Frees up Memory
   
   Data = 0
   
   ; Call Trackball widget

   if (UseTrackBall eq 1) then begin
        Widget_Control, wBase, SET_UVALUE=sState, /No_Copy
        XManager, 'TrackEx', wBase, /NO_BLOCK
   end

   ; Anti-Aliasing
   
   if ((AntiAlias gt 0) and (UseTrackBall ne 1)) then SceneAntiAlias, oWindow, oView, AntiAlias 

 End else begin
   
   print, 'No data supplied!'
   
 end
  
End