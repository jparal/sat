;-------------------------------------------------- LaserCentroid2D ---
; Returns an array of points that follow
; the centroid of a laser pulse
;----------------------------------------------------------------------
pro Centroid2D, Data2D, cvert, cpoints, DIRECTION = Direction, WAIST = Waist, MINVAL = MinVal, $
                          XAXIS = XAxisData, YAXIS = YAxisData
                          
  If N_Params() ne 3 then begin
    res = Error_Message('Invalid number of parameters')
    return  
  end
  
  if N_Elements(Data2D) eq 0 then begin
    res = Error_Message('Invalid Data')
    return  
  end
  
  S = Size(Data2D)
  
  if (S[0] ne 2) then begin
    res = Error_Message('DATA is not 2 - Dimensional')
    return
  end
  
  nx0 = S[1]
  nx1 = S[2]
  
;  Data = abs(Data2D)

  DataMax = MAX(Data2D, MIN =DataMin)
  if (DataMin lt 0.0) then begin
    res = Error_Message('All elements of DATA must be >= 0.0.'+$
                        ' Try taking the centroid of the absolute value of the data')
    return
  end
   
  ; Default Axis
      
  If N_Elements(XAxisData) eq 0 then XAxisData = -1. + IndGen(nx0)*2.0/(nx0-1) 
  If N_Elements(YAxisData) eq 0 then YAxisData = -1. + IndGen(nx1)*2.0/(nx1-1) 

  ; DIRECTION
  ;
  ; The parameter specifies the main propagation direction of the laser pulse
  ; 0 - along x axis
  ; 1 - along y axis

  if (N_Elements(Direction) eq 0) then Direction = 0

  ; MINVAL
  ;
  ; The minimum value of the field to be considered for generating a centroid point
  ; If not specified defaults to 10% of the maximum value
  
  If (N_Elements(MinVal) eq 0) then begin
    MinVal = DataMin + 0.10 * (DataMax - DataMin) 

    print, 'Centroid 2D'
    print, '----------------------------'
    print, 'DataMax ', DataMax
    print, 'DataMin ', DataMin
    print, 'MinVal  ', MinVal
  end

  case (Direction) of
     1: begin
          cvert = DblArr(2,nx1)
          cpoints = [0l]
          x0 = LIndGen(nx0)
          i = 0l
          j = 0l
          while (i lt nx1-1) do begin
             while (i lt nx1-1) and (Max(Data2D[*,i]) le MinVal) do i = i+1l
              
             if (i lt nx1-1) then begin
   
               j0 = j          
   
               while ((i lt nx1-1) and (Max(Data2D[*,i]) gt MinVal)) do begin
                  cx0 = Total(reform(Data2D[*,i])*x0, /double)/total(reform(Data2D[*,i]), /double)
                  cx1 = i
                  cvert[0,j] = cx0
                  cvert[1,j] = cx1
                  
                  j = j+1l
                  i = i+1l
               end
               
               np = j-j0
               
               if (np gt 0) then begin
         ;        print, 'Segment, j0, j, np', j0, j, np
                 cpoints = [ cpoints, np, lindgen(np) + j0 ] 
               end 
         ;      print, ' Current i ', i             
            end
          end                  
          if (j gt 1) then cvert = cvert[*,0:j-1]
        end
     0: begin
          cvert = DblArr(2,nx0)
          cpoints = [0l]
          x1 = LIndGen(nx1)
          i = 0l
          j = 0l
          while (i lt nx0-1) do begin
             while (i lt nx0-1) and (Max(Data2D[i,*]) le MinVal) do i = i+1l
              
             if (i lt nx0-1) then begin
   
               j0 = j          
   
               while ((i lt nx0-1) and (Max(Data2D[i,*]) gt MinVal)) do begin
                  cx0 = i
                  cx1 = Total(reform(Data2D[i,*])*x1, /double)/total(reform(Data2D[i,*]), /double)
                  cvert[0,j] = cx0
                  cvert[1,j] = cx1
                  
                  j = j+1l
                  i = i+1l
               end
               
               np = j-j0
               
               if (np gt 0) then begin
                 cpoints = [ cpoints, np, lindgen(np) + j0 ] 
               end 
            end
          end 
          if (j gt 1) then cvert = cvert[*,0:j-1]
        end
  else: begin
          print, 'LaserCentroid2D, DIRECTION must be 0, or 1'
          return
        end
  end


  cvert[0,*] = XAxisData[0] + cvert[0,*]*(XAxisData[nx0-1] - XAxisData[0])/(nx0 - 1.)
  cvert[1,*] = YAxisData[0] + cvert[1,*]*(YAxisData[nx1-1] - YAxisData[0])/(nx1 - 1.)
  
end

;-------------------------------------------------- LaserCentroid3D ---
; Returns an array of points that follow
; the centroid of a laser pulse
;----------------------------------------------------------------------

pro Centroid3D, Data3D, cvert, cpoints, DIRECTION = Direction, WAIST = Waist, MINVAL = MinVal, $
                          XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
                          
  If N_Params() ne 3 then begin
    res = Error_Message('Invalid number of parameters')
    return  
  end
  
  if N_Elements(Data3D) eq 0 then begin
    res = Error_Message('Invalid Data')
    return  
  end
  
  S = Size(Data3D)
  
  if (S[0] ne 3) then begin
    res = Error_Message('DATA is not 3 - Dimensional')
    return
  end
  
  nx0 = S[1]
  nx1 = S[2]
  nx2 = S[3]
  
;  Data = abs(Data3D)

  DataMax = MAX(Data3D, MIN =DataMin)
  if (DataMin lt 0.0) then begin
    res = Error_Message('All elements of DATA must be >= 0.0.'+$
                        ' Try taking the centroid of the absolute value of the data')
    return
  end
 
  ; Default Axis
      
  If N_Elements(XAxisData) eq 0 then XAxisData = -1. + IndGen(nx0)*2.0/(nx0-1) 
  If N_Elements(YAxisData) eq 0 then YAxisData = -1. + IndGen(nx1)*2.0/(nx1-1) 
  If N_Elements(ZAxisData) eq 0 then ZAxisData = -1. + IndGen(nx2)*2.0/(nx2-1)

  ; DIRECTION
  ;
  ; The parameter specifies the main propagation direction of the laser pulse
  ; 0 - along x axis
  ; 1 - along y axis
  ; 2 - along z axis

  if (N_Elements(Direction) eq 0) then Direction = 0

  ; MINVAL
  ;
  ; The minimum value of the field to be considered for generating a centroid point
  ; If not specified defaults to 10% of the maximum value
  
  If (N_Elements(MinVal) eq 0) then begin
    MinVal = DataMin + 0.10 * (DataMax - DataMin) 

    print, 'Centroid 3D'
    print, '----------------------------'
    print, 'DataMax ', DataMax
    print, 'DataMin ', DataMin
    print, 'MinVal  ', MinVal
  end

  case (Direction) of
     2: begin
          cvert = DblArr(3,nx2)
          cpoints = [0l]
          x0 = LIndGen(nx0)
          x1 = LIndGen(nx1)
          i = 0l
          j = 0l
          while (i lt nx1-1) do begin
             while (i lt nx1-1) and (Max(Data3D[*,i,*]) le MinVal) do i = i+1l
              
             if (i lt nx1-1) then begin
   
               j0 = j          
   
               while ((i lt nx1-1) and (Max(Data3D[*,i,*]) gt MinVal)) do begin
                  totalx0 = reform(Total(Data3D[*,*,i], 1, /double))
                  totalx1 = reform(Total(Data3D[*,*,i], 2, /double))
            
                  cx0 = Total(totalx1*x0, /double)/Total(totalx1, /double)
                  cx1 = Total(totalx0*x1, /double)/Total(totalx0, /double)
                  cx2 = i
                  cvert[0,j] = cx0
                  cvert[1,j] = cx1
                  cvert[2,j] = cx2
                  
                  j = j+1l
                  i = i+1l
               end
               
               np = j-j0
               
               if (np gt 0) then begin
         ;        print, 'Segment, j0, j, np', j0, j, np
                 cpoints = [ cpoints, np, lindgen(np) + j0 ] 
               end 
         ;      print, ' Current i ', i             
            end
          end 
          if (j gt 1) then cvert = cvert[*,0:j-1]                 
        end
     1: begin
          cvert = DblArr(3,nx1)
          cpoints = [0l]
          x0 = LIndGen(nx0)
          x2 = LIndGen(nx2)
          i = 0l
          j = 0l
          while (i lt nx1-1) do begin
             while (i lt nx1-1) and (Max(Data3D[*,i,*]) le MinVal) do i = i+1l
              
             if (i lt nx1-1) then begin
   
               j0 = j          
   
               while ((i lt nx1-1) and (Max(Data3D[*,i,*]) gt MinVal)) do begin
                  totalx0 = reform(Total(Data3D[*,i,*], 1,/double))
                  totalx2 = reform(Total(Data3D[*,i,*], 3, /double))
     
                  cx0 = Total(totalx2*x0, /double)/total(totalx2, /double)
                  cx1 = i
                  cx2 = Total(totalx0*x2, /double)/total(totalx0, /double)
                  cvert[0,j] = cx0
                  cvert[1,j] = cx1
                  cvert[2,j] = cx2
                  
                  j = j+1l
                  i = i+1l
               end
               
               np = j-j0
               
               if (np gt 0) then begin
         ;        print, 'Segment, j0, j, np', j0, j, np
                 cpoints = [ cpoints, np, lindgen(np) + j0 ] 
               end 
         ;      print, ' Current i ', i             
            end
          end 
          if (j gt 1) then cvert = cvert[*,0:j-1]                 
        end
     0: begin
          cvert = DblArr(3,nx0)
          ;waist = FltArr(3,nx0)
          cpoints = [0l]
          x1 = LIndGen(nx1)
          x2 = LIndGen(nx2)
          i = 0l
          j = 0l
          while (i lt nx0-1) do begin
             while (i lt nx0-1) and (Max(Data3D[i,*,*]) le MinVal) do i = i+1l
              
             if (i lt nx0-1) then begin
   
               j0 = j          
   
               while ((i lt nx0-1) and (Max(Data3D[i,*,*]) gt MinVal)) do begin
                  totalx1 = reform(Total(Data3D[i,*,*], 2, /double))
                  totalx2 = reform(Total(Data3D[i,*,*], 3, /double))
                  cx0 = i
                  cx1 = Total(totalx2*x1, /double)/total(totalx2, /double)
                  cx2 = Total(totalx1*x2, /double)/total(totalx1, /double)
                  cvert[0,j] = cx0
                  cvert[1,j] = cx1
                  cvert[2,j] = cx2
                  
                  j = j+1l
                  i = i+1l
               end
               
               np = j-j0
               
               if (np gt 0) then begin
         ;        print, 'Segment, j0, j, np', j0, j, np
                 cpoints = [ cpoints, np, lindgen(np) + j0 ] 
               end 
         ;      print, ' Current i ', i             
            end
          end 
          if (j gt 1) then cvert = cvert[*,0:j-1]
          ; waist = waist[0:j-1]                 
        end
  else: begin
          res = Error_Message('DIRECTION must be 0,1 or 2')
          return
        end
  end

  ; Convert cvert to axis units
  
  cvert[0,*] = XAxisData[0] + cvert[0,*]*(XAxisData[nx0-1] - XAxisData[0])/(nx0 - 1.)
  cvert[1,*] = YAxisData[0] + cvert[1,*]*(YAxisData[nx1-1] - YAxisData[0])/(nx1 - 1.)
  cvert[2,*] = ZAxisData[0] + cvert[2,*]*(ZAxisData[nx2-1] - ZAxisData[0])/(nx2 - 1.)
  
end


;---------------------------------------------------- Centroid ---
; Returns an array of points that follow
; the mass centroid along the direction specified
;----------------------------------------------------------------------

pro Centroid, Data, cvert, cpoints, DIRECTION = Direction, WAIST = Waist, MINVAL = MinVal, $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                        VALIDPOINTS = validpoints                        
  
  If N_Params() ne 3 then begin
    res = Error_Message('Invalid number of parameters')
    return  
  end
  
  if N_Elements(Data) eq 0 then begin
    res = Error_Message('Invalid Data')
    return  
  end
  
  s = Size(Data)
  
  case (s[0]) of 
        2: Centroid2D, Data, cvert, cpoints, DIRECTION = Direction, WAIST = Waist, MINVAL = MinVal, $
                        XAXIS = XAxisData, YAXIS = YAxisData
        3: Centroid3D, Data, cvert, cpoints, DIRECTION = Direction, WAIST = Waist, MINVAL = MinVal, $
                        XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
     else: begin
             res = Error_Message('Data must be 2 or 3 Dimensional')
             return
           end
  end  
  
end
