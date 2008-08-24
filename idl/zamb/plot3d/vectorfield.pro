;**********************************************************************
;******************************************** Vector Field Routines ***
;**********************************************************************
 
;---------------------------------------------- VectorField_vel_pos ---
; This function return the interpolated velocity at position
; pos (the parameter t is here for compatibility with the RK4 function) 
;----------------------------------------------------------------------

function VectorField_vel_pos, t, pos
   
   COMMON VectorField_Shared,$
                  NX, NY, NZ, $		 	; Array dimensions
                  minx, miny, minz, $   	; Minimum positions 
                  LX, LY, LZ, $			; Dimensions
                  pvx, pvy, pvz  		; pointers to velocity arrays
  
   x = pos[0]
   y = pos[1]
   z = pos[2]

   i = (double(NX)-1)*(x-minx)/LX
   j = (double(NY)-1)*(y-miny)/LY 
   k = (double(NZ)-1)*(z-minz)/LZ 
  
   
   u = interpolate(*pvx,i,j,k)
   v = interpolate(*pvy,i,j,k)
   w = interpolate(*pvz,i,j,k)
   
   return, [u,v,w]
end
;----------------------------------------------------------------------

;----------------------------------------------------- streamvector ---
; Returns an array of points that follow
; the field line near/passing trough a given point
;----------------------------------------------------------------------

function streamvector, pos, lboxref, NSEGS = _qual, _EXTRA=extrakeys
  
  if (N_Elements(_qual)   eq 0) then _qual = 10
  if (N_Elements(line)    eq 0) then line = 0
  if (N_Elements(double)  eq 0) then double = 0
   
  dt = lboxref/(2.0*_qual)
  nsteps = _qual
  
  points = fltarr(3,nsteps*2+1) 

  ; Backward part

  pos1 = pos  
  for i=1, nsteps do begin
    vel1 = VectorField_vel_pos(0.0,pos1)
    pos1 = RK4(pos1, vel1, 0.0, -dt, 'VectorField_vel_pos', DOUBLE = double)
    points[*,nsteps-i] = pos1
  end 

  ; central point
  
  points[*,nsteps] = pos

  ; Forward part
 
  pos1 = pos
  for i=1, nsteps do begin 
     vel1 = VectorField_vel_pos(0.0,pos1)
     pos1 = RK4(pos1, vel1, 0.0, dt, 'VectorField_vel_pos', DOUBLE = double)
     points[*,nsteps+i] = pos1
  end 
  
  return, points
end

;----------------------------------------------------------------------

;------------------------------------------------------ VectorField ---
; Generates the Vector Field model from the data in parameter v[3,*,*,*]
; outputs the result to the parameter oModelVectorField
;----------------------------------------------------------------------

pro VectorField, pv, oModelVectorField, _EXTRA=extrakeys,$
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $  
               NUMVECTS = NumberVectors, VECTDIST = VectorDistribution, $
               STARTPOS = StartPositions, GETSTARTPOS = GetStartPositions, $ 
               LREF = lref, RADIUS = radius, CT = FieldCT, $
               LENGTH = length, COLOR = Color, LINE = useline, TYPECOLOR = ColorType, $
               PROJ = doProjections, AXISRATIO = AxisScale


   COMMON VectorField_Shared,$
                  NX, NY, NZ, $		 	; Array dimensions
                  minx, miny, minz, $   	; Minimum positions 
                  LX, LY, LZ, $			; Dimensions
                  pvx, pvy, pvz       	; velocity arrays

  ; Initialize local variables and test the validity of the parameters
                  
   S = Size(pv)

   if ((s[0] ne 1) or (s[1] ne 3) or (s[2] ne 10)) then begin
     res = Dialog_Message('p must be an array of 3 pointers', /Error)
     return       
   end    

   s = Size(*(pv[0]))      
   if (s[0] ne 3) then begin
     res = Dialog_Message('Data pointed to must be a 3D array', /Error)
     return       
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]

   for i=1,2 do begin
     s =  Size(*(pv[i]))  
     if (s[0] ne 3) then begin
       res = Dialog_Message('Data pointed to must be a 3D array', /Error)
       return 
     end
     if ((s[1] ne NX) or (s[2] ne NY) or (s[3] ne NZ)) then begin
       res = Dialog_Message('all Data pointed to must have the same dimensions', /Error)
       return 
     end
   end

  pvx = pv[0]
  pvy = pv[1]
  pvz = pv[2]

  LX = XAxisData[NX-1]-XAxisData[0]
  minx = XAxisData[0]
  maxx = XAxisData[NX-1]
  dx = LX/(NX-1) 

  LY = YAxisData[NY-1]-YAxisData[0]
  miny = YAxisData[0]
  maxy = YAxisData[NY-1]
  dy = LY/(NY-1) 

  LZ = ZAxisData[NZ-1]-ZAxisData[0]
  minz = ZAxisData[0]
  maxz = ZAxisData[NZ-1]
  dz = LZ/(NZ-1) 

; LINE
;
; Use a line for the streamline instead of a tube.

if N_Elements(useline) eq 0 then useline = 0

; VECTDIST
;
; Vector distribution. This parameter allows you to choose between a regular distribution (0 - default) and a 
; random distribution (1)

  if N_Elements(VectorDistribution) eq 0 then VectorDistribution = 0

; NUMVECTS
;
; Number of vectors to plot. This parameter allows you to define the number of vectors to plot. The default
; is 125. 

  if N_Elements(NumberVectors) eq 0 then begin
    case VectorDistribution of  
       1: NumberVectors = 125 
    else: NumberVectors = [5,5,5]
    endcase
  endif else begin
    s = size(NumberVectors) 
    if (s[0] eq 0) then begin   ; scalar provided
      case VectorDistribution of  
         1: NumberVectors = 1.0*NumberVectors 
      else: begin
              NumberVectors = Abs(NumberVectors)
              n = long(NumberVectors^(1./3.))
              NumberVectors = [n,n,n]
            end
      endcase
    endif else begin
      if (s[1] ne 3) then begin
       newres = Dialog_Message("NUMVECTS must be a scalar or a 1D vector with 3 components", /Error)
       return
      endif  
    endelse
  endelse

; STARTPOS
;
; Vector starting points. Use this parameter to supply a vector containing the starting points to
; the vectors you wish to draw. If you set this parameter the program will ignore NUMVECTS and VECTDIST

  if N_Elements(StartPositions) eq 0 then begin
    case VectorDistribution of  
       1: begin                           ; random
            StartPositions=randomu(seed, 3, NumberVectors)
            StartPositions[0,*] = minx + StartPositions[0,*]*LX
            StartPositions[1,*] = miny + StartPositions[1,*]*LY
            StartPositions[2,*] = minz + StartPositions[2,*]*LZ
            NV = NumberVectors
          end
    else: begin                           ; regular
            StartPositions = FltArr(3,NumberVectors[0]*NumberVectors[1]*NumberVectors[2])
            k = long(0)
            for i = 0, NumberVectors[0] - 1 do begin
              x = minx + LX*(1.+1.*i)/(1.*NumberVectors[0] + 1.)
              for j = 0, NumberVectors[1] - 1 do begin
                y = miny + LY*(1.+1.*j)/(1.*NumberVectors[1] + 1. )
                  for l = 0, NumberVectors[2] -1 do begin
                    z = minz + LZ*(1.+1.*l)/(1.*NumberVectors[2] + 1. )
                    StartPositions[0,k] = x
                    StartPositions[1,k] = y
                    StartPositions[2,k] = z              
                    k = k+1
                  end
              end
            end
            NV = NumberVectors[0]*NumberVectors[1]*NumberVectors[2]
          end         
    endcase
  end

; COLORTYPE
;
; The type of color to be used for the lenght of the vectors. This parameter allows you to chose 
; the between the following:
;
; 0 - All the lines/tubes are drawn using the same color (see COLOR parameter)
; 1 - Each vector uses a random color from the color table (see CT parameter)
; 2 - The color is taken from the color table according to the vector magnitude (see CT parameter) 

  if N_Elements(ColorType) eq 0 then ColorType = 2

; CT
;
; Color table to be used for drawing the lines. 

 if N_Elements(fieldCT) eq 0 then fieldCT = 25

; COLOR
;
; Color to be used when drawing the lines in a single color (alpha is ignored)
 
 if N_Elements(color) eq 0 then color=[255b,0b,0b,255b]

; calculates the length of the vectors

vel = DblArr(3,NV) 
for k= long(0), NV-1 do vel[*,k] = VectorField_vel_pos(0.0, reform(StartPositions[*,k]))
l = sqrt(vel[0,*]^2+vel[1,*]^2+vel[2,*]^2)

; LREF
;
; The reference length of the vectors in the field. The program uses this value to scale the lenght 
; of the vectors plotted. If not supplied the program autoscales to the maximum value in the data supplied.


if N_Elements(lref) eq 0 then begin
 lref = MAX(l)
end

maxl= lref

; LENGTH
;
; The scale length of the vectors. This parameter specifies the size of the vector with size LREF to be plotted
; as a fraction of the plot area (in data units). The default is 0.3

if N_Elements(length) eq 0 then begin
 length = 0.5
end

; RADIUS
;
; The radius of the tube to draw. If positive is a percentage of the length of the vector being
; drawn. If negative its the percentage of length

if N_Elements(radius) eq 0 then begin
  radius = 0.
end 
 
if ((radius eq 0.) or (radius gt 1.) or (radius lt -1.)) then begin
  radius = 0.0008
end

; Generates the streamline points and adds result to oModelStream
  
  LBoxMax = Max([LX,LY,LZ])
  lboxRef = length * LBoxMax / maxl
           
; Generates colors for each vector 

  vcolor = BytArr(4,NV)
 
  case ColorType of
        2: begin                ; scaled color
             getCTcolors, fieldCT, RED = rr, GREEN = gg, BLUE = bb
             for k=long(0), NV-1 do begin       
               rci = byte(255.*l[k]/maxl)
               vcolor[*,k] = [rr[rci],gg[rci],bb[rci],255b]
             end
           end
        1: begin                ; random color
             getCTcolors, fieldCT, RED = rr, GREEN = gg, BLUE = bb
             for k=long(0), NV-1 do begin       
               rci = byte(255*randomu(seed))
               vcolor[*,k] = [rr[rci],gg[rci],bb[rci],255b]
             end
           end
    else : begin                ; fixed color
             vcolor[0,*] = color[0]
             vcolor[1,*] = color[1]
             vcolor[2,*] = color[2]
             vcolor[3,*] = 255b
           end
  end

           
  for k=long(0), NV-1 do begin       
       points = streamvector(StartPositions[*,k],lboxref, _EXTRA=extrakeys)    
       
       rad = abs(radius)*LBoxMax 

       if (radius gt 0) then rad = rad * l[k]/maxl

       Trajectory, points, oModelVectorField, COLOR = vcolor[*,k], $
                   XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                   RADIUS = rad, LINE = useline, /arrow, $
                   AXISRATIO = AxisScale, PROJ = doProjections
  end
 
end


; ---------------------------------------------------------------------
