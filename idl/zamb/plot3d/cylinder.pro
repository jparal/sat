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
