;------------------------------------------------- KFilter1d ---
; Filters the k space of a 1D field
;---------------------------------------------------------------

pro Kfilter1D, pData1D, kval, xaxis = xaxis, highpass = highpass, RETTYPE = rettype,$
                TIME = time

  nx = size(*pData1D, /dimensions)

  if (N_Elements(xaxis) eq 0) then deltaX = 1.0 $
  else deltaX = xaxis[1]-xaxis[0]

  ; get k values

  N21x = nx[0]/2 + 1
  kx = IndGen(nx[0])
  kx[N21x] = N21x - nx[0] + FINDGEN(N21x - 2)
  kx = 2.0*!PI*kx/(nx[0]*deltaX)

  ; transform data
  *pData1D = fft(*pData1D)
  
  ; filter data

  c0 = complex(0.,0.)
  
  if not keyword_set(highpass) then begin
    ; lowpass
    idx = where(kx gt kval,count)
    if (count gt 0) then (*pData1D)[temporary(idx)] = c0
  end else begin
    ; highpass
    idx = where(kx lt kval,count)
    if (count gt 0) then (*pData1D)[temporary(idx)] = c0
  end
  
  ; transform data back
  *pData1D = fft(*pData1D, /inverse)
  
  if (N_Elements(rettype) eq 0) then rettype = 0
  
  case (rettype) of
    0: *pData1D = abs(temporary(*pData1D))
    1: *pData1D = float(temporary(*pData1D))
    2: *pData1D = imaginary(temporary(*pData1D)) 
  else:
  endcase
    
end

;---------------------------------------------------------------

;------------------------------------------------- KFilter2d ---
; Filters the k space of a 2D field
;---------------------------------------------------------------

pro Kfilter2D, pData2D, kval, xaxis = xaxis, yaxis = yaxis, RETTYPE = rettype,$
               highpass = highpass, TIME = time

  nxy = size(*pData2D, /dimensions)
  
  nx = nxy[0]
  ny = nxy[1]

  if (N_Elements(xaxis) eq 0) then deltax = 1.0 $
  else deltax = xaxis[1]-xaxis[0]

  if (N_Elements(yaxis) eq 0) then deltay = 1.0 $
  else deltay = yaxis[1]-yaxis[0]

  ; get k values

  nx2 = nx/2+1
  ny2 = ny/2+1
  
  xy_idx = LIndGen(nx*ny)
  
  kx = reform(xy_idx mod nx, nx, ny)
  kx[nx2:*,*] = kx[nx2:*,*] - nx
  kx = 2.0*!Pi*kx/(nx*deltax)
    
  ky = reform(xy_idx/nx,nx,ny)
  ky[*,ny2:*] = ky[*,ny2:*]-ny
  ky = 2.0*!Pi*ky/(nx*deltax)

  xy_idx = 0b
  
  
  ; transform data
  *pData2D = fft(*pData2D)
  
  ; filter data
  c0 = complex(0.,0.)
  
  case N_Elements(kval) of
    2:  begin 
          kdotkval = abs(temporary(kx)*kval[0]+temporary(ky)*kval[1])
          kval2 = total(kval*kval)
          if not keyword_set(highpass) then begin
          ; lowpass
            idx = where(kdotkval gt kval2,count)
            if (count gt 0) then (*pData2D)[temporary(idx)] = c0
          end else begin
          ; highpass
            idx = where(kdotkval lt kval2,count)
            if (count gt 0) then (*pData2D)[temporary(idx)] = c0
          end
        end
  else: begin ; assume scalar kval
          k2 = temporary(kx)^2+temporary(ky)^2
          kval2 = kval[0]^2
          if not keyword_set(highpass) then begin
          ; lowpass
            idx = where(k2 gt kval2,count)
            if (count gt 0) then (*pData2D)[temporary(idx)] = c0
          end else begin
          ; highpass
            idx = where(k2 lt kval2,count)
            if (count gt 0) then (*pData2D)[temporary(idx)] = c0
          end
        end 
  endcase
  
  ; debug
  ;plot2d, abs(*pdata2D), /zlog
    
  ; transform data back
  *pData2D = fft(*pData2D, /inverse, /overwrite)
  
  if (N_Elements(rettype) eq 0) then rettype = 0
  
  case (rettype) of
    0: *pData2D = abs(temporary(*pData2D))
    1: *pData2D = float(temporary(*pData2D))
    2: *pData2D = imaginary(temporary(*pData2D)) 
  else:
  endcase
    
end

;---------------------------------------------------------------

;------------------------------------------------- KFilter3d ---
; Filters the k space of a 3D field, UNFINISHED!
;---------------------------------------------------------------

pro Kfilter3D, pData3D, kval, xaxis = xaxis, yaxis = yaxis, zaxis = zaxis, $
               highpass = highpass, RETTYPE = rettype, TIME = time

  nxyz = size(*pData3D, /dimensions)
  
  nx = nxyz[0]
  ny = nxyz[1]
  nz = nxyz[2]

  if (N_Elements(xaxis) eq 0) then deltax = 1.0 $
  else deltax = xaxis[1]-xaxis[0]

  if (N_Elements(yaxis) eq 0) then deltay = 1.0 $
  else deltay = yaxis[1]-yaxis[0]

  if (N_Elements(zaxis) eq 0) then deltaz = 1.0 $
  else deltaz = zaxis[1]-zaxis[0]

  ; get k values

  nx2 = nx/2+1
  ny2 = ny/2+1
  
  xy_idx = LIndGen(nx*ny)
  
  kx = reform(xy_idx mod nx, nx, ny)
  kx[nx2:*,*] = kx[nx2:*,*] - nx
  kx = 2.0*!Pi*kx/(nx*deltax)
    
  ky = reform(xy_idx/nx,nx,ny)
  ky[*,ny2:*] = ky[*,ny2:*]-ny
  ky = 2.0*!Pi*ky/(nx*deltax)

  xy_idx = 0b
  
  
  ; transform data
  *pData3D = fft(*pData3D)
  
  ; filter data
  c0 = complex(0.,0.)
  nxy = nx*ny
  nz = nz/2
  a0 = 2.0*!Pi/(nz*deltaz)
  
  case N_Elements(kval) of
    3:  begin 
          kdotkvalxy = abs(temporary(kx)*kval[0]+temporary(ky)*kval[1])
          kval2 = total(kval*kval)
          if not keyword_set(highpass) then begin
          ; lowpass
            for i=0,nz-1 do begin
              kz = a0*(i gt nz2?i-nz:1)
              idx = where((kdotkvalxy + kz*kval[2]) gt kval2,count)
              if (count gt 0) then (*pData3D)[i*nxy+temporary(idx)] = c0
            end
          end else begin
          ; highpass
            for i=0,nz-1 do begin
              kz = a0*(i gt nz2?i-nz:1)
              idx = where((kdotkvalxy + kz*kval[2]) lt kval2,count)
              if (count gt 0) then (*pData3D)[i*nxy+temporary(idx)] = c0
            end
          end
        end
  else: begin ; assume scalar kval
          k2xy = temporary(kx)^2+temporary(ky)^2
          if not keyword_set(highpass) then begin
          ; lowpass
            for i=0,nz-1 do begin
              k2 = k2xy + (a0*(i gt nz2?i-nz:1))^2
              idx = where(k2 gt kval2,count)
              if (count gt 0) then (*pData3D)[i*nxy+temporary(idx)] = c0
            end
          end else begin
          ; highpass
            for i=0,nz-1 do begin
              k2 = k2xy + (a0*(i gt nz2?i-nz:1))^2
              idx = where(k2 lt kval2,count)
              if (count gt 0) then (*pData3D)[i*nxy+temporary(idx)] = c0
            end
          end
        end 
  endcase
      
  ; transform data back
  *pData3D = fft(*pData3D, /inverse, /overwrite)
  
  if (N_Elements(rettype) eq 0) then rettype = 0
  
  case (rettype) of
    0: *pData3D = abs(temporary(*pData3D))
    1: *pData3D = float(temporary(*pData3D))
    2: *pData3D = imaginary(temporary(*pData3D)) 
  else:
  endcase
  
end

;---------------------------------------------------------------


; ###################################################################################

pro kfilter, pData, kval, HIGHPASS = highpass, RETTYPE = rettype, $
             xaxis = xaxis, yaxis = yaxis, zaxis = zaxis

  help, rettype
 
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

    n = Size(*pData, /N_DIMENSIONS)
    
    if (N_Elements(kval) ne 1) and (N_Elements(kval) ne n) then begin
       res = Error_Message('kval must either be a scalar or a vector with the same number of elements '+$
                           'as the number of dimensions of data')
       return
    end

    if Keyword_Set(time) then begin
      time0 = systime(1)
    end
  
    case (n) of 
       1: kfilter1D, pData, kval, xaxis = xaxis, highpass = highpass, RETTYPE = rettype, $
                     TIME = time
       2: kfilter2D, pData, kval, xaxis = xaxis, yaxis = yaxis, highpass = highpass, RETTYPE = rettype,$
                     TIME = time
       2: kfilter2D, pData, kval, xaxis = xaxis, yaxis = yaxis, zaxis = zaxis, highpass = highpass, $
                     RETTYPE = rettype, TIME = time
    else: begin
           res = Error_Message('*pData must be 1, 2 or 3 Dimensional')
           return
          end
    end  

    if Keyword_Set(time) then begin
      print, 'kfilter, time elapsed (seconds) ', systime(1) - time0
    end

  end else begin
    res = Error_Message('Invalid pData')
    return         
  end

end