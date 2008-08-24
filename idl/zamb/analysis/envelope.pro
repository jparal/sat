;+
; NAME:
;    ENVELOPE
;
; PURPOSE:
;
;    The purpose of this function is to get the envelope of a laser field.
;    This routine takes the absolute value of the field supplied and filters
;    out all modes with k such that:
;
;       sqrt( k. laser_k ) > filter_val*|| laser_k ||,
;
;    where laser_k is the laser wave vector, and filter_val is a scalar
;    ranging from 0.0 to 1.0 (see the FILTER keyword below). Finnaly, the 
;    routine normalizes the result by making the maximum value of the
;    result match the maximum value of the input data
;
; AUTHOR:
;
;   Ricardo Fonseca
;   E-mail: zamb@physics.ucla.edu
;
; CATEGORY:
;
;    Math.
;
; CALLING SEQUENCE:
;
;    envelope, pField
;
; INPUTS:
;
;    pField: This is a pointer to a float array (1,2 or 3 Dimensional) 
;       containing the laser field. The envelope of this field is returned 
;       on the same pointer and it overwrites the original laser field. If this paramater
;       is not specified the routine issues an error message
;
;
; KEYWORDS:
;
;    FILTER: Set this keyword to the position of the low-pass filter in units of the laser
;       wave number. The default values for this value are 0.25 in 1D and 2D and 0.5 in 3D
;       (determined empirically)
;
;    KMIN: Set this keyword to the minimum value of the wave number to be considered when
;       searching for the laser wave number of the data supplied. If not specified the
;       searching algorithm will return the first peak in the power spectrum after the DC 
;       component. Altough this is generally correct, when the field has strong modulations
;       the algorithm can fail, and setting this argument to an appropriate value usually 
;       corrects this problem. If the LASERK argument is specified this keyword has no effect. 
;
;    LASERK: Set this keyword to an array containing the wave vector (or in 1D the wave number) 
;       of the laser field to be used for filtering the data in units of [ 2 * PI/ (N * delta) ],
;       where N and delta are the number of cells and cell size in each direction. 
;       If not specfied, the program will try to find this value automatically (see the KMIN
;       keyword)
;
;    MIRROR: Setting this keyword results in extending the data to x = [-Lx,0] (assuming
;       the box has a size Lx along the x direction) by mirroring the data on x = [0, Lx].
;       This is usefull when the laser field is not fully contained inside the simulation
;       box, and is exiting through the rear boundary (e.g. moving window run). Since fourier
;       filtering assumes periodic boundaries not setting this keyword in the situations 
;       mentioned causes the field to be aliased to the front of the box.
;       Note: 
;         - setting this keyword may cause the normalization to be slighlty off because of the
;         value of the field on the rear boundary which may not be accurate.
;         - setting this keyword doubles the memory requirements of this routine and slows it
;         down by a factor of at least two (usually more).
;
;    TIME: Setting this keyword results in printing timing (profiling) information
;
;    
; OUTPUTS:
;
;    The solution found for the envelope is returned in the variable pField. Some additional
;    information is printed to the output log.
;
; RESTRICTIONS:
;
;    The technique used by this function requires periodic boundary conditions on every
;    direction. This is usually not a problem on any laser run because the laser field dies
;    out before reaching the edges of the simulation box. However, on moving window runs,
;    the laser will eventually start to exit the simulation box through the rear boundary of 
;    the simulation. In this case the /MIRROR option should be used (see details above)
;
; EXAMPLE:
;
;    To find the envelope of a 1D laser field:
;
;    LX = 10.								; Simulation box size
;    LP = 3.								; Laser pulse size
;    wavelength = 0.5							; Laser wavelength
;    k = 2*!PI/(wavelength)					; laser k number
;    NX = 1000								; Number of cells
;    x = findgen(NX)*LX/(NX-1)					; generate position data
;
;    y =  cos(k*x)*((exp(-(x^2)/ (2*LP/4)^2))  + $	; generate laser data
;             0.5*exp(-(x-3*LX/4)^2/ (LP/4)^2)) 
;
;    py = ptr_new(y, /no_copy)					; move data to a pointer
;
;    window, /free							; open a window ...
;    plot, x,(*py), TITLE = 'Laser Pulse'			; and plot laser field
;
;    envelope, py, /mirror, kmin = 10				; get the envelope of the field
;										; using the mirror extension of the field
;										; and using k >= 10
;
;    oplot, x,(*py) & oplot, x,-(*py)				; overplot the envelope
;
;    ptr_free, py							; free the pointer
;
; MODIFICATION HISTORY:
;
;    Written by: Ricardo Fonseca, 15 April 2000.
;    Changed 2D and 3D filtering algorithms (much faster!), and added TIME
;      keyword, 30 Apr 2000. zamb.
;    Added MIRROR keyword, extended the TIME functionality, changed the 3D
;      filtering routine (20% faster and a lot more memory efficient), 10 Sep 2000. zamb
;    Updated the local max routine call now MUCH faster, 18 Sep 2000. zamb
;      
;-
;###########################################################################


;---------------------------------------------------------------------------------- 1D -------

;-------------------------------------------------- get_k_1d ---
; Returns the k vector of the laser field (+ or -)
;---------------------------------------------------------------

function get_k_1d, DataPow1, KMIN = kmin
        
  list_max_pos = local_max(DataPow1, NMAX = nmax, /verbose, THRESH = max(datapow1)/100.0, /periodic)  
  
  if (nmax lt 3) then begin
    print, 'get_k_1d, not enough local maximums in power spectrum'
    return, 0
  end
  
;  window, /free
;  plot, DataPow1, xrange = [400,600]
;  oplot, list_max_pos, DataPow1[list_max_pos], psym = 6
  
  if (N_Elements(kmin) eq 0) then begin 
     return, list_max_pos[1]
  end else begin     
     kmin2 = (2.0*kmin)^2
     if (kmin2 lt 1) then kmin2  = 1
     i = 1
     n21 = (size(DataPow1, /dimensions))[0]/2+1
     while ((i lt nmax-1) and ((list_max_pos[i]-n21)*(list_max_pos[i]-n21) lt kmin2)) do i = i+1
     return, list_max_pos[i]
  end

  
end

;----------------------------------------------- Envelope_1d ---
; Returns the envelope of a 1D laser field
;---------------------------------------------------------------

pro Envelope1D, pData1D, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                MIRROR = mirror, TIME = time
  
  ; FILTER
  ;
  ; Position of the low-pass filter in units of laser k number. The default is 0.25
  
  if (N_Elements(filter_val) eq 0) then filter_val = 0.25

  S = Size(*pData1D)
  if (S[0] ne 1) then begin
    print, 'Envelope1D, Data must be 1 dimensional'
    return
  end
  NX = S[1]  
  *pData1D = Abs(temporary(*pData1D))
  max_abs_data1D = Max(*pData1D)

  ; MIRROR
  ;
  ; Mirror the data at x=0. Useful when the laser is exiting the simulation box
  ; through that boundary
  
  if (keyword_set(mirror)) then begin
    tmp = reverse(*pData1D,1)
    *pData1D = [temporary(tmp),temporary(*pData1D)]
    NX = 2*NX
  end
  

  N21x = NX/2 + 1 
  *pData1D = FFT(*pData1D, /overwrite)
  *pData1D = Shift(temporary(*pData1D), -N21x)  

  ; LASERK
  ;
  ; Laser K vector. If not specified the program finds it automatically
  
  If N_Elements(laserk) eq 0 then begin
    laserk = get_k_1D(Abs(*pData1D), KMIN = kmin) - n21x
  end else laserk = laserk*2.0
  
  filter = long(filter_val* abs(laserk))


  (*pData1D)[n21x + filter: nx-1] = COMPLEX(0.,0.)
  (*pData1D)[0: n21x - filter] = COMPLEX(0.,0.)
  
  *pData1D = Shift(temporary(*pData1D), N21x)
  *pData1D = FFT(*pData1D, /Inverse, /overwrite)

  if (keyword_set(mirror)) then begin
    *pData1D = (temporary(*pData1D))[NX/2:*]
  end


  *pData1D = abs(temporary(*pData1D))
  
  max_abs_data = Max(*pData1D)
  
  print, 'Normalization factor, ',max_abs_data1D/max_abs_data
  
  *pData1D = temporary(*pData1D)*max_abs_data1D/max_abs_data
end

;---------------------------------------------------------------------------------- 2D -------


function get_k_2d, DataPow, KMIN = kmin, TIME = time

  s = size(DataPow)
  nx = s[1]
  ny = s[2]
        
  N21= [nx/2 + 1, ny/2 + 1]
  list_max_pos = local_max(DataPow, NMAX = n_max, /verbose, TIME = time, THRESH = max(datapow)/100.0, /periodic)  
  
  if (n_max lt 3) then begin
    print, 'get_k_2d, not enough local maximums in power spectrum'
    return, 0
  end
 
   ; Since we no longer shift the matrix we need to correct the local maxima
  lim = nx/2
  idx = where(list_max_pos[0,*] gt lim, n_idx)
  if (n_idx gt 0) then list_max_pos[0,idx] = -nx+list_max_pos[0,idx]
  idx = 0b

  lim = ny/2
  idx = where(list_max_pos[1,*] gt lim, n_idx)
  if (n_idx gt 0) then list_max_pos[1,idx] = -ny+list_max_pos[1,idx]
  idx = 0b
  
  if (N_Elements(kmin) eq 0) then begin 
     return, reform(list_max_pos[*,0])
  end else begin
     kmin2 = (kmin*2.0)^2
     if (kmin2 lt 1) then kmin2  = 1
     i = 0
     
     while ((i lt n_max-1) and (total((reform(list_max_pos[*,i]))*(reform(list_max_pos[*,i]))) lt kmin2)) do i = i+1
     return, reform(list_max_pos[*,i])

  end

end

pro Envelope2D, pData, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                MIRROR = mirror, TIME = time
   
  ; FILTER
  ;
  ; Position of the low-pass filter in units of laser-k. The default is 0.25
  
  if (N_Elements(filter_val) eq 0) then filter_val = 0.25

  S = Size(*pData)
  if (S[0] ne 2) then begin
    print, 'Envelope2D, Data must be 2 dimensional'
    return
  end
  NX = S[1]  
  NY = S[2]
  *pData = Abs(temporary(*pData))
  max_abs_data2D = Max(*pData)

  ; MIRROR
  ;
  ; Mirror the data at x=0. Useful when the laser is exiting the simulation box
  ; through that boundary
  
  if (keyword_set(mirror)) then begin
    tmp = reverse(*pData,1)
    *pData = [temporary(tmp),temporary(*pData)]
    NX = 2*NX
  end

  N21x = NX/2 + 1 
  N21y = NY/2 + 1
  *pData = FFT(*pData, /overwrite)
  
  ; LASERK
  ;
  ; Laser K vector. If not specified the program finds it automatically
  
  If N_Elements(laserk) eq 0 then begin
     laserk = get_k_2D(Abs(*pData), KMIN = kmin)
  end else laserk = laserk*2.0
 
  ; Internally the laserk is represented by twice the real value
  ; because we work with the absolute value of the data

  print, 'Laser wave vector (+/-)', laserk/2.0, '[ 2*Pi / (N*cell_size) ]'

  laserk = laserk * float(filter_val)
  k2 = total(laserk*laserk)
  
  ; New Filtering
  
  nx2 = nx/2+1
  ny2 = ny/2+1
    
  ; Generate x and y components
  
  xy_idx = LIndGen(nx*ny)
  x_idx = reform(xy_idx mod nx, nx, ny)
  x_idx[nx2:*,*] = x_idx[nx2:*,*] - nx
    
  y_idx = reform(xy_idx/nx,nx,ny)
  y_idx[*,ny2:*] = y_idx[*,ny2:*]-ny
  
  ; free memory
  xy_idx = 0b
  t = 0b

  ; find abs dot product

  idx = abs(temporary(x_idx)*laserk[0]+temporary(y_idx)*laserk[1])
  
  ; filter where abs dot product gt k2
   
  c0 = complex(0.,0.) 
  (*pData)[where(temporary(idx) gt k2 )] = c0
         
  *pData = FFT(*pData, /Inverse, /overwrite)

  if (keyword_set(mirror)) then begin
    *pData = (temporary(*pData))[NX/2:*,*,*]
  end

  *pData = abs(temporary(*pData))
  
  max_abs_data = Max(*pData)
  
  *pData = temporary(*pData)*max_abs_data2D/max_abs_data
end

;---------------------------------------------------------------------------------- 3D -------


function get_k_3d, DataPow, KMIN = kmin, TIME = time
  
  S = size(DataPow)
  
  nx = s[1]
  ny = s[2]
  nz = s[3]
   
  list_max_pos = local_max(DataPow, NMAX = n_max, /verbose, TIME = time, THRESH = max(datapow)/100.0, /periodic)  
   
  if (n_max lt 3) then begin
    print, 'get_k_3d, not enough local maximums in power spectrum'
    return, 0
  end
  
  ; Since we no longer shift the matrix we need to correct the local maxima
  lim = nx/2
  idx = where(list_max_pos[0,*] gt lim, n_idx)
  if (n_idx gt 0) then list_max_pos[0,idx] = -nx+list_max_pos[0,idx]
  idx = 0b

  lim = ny/2
  idx = where(list_max_pos[1,*] gt lim, n_idx)
  if (n_idx gt 0) then list_max_pos[1,idx] = -ny+list_max_pos[1,idx]
  idx = 0b

  lim = nz/2
  idx = where(list_max_pos[2,*] gt lim, n_idx)
  if (n_idx gt 0) then list_max_pos[2,idx] = -ny+list_max_pos[2,idx]
  idx = 0b
   
  
  if (N_Elements(kmin) eq 0) then begin 
     k_3D = reform(list_max_pos[*,0])
  end else begin
     kmin2 = (kmin*2.0)^2
     if (kmin2 lt 1) then kmin2  = 1
     i = 0
     
     while ((i lt n_max-1) and $
        (total(reform(list_max_pos[*,i])^2) lt kmin2)) $
           do i = i+1
     
     k_3D = reform(list_max_pos[*,i])
  end

  return, k_3D
  
end

pro Envelope3D, pData, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                MIRROR = mirror, TIME = time
   
  ; FILTER
  ;
  ; Position of the low-pass filter in units of laser-k. The default is 0.5
  
  if (N_Elements(filter_val) eq 0) then filter_val = 0.5

  S = Size(*pData)
  if (S[0] ne 3) then begin
    print, 'Envelope3D, Data must be 3 dimensional'
    return
  end
  NX = S[1]  
  NY = S[2]
  NZ = S[3]

  *pData = Abs(Temporary(*pData))

  max_abs_data3D = Max(*pData)

  ; MIRROR
  ;
  ; Mirror the data at x=0. Useful when the laser is exiting the simulation box
  ; through that boundary
  
  if (keyword_set(mirror)) then begin
    if Keyword_Set(time) then time0 = systime(1)
    tmp = reverse(*pData,1)
    *pData = [temporary(tmp),temporary(*pData)]
    NX = 2*NX
    if Keyword_Set(time) then print, 'Envelope3D, time for mirror (s) ', systime(1) - time0
  end

  N21x = NX/2 + 1 
  N21y = NY/2 + 1
  N21z = NZ/2 + 1

  print, 'Fourier Transforming...'

  if Keyword_Set(time) then time0 = systime(1)
      
  *pData = FFT(temporary(*pData))

  if Keyword_Set(time) then print, 'Envelope3D, time for fft (s) ', systime(1) - time0

  ; LASERK
  ;
  ; Laser K vector. If not specified the program finds it automatically
  
  if N_Elements(laserk) eq 0 then begin
    print, 'Finding k ...'
    laserk = get_k_3D(Abs(*pData), KMIN = kmin, TIME = time)
  end else laserk = laserk*2.0

  
  ; Internally the laserk is represented by twice the real value
  ; because we work with the absolute value of the data

  print, 'Laser wave vector (+/-)', laserk/2.0, '[ 2*Pi / (N*cell_size) ]'

  laserk = float(laserk) * filter_val
  k2 = total(laserk*laserk)
  
  print, 'Filtering Data...'

  if Keyword_Set(time) then time0 = systime(1)

  ; New Filtering
  
  nx2 = nx/2+1
  ny2 = ny/2+1
  
  ; Generate x and y components
  
  xy_idx = LIndGen(nx*ny)
  x_idx = reform(xy_idx mod nx, nx, ny)
  x_idx[nx2:*,*] = x_idx[nx2:*,*] - nx
  
  y_idx = reform(xy_idx/nx,nx,ny)
  y_idx[*,ny2:*] = y_idx[*,ny2:*]-ny
  
  ; free memory
  xy_idx = 0b
  t = 0b

  ; find dot product

  idx = temporary(x_idx)*laserk[0]+temporary(y_idx)*laserk[1]
 
  ; Filtering
 ; for i = 0, nx-1 do begin
 ;   for j = 0, ny-1 do begin
 ;     for k = 0, nz-1 do begin
 ;        localk = abs(total([(i-n21x),(j-n21y),(k-n21z)]*laserk)) 
 ;        if (localk gt k2) then Data[i,j,k] = complex(0.,0.)
 ;     end   
 ;   end
 ; end  

  
  ; filter where abs dot product gt k2
   
  nxy = nx*ny
  
  c0 = complex(0.,0.)
  
  nz2 = nz/2
  for i=0,nz-1 do begin
    tmp_idx = where(abs(idx+(i gt nz2?i-nz:i)*laserk[2]) gt k2, count )
    if (count gt 0) then (*pData)[i*nxy + temporary(tmp_idx)] = c0
  end
  
  idx = 0b
   
  if Keyword_Set(time) then print, 'Envelope3D, time for filtering (s) new', systime(1) - time0
   
  print, 'Reverse Fourier Transforming...'
      
  if Keyword_Set(time) then time0 = systime(1)

  *pData = FFT(*pData, /Inverse, /overwrite)

  if Keyword_Set(time) then print, 'Envelope3D, time for FFT-1 (s) ', systime(1) - time0

  if (keyword_set(mirror)) then begin
    *pData = (temporary(*pData))[NX/2:*,*,*]
  end

  *pData = abs(temporary(*pData))
  
  max_abs_data = Max(*pData)
  
  *pData = temporary(*pData)*max_abs_data3D/max_abs_data

  print, 'Done, evelope 3D.'

end


;--------------------------------------------------------------------------- Envelope -------


pro Envelope, pData, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                    TIME = time, $
                    MIRROR = mirror, _EXTRA=extrakeys
                        
  if (N_Elements(pData) eq 1) then begin

    T_POINTER = 10
              
    if (size(pData, /type) ne T_POINTER) then begin       ; Data must be a Pointer
      res = Error_Message('pData must be a pointer')
      return
    end 

    if (not ptr_valid(pData)) then begin       ; Data must be a valid Pointer
      res = Error_Message('pData is not a valid pointer')
      return
    end 

    if Keyword_Set(time) then begin
      time0 = systime(1)
    end

    s = Size(*pData)
  
    case (s[0]) of 
       1: Envelope1D, pData, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                      MIRROR = mirror, TIME = time
       2: Envelope2D, pData, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                      MIRROR = mirror, TIME = time
       3: Envelope3D, pData, FILTER = filter_val, LASERK = laserk, KMIN = kmin, $
                      MIRROR = mirror, TIME = time
    else: begin
           res = Error_Message('*pData must be 1, 2 or 3 Dimensional')
           return
          end
    end  

    if Keyword_Set(time) then begin
      print, 'Envelope, time elapsed (seconds) ', systime(1) - time0
    end

   end else begin
     res = Error_Message('Invalid pData')
     return         
   end
end 