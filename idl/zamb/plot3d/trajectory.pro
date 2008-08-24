pro Trajectory, verts, oModelTrajectory, _EXTRA=extrakeys, $
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
               PROJ = doProj, COLOR = Color, RADIUS = Radius, VERT_COLORS = VColor, LINE = useline, $
               POINTS = points, AXISRATIO = Ratio, THICK = linethick, $
               ARROW = doArrow
               
  if not (Arg_Present(verts) and Arg_Present(oModelTrajectory)) then return

  s = size(verts)
  
  if ((s[0] ne 2) or (s[1] ne 3) or (s[2] le 2)) then begin
    print, 'Trajectory, verts must be an array in the form [3,npoints] with npoints greater '
    print, 'than 2'
    return
  end

  npoints = s[2]  
  
  ;print, 'Trajectory, Number of Points',npoints

  ; THICK
  ;
  ; line thickness to be used for the projections
  
  if (N_Elements(linethick) eq 0) then linethick = 1 

  ; AXISRATIO
  ;
  ; The ratio between the axis in display units (not data units!). Use this to make sure
  ; that the tubes drawn have a circular section
  
  if (N_Elements(Ratio) eq 0) then Ratio = [1.,1.,1.] 
  
  ; Normalize axisratio
  AxisRatio = Ratio/Max(Ratio)
;  print, 'Trajectory, AxisRatio = ', axisratio


  ; COLOR
  ;
  ; Line Color, defaults to white 

  if (N_Elements(Color) eq 0) then begin
    Color = [255b,255b,255b,255b]
  end else begin
    s = size(Color)
    if (s[0] ne 1) or (s[1] ne 4) then begin
      print, 'Trajectory, COLOR must be a four element vector in the form [R,G,B,alpha] '
      return
    end
  end
  
  ; VERT_COLORS
  ;
  ; Color for each vertex of the line. If set overrides COLOR
  
  if (N_Elements(VColor) eq 0) then begin
    VColor = BytArr(4,npoints)
    VColor[0,*] = Color[0]
    VColor[1,*] = Color[1]
    VColor[2,*] = Color[2]
    VColor[3,*] = Color[3]
  end else begin
    s = size(VColor)
    if ((s[0] ne 2) or (s[1] ne 4) or (s[2] ne npoints)) then begin
      print, 'Trajectory VCOLOR must be an array in the form [4, npoints], with [0,*] -> R,'
      print, '[1,*] -> G, [2,*] -> B, [3,*] -> alpha  '
      return
    end
  end

  tip_color = reform(vcolor[*,npoints-1]) 


  ; RADIUS
  ;
  ; The radius of the tube to draw as a percentage of the maximum length of the box

  if N_Elements(radius) eq 0 then begin
    radius = 0.
  end 
 
  if ((radius le 0.) or (radius gt 1.)) then begin
    radius = 0.02
  end

  ; Default Axis
      
  If N_Elements(XAxisData) eq 0 then begin
       NX = 100
       XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
  end else begin
       s = Size(XAxisData)
       NX = S[1]
  end 

  If N_Elements(YAxisData) eq 0 then begin
       NY = 100
       YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
  end else begin
       s = Size(YAxisData)
       NY = S[1]
  end 

  If N_Elements(ZAxisData) eq 0 then begin
       NZ = 100
       ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
  end else begin
       s = Size(ZAxisData)
       NZ = S[1]
  end 

  
  LX = XAxisData[NX-1]-XAxisData[0]
  xmin = XAxisData[0]
  xmax = XAxisData[NX-1]
  dx = LX/(NX-1) 

  LY = YAxisData[NY-1]-YAxisData[0]
  ymin = YAxisData[0]
  ymax = YAxisData[NY-1]
  dy = LY/(NY-1) 

  LZ = ZAxisData[NZ-1]-ZAxisData[0]
  zmin = ZAxisData[0]
  zmax = ZAxisData[NZ-1]
  dz = LZ/(NZ-1) 
  
  LBoxMax = Max([LX,LY,LZ])    
  rad = radius*LBoxMax 
  tuberatio = ([LX,LY,LZ] / AxisRatio) 


  
  if N_Elements(Points) eq 0 then begin ; No points specified

    ; Polyline
          
    if KeyWord_Set(useline) then begin  ; Line
      oPoly = OBJ_NEW('IDLgrPolyline', verts, VERT_COLORS = vcolor) 
      oModelTrajectory -> Add, oPoly
    end else begin                ; Tube
      if (rad gt 0.) then begin
      ;  print, 'Trajectory, tuberatio = ',tuberatio
        Tube, vert, poly, 10, verts, rad, COLOR = vcolor, ASPECTRATIO = tuberatio
        s = size(vert)
        if (s[0] ne 0) then begin
          oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                       VERT_COLORS = vcolor, REJECT = 1)
          if oPoly ne OBJ_NEW() then oModelTrajectory -> Add, oPoly
        end
      end
    end          
         
    ; Projections
  
    if KeyWord_Set(doProj) then begin 
      ; XY-Plane projections
  
      xypoints = verts
      xypoints[2,*] = zmin
      oPoly = OBJ_NEW('IDLgrPolyline', xypoints, VERT_COLORS = vcolor, THICK = linethick) 
      oModelTrajectory -> Add, oPoly
      xypoints = 0
    
      ; XZ-Plane projections
  
      xzpoints = verts
      xzpoints[1,*] = ymax
      oPoly = OBJ_NEW('IDLgrPolyline', xzpoints, VERT_COLORS = vcolor, THICK = linethick) 
      oModelTrajectory -> Add, oPoly
      xzpoints = 0

      ; YZ-Plane projections
  
      yzpoints = verts
      yzpoints[0,*] = xmax
      oPoly = OBJ_NEW('IDLgrPolyline', yzpoints, VERT_COLORS = vcolor, THICK = linethick) 
      oModelTrajectory -> Add, oPoly
      yzpoints = 0  

    end

    ; Arrow
    
    if KeyWord_Set(doArrow) then begin
       if (rad gt 0.) then begin
         s = size(verts)
         np = s[2] 
         i = np-2
         p0 = reform(verts[*,np-2])
         p1 = reform(verts[*,np-1])
         norm_cone = p1 - p0
         lnc=sqrt(total(norm_cone*norm_cone))
         while (lnc eq 0. and i gt 0) do begin
          i = i-1
          p0 = reform(verts[*,np-2])
          p1 = reform(verts[*,np-1])
          norm_cone = p1 - p0
          lnc=sqrt(total(norm_cone*norm_cone))
         end
         if (i ne 0) then begin
           norm_cone = norm_cone/lnc         
           Cone,vert,poly, 10, p1- norm_cone*rad, p1 + norm_cone*2.*rad, 2.*rad, ASPECTRATIO = tuberatio 
           oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                          COLOR = tip_color , REJECT = 1)
           if oPoly ne OBJ_NEW() then oModelTrajectory -> Add, oPoly
         end
         
       end
    end
        
  end else begin
     
     s = size(Points)
     
     if (s[0] ne 1) then begin
       print, 'Trajectory, verts must be a 1D array in the form [nv1,v11, v12, ...,vnv1, nv2, ...]'
       return
     end
  
     imax = s[1]
     
     i=0
     
     while(i lt imax) do begin
       nv = points[i]
       if (nv le 0) then begin
         i = i+1
       end else begin         
          print, 'Adding Trajectory, i, nv', i, nv
 
          iverts = verts[*,points[i+1:i+nv]]
           
    
          ; Polyline
          
          if KeyWord_Set(useline) then begin  ; Line
             oPoly = OBJ_NEW('IDLgrPolyline', verts[*,points[i+1:i+nv]], VERT_COLORS = vcolor[*,points[i+1:i+nv]]) 
             oModelTrajectory -> Add, oPoly    
          end else begin                ; Tube
            if (rad gt 0.) then begin
              Tube, tvert, poly, 10, verts[*,points[i+1:i+nv]], rad, COLOR = vcolor[*,points[i+1:i+nv]], ASPECTRATIO = tuberatio
              s = size(tvert)
              if (s[0] ne 0) then begin
                oPoly = OBJ_NEW('IDLgrPolygon',tvert, POLYGON = poly, STYLE = 2, Shading = 1, $
                             VERT_COLORS = vcolor[*,points[i+1:i+nv]], REJECT = 1)
                if oPoly ne OBJ_NEW() then oModelTrajectory -> Add, oPoly
              end
            end
          end          
          
          ; Projections
  
          if KeyWord_Set(doProj) then begin 
            ; XY-Plane projections
    
            xypoints = verts[*,points[i+1:i+nv]]
            xypoints[2,*] = zmin 
            oPoly = OBJ_NEW('IDLgrPolyline', xypoints, VERT_COLORS = vcolor, THICK = linethick) 
            oModelTrajectory -> Add, oPoly
            xypoints = 0
    
            ; XZ-Plane projections
  
            xzpoints = verts[*,points[i+1:i+nv]]
            xzpoints[1,*] = ymax
            oPoly = OBJ_NEW('IDLgrPolyline', xzpoints, VERT_COLORS = vcolor, THICK = linethick) 
            oModelTrajectory -> Add, oPoly
            xzpoints = 0

            ; YZ-Plane projections
  
            yzpoints = verts[*,points[i+1:i+nv]]
            yzpoints[0,*] = xmax
            oPoly = OBJ_NEW('IDLgrPolyline', yzpoints, VERT_COLORS = vcolor, THICK = linethick)   
            oModelTrajectory -> Add, oPoly
            yzpoints = 0  
          end     
         
          ; Increase i
    
          i = i + 1 + nv    
                
       end
     end
  
  end
  
     
end          
          
          
          
          
          
          
          