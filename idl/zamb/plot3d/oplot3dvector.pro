;--------------------------------------------------------------------------------------------------------------
; function vel_pos, t, pos
;--------------------------------------------------------------------------------------------------------------
; This function return the interpolated velocity at position
; pos (the parameter t is here for compatibility with the RK4 function) 
;--------------------------------------------------------------------------------------------------------------

function vel_pos, t, pos
   COMMON shared, NX, NY, NZ, minx, miny, minz, LX, LY, LZ, vx, vy, vz, dx, dy, dz, maxl
  
   x = pos[0]
   y = pos[1]
   z = pos[2]

   i = (double(NX)-1)*(x-minx)/LX
   j = (double(NY)-1)*(y-miny)/LY 
   k = (double(NZ)-1)*(z-minz)/LZ 
  
   
   u = interpolate(vx,i,j,k)
   v = interpolate(vy,i,j,k)
   w = interpolate(vz,i,j,k)
   
   return, [u,v,w]
end

;--------------------------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------------------------
; pro streamline3D
;--------------------------------------------------------------------------------------------------------------
; Draws a polyline or tube that follows the streamline of the field
; at the given position
;--------------------------------------------------------------------------------------------------------------

pro streamline3D, pos, NSEGS = _qual, _EXTRA=extrakeys, LINE = line
  
  if (N_Elements(_qual)   eq 0) then _qual = 10
  if (N_Elements(line)    eq 0) then line = 0
   
  dt = 1.0/_qual
  nsteps = _qual
  
  points = fltarr(3,nsteps*2) 

  ; Backward part

  pos1 = pos  
;  plots, pos1[0], pos1[1]
  for i=1, nsteps do begin
    vel1 = vel_pos(0.0,pos1)
    pos1 = RK4(pos1, vel1, 0.0, -dt, 'vel_pos')
    points[*,nsteps-i] = pos1
;    plots, pos1[0], pos1[1], /continue, _EXTRA=extrakeys
  end 

  ; Forward part
 
  pos1 = pos
;  plots, pos1[0], pos1[1]
  for i=1, nsteps do begin 
     vel1 = vel_pos(0.0,pos1)
     pos1 = RK4(pos1, vel1, 0.0, dt, 'vel_pos')
     points[*,nsteps+i-1] = pos1
;     plots, pos1[0], pos1[1], /continue, _EXTRA=extrakeys 
  end 
  
  plots, points, _EXTRA = extrakeys, /t3d

end

;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
; pro oplot3Dvector
;--------------------------------------------------------------------------------------------------------------
; overplots the 3D vector field on the current data region
;--------------------------------------------------------------------------------------------------------------

pro oplot3Dvector, v, _EXTRA=extrakeys,$
                   XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $  
                   NUMVECTS = NumberVectors, VECTDIST = VectorDistribution, $
                   STARTPOS = StartPositions, TYPE = PlotType, SCALETYPE = ScaleType, LREF = lref, $
                   COLOR = color, LENGTH = length, CT = ColorTable
                   
COMMON shared, NX, NY, NZ, minx, miny, minz, LX, LY, LZ, vx, vy, vz, dx, dy, dz, maxl

if (!D.Name ne 'Z') then begin
  print, 'oPlot3Dvector only works in the Z-Buffer device'
  return
end

; Initialize local variables and test the validity of the parameters
                  
s = size(v)
if ((s[0] ne 4) or (s[1] ne 3)) then begin
     print, s
     newres = Dialog_Message("v must be a 3*3D array", /Error)
     return 
end

NX = s[2]
NY = s[3]
NZ = s[4]

vx = reform(v[0,*,*,*])
vy = reform(v[1,*,*,*])
vz = reform(v[2,*,*,*])

help, vx, vy, vz

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

print, 'LX,LY,LZ', LX,LY,LZ

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
     1: NumberVectors = 64 
  else: NumberVectors = [4,4,4]
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

; TYPE 
;
; The type of plot to make. This parameter allows you to choose between a plot curved arrows that follow the
; field lines (0-default), or straight arrows parallel to the field in the chosen position (1)

if N_Elements(PlotType) eq 0 then PlotType = 0

; SCALETYPE
;
; The type of representation to be used for the lenght of the vectors. This parameter allows you to chose 
; the between the following:
;
; 0 - The arrow size and the color are proportional to the field magnitude (default)
; 1 - Only the size is proportional to the field magnitude (plots using default color)
; 2 - Only the color is proportional to the field magnitude
; 3 - The size and the color are constant (plots using default color)

if N_Elements(ScaleType) eq 0 then ScaleType = 0

; LREF
;
; The reference length of the vectors in the field. The program uses this value to scale the lenght 
; of the vectors plotted. If not supplied the program autoscales to the maximum value in the data supplied.

; calculates the length of the vectors


vel = DblArr(3,NV) 
for k= long(0), NV-1 do vel[*,k] = vel_pos(0.0, reform(StartPositions[*,k]))
l = sqrt(vel[0,*]^2+vel[1,*]^2+vel[2,*]^2)

if N_Elements(lref) eq 0 then begin
 lref = MAX(l)
end

maxl= lref


; LENGTH
;
; The scale length of the vectors. This parameter specifies the size of the vector with size LREF to be plotted
; as a percentage of the plot area (in data units). The default is 0.1

if N_Elements(length) eq 0 then begin
 length = 0.2
end


; --------------------------------------- New Routine -------------------------------------

   MaxColor = !D.Table_Size
   numcolors=(MaxColor - 9)

; COLOR = color
;
; The color to use when plotting the vectors with a single color. The Default is white, -1 means black

if N_Elements(color) eq 0 then begin
 color = MaxColor -1
end

if (color lt 0) then color = MaxColor - 9 - color


; ------------------------------- Vector Plot --------------------------------------------------

; Generates the color scale

if ((scaletype eq 1) or (scaletype eq 3)) then begin
     colors = 0.0* BytArr(NV) + color
endif else begin
     colors = bytscl(l/maxl, MAX = 1.0, TOP = numcolors-1)
endelse

case PlotType of
    1: begin    ; straight arrows
         vel = 0.5*(vel/maxl)*length*Min([LX,LY])
         
         for k=long(0), NV-1 do begin         
           pos0 = StartPositions[*,k]-vel[*,k]
           pos1 = StartPositions[*,k]+vel[*,k]
           straight_arrow, pos0, pos1, COLOR = colors[k], NOCLIP =0, _EXTRA=extrakeys
         end   
       end

 else: begin   ; curved arrows
         print, 'beggining, Curved Arrows'
        
         LBOXMAX = Max([LX,LY,LZ])
         vx = 0.5*(vx/maxl)*length*LBOXMAX
         vy = 0.5*(vy/maxl)*length*LBOXMAX       
         vz = 0.5*(vz/maxl)*length*LBOXMAX       
         
         for k=long(0), NV-1 do begin
           
           streamline3D, StartPositions[*,k], COLOR = colors[k], $
                        NOCLIP = 0, _EXTRA=extrakeys    
         end
         print, 'ended, Curved Arrows'

       end
endcase 
                
end