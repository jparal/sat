;---------------------------------------------- local_max_3D ---
; Returns an array with the indexes of the local maximums
; for a 3D array
;---------------------------------------------------------------

function local_max_3D, Data3D, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = noSort, TIMEFUNCTION = timefunction

  if Keyword_Set(timefunction) then begin
    time0 = systime(1)
  end
 
  print, 'Begining local_max_3D'
  print, '-------------------------'

  s = size(Data3D)
  
  if (s[0] ne 3) then begin
    print, 'local_max_3D, Data must be 3-Dimensional'
    return, 0
  end
  
  nx = s[1]
  ny = s[2]
  nz = s[3]

  ; Transform 3D Data to 1D data
  
;  Data3D = temporary(reform(Data3D, nx*ny*nz))
  
  ; find local maximuns
  
  print, 'Finding 1D maximuns...'
  
  ; Implementation 1
  ; list_max_pos = where(Data3D gt median(Data3D,3))  
  
  ; Implementation 2
  list_max_pos = where((data3D lt data3D(1:*)) and (data3D(1:*) gt data3D(2:*)))+1
 
  ; remove edges
  
  nxy = nx*ny

  print, 'Removing Edges...'
  
  list_max_pos = list_max_pos[ where( (((list_max_pos mod nxy) mod nx) gt 0) and (((list_max_pos mod nxy) mod nx) lt nx-1) and $     ;x
                                      (((list_max_pos mod nxy) / nx) gt 0) and (((list_max_pos mod nxy) / nx) lt ny-1) and $         ;y
                                      ((list_max_pos / nxy) gt 0) and ((list_max_pos / nxy) lt nz-1) ) $         				;z
                                       ]

                                      
  ; remove false 3D maximuns

  print, 'Removing false 3D maximuns...'
  
  ; y
  
  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos+nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos-nx]) ) ]

  ; x
  
  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos+nxy]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos-nxy]) ) ]


  ; (z+1)y

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos+1+nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos+1-nx]) ) ]

  ; (z-1)y

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos-1+nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos-1-nx]) ) ]


  ; (z+1)x

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos+1+nxy]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos+1-nxy]) ) ]

  ; (z-1)x

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos-1+nxy]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos-1-nxy]) ) ]

  ; (z+1)x(+y)

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos+1+nxy+nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos+1-nxy+nx]) ) ]

  ; (z+1)x(-y)

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos+1+nxy-nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos+1-nxy-nx]) ) ]

  ; (z-1)x(+y)

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos-1+nxy+nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos-1-nxy+nx]) ) ]

  ; (z-1)x(-y)

  list_max_pos = list_max_pos[ where( (Data3D[list_max_pos] gt Data3D[list_max_pos-1+nxy-nx]) and $
                                      (Data3D[list_max_pos] gt Data3D[list_max_pos-1-nxy-nx]) ) ]


    
  if not Keyword_set(noDerivCheck) then begin

    print, 'Checking derivatives...'
       
    ;Remove points next to edges
    list_max_pos = list_max_pos[ where((((list_max_pos mod nxy) mod nx) gt 1) and (((list_max_pos mod nxy) mod nx) lt nx-2) and $     ;x
                                      (((list_max_pos mod nxy) / nx) gt 1) and (((list_max_pos mod nxy) / nx) lt ny-2) and $         ;y
                                      ((list_max_pos / nxy) gt 1) and ((list_max_pos / nxy) lt nz-2) ) $         				;z
                                       ]
  
    list_max_pos = list_max_pos[ where( $   ; z derivs 
                                        ((Data3D[list_max_pos]-Data3D[list_max_pos - 2])* $
                                         (Data3D[list_max_pos+2] - Data3D[list_max_pos]) lt 0.) and $
                                            ; y derivs
                                        ((Data3D[list_max_pos]-Data3D[list_max_pos - nx])* $
                                         (Data3D[list_max_pos+nx] - Data3D[list_max_pos]) lt 0.) and $
                                            ; x derivs
                                        ((Data3D[list_max_pos]-Data3D[list_max_pos - nxy])* $
                                         (Data3D[list_max_pos+nxy] - Data3D[list_max_pos]) lt 0.) $
                                         )]
   end

  ; Save max values

  print, 'Saving values...'

  list_max_val = Data3D[list_max_pos] 

  ; Transform Data back to 3D
  
;  Data3D = temporary(reform(Data3D, nx,ny, nz))
  
  ; Transform list_max_pos to 3D
  
  list_max_pos = transpose([[(list_max_pos mod nxy) mod nx],[(list_max_pos mod nxy) / nx], [list_max_pos /nxy]])
  
  s = size(list_max_pos)
  n_max = s[2]

  ; Sort Results

  if not Keyword_Set(nosort) then begin 
    print, 'Sorting results...'
    sort_idx = reverse(sort(list_max_val))
    list_max_pos[0,*] = list_max_pos[0,sort_idx]
    list_max_pos[1,*] = list_max_pos[1,sort_idx]
    list_max_pos[2,*] = list_max_pos[2,sort_idx]
    list_max_val = list_max_val[sort_idx]
  end
 
  ; Print Results   

  if KeyWord_Set(verbose) then begin
    print, 'local_max_pos_3D'
    print, '------------------------------------------'
    print, ' Number of local maximums: ', n_max
    for i=0, MIN([3,n_max-1]) do begin
      print, ' Position, Value         : ', list_max_pos[*,i],list_max_val[i] 
    end
  end  

  ; Return results

  if Keyword_Set(timefunction) then begin
    print, 'local_max_3D, time elapsed (seconds) ', systime(1) - time0
  end


  return, list_max_pos

end
