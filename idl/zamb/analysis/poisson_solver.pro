;+
; NAME:
;    POISSON_SOLVER
;
; PURPOSE:
;
;    The purpose of this function is to solve the poisson equation
;    (del^2) phy = - rho
;    for a periodic system using an fft technique
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
;    poisson_solver, [pField[, dX]]
;
; INPUTS:
;
;    pField: This is a pointer to a float array (1,2 or 3 Dimensional) 
;       containing the rho field. The phy field is returned on the same
;       pointer and it overwrites the rho field. If undefined, the procedure
;       will do a 2D demo
;
;    dX: This is an array with the same number of elements as dimensions
;       on (*pField) containing the cell size on each direction. If undefined,
;       it is defaulted to 1.0
;
; KEYWORDS:
;
;    TIME: Setting this keyword results in printing timing (profiling) information
;
; OUTPUTS:
;
;    The solution found for phi is returned in the variable pField.
;
; RESTRICTIONS:
;
;    None.
;
; EXAMPLE:
;
;    To find the potential for a quadrupole:
;
;    pField = ptr_new(FltArr(128,128), /no_copy)  ; create rho field
;    (*pField)[30:34,30:34] =  1.0                ; add charge 1
;    (*pField)[94:98,30:34] = -1.0                ; add charge 2
;    (*pField)[30:34,94:98] = -1.0                ; add charge 3
;    (*pField)[94:98,94:98] =  1.0                ; add charge 4
;
;    plot2D, pField, TITLE = 'charge'             ; plot rho field
;
;    poisson_solver, pField                       ; solve for phi
;
;    plot2D, pField, TITLE = 'potential'          ; plot phi field
;
; MODIFICATION HISTORY:
;
;    Written by: Ricardo Fonseca, 31 August 2000.
;    Added 1D and 3D algorithms and TIME keyword. 1 Sep 2000. zamb.
;-
;###########################################################################


;**************************************************************************
;*                               k2_field2D                               *
;**************************************************************************
;*                                                                        *
;* This function returns a 2D matrix (n,m) in the form:                   *
;* k2(i,j) = (dx*(i-n/2))^2+(dx*(j-m/2))^2                                * 
;* with the result shifted by  -(n/2,m/2) such that k2(0,0) eq 0.         *
;*                                                                        *
;* This is the same type of geometry                                      *
;* as the output of the FFT routine. Original code from dist.pro, from    *
;* the IDL lib                                                            *
;*                                                                        *
;**************************************************************************

function k2_field2D, nx, ny, DX = dx, DY = dy
  if (N_Elements(DX) eq 0) then dx = 1.0
  if (N_Elements(DY) eq 0) then dy = 1.0
  
  x = findgen(nx)
  x = (dx*(x<(nx-x)))^2  ; x(i) = (dx*(i-n/2))^2 & shift(x, -n/2)
  
  k2 = fltarr(nx,ny, /nozero)
  k2[0,0] = x
  for i = 1L, ny/2 do begin
    y = ( x + (i*dy)^2)
    k2[0,i] = y
    k2[0,ny-i] = y ; use symmetrical
  end
  return, k2
end

;**************************************************************************


;**************************************************************************
;*                    1D Poisson Solver, Periodic boudaries               *
;**************************************************************************

pro poisson_1D, pField, dX, TIME = time

; Start timer
if (Keyword_Set(time)) then time0 = systime(1)

; Get field dimensions
N = size(*pField, /dimensions)

; FFT the field
*pField = fft(*pField, /overwrite)

; Divide by k2
(*pField)[0] = complex(0)
k2 = findgen(N[0])
k2 = ((1.0/(N[0]*dX[0]))*(k2<(N[0]-k2)))^2 
k2[0] = 1.0 
*pField = temporary(*pField) / temporary(k2)

; Inverse FFT the field
*pField = fft(*pField, /overwrite, /inverse)

; Take the real value
*pField = float(temporary(*pField))

; Stop Timer
if (Keyword_Set(time)) then $
  print, '1D poisson solver, time for [',N[0],',',N[1],'] array was ', $
         systime(1) - time0, ' seconds'

end

;**************************************************************************



;**************************************************************************
;*                    2D Poisson Solver, Periodic boudaries               *
;**************************************************************************

pro poisson_2D, pField, dX, TIME = time, DEMO = demo

if (Keyword_Set(Demo)) then begin
  window, /free
  plot2D, pField, TITLE = 'Charge'
end

; Start timer
if (Keyword_Set(time)) then time0 = systime(1)

; Get field dimensions
N = size(*pField, /dimensions)

; FFT the field
*pField = fft(*pField, /overwrite)

; Divide by k2
(*pField)[0] = complex(0)
k2 = k2_field2D(N[0],N[1], DX = 1.0/(N[0]*dX[0]), DY = 1.0/(N[1]*dX[1]))
k2[0] = 1.0 
*pField = temporary(*pField) / temporary(k2)

; Inverse FFT the field
*pField = fft(*pField, /overwrite, /inverse)

; Take the real value
*pField = float(temporary(*pField))

; Stop Timer
if (Keyword_Set(time)) then $
  print, '2D poisson solver, time for [',N[0],',',N[1],'] array was ', $
         systime(1) - time0, ' seconds'

if (Keyword_Set(Demo)) then begin
  pData = ptr_new(float(*pField))
  
  min = Min(*pData, Max = max)
  Levels = min +(1.0+FIndGen(20))*(max-min)/22.0 

  window, /free  
  plot2D, pData, TITLE = 'Potential',/ADDCONTOUR, CONTOURLEVELS = Levels
  ptr_free, pData
end

end

;**************************************************************************

;**************************************************************************
;*                    3D Poisson Solver, Periodic boudaries               *
;**************************************************************************

pro poisson_3D, pField, dX, TIME = time

; Start timer
if (Keyword_Set(time)) then begin
  time0 = systime(1)
  print, '3D Poisson solver, taking FFT(Field)...'
end

; Get field dimensions
N = size(*pField, /dimensions)

; FFT the field
*pField = fft(*pField, /overwrite)

if (Keyword_Set(time)) then begin
  time1 = systime(1)
  print, 'FTT in ', time1-time0, ' seconds, dividing by k2'
end

; Divide by k2

kxy2 = k2_field2D(N[0],N[1], DX = 1.0/(N[0]*dX[0]), DY = 1.0/(N[1]*dX[1]))
kz2  = findgen(N[2]) 
kz2 = ((1.0/(N[2]*dX[2]))*(kz2<(N[2]-kz2)))^2 

for i=1, N[2]-1 do (*pField)[*,*,i] = (*pField)[*,*,i] / (kxy2+kz2[i])

(*pField)[0] = complex(0)
kxy2[0] = 1.0 
(*pField)[*,*,0] = (*pField)[*,*,0] / (temporary(kxy2))
kz2 = 0b

if (Keyword_Set(time)) then begin
  time2 = systime(1)
  print, 'division by k2 in ', time2-time1, ' seconds, taking inverse FFT(field)'
end


; Inverse FFT the field
*pField = fft(*pField, /overwrite, /inverse)
if (Keyword_Set(time)) then begin
  time3 = systime(1)
  print, 'FFT in ', time3-time2, ' seconds.'
end


; Take the real value
*pField = float(temporary(*pField))

; Stop Timer
if (Keyword_Set(time)) then $
  print, '3D poisson solver, time for [',N[0],',',N[1],$
         ',',N[2],'] array was ', systime(1) - time0, ' seconds'

end

;**************************************************************************


;**************************************************************************
;*                     Poisson Solver, Periodic boudaries                 *
;**************************************************************************

pro poisson_solver, pField, dX, TIME = time

if (not Arg_Present(pField)) then begin

  ; 2D Demo
  pField = ptr_new(FltArr(128,128), /no_copy)
  dX = FltArr(2, /nozero)
  dX[*] = 1.0
  (*pField)[30:34,30:34] =  1.0
  (*pField)[94:98,30:34] = -1.0
  (*pField)[30:34,94:98] = -1.0  
  (*pField)[94:98,94:98] =  1.0
  
  demo = 1  
end 

n_dim =  size(*pField, /N_Dimensions) 

if (N_Elements(dX) eq 0) then begin
  dX = FltArr(n_dim, /nozero)
  dX[*] = 1.0
end

case (n_dim) of
  3: poisson_3D, pField, dX, TIME=time
  2: poisson_2D, pField, dX, TIME=time, DEMO = Demo
  1: poisson_1D, pField, dX, TIME=time
else: res = Error_Message('pField must be a pointer to a 1,2 or 3 dimensional array.')
end

if (N_Elements(demo) ne 0) then ptr_free, pField

end

;**************************************************************************
