;--------------------------------------------------------------------------------------------------------------
; pro straight_arrow
;--------------------------------------------------------------------------------------------------------------
; Defines the vertex and connection list for an arrow connecting x0,y0 to x1,y1
;--------------------------------------------------------------------------------------------------------------

pro straight_arrow, vert, poly, pos0, pos1, _EXTRA=extrakeys, HSIZE = hsize, $
                    HANG = hang

  x0 = float(pos0[0])
  y0 = float(pos0[1])
  x1 = float(pos1[0])
  y1 = float(pos1[1])
  
  dx = x1-x0
  dy = y1-y0
  
  l = sqrt(dx^2+dy^2)
  
  if (l gt 0.0) then begin
      
    ; arrow head angle
    
    if (N_Elements(hang) eq 0 ) then begin  
      ; default is 25 deg.
      cosa = 0.9063078
      sina = 0.4226183  
    endif else begin
      cosa = cos(hang)
      sina = sin(hang)
    endelse
  
    ; arrow head size (in relation to the arrow size)
  
    if (N_Elements(hsize) eq 0 ) then begin
      rl = 0.15
    endif else begin
      if (hsize gt 0) then rl = hsize $
      else rl = (-hsize)/l
    endelse
  
    x2 = x1 - rl*(dx*cosa + dy*sina)
    y2 = y1 - rl*(dy*cosa - dx*sina)
  
    x3 = x1 - rl*(dx*cosa - dy*sina)
    y3 = y1 - rl*(dy*cosa + dx*sina) 
  
    vert = [[x0,y0], [x1,y1], [x2,y2], [x3,y3]]
    poly = [2,0,1,2,1,2,2,1,3]
  
  end else begin
    vert = [[x0,y0]]
    poly = [2,0,0]
  end  
end
;--------------------------------------------------------------------------------------------------------------
