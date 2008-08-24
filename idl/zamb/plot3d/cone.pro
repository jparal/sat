;----------------------------------------------------------------------------
function get_cone_circle, np, radius, normal,  pos
    
    
    v = dblarr(3,np)  
    v0= dblarr(3)

    t = 0.0
    tinc = (2.*!PI)/float(np)

    n0 = [0.,0.,1.] 
    n1 = normal
    
    if (total(n1*n1) eq 0.) then n1 = n0

    ;print, 'n0, ', mod_vect(n0)
    ;print, 'n1, ', mod_vect(n1)

    n = crossp(n0,n1)

    cost = dotp(n0,n1)
    sint = -mod_vect(n)
    
    ;print, ' sint ', sint
    ;print, ' cost ', cost
    ;print, ' 1  = ', sint^2 + cost^2
    
    if (sint ne 0.) then n = n/abs(sint)
    
    ;print, 'get_tube_circle'
      
    for i=0, np-1 do begin
       v0[0] = radius*cos(t)	; x    
       v0[1] = radius*sin(t)	; y
       v0[2] = 0.0              ; z                               
       t = t+tinc         

       ;print, 'i, dist ', i,mod_vect(v0[*])
       
       if (sint ne 0) then begin
           v0 = v0*cost + n*dotp(n,v0)*(1-cost) + crossp(v0,n) * sint
       end else if (cost eq -1) then begin
           ; down cilinder 
           ; erro
           ; print, 'Warning, possible error...'
           v0 = -v0
       end   

       ;print, 'i, dist after rotation', i,mod_vect(v0[*])
                
       v[*,i] = v0
       
    end
    
 
    ; translate
    
    v[0,*] = v[0,*] + pos[0] 
    v[1,*] = v[1,*] + pos[1]
    v[2,*] = v[2,*] + pos[2]

    return, v
end 

pro Cone,verts,poly, n, pos0, pos1, radius, $
             ASPECTRATIO = coneratio
    
     if N_Elements(coneratio) eq 0 then coneratio = [1.,1.,1.] 
    
     aspectratio = coneratio/MAX(coneratio) 
      
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
     
     v = get_cone_circle(n,radius,l, [0.,0.,0.] )
     
     ; correct aspect ratio
     
     v[*,0] = v[*,0]*aspectratio[0]
     v[*,1] = v[*,1]*aspectratio[1]
     v[*,2] = v[*,2]*aspectratio[2]
      
     
       
       
     ; verts = fltarr(3, number of vertices)
     ; so in our case we have n+1 vertices
     
     	verts = fltarr(3,n+1)
	
	; tip of the cone vertex
	verts[*,0] = pos1
	
	; base vertices
    
     for i=0, n-1 do begin
        verts[*,i+1] = v[*,i] + pos0
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
