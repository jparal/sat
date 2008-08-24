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
