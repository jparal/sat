;
;  Program:  
;
;  Plot3Dobj
;
;  Description:
;
;  Opens 3D data output from the osiris code and plots it using object graphics

; -------------------------------------------------- SceneAntiAlias
; AntiAliases the view/scence v on window w, with a jitter factor of 4
; Original Copied from the object world demo d_objworld2.pro

PRO SceneAntiAlias,w,v,n
  if N_Elements(n) eq 0 then n = 4
  case n of
        2 : begin
                jitter = [[ 0.246490,  0.249999],[-0.246490, -0.249999]]
                njitter = 2
        end
        3 : begin
                jitter = [[-0.373411, -0.250550],[ 0.256263,  0.368119], $
                          [ 0.117148, -0.117570]]
                njitter = 3
        end
        8 : begin
                jitter = [[-0.334818,  0.435331],[ 0.286438, -0.393495], $
                          [ 0.459462,  0.141540],[-0.414498, -0.192829], $
                          [-0.183790,  0.082102],[-0.079263, -0.317383], $
                          [ 0.102254,  0.299133],[ 0.164216, -0.054399]]
                njitter = 8
        end
        else : begin
                jitter = [[-0.208147,  0.353730],[ 0.203849, -0.353780], $
                          [-0.292626, -0.149945],[ 0.296924,  0.149994]]
                njitter = 4
        end
  end
 
  w->getproperty,dimension=d
  acc = fltarr(3,d[0],d[1])

  if (obj_isa(v,'idlgrview')) then begin
	nViews = 1
	oViews = objarr(1)
	oViews[0] = v
  end else begin
	nViews = v->count()
	oViews = v->get(/all)
  end

  rView = fltarr(4,nViews)
  for j=0,nViews-1 do begin 
 	oViews[j]->idlgrview::getproperty,view=view
	rView[*,j] = view
  end

  for i=0,njitter-1 do begin

	for j=0,nViews-1 do begin 
  		sc = float(rView(2,j))/(float(d[0]))
        	oViews[j]->setproperty,view=[rView[0,j]+jitter[0,i]*sc, $
                             rView[1,j]+jitter[1,i]*sc,rView[2,j],rView[3,j]]
  	end

        w->draw,v
        img = w->read()
        img->getproperty,data=data
        acc = acc + float(data)
        obj_destroy,img

	for j=0,nViews-1 do begin
  		oViews[j]->setproperty,view=rView[*,j]
	end
  end

  acc = acc / float(njitter)

  o=obj_new('idlgrimage',acc)

  v2=obj_new('idlgrview',view=[0,0,d[0],d[1]],proj=1)
  m=obj_new('idlgrmodel')
  m->add,o
  v2->add,m

  w->draw,v2

  obj_destroy,v2

END

; -------------------------------------------------- image24
; returns a 24 bit image from an 8-bit image and
; a palette

function image24, image, ct
  s = Size(image)  
  image24bit = BytArr(3, s[1], s[2])
  loadct, ct, NCOLORS = 256
  TVLCT, rr, gg, bb, /get
  
  image24bit[0,*,*] = rr(image[*,*])
  image24bit[1,*,*] = gg(image[*,*])
  image24bit[2,*,*] = bb(image[*,*])

  return, image24bit
end

; -------------------------------------------------- Trackball control

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
        sState.oWindow->SetProperty, QUALITY=0
        sState.oModelIsoSurf->SetProperty, HIDE =1
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
         sState.oWindow->Draw, sState.oView
    ENDIF
  
    ; Button release.
    IF (sEvent.type EQ 1) THEN BEGIN
;        print, 'Button Release'

        IF (sState.btndown EQ 1b) THEN BEGIN
             print, 'Rendering Image...'
             sState.oModelIsoSurf->SetProperty, HIDE =0
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

; ******************//****************************************************************************************

Pro Plot3Dobj, PlotData, $
            MIN = DataMin, MAX = DataMax, $
            XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
            TITLE = Title1, SUBTITLE = Title2, LOG = UseLogScale, SMOOTH = SmoothFact, $
            NOPROJ = noProjections, IMAGE = outimage, $
            PMAX = ProjMax, PMIN = ProjMin, $
            RES = ImageResolution, ISOLEVELS = isolevels, ABSISOLEVEL = absisolevel, $
            COLOR = Colors, BOTTOM = BottomColors, $
            AX = angleAX, AY = angleAY, AZ = angleAZ, RATIO = AxisScale, $
            SCALE = PlotScale, VSHADES = vshades, NOFACES = noFaceSlices, LOW = low, TRACK = UseTrackBall, $
            ANTIALIAS = AntiAlias

; MIN
;
; Minimum Value to be considered. If not specified the routine autoscales to the minimum value of the provided
; DataSet
;
; MAX
;
; Maximum Value to be considered. If not specified the routine autoscales to the maximum value of the provided
; DataSet
;
; [XYZ] AxisData
;
; Axis Data. No effect at the moment

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
   
   ; Slice Cube position
   
   if N_Elements(cutpos) eq 0 then begin
       ;xpos = NX/2
       ;ypos = NY/2
       ;zpos = NZ/2
       xpos = 0
       ypos = 0
       zpos = 0
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
       pMax = Max([Max(p1image),Max(p2image),Max(p3image)])
       ProjMax = [pMax,pMax,pMax]
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
       pMin = Min([Min(p1image),Min(p2image),Min(p3image)])
       ProjMin = [pMin,pMin,pMin]
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
   
   
   XAxisData = -1. + IndGen(NX)*2.0/(NX-1) *AxisScale[0]
   YAxisData = -1. + IndGen(NY)*2.0/(NY-1) *AxisScale[1]
   ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1) *AxisScale[2]

   ; Log Scale
   
   if N_Elements(UseLogScale) eq 0 then UseLogScale = 0
      
   ; Default Plot Title 
   
   if N_Elements(Title1) eq 0 then Title1 = ''

   ; Default Plot Sub Title
   
   if N_Elements(Title2) eq 0 then Title2 = ''

   ; Defalut Data 2 Title
   
   if N_Elements(TitleData2) eq 0 then TitleData2 = ''

   ; ******************************************************************** Plotting
   
 
   ; Sets the scaling to the dimensions of the data volume for the slices/projections

   MinX = Min(XAxisData, MAX = MaxX)
   MinY = Min(YAxisData, MAX = MaxY)
   MinZ = Min(ZAxisData, MAX = MaxZ)
  

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

   ; Isosurface level

   if N_Elements(isolevels) eq 0 then begin
     print, "Using default isolevels"
     isolevels = [0.75, 0.5, 0.25]
   endif else begin
     if KeyWord_Set(absisolevel) then isolevels= (isolevels-DataMin)/(DataMax-DataMin) 
   end

   S = Size(isolevels)
   NumIsoLevels = S[1]

   ; Isosurface top colors
       
   if (N_elements(Colors) eq 0) then begin
      DefColors = [ [180b,000b,000b,255b], $
                    [255b,255b,000b,128b], $
                    [000b,255b,000b,064b]]
      Colors = BytArr(4, NumIsoLevels)
      for i = 0, NumIsoLevels - 1 do begin
        if (i le 2) then Colors[*,i] = DefColors[*,i] $
        else Colors[*,i] = (NumIsoLevels -1 -i)/(1.*NumIsoLevels) * [255b, 255b, 255b, 255b] 
      end
   end else begin
      S = Size(Colors)
      if ((S[0] ne 1) or (S[1] ne 4) or (S[2] ne NumIsoLevels)) then begin
        print, 'COLOR must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
        print, 'and each color must be in the form [R,G,B,alpha], with byte values. Note that alpha '
        print, 'equal to 255b means a opaque surface'
        return
      end   
   end

   ; Isosurface bottom colors

   if (N_elements(BottomColors) eq 0) then begin
      DefBottomColors = [ [090b,000b,000b,255b], $
                          [090b,090b,000b,255b], $
                          [000b,128b,000b,255b]]    
      BottomColors = BytArr(4, NumIsoLevels)
      for i = 0, NumIsoLevels - 1 do begin
        if (i le 2) then BottomColors[*,i] = DefBottomColors[*,i] $
        else BottomColors[*,i] = [128b, 128b, 128b, 128b] 
      end
   end else begin
      S = Size(BottomColors)
      if ((S[0] ne 1) or (S[1] ne 4) or (S[2] ne NumIsoLevels)) then begin
        print, 'BOTTOM must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
        print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
        print, 'have any value'
        return
      end   
   end

   ; **************************************************** Plot Model
   
   oModel = OBJ_NEW('IDLgrModel')                    ; Projections, box, labels and extras
   oModelIsoSurf = OBJ_NEW('IDLgrModel')             ; IsoSurfaces
   

   ; **************************************************** Isosurfaces
  
   for i=0, NumIsoLevels -1 do begin
     isoval = DataMin + isolevels[i]*(DataMax - DataMin)     
     print, 'Generating Isosurface, isovalue = ', isoval
     Shade_Volume, Data, isoval, vert, poly, LOW = low   
     S = Size(poly)

     if (S[1] gt 0) then begin ; If any polygons to draw
       print, 'Generating 3D polygons'
       SurfColor = Reform(Colors[*,i])
       SurfBottomColor = Reform(BottomColors[*,i])

       vert[0,*] = MinX + vert[0,*]*(MaxX - MinX)/(NX-1)   
       vert[1,*] = MinY + vert[1,*]*(MaxY - MinY)/(NY-1)   
       vert[2,*] = MinZ + vert[2,*]*(MaxZ - MinZ)/(NZ-1)   
       
       if (SurfColor[3] eq 255b) then begin  ; Opaque IsoSurface
   
         oPolygonIsoSurf = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1,$
                                    COLOR = SurfColor, BOTTOM = SurfBottomColor, reject = 0)
         
       end else begin                        ; Transparent IsoSurface

         alphaimgsurf = BytArr(4, 16, 16)
         alphaimgsurf[0,*,*] = 255b
         alphaimgsurf[1,*,*] = 255b
         alphaimgsurf[2,*,*] = 255b  
         alphaimgsurf[3,*,*] = SurfColor[3]  

         oimgTranspSurf =  OBJ_NEW('IDLgrImage', alphaimgsurf)  

         oPolygonIsoSurf = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1, reject = 0, $
                                    COLOR = SurfColor, $
                                    Texture_Map = oimgTranspSurf )       
       end

       oModelIsoSurf -> ADD, oPolygonIsoSurf               
       print, 'done' 
     end else begin
       print, 'No polygons generated'
     end
   end

   ; Isosurface lighting

   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1]) 
   oModelIsoSurf -> ADD, oLightIsoSurf
   oLightIsoSurf = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1]) 
   oModelIsoSurf -> ADD, oLightIsoSurf


   ; ******************************************* Projections
   
   if (noProjections eq 0) then begin
     projCT = 25

     ; X Projection

     p1image = BytScl(p1image, Max = ProjMax[0], Min = ProjMin[0])
     oimgProj1 =  OBJ_NEW('IDLgrImage', image24(p1image, projCT ))  
     opolProj1 = OBJ_NEW('IDLgrPolygon', [[MaxX, MinY, MinZ], [MaxX, MaxY, MinZ],[MaxX, MaxY, MaxZ], $
                                          [MaxX, MinY, MaxZ]], $
                                          COLOR = [255,255,255], $
                                          Texture_Map = oimgProj1, $
                                          Texture_Coord = [[0,0],[1,0],[1,1],[0,1]])                                    

     ; Y Projection

     p2image = BytScl(p2image, Max = ProjMax[1], Min = ProjMin[1])
     oimgProj2 =  OBJ_NEW('IDLgrImage', image24(p2image, projCT ))  
     opolProj2 = OBJ_NEW('IDLgrPolygon', [[MinX, MaxY, MinZ], $
                                          [MaxX, MaxY, MinZ], [MaxX, MaxY, MaxZ],[MinX, MaxY, MaxZ]],$
                                          COLOR = [255,255,255], $
                                          Texture_Map = oimgProj2, $
                                          Texture_Coord = [[0,0],[1,0],[1,1],[0,1]])                                    

     ; Z Projection
  
     p3image = BytScl(p3image, Max = ProjMax[2], Min = ProjMin[2])
     oimgProj3 =  OBJ_NEW('IDLgrImage', image24(p3image, projCT ))  
     opolProj3 = OBJ_NEW('IDLgrPolygon', [[MinX, MinY, MinZ],[MaxX, MinY, MinZ], $
                                          [MaxX, MaxY, MinZ],[MinX, MaxY, MinZ]], $
                                          COLOR = [255,255,255], $
                                          Texture_Map = oimgProj3, $
                                          Texture_Coord = [[0,0],[1,0],[1,1],[0,1]])                                    

     oModel -> ADD, opolProj1 
     oModel -> ADD, opolProj2 
     oModel -> ADD, opolProj3   

     ; Projection Lighting effects

  ;   oLightProj = OBJ_NEW('IDLgrLight', TYPE = 0) ; ambient light
  ;   oModel -> ADD, oLightProj
   end
  

   ; ******************************************* Visualisation cube

   solid, vert, poly, [MinX, MinY, MinZ], [MaxX, MaxY, MaxZ]
   oPolygonVisCube = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 1, $
                       COLOR = [0,0,0])
   oModel -> ADD, oPolygonVisCube 
  
   ; ******************************************* Visualization Angle and rendering

   print, 'Rotating Model...'

   oModel -> Rotate, [1,0,0], -90
   oModel -> Rotate, [0,1,0], 30
   oModel -> Rotate, [1,0,0], 30

   oModelIsoSurf -> Rotate, [1,0,0], -90
   oModelIsoSurf -> Rotate, [0,1,0], 30
   oModelIsoSurf -> Rotate, [1,0,0], 30
   
   
;   oModel -> Rotate, [1,0,0], angleAX
;   oModel -> Rotate, [0,1,0], angleAY
;   oModel -> Rotate, [0,0,1], angleAZ
  
   print, 'Adding Models to view...'

   oView = OBJ_NEW('IDLgrView', COLOR = [255,255,255], PROJECTION = 1)  
   oView -> ADD, oModelIsoSurf
   oView -> ADD, oModel

   print, 'Rendering and saving image...'

     
   if (UseTrackBall eq 1) then begin

     xdim = ImageResolution[0]
     ydim = ImageResolution[1]
     wBase = Widget_Base()
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
               oModelIsoSurf: oModelIsoSurf     $
             }  

     set_view, oView, oWindow
   end else begin 
     oWindow = OBJ_NEW('IDLgrWindow')
     set_view, oView, oWindow
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