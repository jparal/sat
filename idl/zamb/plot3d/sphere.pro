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
