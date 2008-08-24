;**********************************************************************
;********************************************* 3D Vector Operations ***
;**********************************************************************

; -------------------------------------------------------- dotp ---
; returns the dot product between v1 and v2
; ---------------------------------------------------------------------

function dotp,v1,v2
 return, total(v1*v2)
end

; ---------------------------------------------------------------------


; -------------------------------------------------------- crossp ---
; returns the cross product between v1 and v2
; ---------------------------------------------------------------------

;function crossp, v1, v2

;  v = fltarr(3)  

;  v[0] =  v1[1]*v2[2]-v2[1]*v1[2]
;  v[1] = -v1[0]*v2[2]+v2[0]*v1[2]
;  v[2] =  v1[0]*v2[1]-v2[0]*v1[1]

;  return, v
;end

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

function get_v_circle, np, radius, normal,  pos, ASPECTRATIO = aspectratio
    
    if N_Elements(aspectratio) eq 0 then aspectratio = [1,1,1] 
    
    x = normal[0]
    y = normal[1]
    z = normal[2]

    v = fltarr(3,np)  
    v0= fltarr(3)

    t = 0.0
    tinc = (2.*!PI)/float(np)

    n0 = [0.,0.,1.] 
    n1 = normal

    n = crossp(n0,n1)
    
    sint = -sqrt(dotp(n,n))
    cost = total(n0*n1)
      
    for i=0, np-1 do begin
       v0[0] = radius*cos(t)	; x    
       v0[1] = radius*sin(t)	; y
       v0[2] = 0.0              ; z                               
       t = t+tinc         
       
       if (sint ne 0) then begin
           v0 = v0*cost + n*dotp(n,v0)*(1-cost) + crossp(v0,n) * sint
       end else if (cost eq -1) then begin
           ; down cilinder 
           ; erro
           ; print, 'Warning, possible error...'
           v0 = -v0
       end   
                 
       v[*,i] = v0
       
    end
    
    ; correct aspect ratio
 
    v[0,*] = v[0,*]*aspectratio[0]
    v[1,*] = v[1,*]*aspectratio[1]
    v[2,*] = v[2,*]*aspectratio[2]
 
    ; translate
    
    v[0,*] = v[0,*] + pos[0] 
    v[1,*] = v[1,*] + pos[1]
    v[2,*] = v[2,*] + pos[2]

    return, v
end 

; ---------------------------------------------------------------------

; ------------------------------------------------------------ Tube ---
; Tube is a 3D polyline with radius. The parameter pos is an array with
; the positions of all the inflection angles [3,npoints]
; You can supply an optional argument COLORS with the dimensions
; [4, npoints] (4 is RGB+alpha) to specify the color value at each point.
; In this case the procedure returns an array [4, nverts] through the 
; same parameter to be used by the POLYSHADE SHADE parameter or by the
; VERT_COLORS parameter for the IDLgrPolygon Object
;
; Set the ASPECTRATIO parameter for plots where the ratio between the 
; several axis is not 1
 
pro Tube, verts, poly, n, pos, radius, COLORS = vColors, ASPECTRATIO = aspectratio

    help, aspectratio
   
    verts = 0
    poly = 0
    S = Size(pos)
    npoints = s[2]
    if ((s[1] ne 3) and (npoints le 1)) then begin
      print, 'Tube - pos must be in the form [3,npoints] and npoints must be gt 1'
      return
    end
     
    nverts = npoints*n
    color = 0
 
    if N_Elements(vColors) ne 0 then begin
      S = Size(vColors)
      if ((S[0] ne 2) or (S[1] ne 4) or (S[2] ne npoints)) then begin
        print, 'Tube - COLOR must be in the form [4,npoints]'
        return 
      end       
      posColors = vColors
      vColors = fltarr(4,nverts)
      color = 1
    end

    ;----------------------------------- Vertices
    
    verts = fltarr(3, nverts)


    ; First set of points
   
    l = pos[*,1] - pos[*,0]
    ls = sqrt(l[0]^2+l[1]^2+l[2]^2)
    l =  l/ls
   
    v = get_v_circle(n,radius,l, pos[*,0], ASPECTRATIO = aspectratio)
    for i=0, n-1 do verts[*,i] = v[*,i]
    
    if (color eq 1) then for i=0, n-1 do vColors[*,i] = posColors[*,0]
    
    ; v0 first
     
    v0 = get_v_circle(n,radius,l, pos[*,1], ASPECTRATIO = aspectratio)
 
    l0 = l
    for p = 1, npoints-2 do begin
              
       ; Calculate 

       l1 = pos[*,p+1] - pos[*,p]
       ls1 = sqrt(l1[0]^2+l1[1]^2+l1[2]^2)
       l1 = l1/ls1

       v1 = get_v_circle(n,radius,l1, pos[*,p], ASPECTRATIO = aspectratio)

       l0l1 = total(l0*l1)
       
       if (l0l1 lt -0.99) then begin
         print, 'Angle too large, aborting'
         verts = 0
         poly = 0
         vColors = 0
         return
       end else begin
         for i = 0, n-1 do begin
           v10 = (v1[*,i] + v0[*,i])/2
           verts[*,i+n*p] = v10                  
         end
       end

       if (color eq 1) then for i=0, n-1 do vColors[*,i+n*p] = posColors[*,p]
         
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

    v = get_v_circle(n,radius,l, pos[*,npoints-1], ASPECTRATIO = aspectratio)
    for i=0, n-1 do begin
        verts[*,i+(npoints-1)*n] = v[*,i]
    end   

    if (color eq 1) then for i=0, n-1 do vColors[*,i+(npoints-1)*n] = posColors[*,npoints-1]
   
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
    
    j = long(2*(n+1))   
    for p = long(0), npoints -2 do begin
      pbase = p*n
      for i=long(0), n-2 do begin
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
