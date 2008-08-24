;---------------------------------------------- local_max_1D ---
; Returns an array with the indexes of the local maximums
; for a 1D array
;---------------------------------------------------------------

function local_max_1D, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                           THRESHOLD = thresh, TIME = time

  npoints = N_Elements(Data)
  
  if (npoints lt 3) then begin
    res = Error_Message('Data must have 3 or more points')
    return, -1
  end

  if (not Keyword_set(noDerivCheck)) and (npoints lt 5) then begin     
    res = Error_Message('if NODERIVCHECK keyword is not set Data must have 5 or more points')
    return, -1
  end
    

  if (Keyword_Set(noDerivCheck)) then begin  
    ; Get the values that are larger than the two neighbouring values
    list_max_pos = where((data lt data[1:*]) and (data[1:*] gt data[2:*]),n_max)+1
  end else begin
    list_max_pos = where((data      lt data[2:*])    and $
                         (data[1:*] lt data[2:*])    and $
                         (data[2:*] gt data[3:*])    and $
                         (data[2:*] gt data[4:*]), n_max)+2
  end   
  
  
  ; remove points below threshold
  
  if (N_Elements(threshold) ne 0) then begin
    idx = where( data[list_max_pos] ge threshold, n_max)
    if (n_max eq 0) then goto, no_max
    list_max_pos = list_max_pos[temporary(idx)]
  end

    
  if (n_max eq 0) then begin
    n_max = -1
    list_max_pos = [-1]
  end

  if (Keyword_Set(periodic)) then begin
    if (Keyword_Set(noDerivCheck)) then begin
      if (data[0] gt data[npoints-1]) and $
         (data[0] gt data[1]) then begin
          list_max_pos = [list_max_pos,0]
          n_max = n_max + 1
      end else if (data[npoints-1] gt data[npoints-2]) and $
                  (data[0] gt data[1]) then begin
          list_max_pos = [list_max_pos,n_points-1]
          n_max = n_max + 1
      end
    end else begin
      if (data[0] gt data[npoints-2]) and $
         (data[0] gt data[npoints-1]) and $
         (data[0] gt data[1]        ) and $
         (data[0] gt data[2]        ) then begin
        list_max_pos = [list_max_pos,0]
        n_max = n_max + 1
      end else if (data[npoints-1] gt data[npoints-3]) and $
                  (data[npoints-1] gt data[npoints-2]) and $
                  (data[npoints-1] gt data[0]        ) and $
                  (data[npoints-1] gt data[1]        ) then begin
        list_max_pos = [list_max_pos,n_points-1]
        n_max = n_max + 1
      end
    
    end
  end
  
  if (n_max lt 1) then goto, no_max $
  else if (n_max eq 0) then begin
    n_max = 1
    list_max_pos = list_max_pos[1] 
  end
  
  if (not Keyword_Set(nosort)) then begin
    ; Generate values and Sort Results
    list_max_val = Data[list_max_pos]
    sort_idx = reverse(sort(list_max_val))
    list_max_pos = list_max_pos[sort_idx]
    list_max_val = list_max_val[sort_idx]
  end else if Arg_Present(list_max_val) ne 0 then begin
    ; Generate Values
    list_max_val = Data[list_max_pos]
  end
 
  ; Print Results   
  if KeyWord_Set(verbose) then begin
    print, 'local_max_1D'
    print, '------------------------------------------'
    print, ' Number of local maximums: ', n_max
    if (N_Elements(list_max_val) ne 0) then begin
      ; DEBUG
      ; window, /free, TITLE = 'Debug local_max_1D'
      ; plot, data, xrange = [-npoints/10, npoints+npoints/10], xstyle = 1
      ; oplot, list_max_pos, list_max_val, psym = 6

      for i=0, MIN([3,n_max-1]) do $
        print, ' Position, Value         : ', list_max_pos[i],list_max_val[i] 
    end else begin
      for i=0, MIN([3,n_max-1]) do $
        print, ' Position                : ', list_max_pos[i]
    end
  end  

  ; Return results

  return, list_max_pos
  
no_max:  

  if KeyWord_Set(verbose) then begin
    print, 'local_max_1D'
    print, '------------------------------------------'
    print, ' No local maxima found'
  end
  return, -1

end

;---------------------------------------------- local_max_2D ---
; Returns an array with the indexes of the local maximums
; for a 2D array
;---------------------------------------------------------------

pro __is_2D_max, data2D, list_max_pos, nx, ny, dx, dy, n_max, PERIODIC = periodic 
  
  nxy = nx*ny  
  nx_1 = nx-1
  ny_1 = ny-1


  x = list_max_pos mod nx + dx
  y = list_max_pos / nx + dy
  aux1 = list_max_pos + dx + dy*nx  
   
  if keyword_set(periodic) then begin
    ; correct wrong  positions
    
    idx = where( x lt 0, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] + nx
    idx = where( x gt nx_1, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] - nx
    idx = where( y lt 0, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] + nxy
    idx = where( y gt ny_1, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] - nxy
    
    idx = where(data2D[list_max_pos] gt data2D[aux1], n_max)
  end else begin
    ; ignore wrong positions
    idx = where((x ge 0) and (x le nx_1) and $
                 (y ge 0) and (y le ny_1), n_max)
    
    if (n_max ne 0) then begin
      list_max_pos = list_max_pos[idx]
      aux1 = aux1[temporary(idx)]
      idx = where(data2D[list_max_pos] gt data2D[aux1], n_max)
    end 
  end

  if (n_max ne 0) then list_max_pos = list_max_pos[temporary(idx)]
  
end


function local_max_2D, Data2D, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                       NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                       THRESHOLD = threshold, TIME = time, __RECUR_PERIODIC = __recur_periodic, $
                       NOREFORM = noreform    

  s = size(Data2D, /dimensions)
    
  nx = s[0]
  ny = s[1]

  if ((nx lt 3) or (ny lt 3)) then begin
    res = Error_Message('Data must be at least be 3x3 ')
    return, -1
  end

  if (not Keyword_set(noDerivCheck)) and ((nx lt 5) or (ny lt 5)) then begin     
    res = Error_Message('if NODERIVCHECK keyword is not set Data must be at least 5x5')
    return, -1
  end
  
  ; find local maximuns along x
  
;  time0 = systime(1)
  list_max_pos = where((data2D lt data2D[1:*]) and (data2D[1:*] gt data2D[2:*]),n_max)+1
  if (n_max eq 0) then goto, no_max
;  print, 'Time for 1D max = ', systime(1) - time0


  ; remove points below threshold
  
  if (N_Elements(threshold) ne 0) then begin
;    time0 = systime(1)
    idx = where( data2D[list_max_pos] ge threshold, n_max)
;    print, 'Time for threshold = ', systime(1) - time0
    if (n_max eq 0) then goto, no_max
    list_max_pos = list_max_pos[temporary(idx)]
  end
  
  
  ; remove false 2D maximums
  
  ;time0 = systime(1)

  __is_2D_max, data2D, list_max_pos, nx, ny, -1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_2D_max, data2D, list_max_pos, nx, ny, 0, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_2D_max, data2D, list_max_pos, nx, ny, 1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_2D_max, data2D, list_max_pos, nx, ny, -1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_2D_max, data2D, list_max_pos, nx, ny, 0, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_2D_max, data2D, list_max_pos, nx, ny, 1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  
  ;print, 'Time for false 2D maximums = ', systime(1) - time0


  ; Check derivatives
  
  if not Keyword_set(noDerivCheck) then begin

     time0 = systime(1)

     __is_2D_max, data2D, list_max_pos, nx, ny, -2, 0, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_2D_max, data2D, list_max_pos, nx, ny, 2, 0, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_2D_max, data2D, list_max_pos, nx, ny, 0, -2, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_2D_max, data2D, list_max_pos, nx, ny, 0, 2, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max
    
;     print, 'Time for wrong derivatives = ', systime(1) - time0
  end
        
  if (not Keyword_Set(nosort)) then begin
    ; Generate values and Sort Results   
    list_max_val = Data2D[list_max_pos]
    sort_idx = reverse(sort(list_max_val))
    list_max_pos = list_max_pos[sort_idx]
    list_max_val = list_max_val[sort_idx]
  end else if (N_Elements(list_max_val) ne 0) or $
              (N_Elements(threshold) ne 0) then begin
    ; Generate Values
    list_max_val = Data2D[list_max_pos]
  end

  ; Transform list_max_pos to 2D
  
  if (keyword_set(noreform)) then begin
    ; Print Results   
    if KeyWord_Set(verbose) then begin
      print, 'local_max_2D'
      print, '------------------------------------------'
      print, ' Number of local maximums: ', n_max
      if (N_Elements(list_max_val) ne 0) then begin
          for i=0, MIN([10,n_max-1]) do $
          print, ' Position, Value         : ', list_max_pos[i],list_max_val[i] 
      end else begin
        for i=0, MIN([10,n_max-1]) do $
          print, ' Position                : ', list_max_pos[i]
      end
    end  
  
  end else begin
    list_max_pos = transpose([[temporary(list_max_pos mod nx)],[temporary(list_max_pos / nx)]])
 
    ; Print Results   
    if KeyWord_Set(verbose) then begin
      print, 'local_max_2D'
      print, '------------------------------------------'
      print, ' Number of local maximums: ', n_max
      if (N_Elements(list_max_val) ne 0) then begin
          for i=0, MIN([10,n_max-1]) do $
          print, ' Position, Value         : ', list_max_pos[*,i],list_max_val[i] 
      end else begin
        for i=0, MIN([10,n_max-1]) do $
          print, ' Position                : ', list_max_pos[*,i]
      end
    end  
  end
  
  ; Return results

  return, list_max_pos
  
no_max:  

  if KeyWord_Set(verbose) then begin
    print, 'local_max_2D'
    print, '------------------------------------------'
    print, ' No local maxima found'
  end
  return, -1

end

;---------------------------------------------- local_max_3D ---
; Returns an array with the indexes of the local maximums
; for a 3D array
;---------------------------------------------------------------


pro __is_3D_max, data3D, list_max_pos, nx, ny, nz, dx, dy, dz, n_max, PERIODIC = periodic 
  
  nxy = nx*ny  
  nxyz = nxy*nz
  nx_1 = nx-1
  ny_1 = ny-1
  nz_1 = nz-1

  aux1 = list_max_pos + dx + dy*nx + dz*nxy
  i1 = list_max_pos mod nxy
  x = i1 mod nx + dx
  y = i1 / nx + dy
  z = list_max_pos/nxy + dz

 
  if keyword_set(periodic) then begin
    ; correct wrong positions
    
    idx = where( x lt 0, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] + nx
    idx = where( x gt nx_1, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] - nx
    
    idx = where( y lt 0, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] + nxy
    idx = where( y gt ny_1, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] - nxy
     
    idx = where( z lt 0, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] + nxyz
    idx = where( z gt nz_1, n_idx )
    if (n_idx ne 0) then aux1[idx] = aux1[idx] - nxyz

    idx = where(data3D[list_max_pos] gt data3D[aux1], n_max)
      
  end else begin

    ; delete wrong positions
    idx = where((x gt 0) and (x lt nx_1) and $
                 (y gt 0) and (y lt ny_1) and $
                 (z gt 0) and (z lt nz_1), n_max)

    if (n_max ne 0) then begin
      list_max_pos = list_max_pos[idx]
      aux1 = aux1[temporary(idx)]
      idx = where(data3D[list_max_pos] gt data3D[aux1], n_max)
    end 

  end
    
  if (n_max ne 0) then list_max_pos = list_max_pos[temporary(idx)]

end


function local_max_3D, Data3D, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                           THRESHOLD = thresh, TIME = time

  s = size(Data3D, /dimensions)
    
  nx = s[0]
  ny = s[1]
  nz = s[2]

  if ((nx lt 3) or (ny lt 3) or (nz lt 3)) then begin
    res = Error_Message('Data must be at least be 3x3x3 ')
    return, -1
  end

  if (not Keyword_set(noDerivCheck)) and ((nx lt 5) or (ny lt 5) or (nz lt 5)) then begin     
    res = Error_Message('if NODERIVCHECK keyword is not set Data must be at least 5x5x5')
    return, -1
  end

  nxy = nx*ny

  ; find 2D maximums 
  
  n_max = 0
  if keyword_Set(periodic) then begin
    i0 = 0
    i1 = nz-1
  end else begin
    ; if not periodic ignore edges
    i0 = 1
    i1 = nz-2
  end
  
  time0 = systime(1)
  
  for i=i0,i1 do begin
    list_max_pos_2D = local_max_2D(reform(Data3D[*,*,i]),  NMAX = n_max_2D, /nosort,  $
                                   THRESHOLD = thresh, /NODERIVCHECK, $
                                   PERIODIC = periodic, /noreform)
    if (n_max_2D gt 0) then begin
      list_max_pos_2D = temporary(list_max_pos_2D) + i*nxy
      if (n_max eq 0) then list_max_pos = list_max_pos_2D  $
      else list_max_pos = [list_max_pos, list_max_pos_2D ]
      n_max = n_max + n_max_2D
    end  
  end

  print, 'local_max_3D, Time for 2D maximums = ', systime(1) - time0
      
  ; remove false 3D maximuns
  
  ;****************************
  ;*                          *
  ;* Data3D[nx,ny,nz]         *
  ;*                          *
  ;* idx = x + nx*y + nx*ny*z *
  ;*                          *
  ;****************************

  time0 = systime(1)

  __is_3D_max, data3D, list_max_pos, nx, ny, nz, -1, -1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,0, -1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,1, -1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,-1, 0, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,0, 0, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,1, 0, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,-1, 1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,0, 1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,1, 1, -1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max
  
  __is_3D_max, data3D, list_max_pos, nx, ny, nz,-1, -1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,0, -1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,1, -1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, nx, nz,-1, 0, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,0, 0, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,1, 0, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,-1, 1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,0, 1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  __is_3D_max, data3D, list_max_pos, nx, ny, nz,1, 1, 1, n_max, PERIODIC = periodic
  if (n_max eq 0) then goto, no_max

  
  print, 'local_max_3D, Time for false 3D maximums = ', systime(1) - time0

  ; Check derivatives
  
  if not Keyword_set(noDerivCheck) then begin

     time0 = systime(1)

     __is_3D_max, data3D, list_max_pos, nx, ny, nz, -2, 0, 0, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_3D_max, data3D, list_max_pos, nx, ny, nz, 2, 0, 0, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_3D_max, data3D, list_max_pos, nx, ny, nz, 0, -2, 0, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_3D_max, data3D, list_max_pos, nx, ny, nz, 0, 2, 0, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_3D_max, data3D, list_max_pos, nx, ny, nz, 0, 0, -2, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max

     __is_3D_max, data3D, list_max_pos, nx, ny, nz, 0, 0, 2, n_max, PERIODIC = periodic
     if (n_max eq 0) then goto, no_max
    
     print, 'local_max_3D, Time for wrong derivatives = ', systime(1) - time0
  end
 
  if (not Keyword_Set(nosort)) then begin
    ; Generate values and Sort Results
    list_max_val = Data3D[list_max_pos]
    sort_idx = reverse(sort(list_max_val))
    list_max_pos = list_max_pos[sort_idx]
    list_max_val = list_max_val[sort_idx]
  end else if N_Elements(list_max_val) ne 0 then begin
    ; Generate Values
    list_max_val = Data3D[list_max_pos]
  end
 
  ; Transform list_max_pos to 3D
  
  if (keyword_set(noreform)) then begin
    ; Print Results   
    if KeyWord_Set(verbose) then begin
      print, ''
      print, 'local_max_3D'
      print, '-------------------------------------------------------------------------------'
      print, ' Number of local maximums: ', n_max
      if (N_Elements(list_max_val) ne 0) then begin
          for i=0, MIN([10,n_max-1]) do $
          print, ' Position, Value         : ', list_max_pos[i],list_max_val[i] 
      end else begin
        for i=0, MIN([10,n_max-1]) do $
          print, ' Position                : ', list_max_pos[i]
      end
    end  
  
  end else begin
    list_max_pos = transpose([[(list_max_pos mod nxy) mod nx], $
                              [(list_max_pos mod nxy)/nx],$
                              [list_max_pos / nxy]])
 
    ; Print Results   
    if KeyWord_Set(verbose) then begin
      print, ''
      print, 'local_max_3D'
      print, '-------------------------------------------------------------------------------'
      print, ' Number of local maximums: ', n_max
      if (N_Elements(list_max_val) ne 0) then begin
          for i=0, MIN([10,n_max-1]) do $
          print, ' Position, Value         : ', list_max_pos[*,i],list_max_val[i] 
      end else begin
        for i=0, MIN([10,n_max-1]) do $
          print, ' Position                : ', list_max_pos[*,i]
      end
    end  
  end

  ; Return results

  return, list_max_pos
  
no_max:  

  if KeyWord_Set(verbose) then begin
    print, 'local_max_3D'
    print, '------------------------------------------'
    print, ' No local maxima found'
  end
  return, -1

end

;-------------------------------------------------------------------------------------------------

function local_max, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                           THRESHOLD = thresh, TIME = time
  
  s = size(Data, /N_DIMENSIONS)
  
  case s of
    3: return,local_max_3D( Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                           THRESHOLD = thresh, TIME = time )
    2: return,local_max_2D( Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                           THRESHOLD = thresh, TIME = time )
    1: return,local_max_1D( Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $ 
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic, $
                           THRESHOLD = thresh, TIME = time )
  else: begin
          res = Error_Message('Data must be a 1, 2, or 3 Dimensional array.') 
          n_max = 0       
          return, 0  
        end
  end

end