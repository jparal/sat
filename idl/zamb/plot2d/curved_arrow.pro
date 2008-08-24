;--------------------------------------------------------------------------------------------------------------
; pro curved_arrow
;--------------------------------------------------------------------------------------------------------------
; Defines the vertex and connection list for an arrow following the path specified by
; 
;--------------------------------------------------------------------------------------------------------------

pro curved_arrow, vert, poly, fline, $
                 HANG = hang, HSIZE = hsize, RATIO = asp_ratio

  np = N_Elements(fline[0,*])
  
  if (np lt 2) then begin
    vert = [fline[0,*]]
    poly = [2,0,0]
  end else begin
    x0 = float(fline[0,np-2])
    y0 = float(fline[1,np-2])
    x1 = float(fline[0,np-1])
    y1 = float(fline[1,np-1])
  
    dx = x1-x0
    dy = y1-y0

    l = sqrt(dx^2+dy^2)
    if (l eq 0.0) then begin    
      vert = fline    
      poly = [np,lindgen(np)]
    end else begin
      
      vert = fltarr(2,np+2)    
      vert[*,0:np-1] = fline
      poly = [np,lindgen(np),2,np-1,np,2,np-1,np+1]

      if (N_Elements(hsize) eq 0) then rl = 0.15*2*np*l $ ; aprox 0.2 of the total length
      else rl = hsize
      
   ;   help, rl
      
      if (N_Elements(hang) eq 0 ) then begin  
      ; default is 25 deg.
        cosa = 0.9063078
        sina = 0.4226183  
      end else begin
        cosa = cos(hang)
        sina = sin(hang)
      end

      if (N_Elements(asp_ratio) eq 0) then begin
        xratio = 1
        yratio = 1
      end else begin
        if (asp_ratio lt 1.0) then begin
          xratio = 1
          yratio = 1/float(asp_ratio)
        end else begin
          xratio = float(asp_ratio)
          yratio = 1
        end
      end

      dx = dx/l      ; dx = cos(vect_ang)
      dy = dy/l      ; dy = sin(vect_ang)
      
      vert[0,np] = x1 - xratio*rl*(dx*cosa + dy*sina)
      vert[1,np] = y1 - yratio*rl*(dy*cosa - dx*sina)
  
      vert[0,np+1] = x1 - xratio*rl*(dx*cosa - dy*sina)
      vert[1,np+1] = y1 - yratio*rl*(dy*cosa + dx*sina) 
    end
  end

end
