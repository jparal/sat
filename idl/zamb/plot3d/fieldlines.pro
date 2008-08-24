;**********************************************************************
;********************************************* Field Lines Routines ***
;**********************************************************************
;--------------------------------------------------- getPointColors ---
; this function takes an array of N values scaled from 0. to 1. and
; returns an array with the colors from the color table CT
;----------------------------------------------------------------------
function getPointColors, val, CT, ALPHA = alpha
  S = Size(val)
  if (s[0] ne 1) then begin
    print, 'getPointColors - val must be a 1D array'
  end

  if N_Elements(alpha) eq 0 then alpha = 255b

  N = s[1]
  getCTcolors, CT, RED = rr, GREEN = gg, BLUE = bb

  valColor = BytArr(4, N)
  rci = bytscl(val, MIN = 0., MAX = 1.)
  valColor[0,*] = rr[rci]
  valColor[1,*] = gg[rci]
  valColor[2,*] = bb[rci]
  valColor[3,*] = alpha

  return, valColor

end

;----------------------------------------------- FieldLines_vel_pos ---
; This function return the interpolated velocity at position
; pos (the parameter t is here for compatibility with the RK4 function)
;----------------------------------------------------------------------
function FieldLines_vel_pos, t, pos

   COMMON FieldLines_Shared,$
                  NX, NY, NZ, $         ; Array dimensions
                  xmin, ymin, zmin, $   ; Minimum positions
                  LX, LY, LZ, $         ; Dimensions
                  pvx, pvy, pvz         ; pointer  to velocity arrays

   x = pos[0]
   y = pos[1]
   z = pos[2]
   i = (double(NX)-1)*(x-xmin)/LX
   j = (double(NY)-1)*(y-ymin)/LY
   k = (double(NZ)-1)*(z-zmin)/LZ


   u = interpolate(*pvx,i,j,k, CUBIC = -0.5)
   v = interpolate(*pvy,i,j,k, CUBIC = -0.5)
   w = interpolate(*pvz,i,j,k, CUBIC = -0.5)

   return, [u,v,w]
end
;----------------------------------------------------------------------
;----------------------------------------------------- GenFieldLines ---
; Returns an array of points that follow
; the field line near/passing trough a given point. Stops when leaving the box
;----------------------------------------------------------------------
function GenFieldLines, pos, xmin, xmax, ymin, ymax, zmin, zmax, $
                     lboxref, $
                     NSEGS = _qual, DOUBLE = double, LOCALVALUES = lvalues, $
                     ACCURACY = accuracy
  
  ; NSEGS
  ;
  ; Number of segments to draw in each direction (total number of segments is
  ; twice this number)

  if (N_Elements(_qual)    eq 0) then _qual = 50

  ; DOUBLE
  ;
  ; Set this to zero to use single precision for the calculation of the field
  ; lines

  if (N_Elements(double)   eq 0) then double = 1

  ; ACCURACY
  ;
  ; Number of intermediate steps between to consecutive points of the field line
  ; The default is one intermediate step

  if (N_Elements(accuracy) eq 0) then accuracy = 5

  accuracy = long(accuracy)
  if (accuracy lt 0) then accuracy = 0

  dt = lboxref/(2.0 * _qual * (accuracy + 1) )
  nsteps = _qual

  points = fltarr(3,nsteps*2+1)
  ; Backward part
  pos1 = pos
  backi = 0
  for i=1, nsteps do begin
    vel1 = FieldLines_vel_pos(0.0,pos1)
    for j = 0, accuracy do begin
      pos1 = RK4(pos1, vel1, 0.0, -dt, 'FieldLines_vel_pos', DOUBLE = double)
    end
    if ((pos1[0] lt xmin) or (pos1[0] gt xmax)) or $
       ((pos1[1] lt ymin) or (pos1[1] gt ymax)) or $
       ((pos1[2] lt zmin) or (pos1[2] gt zmax)) then begin
       backi = nsteps - i + 1
       i = nsteps + 1
    end else  begin
        points[*,nsteps-i] = pos1
    end
  end
  ; central point

  points[*,nsteps] = pos
  ; Forward part

  pos1 = pos
  forwardi = 2*nsteps
  for i=1, nsteps do begin
    vel1 = FieldLines_vel_pos(0.0,pos1)
    for j = 0, accuracy do begin
      pos1 = RK4(pos1, vel1, 0.0, dt, 'FieldLines_vel_pos', DOUBLE = double)
    end
    if ((pos1[0] lt xmin) or (pos1[0] gt xmax)) or $
       ((pos1[1] lt ymin) or (pos1[1] gt ymax)) or $
       ((pos1[2] lt zmin) or (pos1[2] gt zmax)) then begin
       forwardi = nsteps + i - 1
       i = nsteps + 1
    end else points[*,nsteps+i] = pos1
  end

  ; resize point matrix because of line leaving the box

  points = points[*,backi:forwardi]
  npoints = forwardi - backi + 1
  ; Calculates local values

  if N_Elements(lvalues) ne 0 then begin
     lvalues = fltarr(npoints)
     for i = 0, npoints-1 do begin
       vel = FieldLines_vel_pos(0.0,reform(points[*,i]))
       lvalues[i] = sqrt(total(vel*vel))
     end
  end

  return, points
end

;----------------------------------------------------------------------
;------------------------------------------------------- FieldLines ---
; Generates the FieldLines model from the data in parameter v[3,*,*,*]
; outputs the result to the parameter oModelFieldLines
;----------------------------------------------------------------------

pro FieldLines, pv, oModelFieldLines, _EXTRA=extrakeys,$
               XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
               NUMVECTS = NumberVectors, VECTORDIST = VectorDistribution, $
               STARTPOS = StartPositions, GETSTARTPOS = GetStartPositions, $
               LREF = lref, RADIUS = radius,  CT = FieldCT, $
               LENGTH = length, COLOR = Color, LINE = useline, TYPECOLOR = ColorType, $
               ARROW = doArrow, PROJ = doProjections, $
               AXISRATIO = AxisScale

   COMMON FieldLines_Shared,$
                  NX, NY, NZ, $         ; Array dimensions
                  xmin, ymin, zmin, $       ; Minimum positions
                  LX, LY, LZ, $         ; Dimensions
                  pvx, pvy, pvz            ; velocity arrays pointers

  ; Initialize local variables and test the validity of the parameters

   S = Size(pv)

   if ((s[0] ne 1) or (s[1] ne 3) or (s[2] ne 10)) then begin
     res = Dialog_Message('pData must be an array of 3 pointers', /Error)
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
  xmin = XAxisData[0]
  xmax = XAxisData[NX-1]
  dx = LX/(NX-1)
  LY = YAxisData[NY-1]-YAxisData[0]
  ymin = YAxisData[0]
  ymax = YAxisData[NY-1]
  dy = LY/(NY-1)
  LZ = ZAxisData[NZ-1]-ZAxisData[0]
  zmin = ZAxisData[0]
  zmax = ZAxisData[NZ-1]
  dz = LZ/(NZ-1)

; LINE
;
; Use a line for the streamline instead of a tube.

if N_Elements(useline) eq 0 then useline = 0

; VECTORDIST
;
; Vector distribution. This parameter allows you to choose between the following starting
; point distributions:
;
; 0 - Regular distribution
; 1 - Random distribution
; 2 - Random distribution with higher density of field lines in larger field regions

  if N_Elements(VectorDistribution) eq 0 then VectorDistribution = 2

; NUMVECTS
;
; Number of vectors to plot. This parameter allows you to define the number of vectors to plot. The default
; is 125.

  if N_Elements(NumberVectors) eq 0 then begin
    case VectorDistribution of
       2: NumberVectors = 125
       1: NumberVectors = 125
    else: NumberVectors = [5,5,5]
    endcase
  endif else begin
    s = size(NumberVectors)
    if (s[0] eq 0) then begin   ; scalar provided
      case VectorDistribution of
         2: NumberVectors = 1.0*NumberVectors
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
      if ((s[1] eq 3) and (VectorDistribution gt 0)) then begin
        NumberVectors = NumberVectors[0]*NumberVectors[1]*NumberVectors[2]
      endif

    endelse
  endelse

; LREF
;
; The reference length of the vectors in the field. The program uses this value to scale the lenght
; of the vectors plotted. If not supplied the program autoscales to the maximum value in the data supplied.

  if N_Elements(lref) eq 0 then begin
    lv = sqrt((*pvx)^2+(*pvy)^2+(*pvz)^2)
    lref = MAX(lv)
    print, 'AustoScaled lref to ',lref
    lv = 0
  end
  maxl= lref

; STARTPOS
;
; Vector starting points. Use this parameter to supply a vector containing the starting points to
; the vectors you wish to draw. If you set this parameter the program will ignore NUMVECTS and VECTDIST

  if (N_Elements(StartPositions) eq 0) or (KeyWord_Set(GetStartPositions)) then begin
    case VectorDistribution of
       2: begin                           ; random, higher density in high field regions
            print, 'Generating starting points, higher density in high field regions...'
            StartPositions=FltArr(3, NumberVectors)

            i = 0
            repeat begin
               spos = randomu(seed, 4)
               spos[0] = xmin + spos[0]* LX
               spos[1] = ymin + spos[1]* LY
               spos[2] = zmin + spos[2]* LZ

               fval = FieldLines_vel_pos(0.0, spos)
               fval = sqrt(total(fval*fval)) / lref

               if (spos[3]) lt fval then begin
                 StartPositions[*,i] = spos[0:2]
                 i = i+1
               end

            end until (i eq NumberVectors)
            print, 'Done'
            NV = NumberVectors
          end
       1: begin                           ; random
            StartPositions=randomu(seed, 3, NumberVectors)
            StartPositions[0,*] = xmin + StartPositions[0,*]*LX
            StartPositions[1,*] = ymin + StartPositions[1,*]*LY
            StartPositions[2,*] = zmin + StartPositions[2,*]*LZ
            NV = NumberVectors
          end
    else: begin                           ; regular
            StartPositions = FltArr(3,NumberVectors[0]*NumberVectors[1]*NumberVectors[2])
            k = long(0)
            for i = 0, NumberVectors[0] - 1 do begin
              x = Xmin + LX*(1.+1.*i)/(1.*NumberVectors[0] + 1.)
              for j = 0, NumberVectors[1] - 1 do begin
                y = Ymin + LY*(1.+1.*j)/(1.*NumberVectors[1] + 1. )
                  for l = 0, NumberVectors[2] -1 do begin
                    z = Zmin + LZ*(1.+1.*l)/(1.*NumberVectors[2] + 1. )
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
; 1 - Each line uses a random color from the color table (see CT parameter)
; 2 - The color is taken from the color table according to the vector magnitude
;     in the start position (see CT parameter)
; 3 - The color is taken from the color table according to the vector magnitude
;     along the line (see CT parameter)

  if N_Elements(ColorType) eq 0 then ColorType = 3

; CT
;
; Color table to be used for drawing the lines.

 if N_Elements(fieldCT) eq 0 then fieldCT = 25
 print, 'FieldLines, Using CT = ', fieldCT

; COLOR
;
; Color to be used when drawing the lines in a single color (alpha is ignored)

 if N_Elements(color) eq 0 then color=[255b,0b,0b,255b]

; LENGTH
;
; The scale length of the field lines. This parameter specifies the size of the field line passing
; through the point with magnitude LREF to be plotted
; as a fraction of the plot area. The default is 5.0 (five times the size of the box)

  if N_Elements(length) eq 0 then begin
   length = 5.0
  end

; RADIUS
;
; The radius of the tube to draw. If positive is a fraction of the length of the vector being
; drawn. If negative its the fraction of the length of the box. The default -0.0004 (0.04% of the length of the box)

  if N_Elements(radius) eq 0 then begin
    radius = 0.
  end

  if ((radius eq 0.) or (radius gt 1.) or (radius lt -1.)) then begin
    radius = -0.0004
  end

; Generates the streamline points and adds result to oModelStream

  LBoxMax = Max([LX,LY,LZ])
  lboxref = length * LBoxMax / float(maxl)
  
; Generates colors for each vector (ColorType 0,1 and 2)

  vcolor = BytArr(3,NV)

  case ColorType of
        2: begin                ; scaled color
             getCTcolors, fieldCT, RED = rr, GREEN = gg, BLUE = bb
             for k=long(0), NV-1 do begin
               rci = byte(255.*l[k]/maxl)
               vcolor[*,k] = [rr[rci],gg[rci],bb[rci]]
             end
           end
        1: begin                ; random color
             getCTcolors, fieldCT, RED = rr, GREEN = gg, BLUE = bb
             for k=long(0), NV-1 do begin
               rci = byte(255*randomu(seed))
               vcolor[*,k] = [rr[rci],gg[rci],bb[rci]]
             end
           end
    else : begin                ; fixed color
             vcolor[0,*] = color[0]
             vcolor[1,*] = color[1]
             vcolor[2,*] = color[2]
           end
  end

  ; Plots for ColorType = 3

  if (ColorType eq 3) then begin
    lvalues = 0

    for k=long(0), NV-1 do begin
       points = GenFieldLines(StartPositions[*,k], xmin, xmax, ymin, ymax, zmin, zmax, lboxref, $
                              LOCALVALUES = lvalues, _EXTRA=extrakeys)

       lvalues = temporary(lvalues)/maxl
       vcolor = getPointColors( lvalues, fieldCT)

       ; Radius

       rad = abs(radius)*LBoxMax
       if (radius gt 0) then rad = rad * l[k]/maxl
       Trajectory, points, oModelFieldLines, VERT_COLORS = vcolor, $
                   XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                   RADIUS = rad, LINE = useline, ARROW = doArrow, $
                   AXISRATIO = AxisScale, PROJ = doProjections
    end

  end else begin

  ; Plot for ColorType 0,1 or 2

    for k=long(0), NV-1 do begin
       points = GenFieldLines(StartPositions[*,k], xmin, xmax, ymin, ymax, zmin, zmax, lboxref, $
                              _EXTRA=extrakeys)

       ; Radius

       rad = abs(radius)*LBoxMax
       if (radius gt 0) then rad = rad * l[k]/maxl

       Trajectory, points, oModelFieldLines, COLOR = reform(vcolor[*,k]), $
                   XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                   RADIUS = rad, LINE = useline, ARROW = doArrow, $
                   AXISRATIO = AxisScale, PROJ = doProjections

    end
  end

end
; ---------------------------------------------------------------------