;--------------------------------------------------------------------------------------------------------------
; function vel_pos, t, pos
;--------------------------------------------------------------------------------------------------------------
; This function return the interpolated velocity at position
; pos (the parameter t is here for compatibility with the RK4 function) 
;--------------------------------------------------------------------------------------------------------------

function vel_pos, t, pos
   COMMON shared, NX, NY, minx, miny, LX, LY, vx, vy, dx, dy, maxl
  
   x = pos[0]
   y = pos[1] 
  
   i = (double(NX)-1)*(x-minx)/LX
   j = (double(NY)-1)*(y-miny)/LY 
   
   u = interpolate(vx,i,j)
   v = interpolate(vy,i,j)
   
   return, [u,v]
end

;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
; pro straight_arrow
;--------------------------------------------------------------------------------------------------------------
; Draws an arrow from x0,y0 to x1,y1. Coordinates are
; in Data space
;--------------------------------------------------------------------------------------------------------------

pro straight_arrow, pos0, pos1, _EXTRA=extrakeys, SOLID = solid, HSIZE = hsize, $
                    HANG = hang

  x0 = double(pos0[0])
  y0 = double(pos0[1])
  x1 = double(pos1[0])
  y1 = double(pos1[1])
  
  dx = x1-x0
  dy = y1-y0
  
  l = sqrt(dx^2+dy^2)
  
  if (l gt 0) then begin
  
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
    
    if Keyword_set(solid) then begin     
      plots, [x0, x0+dx*0.9], [y0,y0+dy*0.9], _EXTRA=extrakeys, /data
      polyfill, [x1,x2,x3], [y1,y2,y3], _EXTRA=extrakeys, /data
    endif else begin
      plots, [x0, x1], [y0,y1], _EXTRA=extrakeys, /data
      plots, [x1, x2], [y1,y2], _EXTRA=extrakeys, /data
      plots, [x1, x3], [y1,y3], _EXTRA=extrakeys, /data
    endelse
  
  endif  
end
;--------------------------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------------------------
; pro curve_arrow
;--------------------------------------------------------------------------------------------------------------
; Draws an arrow that follows the streamline of the field
; at the given position
;--------------------------------------------------------------------------------------------------------------

pro curve_arrow, pos, NSEGS = _qual, _EXTRA=extrakeys, HSIZE = hsize
  
  if (N_Elements(_qual)   eq 0) then _qual = 10
  if (N_Elements(hsize)   eq 0) then hsize = -0.15
   
  dt = 1.0/_qual
  nsteps = _qual
  
;  v = vel_pos(0.0,pos)
;  pos0 = pos-v
;  pos1 = pos+v
;  straight_arrow, pos0, pos1, NOCLIP =0, _EXTRA=extrakeys
  

  ; Backward part

  pos1 = pos  
  plots, pos1[0], pos1[1]
  for i=1, nsteps do begin
    vel1 = vel_pos(0.0,pos1)
    pos1 = RK4(pos1, vel1, 0.0, -dt, 'vel_pos', /double)
    plots, pos1[0], pos1[1], /continue, _EXTRA=extrakeys
  end 

  ; Forward part
 
  pos1 = pos
  plots, pos1[0], pos1[1]
  for i=1, nsteps do begin 
     vel1 = vel_pos(0.0,pos1)
     pos1 = RK4(pos1, vel1, 0.0, dt, 'vel_pos', /double)
     plots, pos1[0], pos1[1], /continue, _EXTRA=extrakeys 
  end 
  
; Draw arrow tip

   pos2 = pos1
   vel1 = vel_pos(0.0,pos1)
   pos1 = RK4(pos1, vel1, 0.0, dt, 'vel_pos', /double)

   vel1 = vel_pos(0.0,pos)
  
   hs = hsize * 2 * sqrt(vel1[0]^2+vel1[1]^2)
  
   straight_arrow, [pos2[0], pos2[1]], [pos1[0], pos1[1]], /data,  $
                  hsize = hs, _EXTRA=extrakeys   

end

;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
; pro oplot2Dvector
;--------------------------------------------------------------------------------------------------------------
; overplots the 2D vector field on the current data region
;--------------------------------------------------------------------------------------------------------------

pro oplot2Dvector, pvx, pvy, _EXTRA=extrakeys,$ 
                   NUMVECTS = NumberVectors, VECTDIST = VectorDistribution, $
                   STARTPOS = StartPositions, TYPE = PlotType, SCALETYPE = ScaleType, LREF = lref, $
                   COLOR = color, LENGTH = length, CT = ColorTable
                   
COMMON shared, NX, NY, minx, miny, LX, LY, vx, vy, dx, dy, maxl

; Initialize local variables and test the validity of the parameters
                  
s = size(*pvx)
if (s[0] ne 2) then begin
     newres = Dialog_Message("pvx must be a pointer to a 2D array", /Error)
     return 
end

NX = s[1]
NY = s[2]

s = size(*pvy)
if (s[0] ne 2) then begin
     newres = Dialog_Message("pvy must be a pointer to a 2D array", /Error)
     return 
end 

if (NX ne s[1]) or (NY ne s[2]) then begin
     newres = Dialog_Message("(*pvy) must have the same dimensions as (*pvx)", /Error)
     return 
end


x = !X.crange
y = !Y.crange

LX = x[1]-x[0]
minx = x[0]
maxx = x[1]
dx = LX/(NX-1) 

LY = y[1]-y[0]
miny = y[0]
maxy = y[1]
dy = LY/(NY-1)

; VECTDIST
;
; Vector distribution. This parameter allows you to choose between a regular distribution (0 - default) and a 
; random distribution (1)

if N_Elements(VectorDistribution) eq 0 then VectorDistribution = 0

; NUMVECTS
;
; Number of vectors to plot. This parameter allows you to define the number of vectors to plot. The default
; is 256. 

if N_Elements(NumberVectors) eq 0 then begin
  case VectorDistribution of  
     1: NumberVectors = 256 
  else: NumberVectors = [16,16]
  endcase
endif else begin
  s = size(NumberVectors) 
  if (s[0] eq 0) then begin   ; scalar provided
    case VectorDistribution of  
       1: NumberVectors = 1.0*NumberVectors 
    else: begin
            n = long(sqrt(NumberVectors))
            NumberVectors = [n,n]
          end
    endcase
  endif else begin
    if (s[1] ne 2) then begin
     newres = Dialog_Message("NUMVECTS must be a scalar or a 1D vector", /Error)
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
          StartPositions=randomu(seed, NumberVectors, 2)
          StartPositions[*,0] = minx + StartPositions[*,0]*LX
          StartPositions[*,1] = miny + StartPositions[*,1]*LY
          NV = NumberVectors
        end
  else: begin                           ; regular
          StartPositions = FltArr(NumberVectors[0]*NumberVectors[1], 2)
          k = long(0)
          for i = 0, NumberVectors[0] - 1 do begin
            x = minx + LX*(1.0+1.*i)/(1.*NumberVectors[0] + 1.0)
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

vx = *pvx
vy = *pvy

vel = DblArr(NV,2) 
for k= long(0), NV-1 do vel[k,*] = vel_pos(0.0, [StartPositions[k,0],StartPositions[k,1]])
l = sqrt(vel[*,0]^2+vel[*,1]^2)

if N_Elements(lref) eq 0 then begin
 lref = MAX(l)
end

maxl= lref

;maxl = 1.0

; LENGTH
;
; The scale length of the vectors. This parameter specifies the size of the vector with size LREF to be plotted
; as a percentage of the plot area (in data units). The default is 0.1

if N_Elements(length) eq 0 then begin
 length = 0.1
end



; --------------------------------------- New Routine -------------------------------------

ColorTable = 25
MaxColor = !D.Table_Size
 
numcolors = MaxColor - 9 

; Initializes the Display to work with 8 bit colors
truecol = 0 
  
case !D.Name of
    'PS' : begin
             device, Bits_per_Pixel=8
             defcolor = MaxColor - 8
             truecol = 0
           end
    'MAC': begin
            defcolor = MaxColor - 1
            device, get_visual_depth = thisDepth
            if thisDepth gt 8 then begin
              device, decomposed = 0
              truecol = 1
            end
           end
    'WIN': begin
            defcolor = MaxColor - 1
            device, get_visual_depth = thisDepth
            if thisDepth gt 8 then begin
              device, decomposed = 0
              truecol = 1
            end
           end      
     else: begin
            truecol = 0 ; Assume truecol = false
             defcolor = MaxColor - 1
           end
endcase
  
; Loads Appropriate Color Table 
   
LoadCT, 0, /Silent
LoadCT, ColorTable, NColors = numcolors-1, /Silent
   
color_white  = LONG([255, 255, 255])
color_yellow = LONG([255, 255,   0])
color_cyan   = LONG([  0, 255, 255]) 
color_purple = LONG([191,   0, 191])
color_red    = LONG([255,   0,   0])
color_green  = LONG([  0, 255,   0])
color_blue   = LONG([ 63,  63, 255])
color_black  = LONG([  0,   0,   0])

TvLCT, color_white[0], color_white[1], color_white[2], MaxColor - 1
TvLCT, color_yellow[0],color_yellow[1],color_yellow[2], MaxColor - 2
TvLCT, color_cyan[0], color_cyan[1], color_cyan[2], MaxColor - 3
TvLCT, color_purple[0],color_purple[1],color_purple[2], MaxColor - 4
TvLCT, color_red[0],color_red[1],color_red[2], MaxColor - 5
TvLCT, color_green[0],color_green[1],color_green[2], MaxColor - 6
TvLCT, color_blue[0],color_blue[1],color_blue[2], MaxColor - 7
TvLCT, color_black[0],color_black[1],color_black[2], MaxColor - 8

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
           pos0 = StartPositions[k,*]-vel[k,*]
           pos1 = StartPositions[k,*]+vel[k,*]
           straight_arrow, pos0, pos1, COLOR = colors[k], NOCLIP =0, _EXTRA=extrakeys
         end   
       end

 else: begin   ; curved arrows
         vx = 0.5*(vx/maxl)*length*Min([LX,LY])
         vy = 0.5*(vy/maxl)*length*Min([LX,LY])         
         for k=long(0), NV-1 do begin

           curve_arrow, [StartPositions[k,0],StartPositions[k,1]] , COLOR = colors[k], $
                        NOCLIP = 0, _EXTRA=extrakeys    
         end

       end
endcase 

loadct, 0
                
end