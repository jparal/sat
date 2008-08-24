;
;  Program:  
;
;  Plot3Dvetorssobj
;
;  Description:
;
;  Opens a 3D array of 3D vectors and plots it using object graphics

;**********************************************************************
;********************************************* 3D Vector Operations ***
;**********************************************************************

; -------------------------------------------------------- int_prod ---
; returns the dot product between v1 and v2
; ---------------------------------------------------------------------

function int_prod,v1,v2
 return, total(v1*v2)
end

; ---------------------------------------------------------------------


; -------------------------------------------------------- ext_prod ---
; returns the cross product between v1 and v2
; ---------------------------------------------------------------------

function ext_prod, v1, v2

  v = fltarr(3)  

  v[0] =  v1[1]*v2[2]-v2[1]*v1[2]
  v[1] = -v1[0]*v2[2]+v2[0]*v1[2]
  v[2] =  v1[0]*v2[1]-v2[0]*v1[1]

  return, v
end

; ---------------------------------------------------------------------


; -------------------------------------------------------- mod_vect ---
; returns the modulus of vector v1
; ---------------------------------------------------------------------

function mod_vect,v1
 return, sqrt(total(v1*v1))
end

; ---------------------------------------------------------------------


;**********************************************************************
;******************************************************** 3D Shapes ***
;**********************************************************************

; ---------------------------------------------------- get_v_circle ---
; returns an array v = fltarr(3,np) of points along a circunference
; centered about pos with raidus  and normal specified byt the
; parameters with the same name
; ---------------------------------------------------------------------

function get_v_circle, np, radius, normal,  pos
    
    x = normal[0]
    y = normal[1]
    z = normal[2]

    v = fltarr(3,np)  
    v0= fltarr(3)

    t = 0.0
    tinc = (2.*!PI)/float(np)

    n0 = [0.,0.,1.] 
    n1 = normal

    n = ext_prod(n0,n1)
    
    sint = -sqrt(int_prod(n,n))
    cost = total(n0*n1)
      
    for i=0, np-1 do begin
       v0[0] = radius*cos(t)	; x    
       v0[1] = radius*sin(t)	; y
       v0[2] = 0.0              ; z                               
       t = t+tinc         
       
       if (sint ne 0) then begin
           v0 = v0*cost + n*int_prod(n,v0)*(1-cost) + ext_prod(v0,n) * sint
       end else if (cost eq -1) then begin
           ; down cilinder 
           ; erro
           ; print, 'Warning, possible error...'
           v0 = -v0
       end   
                 
       v[*,i] = v0
       
    end
    
 
    ; translate
    
    v[0,*] = v[0,*] + pos[0] 
    v[1,*] = v[1,*] + pos[1]
    v[2,*] = v[2,*] + pos[2]

    return, v
end 

; ---------------------------------------------------------------------



;----------------------------------------------------------------------------
; Tube
; 
; Tube is a 3D polyline with radius. The parameter pos is an array with the positions
; of all the angles [3,npoints]

pro Tube, verts, poly, n, pos, radius

    S = Size(pos)
    npoints = s[2]
    if ((s[1] ne 3) and (npoints le 1)) then begin
      print, 'pos must be in the form [3,npoints] and npoints must be gt 1'
      return
    end

    ;----------------------------------- Vertices
    
    verts = fltarr(3, npoints*n)


    ; First set of points
   
    l = pos[*,1] - pos[*,0]
    ls = sqrt(l[0]^2+l[1]^2+l[2]^2)
    l =  l/ls
   
    v = get_v_circle(n,radius,l, pos[*,0])
    for i=0, n-1 do verts[*,i] = v[*,i]

    ; v0 first
     
    v0 = get_v_circle(n,radius,l, pos[*,1])
 
    l0 = l
    for p = 1, npoints-2 do begin
              
       ; Calculate 

       l1 = pos[*,p+1] - pos[*,p]
       ls1 = sqrt(l1[0]^2+l1[1]^2+l1[2]^2)
       l1 = l1/ls1

       v1 = get_v_circle(n,radius,l1, pos[*,p])

       l0l1 = total(l0*l1)
       
       if (l0l1 lt -0.99) then begin
         print, 'Angle too large, aborting'
         verts = 0
         poly = 0
         return
       end else begin
         for i = 0, n-1 do begin
           v10 = (v1[*,i] + v0[*,i])/2
           verts[*,i+n*p] = v10                  
         end
       end
         
       v0 = v1
       l0 = l1
    end      
       
    ; Last set of points
    
    l = pos[*,npoints-1] - pos[*,npoints-2]
    ls = sqrt(l[0]^2+l[1]^2+l[2]^2)
    l = l/ls

    ; rotation about the y axis
    sinty = l[0]
    
    ; rotation about the x axis
    sintx = l[1]

    v = get_v_circle(n,radius,l, pos[*,npoints-1])
    for i=0, n-1 do begin
        verts[*,i+(npoints-1)*n] = v[*,i]
    end   
    
    ;----------------------------------- Polygons
    
    poly = lonarr((1+n)*2 + (1+4)*n*(npoints-1))
  
    ; base
    poly[0] = n
    for i=0,n-1 do poly[i+1] = i
    
    ; top
    j = n+1
    poly[j] = n
    for i=0,n-1 do poly[j+i+1] = (npoints)*n - 1 - i

    ;faces
    
    j = 2*(n+1)   
    for p = 0, npoints -2 do begin
      pbase = p*n
      for i=0, n-2 do begin
          poly[j] = 4
          poly[j+1] = i+pbase           ; top   
          poly[j+2] = n+i+pbase         ; base
          poly[j+3] = n+i+1+pbase       ; base
          poly[j+4] = i+1+pbase         ; top
          j = j+5
       end
       poly[j] = 4
       poly[j+1] = n-1+pbase         ; top 
       poly[j+2] = 2*n - 1+pbase     ; base
       poly[j+3] = n+pbase           ; base
       poly[j+4] = 0+pbase           ; top
       j = j+5
    end

   
end
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
pro Cone,verts,poly, n, pos0, pos1, radius
      
     verts = 0
     poly = 0
    
     ; validate radius
     
     if (radius le 0.) then begin
       print, 'Cone - invalid radius, returning...'
       return    
     end

     ; validate axial coordinates
         
     l = (pos1 - pos0)   
     ls = mod_vect(l)
     if (ls eq 0) then begin
       print, 'Cone - pos0 is equal to pos1, returning...'
       return
     end

     l = l/ls    
     ; generate base
     
     v = get_v_circle(n,radius,l, pos0)
       
     ; verts = fltarr(3, number of vertices)
     ; so in our case we have n+1 vertices
     
     	verts = fltarr(3,n+1)
	
	; tip of the cone vertex
	verts[*,0] = pos1
	
	; base vertices
    
     for i=0, n-1 do begin
        verts[*,i+1] = v[*,i]
     end    
	
	; poly = lonarr(sum for all polygons i of 1+number of vertices on polygon i) 
	; so in our case we have (3+1)*n, n 3 vertices poligon and (n+1)*1, one n vertices polygons
	
	poly = lonarr(4*n+(n+1))             
	
	; base polygons
	poly[0] = n                           ; number of vertices in base
	for i=1,n do poly[i] = (n-i+1)        ; index of base vertices
	
	; face polygons 
	j = n+1
	for i=1,n do begin                    
		poly[j] = 3                      ; 3 vertices per polygon 
		poly[j+1] = i + 1                ; 1st vertex
		poly[j+2] = 0                    ; 2nd vertex (tip of the cone)
		poly[j+3] = i                    ; 3rd vertex (next vertex)
		if (i EQ n) then poly[j+1] = 1   ; if over end of vertices vector use first
		j = j + 4
	end

end
;----------------------------------------------------------------------------


;----------------------------------------------------------------------------
pro solid, vert, poly, pos1, pos2
  
  vert=fltarr(3,8)

  ; top face vertices
  
  vert[0,0] = pos2[0] 
  vert[1,0] = pos2[1] 
  vert[2,0] = pos2[2] 

  vert[0,1] = pos2[0] 
  vert[1,1] = pos1[1] 
  vert[2,1] = pos2[2]
 
  vert[0,2] = pos1[0]
  vert[1,2] = pos1[1] 
  vert[2,2] = pos2[2] 

  vert[0,3] = pos1[0] 
  vert[1,3] = pos2[1] 
  vert[2,3] = pos2[2] 

  ; bottom face vertices
    
  vert[0,4] = pos2[0] 
  vert[1,4] = pos2[1] 
  vert[2,4] = pos1[2] 

  vert[0,5] = pos2[0] 
  vert[1,5] = pos1[1] 
  vert[2,5] = pos1[2] 
 
  vert[0,6] = pos1[0] 
  vert[1,6] = pos1[1] 
  vert[2,6] = pos1[2] 

  vert[0,7] = pos1[0] 
  vert[1,7] = pos2[1] 
  vert[2,7] = pos1[2] 

  
  ; polygons
  
  poly = lonarr((4+1)*6)
  
  j = 0

  ; top polygon  

  poly[j] = 4
  poly[j+1] = 0
  poly[j+2] = 3
  poly[j+3] = 2
  poly[j+4] = 1
  j = j+5

  ; side polygons

  for i = 0, 3 do begin
    poly[j] = 4
    poly[j+1] = 0 + i
    poly[j+2] = 0 + i + 1
    poly[j+3] = 4 + i + 1
    poly[j+4] = 4 + i  
    if (i eq 3) then begin
      poly[j+2] = 0 + 0
      poly[j+3] = 4 + 0
    end
   
    j = j+5
  end  
  
  ; bottom polygon  

  poly[j] = 4
  poly[j+1] = 4
  poly[j+2] = 5
  poly[j+3] = 6
  poly[j+4] = 7

   
end
;----------------------------------------------------------------------------


;**********************************************************************
;************************************** Auxiliary Graphics Routines ***
;**********************************************************************

; -------------------------------------------------- SceneAntiAlias ---
; AntiAliases the view/scence v on window w, with a jitter factor of 4
; Original Copied from the object world demo d_objworld2.pro
; ---------------------------------------------------------------------

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
; ---------------------------------------------------------------------

; ----------------------------------------------------- GetCTColors ---
; Gets the color table values from the system color table CT into the
; three variables r,g,b
; ---------------------------------------------------------------------

pro GetCTColors, CT, RED = r, GREEN = g, BLUE = b
   theColors = Obj_New('IDLgrPalette')
   theColors->LoadCT, ct
   theColors->GetProperty, Red=r, Green=g, Blue=b
   Obj_Destroy, theColors
end

; --------------------------------------------------------- image24 ---
; returns a 24 bit image from an 8-bit image and
; a palette
; ---------------------------------------------------------------------

function image24, image, ct
  s = Size(image)  
  image24bit = BytArr(3, s[1], s[2])

  GetCTColors, ct, RED = rr, GREEN = gg, BLUE = bb
  
  image24bit[0,*,*] = rr(image[*,*])
  image24bit[1,*,*] = gg(image[*,*])
  image24bit[2,*,*] = bb(image[*,*])

; IMPLEMENT NEW CODE!!!!!!!!!

  return, image24bit
end

; ---------------------------------------------------------------------

; ---------------------------------------------------- image24alpha ---
; returns a 24 bit + alpha image from an 8-bit image a palette, and
; an alpha value
; ---------------------------------------------------------------------

function image24alpha, image, CT, alpha
  GetCTColors, ct, RED = rr, GREEN = gg, BLUE = bb
  
  s = Size(Data8bit)
    
  AlphaChannel = make_array(size=s, value=alpha)
  AlphaImage = [rr[Data8bit], gg[Data8bit], bb[Data8bit], AlphaChannel]
  AlphaImage = reform(AlphaImage, s[1], 4, s[2], /overwrite)
  AlphaImage = transpose(AlphaImage, [1,0,2])
  
  return, AlphaImage
  
end
; ---------------------------------------------------------------------


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
;******************************************** Vector Field Routines ***
;**********************************************************************

;---------------------------------------------------------- vel_pos ---
; This function return the interpolated velocity at position
; pos (the parameter t is here for compatibility with the RK4 function) 
;----------------------------------------------------------------------

function vel_pos, t, pos
   
   COMMON GenStream_Shared,$
                  NX, NY, NZ, $		 	; Array dimensions
                  minx, miny, minz, $   	; Minimum positions 
                  LX, LY, LZ, $			; Dimensions
                  vx, vy, vz  			; velocity arrays
  
   x = pos[0]
   y = pos[1]
   z = pos[2]

   i = (double(NX)-1)*(x-minx)/LX
   j = (double(NY)-1)*(y-miny)/LY 
   k = (double(NZ)-1)*(z-minz)/LZ 
  
   
   u = interpolate(vx,i,j,k)
   v = interpolate(vy,i,j,k)
   w = interpolate(vz,i,j,k)
   
   return, [u,v,w]
end
;----------------------------------------------------------------------

;----------------------------------------------------- streamline3D ---
; Returns an array of points that follow
; the streamline of the field passing through the given position
;----------------------------------------------------------------------

function streamline3D, pos, NSEGS = _qual, _EXTRA=extrakeys
  
  if (N_Elements(_qual)   eq 0) then _qual = 10
  if (N_Elements(line)    eq 0) then line = 0
   
  dt = 1.0/_qual
  nsteps = _qual
  
  points = fltarr(3,nsteps*2) 

  ; Backward part

  pos1 = pos  
  for i=1, nsteps do begin
    vel1 = vel_pos(0.0,pos1)
    pos1 = RK4(pos1, vel1, 0.0, -dt, 'vel_pos')
    points[*,nsteps-i] = pos1
  end 

  ; Forward part
 
  pos1 = pos
  for i=1, nsteps do begin 
     vel1 = vel_pos(0.0,pos1)
     pos1 = RK4(pos1, vel1, 0.0, dt, 'vel_pos')
     points[*,nsteps+i-1] = pos1
  end 
  
  return, points
end

;----------------------------------------------------------------------

;------------------------------------------------------ VectorField ---
; Generates the Vector Field model from the data in parameter v[3,*,*,*]
; outputs the result to the parameter oModelVectorField
;----------------------------------------------------------------------

pro VectorField, v, oModelVectorField, _EXTRA=extrakeys,$
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $  
               NUMVECTS = NumberVectors, VECTDIST = VectorDistribution, $
               STARTPOS = StartPositions, TYPE = PlotType, LREF = lref, $
               LENGTH = length, COLOR = Color, LINE = useline

   COMMON GenStream_Shared,$
                  NX, NY, NZ, $		 	; Array dimensions
                  minx, miny, minz, $   	; Minimum positions 
                  LX, LY, LZ, $			; Dimensions
                  vx, vy, vz  			; velocity arrays

  ; Initialize local variables and test the validity of the parameters
                  
  s = size(v)
  if ((s[0] ne 4) or (s[1] ne 3)) then begin
     print, s
     newres = Dialog_Message("v must be a 3*3D array", /Error)
     return 
  end

  NX = s[2]
  NY = s[3]
  NZ = s[4]

  vx = reform(v[0,*,*,*])
  vy = reform(v[1,*,*,*])
  vz = reform(v[2,*,*,*])

  LX = XAxisData[NX-1]-XAxisData[0]
  minx = XAxisData[0]
  maxx = XAxisData[NX-1]
  dx = LX/(NX-1) 

  LY = YAxisData[NY-1]-YAxisData[0]
  miny = YAxisData[0]
  maxy = YAxisData[NY-1]
  dy = LY/(NY-1) 

  LZ = ZAxisData[NZ-1]-ZAxisData[0]
  minz = ZAxisData[0]
  maxz = ZAxisData[NZ-1]
  dz = LZ/(NZ-1) 

; LINE
;
; Use a line for the streamline instead of a tube.

if N_Elements(useline) eq 0 then useline = 0

; COLOR
;
;
  if N_Elements(color) eq 0 then color=[255b,0b,0b,255b]

; VECTDIST
;
; Vector distribution. This parameter allows you to choose between a regular distribution (0 - default) and a 
; random distribution (1)

  if N_Elements(VectorDistribution) eq 0 then VectorDistribution = 0

; NUMVECTS
;
; Number of vectors to plot. This parameter allows you to define the number of vectors to plot. The default
; is 125. 

  if N_Elements(NumberVectors) eq 0 then begin
    case VectorDistribution of  
       1: NumberVectors = 125 
    else: NumberVectors = [5,5,5]
    endcase
  endif else begin
    s = size(NumberVectors) 
    if (s[0] eq 0) then begin   ; scalar provided
      case VectorDistribution of  
         1: NumberVectors = 1.0*NumberVectors 
      else: begin
              NumberVectors = Abs(NumberVectors)
              n = long(NumberVectors^(1./3.))
              NumberVectors = [n,n,n]
            end
      endcase
    endif else begin
      if (s[1] ne 3) then begin
       newres = Dialog_Message("NUMVECTS must be a scalar or a 1D vector with 3 components", /Error)
       return
      endif  
    endelse
  endelse

; STARTPOS
;
; Vector starting points. Use this parameter to supply a vector containing the starting points to
; the vectors you wish to draw. If you set this parameter the program will ignore NUMVECTS and VECTDIST

  if N_Elements(StartPositions) eq 0 then begin
    case VectorDistribution of  
       1: begin                           ; random
            StartPositions=randomu(seed, 3, NumberVectors)
            StartPositions[0,*] = minx + StartPositions[0,*]*LX
            StartPositions[1,*] = miny + StartPositions[1,*]*LY
            StartPositions[2,*] = minz + StartPositions[2,*]*LZ
            NV = NumberVectors
          end
    else: begin                           ; regular
            StartPositions = FltArr(3,NumberVectors[0]*NumberVectors[1]*NumberVectors[2])
            k = long(0)
            for i = 0, NumberVectors[0] - 1 do begin
              x = minx + LX*(1.+1.*i)/(1.*NumberVectors[0] + 1.)
              for j = 0, NumberVectors[1] - 1 do begin
                y = miny + LY*(1.+1.*j)/(1.*NumberVectors[1] + 1. )
                  for l = 0, NumberVectors[2] -1 do begin
                    z = minz + LZ*(1.+1.*l)/(1.*NumberVectors[2] + 1. )
                    StartPositions[0,k] = x
                    StartPositions[1,k] = y
                    StartPositions[2,k] = z              
                    k = k+1
                  end
              end
            end
            NV = NumberVectors[0]*NumberVectors[1]*NumberVectors[2]
          end         
    endcase
  end

; TYPE 
;
; The type of plot to make. This parameter allows you to choose between a plot curved arrows that follow the
; field lines (0-default), or straight arrows parallel to the field in the chosen position (1)

  if N_Elements(PlotType) eq 0 then PlotType = 0

; SCALETYPE
;
; The type of representation to be used for the lenght of the vectors. This parameter allows you to chose 
; the between the following:
;
; 0 - The arrow size and the color are proportional to the field magnitude (default)
; 1 - Only the size is proportional to the field magnitude (plots using default color)
; 2 - Only the color is proportional to the field magnitude
; 3 - The size and the color are constant (plots using default color)

  if N_Elements(ScaleType) eq 0 then ScaleType = 0

; calculates the length of the vectors

  vel = DblArr(3,NV) 
  for k= long(0), NV-1 do vel[*,k] = vel_pos(0.0, reform(StartPositions[*,k]))
  l = sqrt(vel[0,*]^2+vel[1,*]^2+vel[2,*]^2)

; LREF
;
; The reference length of the vectors in the field. The program uses this value to scale the lenght 
; of the vectors plotted. If not supplied the program autoscales to the maximum value in the data supplied.


  if N_Elements(lref) eq 0 then begin
   lref = MAX(l)
  end

  maxl= lref

; LENGTH
;
; The scale length of the vectors. This parameter specifies the size of the vector with size LREF to be plotted
; as a percentage of the plot area (in data units). The default is 0.3

  if N_Elements(length) eq 0 then begin
   length = 0.3
  end

; RADIUS
;
; The radius of the tube to draw. If positive is a percentage of the length of the vector being
; drawn. If negative its the percentage of length

  if N_Elements(radius) eq 0 then begin
    radius = 0.
  end 
 
  if ((radius eq 0.) or (radius gt 1.) or (radius lt -1.)) then begin
    radius = 0.2
  end

; Generates the streamline points and adds result to oModelStream
  
  LBoxMax = Max([LX,LY,LZ])
  vx = 0.5*(vx/maxl)*length*LBoxMax
  vy = 0.5*(vy/maxl)*length*LBoxMax       
  vz = 0.5*(vz/maxl)*length*LBoxMax       
           
  for k=long(0), NV-1 do begin       
       points = streamline3D(StartPositions[*,k], _EXTRA=extrakeys)    
       
       vel1 = vel_pos(0.0,StartPositions[*,k])

       rad = length/maxl*radius

       if (radius gt 0) then rad = rad * mod_vect(vel1)
              
       if (useline eq 1) then begin  ; Line
          oPoly = OBJ_NEW('IDLgrPolyline', points, COLOR = color) 
          oModelVectorField -> Add, oPoly

       end else begin                ; Tube

          if (rad gt 0.) then begin
             Tube, vert, poly, 10, points, rad
             oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                             COLOR = color, REJECT = 1)
             if oPoly ne OBJ_NEW() then oModelVectorField -> Add, oPoly
          end
       end

       if (rad gt 0.) then begin
         s = size(points)
         np = s[2] 
         p0 = reform(points[*,np-2])
         p1 = reform(points[*,np-1])
         norm_cone = p1 - p0
         norm_cone = norm_cone/sqrt(total(norm_cone*norm_cone))         
         Cone,vert,poly, 10, p1, p1 + norm_cone*8.*rad, 4.*rad
         oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                          COLOR = color, REJECT = 1)
         if oPoly ne OBJ_NEW() then oModelVectorField -> Add, oPoly
       end
 
  end
 
end


; ---------------------------------------------------------------------

;**********************************************************************
;********************************************** IsoSurface Routines ***
;**********************************************************************

;------------------------------------------------------- IsoSurface ---
; Generates the IsoSurface model from the data in parameter 
; Data[NX,NY,NZ], using the isovalues specified in the isolevels param.
; Note that the IsoLevels are in absolute (not relative) values.
; outputs the result to the parameter oModelIsoSurf
;----------------------------------------------------------------------

pro IsoSurface, Data, IsoLevels, oModelIsoSurf, COLOR = Colors, BOTTOM = BottomColors, $
                         LOW = lows, $
                         XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData

   ; test validity of Data
    
   S = Size(Data)
   
   If (S[0] ne 3) then begin
     print, 'IsoSurface, Data must be 3 Dimensional...'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]

   ; Test Validity of IsoLevels

   S = Size(isolevels)
   if (S[0] eq 0) then begin
     isoval = isolevels
     isolevels = FltArr(1)
     isolevels[0] = isoval
     S = Size(isolevels)
   end else if (S[0] ne 1) then begin
     print, 'IsoSurface, IsoLevels must be a scalar or a one dimensional array...'
     return
   end

   NumIsoLevels = S[1]


   ; Isosurfaces top colors
       
   if (N_elements(Colors) eq 0) then begin
        DefColors = [ [255b,000b,000b,064b], $
                      [255b,255b,000b,032b], $
                      [000b,255b,000b,016b]]
        Colors = BytArr(4, NumIsoLevels)
        for i = 0, NumIsoLevels - 1 do begin
          if (i le 2) then Colors[*,i] = DefColors[*,i] $
          else Colors[*,i] = (NumIsoLevels -1 -i)/(1.*NumIsoLevels) * [255b, 255b, 255b, 255b] 
        end
   end else begin
        S = Size(Colors)
        if ((S[0] ne 1) or (S[1] ne 4) or (S[2] ne NumIsoLevels)) then begin
          print, 'IsoSurface, COLOR must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
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
          print, 'IsoSurface, BOTTOM must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
        end   
   end
   
   ; Normal direction
   
   if N_Elements(lows) eq 0 then begin
     lows = BytArr(NumIsoLevels) * 0 + 0
   end else begin
     S = Size(lows)
     if (S[0] eq 0) then begin
       lowval = lows
       lows = BytArr(NumIsoLevels) * 0 + lowval 
     end else if ((S[0] ne 1) or (S[1] ne NumIsoLevels)) then begin
       print, 'IsoSurface, lows must be either a scalae or a 1D array with one element for each isosurface'
       return 
     end  
   end     

   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'IsoSurface, XAXIS must be a 1D array with NX elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'IsoSurface, YAXIS must be a 1D array with NY elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'IsoSurface, ZAXIS must be a 1D array with NZ elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end     

   ; Spatial extents
       
   XMin = XAxisData[0]
   XMax = XAxisData[NX-1]
   XRange = XMax - XMin

   YMin = YAxisData[0]
   YMax = YAxisData[NY-1]
   YRange = YMax - YMin

   ZMin = ZAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZRange = ZMax - ZMin

   ; Isosurfaces

   for i=0, NumIsoLevels -1 do begin
     isoval = isolevels[i]     
     print, 'Generating Isosurface, isovalue = ', isoval
     Shade_Volume, Data, isoval, vert, poly, LOW = low   
     S = Size(poly)

     if (S[1] gt 0) then begin ; If any polygons to draw
       print, 'Generating 3D polygons'
       SurfColor = Reform(Colors[*,i])
       SurfBottomColor = Reform(BottomColors[*,i])

       vert[0,*] = XMin + vert[0,*]*XRange/(NX-1)   
       vert[1,*] = YMin + vert[1,*]*YRange/(NY-1)   
       vert[2,*] = ZMin + vert[2,*]*ZRange/(NZ-1)   
       
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


end

; ---------------------------------------------------------------------

;**********************************************************************
;********************************************** Projection Routines ***
;**********************************************************************

;------------------------------------------------------ Projections ---
; Generates the Projection model from the data in parameter 
; Data[NX,NY,NZ]
; outputs the result to the parameter oModelProj
;----------------------------------------------------------------------

pro Projections, Data, oModelProj, CT = projCT, PMIN = pmin, PMAX = pmax, $
                 XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
                 
   ; test validity of Data
    
   S = Size(Data)
   
   If (S[0] ne 3) then begin
     print, 'Projections, Data must be 3 Dimensional...'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]                 
                 
   ; projections
                   
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
                res = Dialog_Message("Projections, PMAX must be either a scalar or a 3 element vector", /Error)
                return          
               end                  
         else: begin
                res = Dialog_Message("Projections, PMAX must be either a scalar or a 3 element vector", /Error)
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
                res = Dialog_Message("Projections, PMIN must be either a scalar or a 3 element vector", /Error)
                return          
               end    
         else: begin
                res = Dialog_Message("Projections, PMIN must be either a scalar or a 3 element vector", /Error)
                return     
               end
       endcase
   endelse


   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'Projections, XAXIS must be a 1D array with NX elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'Projections, YAXIS must be a 1D array with NY elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'Projections, ZAXIS must be a 1D array with NZ elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end     

   ; Spatial extents
       
   XMin = XAxisData[0]
   XMax = XAxisData[NX-1]
   XRange = XMax - XMin

   YMin = YAxisData[0]
   YMax = YAxisData[NY-1]
   YRange = YMax - YMin

   ZMin = ZAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZRange = ZMax - ZMin

   
   if N_Elements(projCT) eq 0 then projCT = 22

   ; X Projection

   p1image = BytScl(p1image, Max = ProjMax[0], Min = ProjMin[0])
   oimgProj1 =  OBJ_NEW('IDLgrImage', image24(p1image, projCT ))  
   opolProj1 = OBJ_NEW('IDLgrPolygon', [[XMax, YMin, ZMin], [XMax, YMax, ZMin],$
                                        [XMax, YMax, ZMax], [XMax, YMin, ZMax]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgProj1, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    

   p1image = 0
   
   ; Y Projection

   p2image = BytScl(p2image, Max = ProjMax[1], Min = ProjMin[1])
   oimgProj2 =  OBJ_NEW('IDLgrImage', image24(p2image, projCT ))  
   opolProj2 = OBJ_NEW('IDLgrPolygon', [[XMin, YMax, ZMin],[XMax, YMax, ZMin],$
                                        [XMax, YMax, ZMax],[XMin, YMax, ZMax]],$
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgProj2, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    

   p2image = 0
   
   ; Z Projection
  
    p3image = BytScl(p3image, Max = ProjMax[2], Min = ProjMin[2])
    oimgProj3 =  OBJ_NEW('IDLgrImage', image24(p3image, projCT ))  
    opolProj3 = OBJ_NEW('IDLgrPolygon', [[XMin, YMin, ZMin],[XMax, YMin, ZMin], $
                                         [XMax, YMax, ZMin],[XMin, YMax, ZMin]], $
                                         COLOR = [255,255,255], $
                                         Texture_Map = oimgProj3, $
                                         Texture_Coord = [[0,0],[1,0],[1,1],[0,1]],$
                                         /Texture_Interp)                                    

   p3image = 0

   oModelProj -> ADD, opolProj1 
   oModelProj -> ADD, opolProj2 
   oModelProj -> ADD, opolProj3   
   
   oModelProj -> SetProperty, LIGHTING = 0
                 

end

; ---------------------------------------------------------------------

;**********************************************************************
;*************************************************** Slice Routines ***
;**********************************************************************

;----------------------------------------------------------- Slices ---
; Generates the Slice model from the data in parameter 
; Data[NX,NY,NZ]. The slices are specified by the SlicePos parameter
; outputs the result to the parameter oModelSlice
;----------------------------------------------------------------------

pro Slices, Data, SlicePos, oModelSlice, CT = sliceCT, MIN = DataMin, MAX = DataMax, $
                 XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
                 
   ; test validity of Data
    
   S = Size(Data)
   
   If (S[0] ne 3) then begin
     print, 'Slices, Data must be 3 Dimensional...'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]                 

   ; slice positions
   
   S = Size(SlicePos)
   
   if ((S[0] ne 2) or (S[1] ne 2)) then begin
     print, 'Slices, SlicePos must be in the form [ [ axis1, pos1], [axis2, pos2], ..., [axisn, posn] ]'
     return
   end   
      
   NSlices = S[2]
                 
   ; Range of values

   if N_Elements(DataMin) eq 0 then begin
      DataMin = Min(Data)  
   end
      
   if N_Elements(DataMax) eq 0 then begin
      DataMax = Max(Data)  
   end 
                  

   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'IsoSurface, XAXIS must be a 1D array with NX elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'IsoSurface, YAXIS must be a 1D array with NY elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'IsoSurface, ZAXIS must be a 1D array with NZ elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end     

   ; Color Scale
   
   if N_Elements(sliceCT) eq 0 then sliceCT = 25


   ; Spatial extents
       
   XMin = XAxisData[0]
   XMax = XAxisData[NX-1]
   XRange = XMax - XMin
   XDelta = XRange/NX

   YMin = YAxisData[0]
   YMax = YAxisData[NY-1]
   YRange = YMax - YMin
   YDelta = YRange/NY

   ZMin = ZAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZRange = ZMax - ZMin
   ZDelta = ZRange/NZ
   
   for s = 0, NSlices-1 do begin
      dir = SlicePos[0,s]
      pos = SlicePos[1,s]
      
      case dir of
          2: begin  ; XY slice
               p = long( (pos - ZMin) / ZDelta)
               if ((p lt 0) or (p gt NZ-1)) then begin
                  print, 'Slices, Invalid slice position, slice ignored'
               end else begin
                  pos = ZAxisData(p)
                  slice = Reform(Data[*,*,p])
                  slice = BytScl(slice, MIN = DataMin, MAX = DataMax)

                  oimgSlice = OBJ_NEW('IDLgrImage', image24(slice, sliceCT ))  
                  opolSlice = OBJ_NEW('IDLgrPolygon', $
                                       [[XMin, YMin, pos],[XMax, YMin, pos], $
                                        [XMax, YMax, pos],[XMin, YMax, pos]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgSlice, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    
                  oModelSlice -> ADD, opolSlice 
               end 
             end 
          1: begin  ; XZ slice
               p = long( (pos - YMin) / YDelta)
               if ((p lt 0) or (p gt NY-1)) then begin
                  print, 'Slices, Invalid slice position, slice ignored'
               end else begin
                  pos = YAxisData(p)                  
                  slice = Reform(Data[*,p,*])
                  slice = BytScl(slice, MIN = DataMin, MAX = DataMax)

                  oimgSlice = OBJ_NEW('IDLgrImage', image24(slice, sliceCT ))  
                  opolSlice = OBJ_NEW('IDLgrPolygon', $
                                       [[XMin, pos, ZMin],[XMax, pos, ZMin],$
                                        [XMax, pos, ZMax],[XMin, pos, ZMax]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgSlice, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    
                  oModelSlice -> ADD, opolSlice 
               end 
             end 
          0: begin  ; YZ slice
               p = long( (pos - XMin) / XDelta)
               if ((p lt 0) or (p gt NX-1)) then begin
                  print, 'Slices, Invalid slice position, slice ignored'
               end else begin
                  pos = XAxisData(p)
                  slice = Reform(Data[p,*,*])
                  slice = BytScl(slice, MIN = DataMin, MAX = DataMax)

                  oimgSlice = OBJ_NEW('IDLgrImage', image24(slice, sliceCT ))  
                  opolSlice = OBJ_NEW('IDLgrPolygon', $
                                       [[pos, YMin, ZMin], [pos, YMax, ZMin],$
                                        [pos, YMax, ZMax], [pos, YMin, ZMax]], $
                                        COLOR = [255,255,255], $
                                        Texture_Map = oimgSlice, $
                                        Texture_Coord = [[0,0],[1,0],[1,1],[0,1]], $
                                        /Texture_Interp)                                    
                  oModelSlice -> ADD, opolSlice 
               end 
             end 
       else: begin
               print, 'Slices, Invalid slice direction, slice ignored'
             end        
      end
   
   end                    

   oModelSlice -> SetProperty, LIGHTING = 0


end

; ---------------------------------------------------------------------


;**********************************************************************
;******************************************************** Main Code ***
;**********************************************************************

Pro Plot3Dvectorobj, PlotData, _EXTRA = extrakeys,$
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