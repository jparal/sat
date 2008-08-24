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
