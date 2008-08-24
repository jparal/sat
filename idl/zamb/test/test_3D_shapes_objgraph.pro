; -------------------------------------------------- Trackball control

pro TrackEx_Event, sEvent
  common tkball, oTrackBall, oModel1,oModel2, oView, oWindow
  

  bHaveXform = oTrackball -> Update(sEvent, TRANSFORM = TrackXform)
  
  if (bHaveXform) then begin
    oModel1->GetProperty, TRANSFORM = ModelXform
    oModel1->SetProperty, TRANSFORM = ModelXform # TrackXform
    oModel2->GetProperty, TRANSFORM = ModelXform
    oModel2->SetProperty, TRANSFORM = ModelXform # TrackXform
    
    oWindow-> Draw, oView
  endif
end

; -------------------------------------------------- End Trackball control

common tkball, oTrackBall, oModel1,oModel2, oView, oWindow

oView = OBJ_NEW('IDLgrView');, ViewPlane_Rect = [-1.,-1.,2.,2.])

oModel1 = OBJ_NEW('IDLgrModel')
oModel2 = OBJ_NEW('IDLgrModel')

; Using lights
;
; Type 0 - Ambient Light. Ambient light has no direction or position and affects all polygons the same
;          way. It is usually a good idea to add a small intensity ambient light, so that we see all
;          the objects
;
; Type 1 - Positional Light. A positional light has position but no direction (it emits isotropically)
;          
; Type 2 - Directional Light. A directional light has a direction but has no position. To set the direction
;          of a directional light modify the LOCATION parameter. The light rays will be parallel to a 
;          vector beginning from the point specified by the LOCATION parameter and ending at [0,0,0]
;
; Type 3 - Spot Light. A spot light illuminates only a specif area defined by the lights position,
;          direction and the cone angle 


light = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1])
oModel2 -> ADD, light
light = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2)
oModel2 -> ADD, light
light = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1])
oModel2 -> ADD, light


;Sphere, vert, poly, 50, [-0.8,0.,0.], 0.2
;polygon1 = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1,$
;                   COLOR = [0,0,255], BOTTOM = [255,0,0])
;oModel -> ADD, polygon1

;Cone, vert, poly, 50, [0.0,0.0,-0.5], [0.0,0.0,0.5], 0.25
;polygon2 = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1,$
;                   COLOR = [0,0,255], BOTTOM = [255,0,0])
;oModel -> ADD, polygon2

;Cylinder, vert, poly, 50, [0.5,0.0,-0.5], [0.5,0.0,0.5], 0.25
;polygon3 = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1,$
;                   COLOR = [0,0,255], BOTTOM = [255,0,0])
;oModel -> ADD, polygon3

;solid, vert, poly, [-0.5, -0.5, -0.5], [0.5, 0.5, 0.5]
;polygon3 = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 1,$
;                   COLOR = [0,0,255])
;oModel -> ADD, polygon3



;Cylinder, vert, poly, 20, [0.0,0.0,0.0],[0.0,0.5,0.0], 0.2
;polygon = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, SHADING = 1, $
;                   REJECT = 2,  COLOR = [255,0,0])
;model -> ADD, polygon





;Cylinder, vert, poly, 20, [0.0,0.0,0.0],[0.0,0.5,0.0], 0.2
;polygon = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, SHADING = 1, $
;                   REJECT = 2,  COLOR = [255,0,0])
;model -> ADD, polygon

; Spiral

 Np = 100
 NTurns = 4
 t = 0.
 tinc = NTurns*2*!PI/float(NP-1)
 L  = 2.
 Rad = 0.3
 
 points = fltarr(3,NP)
 for i=0, NP-1 do begin
    t = i*tinc
    points[0,i] = Rad*cos(t)
    points[1,i] = Rad*sin(t)
    points[2,i] = -L/2. +  L*i/(NP-1)
 end

; Junction

;points = fltarr(3,3)

;points[0,0] = 0.
;points[1,0] = 0.
;points[2,0] = 0.

;points[0,1] = 0.5
;points[1,1] = 0.0
;points[2,1] = 0.0

;points[0,2] = 0.5
;points[1,2] = 0.5
;points[2,2] = 0.0

;points[0,2] = 0.5
;points[1,2] = 0.0
;points[2,2] = 0.5

Tube, vert, poly, 20, points, 0.05

polygon = OBJ_NEW('IDLgrPolygon',vert, STYLE = 1, POLYGON = poly,  COLOR = [0,0,0])
oModel1 -> ADD, polygon
oModel1 -> Translate, 0,0,-0.25

polygon = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, REJECT = 1, Shading = 1, $
                    COLOR = [255,0,0], BOTTOM = [0,255,0])

oModel2 -> ADD, polygon
 
;polygon = OBJ_NEW('IDLgrPolygon',points, STYLE = 1,  COLOR = [0,0,0])
;oModel -> ADD, polygon

xdim = 600
ydim = 600
wBase = Widget_Base()
wDraw = Widget_Draw(wBase, XSIZE = xdim, YSIZE = ydim, $
                    Graphics_Level = 2, /Button_Events, $
                    /Motion_Events, /Expose_Events, Retain = 0)
Widget_Control, wBase, /REALIZE
Widget_Control, wDraw, Get_Value = oWindow
oTrackBall = OBJ_NEW('TrackBall', [xdim/2.,ydim/2.], xdim/2.)

; rotation
;oModel -> Rotate, [1,0,0], -90
;oModel -> Rotate, [0,1,0], 30
;oModel -> Rotate, [1,0,0], 30

oView -> ADD, oModel2
oView -> ADD, oModel1

oWindow-> Draw, oView

XManager, 'TrackEx', wBase, /NO_BLOCK

print, 'Done!'

end