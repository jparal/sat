;----------------------------------------------------------------------------
pro Cube, vert, poly, pos, side
  
  vert=fltarr(3,8)
  l = float(side)/2.

  ; top face vertices
  
  vert[0,0] = pos[0] + l
  vert[1,0] = pos[1] + l
  vert[2,0] = pos[2] + l

  vert[0,1] = pos[0] + l
  vert[1,1] = pos[1] - l
  vert[2,1] = pos[2] + l
 
  vert[0,2] = pos[0] - l
  vert[1,2] = pos[1] - l
  vert[2,2] = pos[2] + l

  vert[0,3] = pos[0] - l
  vert[1,3] = pos[1] + l
  vert[2,3] = pos[2] + l

  ; bottom face vertices
    
  vert[0,4] = pos[0] + l
  vert[1,4] = pos[1] + l
  vert[2,4] = pos[2] - l

  vert[0,5] = pos[0] + l
  vert[1,5] = pos[1] - l
  vert[2,5] = pos[2] - l
 
  vert[0,6] = pos[0] - l
  vert[1,6] = pos[1] - l
  vert[2,6] = pos[2] - l

  vert[0,7] = pos[0] - l
  vert[1,7] = pos[1] + l
  vert[2,7] = pos[2] - l

  
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



;----------------------------------------------------------------------------
pro Sphere, vert, poly, n, pos, radius

   t = 0.0
   tinc = (1.*!PI)/float(n)

   p = 0.0
   pinc = (2.*!PI)/float(n)
  
   vert = fltarr(3, (n-1)*n + 2)
   
   ; top vertex

   vert[0,0] = pos[0]+0
   vert[1,0] = pos[1]+0
   vert[2,0] = pos[2]+radius

   ; bottom vertex
      
   vert[0,1] = pos[0]+0
   vert[1,1] = pos[1]+0
   vert[2,1] = pos[2]-radius
      
   t = t + tinc    
   i = 2
   l = 1
   m = 1
   
   ; side vertices
   
   while (m le n-1) do begin
     sint = sin(t)
     cost = cos(t)
     sinp = sin(p)
     cosp = cos(p)
     
     vert[0,i] = pos[0] + float(radius) * sint*cosp
     vert[1,i] = pos[1] + float(radius) * sint*sinp
     vert[2,i] = pos[2] + float(radius) * cost
 
     i = i + 1
     p = p+pinc     
     l = l +1
     if (l gt n) then begin
       l = 1
       p = 0.0
       t = t + tinc
       m = m + 1
     end   
   end   
    
    
   n = long(n)   
   poly = lonarr( (1+3)*n*2  + (1+4)*n*(n-2) )   
   
   ; top polygons
   
   j = long(0)
   for i=0, n-1 do begin
      poly[j]   = 3
      poly[j+1] = 0
      poly[j+2] = 2 + i
      poly[j+3] = 2 + i + 1
      
      if (i eq (n-1)) then poly[j+3] = 2   
      j = j+4
   end 
   
   ; side polygons
    
   for m = 1, n-2 do begin
     for i = 0, n-1 do begin
       poly[j]   = 4
       poly[j+1] = 2 + (m-1)*n + i        ; high
       poly[j+2] = 2 + (m  )*n + i        ; low
       poly[j+3] = 2 + (m  )*n + i + 1    ; low
       poly[j+4] = 2 + (m-1)*n + i + 1    ; high
       
       if (i eq (n-1)) then begin
         poly[j+3] = 2 + (m  )*n + 0 
         poly[j+4] = 2 + (m-1)*n + 0        
       end       
       j = j+5
     end
   end

   ; bottom polygons
 
   m = n - 1  
   for i=0, n-1 do begin
      poly[j]   = 3
      poly[j+1] = 2 + (m-1)*n + i
      poly[j+2] = 1
      poly[j+3] = 2 + (m-1)*n + i + 1
      
      if (i eq (n-1)) then poly[j+3] =  2 + (m-1)*n    
      j = j+4
   end
   
end
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
pro Cylinder, verts, poly, n, pos0, pos1, radius
    
    ; generate base
    l = (pos1 - pos0)   
    ls = sqrt(l[0]^2+ l[1]^2+ l[2]^2)
    if (ls eq 0) then begin
      print, 'Cylinder - pos0 is equal to pos1, returning...'
      return
    end

    l = l/ls    
    
    ; rotation about the y axis
    sinty = l[0]
    costy = sqrt( 1 - sinty^2)
    
    ; rotation about the x axis
    sintx = l[1]
    costx = sqrt( 1 - sintx^2)
   
    v = fltarr(3,n)
    t = 0.0
    tinc = (2.*!PI)/float(n)
   
    for i=0, n-1 do begin
       v[0,i] = radius*cos(t)	     ; x    
       v[1,i] = radius*sin(t)  		; y
       v[2,i] = 0.0                  ; z      
            
       ; rotates about the y axis      
       v2 = v[2,i]*costy - v[0,i]*sinty
       v0 = v[0,i]*costy + v[2,i]*sinty
       
       v[2,i] = v2
       v[0,i] = v0

       ; rotates about the x axis       
       v2 = v[2,i]*costx - v[1,i]*sintx
       v1 = v[1,i]*costx + v[2,i]*sintx
       
       v[2,i] = v2
       v[1,i] = v1
       
       t = t+tinc  
    end

    verts = fltarr(3, 2*n)

    ; translate
    
    for i=0, n-1 do begin
        verts[*,i] = v[*,i] + pos1
        verts[*,i+n] = v[*,i] + pos0
    end    
    
    poly = lonarr((1+n)*2 + (1+4)*n)
  
    ; top
    poly[0] = n
    for i=1,n do poly[i] = i - 1
    
    ;base
    j = n+1
    poly[j] = n
    for i=1,n do poly[j+i] = 2*n  - i

    ;faces
    
    j = 2*(n+1) 
    for i=0, n-2 do begin
       poly[j] = 4
       poly[j+1] = i           ; top 
       poly[j+2] = n+i         ; base
       poly[j+3] = n+i+1       ; base
       poly[j+4] = i+1         ; top
       j = j+5
    end
    poly[j] = 4
    poly[j+1] = n-1         ; top 
    poly[j+2] = 2*n - 1     ; base
    poly[j+3] = n           ; base
    poly[j+4] = 0           ; top
  
end
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
pro Cone,verts,poly,n, pos0, pos1, radius

     ; generate base
     l = (pos1 - pos0)   
     ls = sqrt(l[0]^2+ l[1]^2+ l[2]^2)
     if (ls eq 0) then begin
       print, 'Cylinder - pos0 is equal to pos1, returning...'
       return
     end

     l = l/ls    
    
     ; rotation about the y axis
     sinty = l[0]
     costy = sqrt( 1 - sinty^2)
    
     ; rotation about the x axis
     sintx = l[1]
     costx = sqrt( 1 - sintx^2)

     v = fltarr(3,n)
     t = 0.0
     tinc = (2.*!PI)/float(n)
   
     for i=0, n-1 do begin
        v[0,i] = radius*cos(t)	     ; x    
        v[1,i] = radius*sin(t)  	; y
        v[2,i] = 0.0                 ; z      
            
        ; rotates about the y axis      
        v2 = v[2,i]*costy - v[0,i]*sinty
        v0 = v[0,i]*costy + v[2,i]*sinty
       
        v[2,i] = v2
        v[0,i] = v0

        ; rotates about the x axis       
        v2 = v[2,i]*costx - v[1,i]*sintx
        v1 = v[1,i]*costx + v[2,i]*sintx
       
        v[2,i] = v2
        v[1,i] = v1
       
        t = t+tinc  
     end
    
     ; verts = fltarr(3, number of vertices)
     ; so in our case we have n+1 vertices
     
     	verts = fltarr(3,n+1)
	
	; tip of the cone vertex
	verts[*,0] = pos1[*]
	
	; base vertices
    
     for i=1, n do begin
        verts[*,i] = v[*,i-1] + pos0
     end    
	
	; poly = lonarr(sum for all polygons i of 1+number of vertices on polygon i) 
	; so in our case we have (3+1)*n, n 3 vertices poligon and (n+1)*1, one n vertices polygons
	
	poly = lonarr(4*n+(n+1))             
	i = 0
	
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


Set_Plot, 'Z', /Copy
loadct, 1
Device, Set_Resolution = [640,480]


set_shading, gouraud = 1, reject = 1

Erase
Scale3, xrange = [-1,1], yrange =[-1,1], zrange = [-1,1]


; Desenha o Cilindro

;pos0 = [ 0.0, -0.9, -0.9] 
;pos1 = [ 0.0, 0.3, 0.3]
;Cylinder, verts, poly, 30, pos0, pos1, 0.2
;dummy = Polyshade(verts, poly, /t3d)


; Desenha o Cone

;pos0 = pos1
;pos1 = [0.0,0.9,0.9] 
;Cone, verts, poly, 30, pos0, pos1, 0.4
;dummy = Polyshade(verts, poly, /t3d)

; Desenha as esferas

;pos0 = [0.0,0.0,0.0]
;Sphere, verts, poly, 30, pos0, 0.5
;dummy = Polyshade(verts, poly, /t3d)

;pos0 = [0.5,0.0,0.0]
;Sphere, verts, poly, 30, pos0, 0.3
;dummy = Polyshade(verts, poly, /t3d)

;pos0 = [-0.5,0.0,0.0]
;Sphere, verts, poly, 30, pos0, 0.3
;dummy = Polyshade(verts, poly, /t3d)


; Desenha o cubo

pos0 = [0.0,0.0,0.0]
Cube, verts, poly, pos0, 0.5
dummy = Polyshade(verts, poly, /t3d)
plots, verts, /t3d, PSYM = 3 

; Visualisation Cube Faces

plots, -1,-1,-1, color = 255, /t3d
plots, -1,-1, 1, /continue, color = 255, /t3d
plots, -1, 1, 1, /continue, color = 255, /t3d
plots, -1, 1,-1, /continue, color = 255, /t3d
plots, -1,-1,-1, /continue, color = 255, /t3d

plots, -1,-1,-1, color = 255, /t3d
plots,  1,-1,-1, color = 255, /t3d, /continue

plots, -1,-1, 1, color = 255, /t3d
plots,  1,-1, 1, color = 255, /t3d, /continue

plots, -1, 1, 1, color = 255, /t3d
plots,  1, 1, 1, color = 255, /t3d, /continue

plots, -1, 1,-1, color = 255, /t3d
plots,  1, 1,-1, color = 255, /t3d, /continue


plots, 1,-1,-1, color = 255, /t3d
plots, 1,-1, 1, /continue, color = 255, /t3d
plots, 1, 1, 1, /continue, color = 255, /t3d
plots, 1, 1,-1, /continue, color = 255, /t3d
plots, 1,-1,-1, /continue, color = 255, /t3d


image = TVRD()

Set_Plot, 'MAC'
window, /free, xsize = 640, ysize = 480
tv, image

print, 'Done!'

end