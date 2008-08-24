;---------------------------------------------------------------------------------------------

function __vector2D_vel_pos, t,pos
   COMMON __Vector_2D_Shared, nx_1_lx, ny_1_ly, i0, j0, minx, miny, pvx, pvy 

   i = i0 + nx_1_lx*(pos[0]-minx)
   j = j0 + ny_1_ly*(pos[1]-miny) 
   
   u = interpolate(*pvx,i,j)
   v = interpolate(*pvy,i,j)
   
   return, [u,v]
end

;---------------------------------------------------------------------------------------------

function __vector2D_get_fline, pos0, scale, NSEGS = _qual

  if (N_Elements(scale) eq 0) then scale = 1.0

  if (N_Elements(_qual)   eq 0) then _qual = 10
  if (N_Elements(hsize)   eq 0) then hsize = -0.15
   
  dt = scale/_qual
  nsteps = _qual
  
  fline = FltArr(2,2*nsteps+1)  

  ; Backward part

  fline[*,0] = pos0
  pos1 = pos0
  for i=1, nsteps do begin
    vel1 = __vector2D_vel_pos(0.0,pos1)
    pos1 = RK4(pos1, vel1, 0.0, -dt, '__vector2D_vel_pos')
    fline[*,i] = pos1
  end 
  
  fline[*,0:nsteps] = reverse(fline[*,0:nsteps],2) 

  ; Forward part
 
  pos1 = pos0
  for i=1, nsteps do begin 
    vel1 = __vector2D_vel_pos(0.0,pos1)
    pos1 = RK4(pos1, vel1, 0.0, dt, '__vector2D_vel_pos')
    fline[*,nsteps+i] = pos1
  end 
  
  return, fline   
end

;---------------------------------------------------------------------------------------------

pro Vector2D, pField, $					; pointer to 2D vector field
              oModel, $					; IDLgrModel to Hold the result
              XAXIS = xaxis,YAXIS = yaxis,$ 	; Axis Information
              XRANGE = xrange,YRANGE = yrange,$ ; Range Information
              NUMVECTS = NumberVectors, $		; Number of vectors to plot 
              RANDOMDIST = RandomDist, $		; Use random initial positions
              STARTPOS = StartPositions, $		; Starting Positions of vectors
              TYPE = PlotType, $			; Plot Type
              SCALETYPE = ScaleType, $		; Scale Type
              LREF = lref, $				; Reference Length
              COLOR = color, $				; Color for the vectors
              THICK = linethick, $			; Line thickness for the vectors
              LENGTH = length, $			; 
              CT = ColorTable				; Color Table number (for color index)
              
   COMMON __Vector_2D_Shared, nx_1_lx, ny_1_ly, i0, j0, minx, miny, pvx, pvy 

;##########################################################################################

  ; Check Data
  
  if (N_Elements(pField) ne 2) then begin
    res = Error_Message('pField must be a two element array of pointers')
    return
  end

  if (not ptr_valid(pField[0])) or (not ptr_valid(pField[1])) then begin
    res = Error_Message('Invalid pointer, pField')
    return
  end
  
  type0 = size(*pField[0], /type)
  type1 = size(*pField[1], /type)

  if (type1 ne type0) then begin
    res = Error_Message('pField must point to two fields of the same numeric type')
    return
  end

  if (type1 lt 1) or (type1 gt 5) then begin
     res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                         'Precision Floating Point')
     return
  end

  s0 = size(*pField[0], /n_dimensions)
  s1 = size(*pField[1], /n_dimensions)
 
  if ((s0 ne 2) or (s1 ne 2)) then begin
    res = Error_Message('Both datasets must be two dimensional')
    return
  end  

  s = size(*pField[0], /dimensions)
  nx = s[0]
  ny = s[1]  

  if ((nx lt 3) or (ny lt 3)) then begin
    res = Error_Message('Data must be at least 3x3')
    return
  end  

  s = size(*pField[1], /dimensions)
  nx1 = s[0]
  ny1 = s[1]  
  
  if ((nx ne nx1) or (ny ne ny1)) then begin
    res = Error_Message('Both datasets must have the same dimensions')
    return
  end
 
  ; Check Axis
   
  if (n_elements(xaxis) eq 0) then xaxis = findgen(nx) $
  else begin
    if (n_elements(xaxis) ne nx) then begin
      res = Error_Message('XAXIS must have the same number of elements as the first dimension of data')
      return
    end
  end

  if (n_elements(yaxis) eq 0) then yaxis = findgen(ny) $
  else begin
    if (n_elements(yaxis) ne ny) then begin
      res = Error_Message('YAXIS must have the same number of elements as the second dimension of data')
      return
    end
  end

  ; Check Ranges
  
  xmin = min(xaxis, max = xmax)
  ymin = min(yaxis, max = ymax)
   
  if (N_Elements(xrange) eq 0) then begin
     xrange = [xmin,xmax]
  end else begin
    if (xrange[1] le xrange[0]) then begin
      res = Error_Message('Invalid XRANGE.')
      return
    end      
    if (xrange[0] lt xmin) then xrange[0] = xmin
    if (xrange[1] gt xmax) then xrange[1] = xmax
  end

  if (N_Elements(yrange) eq 0) then begin
     yrange = [ymin,ymax]
  end else begin
    if (yrange[1] le yrange[0]) then begin
      res = Error_Message('Invalid XRANGE.')
      return
    end      
    if (yrange[0] lt ymin) then yrange[0] = ymin
    if (yrange[1] gt ymax) then yrange[1] = ymax
  end
   
  xrange = float(xrange)
  yrange = float(yrange)
   
  dataXrange = long((NX-1)*(xrange-xmin)/(xmax-xmin))
  dataYrange = long((NY-1)*(yrange-ymin)/(ymax-ymin))   
   
  xrange = xaxis[dataXrange]
  yrange = yaxis[dataYrange]
  
  ; Check Model

  if (N_Elements(oModel) eq 0) then begin
    res = Error_Message('invalid oModel')
    return
  end

  if (not obj_valid(oModel)) then begin
    res = Error_Message('invalid oModel, not an object')
    return
  end

  if (obj_class(oModel) ne 'IDLGRMODEL') then begin
    res = Error_Message('invalid oModel class, not an IDLgrModel')
    return
  end

;##########################################################################################
  
   ; Initialize shared variables

   pvx = pField[0]
   pvy = pField[1]
   
   ; full range
   
;   i0 = 0
;   j0 = 0
;   minx = xaxis[0]
;   miny = yaxis[0]
;   lx = xaxis[nx-1]-xaxis[0]
;   ly = yaxis[nx-1]-yaxis[0]
;   nx_1_lx = (float(nx)-1.0)/lx
;   ny_1_ly = (float(ny)-1.0)/ly

   ; Sub range

   i0 = dataXrange[0]
   j0 = dataYrange[0]
   minx = xaxis[i0]
   miny = yaxis[j0]
   lx = float(xrange[1]-xrange[0])
   ly = float(yrange[1]-yrange[0])
   nx_1_lx = ((dataXrange[1]-dataXrange[0])-1.0)/lx
   ny_1_ly = ((dataYrange[1]-dataYrange[0])-1.0)/ly


;##########################################################################################

  ; Check Parameters

  ; RANDOMDIST
  
  if Keyword_Set(RandomDist) then vectordist = 1 $
  else vectordist = 0

  ; NUMVECTS
  
  if N_Elements(NumberVectors) eq 0 then begin
    case VectorDist of  
       1: NumberVectors = 400 
    else: NumberVectors = [20,20]
    endcase
  end else begin
    s = size(NumberVectors) 
    if (s[0] eq 0) then begin   ; scalar provided
      case VectorDist of  
         1: NumberVectors = 1.0*NumberVectors 
      else: begin
              n = long(sqrt(NumberVectors))
              NumberVectors = [n,n]
            end
      endcase
    end else begin
      if (s[1] ne 2) then begin
        res = Error_Message("NUMVECTS must be a scalar or a two element vector")
        return
      end  
    end
  end

  ; STARTPOS
 
  if N_Elements(StartPositions) eq 0 then begin
    case VectorDist of  
        1: begin                           ; random
             StartPositions=randomu(seed, NumberVectors, 2)
             StartPositions[*,0] = minx + StartPositions[*,0]*lx
             StartPositions[*,1] = miny + StartPositions[*,1]*ly
             NV = NumberVectors
           end
     else: begin                           ; regular
             StartPositions = FltArr(NumberVectors[0]*NumberVectors[1], 2)
             k = long(0)
             for i = 0, NumberVectors[0] - 1 do begin
               x = minx + lx*(1.0+1.*i)/(1.*NumberVectors[0] + 1.0)
               for j = 0, NumberVectors[1] - 1 do begin
                 y = miny + LY*(1.0+1.*j)/(1.*NumberVectors[1] + 1.0 )
                 StartPositions[k,0] = x
                 StartPositions[k,1] = y
                 k = k+1
               end
             end
             NV = NumberVectors[0]*NumberVectors[1]
           end         
     endcase
   end
  
   ; TYPE 
   ;
   ; The type of plot to make. This parameter allows you to choose between a plot curved arrows that follow the
   ; field lines (0-default), or straight arrows parallel to the field in the chosen position (1)

   if N_Elements(PlotType) eq 0 then PlotType = 0

   ; COLORTYPE
   ;
   ; 0 - The color index is proportional to the field magnitude 
   ; 1 - The color index is independent of the field magnitude (default)  

   if N_Elements(ScaleType) eq 0 then ScaleType = 1

   vel = FltArr(NV,2) 
   for k= 0L, NV-1 do vel[k,*] = __vector2D_vel_pos(0.0, reform(StartPositions[k,*]))
   l = sqrt(vel[*,0]^2+vel[*,1]^2)

   ; LREF
   ;
   ; The reference length of the vectors in the field. The program uses this value to scale the lenght 
   ; of the vectors plotted. If not supplied the program autoscales to the maximum value in the data supplied.

   ; calculates the length of the vectors

   if N_Elements(lref) eq 0 then begin
     lref = MAX(l)
   end
   
   if (lref le 0.0) then lref = 1.0
   
   ; LENGTH 
   ;
   ; The scale length of the vectors. This parameter specifies the size of the vector with size LREF to be plotted
   ; in units of the smallest axis range. The default is 0.1

   if N_Elements(length) eq 0 then length = 0.1

   ; CT
   ;
   ; Color table number for color indexing. Default is 13
   
   if N_Elements(ct) eq 0 then ct = 13
   
   ; COLOR
   
   if N_Elements(color) eq 0 then color = [0b,0b,0b] $
   else if (N_Elements(color) ne 3) then begin
     res = Error_Message('Invalid COLOR; must be in the form [R,G,B]')
     return
   end

   ; THICK
   
   If N_Elements(linethick) eq 0 then linethick = 1 

;##########################################################################################
       
   ; Generates the color scale

   if ((scaletype eq 1) or (scaletype eq 3)) then begin
     colors = BytArr(NV,3)
     colors[*,0] = color[0]
     colors[*,1] = color[1]
     colors[*,2] = color[2]
   end else begin
     color_idx = bytscl(float(l)/lref, MAX = 1.0)
     GetCTColors, CT, RED = r, GREEN = g, BLUE = b
     colors = [ [r(color_idx)],[g(color_idx)],[b(color_idx)]]   
   end
   
   scale = float(0.5*length*Min([lx,ly])/lref)
   ratio = lx/ly   
   ;plottype = 1
   
   case PlotType of
      1: begin    ; straight arrows
           vel = temporary(vel)*scale     
           for k=0, NV-1 do begin         
             pos0 = reform(StartPositions[k,*]-vel[k,*])
             pos1 = reform(StartPositions[k,*]+vel[k,*])
             straight_arrow, _EXTRA=extrakeys, vert, poly, pos0, pos1
             oPoly = OBJ_NEW('IDLgrPolyline', vert, POLYLINES = poly)
             oPoly -> SetProperty, COLOR = colors[k]
             oPoly -> SetProperty, THICK = linethick 
             oModel -> Add, oPoly
           end   
         end

   else: begin   ; curved arrows
           for k=long(0), NV-1 do begin
             fline = __vector2D_get_fline(reform(StartPositions[k,*]), scale)

             ;oPoly = OBJ_NEW('IDLgrPolyline', fline)
                 
             curved_arrow, vert, poly, fline , RATIO = ratio
             oPoly = OBJ_NEW('IDLgrPolyline', vert, POLYLINES = poly)
             
             oPoly -> SetProperty, COLOR = colors[k]
             oPoly -> SetProperty, THICK = linethick 
             oModel -> Add, oPoly
           end
                      
         end
   endcase       

end