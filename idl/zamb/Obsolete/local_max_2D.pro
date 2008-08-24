;---------------------------------------------- local_max_2D ---
; Returns an array with the indexes of the local maximums
; for a 2D array
;---------------------------------------------------------------

function local_max_2D, Data2D, VALUES = list_max_val, NMAX = n_max, $
                       VERBOSE = verbose, NOSORT = noSort

  s = size(Data2D)
  
  if (s[0] ne 2) then begin
    print, 'local_max_2D, Data must be 2-Dimensional'
    return, 0
  end
  
  nx = s[1]
  ny = s[2]

  
  ; Transform 2D Data to 1D data
  
;  Data2D = temporary(reform(Data2D, nx*ny))
  
  ; find local maximuns
  

;  list_max_pos = where(Data2D gt median(Data2D,3))  

   list_max_pos = where((Data2D lt Data2D[1:*]) and (Data2D[1:*] gt Data2D[2:*])) + 1
  
  ; remove edges
  
  list_max_pos = list_max_pos[ where( ((list_max_pos mod nx) gt 0) and ((list_max_pos mod nx) lt nx-1) and $
                                      ((list_max_pos / nx) gt 0) and ((list_max_pos / nx) lt ny-1) ) ]

                                      
  ; remove false 2D maximuns

  ; (y, x+1),(y, x-1)
  
  list_max_pos = list_max_pos[ where( (Data2D[list_max_pos] gt Data2D[list_max_pos+nx]) and $
                                      (Data2D[list_max_pos] gt Data2D[list_max_pos-nx]) ) ]
 
  ; (y+1, x+1),(y-1, x-1)
  
  list_max_pos = list_max_pos[ where( (Data2D[list_max_pos] gt Data2D[list_max_pos+nx+1]) and $
                                      (Data2D[list_max_pos] gt Data2D[list_max_pos-nx-1]) ) ]
  
  ; (y-1, x+1),(y+1, x-1)
  
  list_max_pos = list_max_pos[ where( (Data2D[list_max_pos] gt Data2D[list_max_pos+nx-1]) and $
                                      (Data2D[list_max_pos] gt Data2D[list_max_pos-nx+1]) ) ]

    
  if not Keyword_set(noDerivCheck) then begin
     
      ;Remove points next to edges
      list_max_pos = list_max_pos[ where( ((list_max_pos mod nx) gt 1) and ((list_max_pos mod nx) lt nx-2) and $
                                          ((list_max_pos / nx) gt 1) and ((list_max_pos / nx) lt ny-2) ) ]
  
      list_max_pos = list_max_pos( where( $ ; y derivs 
                                        ((Data2D[list_max_pos]-Data2D[list_max_pos - 2])* $
                                         (Data2D[list_max_pos+2] - Data2D[list_max_pos]) lt 0.) and $
                                            ; x derivs
                                        ((Data2D[list_max_pos]-Data2D[list_max_pos - 2*nx])* $
                                         (Data2D[list_max_pos+2*nx] - Data2D[list_max_pos]) lt 0.) and $
                                            ; (y+1, x+1),(y-1, x-1) derivs
                                        ((Data2D[list_max_pos]-Data2D[list_max_pos - 2*nx - 2])* $
                                         (Data2D[list_max_pos+2*nx+2] - Data2D[list_max_pos]) lt 0.) and $
                                            ; (y-1, x+1),(y+1, x-1) derivs
                                        ((Data2D[list_max_pos]-Data2D[list_max_pos - 2*nx + 2])* $
                                         (Data2D[list_max_pos+2*nx-2] - Data2D[list_max_pos]) lt 0.) $
                                   ))
   end

  ; Save max values

  list_max_val = Data2D[list_max_pos] 

  ; Transform Data back to 2D
  
;  Data2D = temporary(reform(Data2D, nx,ny))
  
  ; Transform list_max_pos to 2D
  
  list_max_pos = transpose([[list_max_pos mod nx],[list_max_pos / nx]])
  print, 'step 4'
  help, list_max_pos

  s = size(list_max_pos)
  n_max = s[2]

  

  ; Sort Results

  if not Keyword_Set(nosort) then begin 
     sort_idx = reverse(sort(list_max_val))
     list_max_pos[0,*] = list_max_pos[0,sort_idx]
     list_max_pos[1,*] = list_max_pos[1,sort_idx]
     list_max_val = list_max_val[sort_idx]
  end
 
;  window, /free
;  plot2d, Data2D, /zlog
;  oplot, list_max_pos[0,0:10],list_max_pos[1,0:10], PSYM = 6

  ; Print Results   

  if KeyWord_Set(verbose) then begin
    print, 'local_max_2D'
    print, '------------------------------------------'
    print, ' Number of local maximums: ', n_max
    for i=0, MIN([3,n_max-1]) do begin
       print, ' Position, Value         : ', list_max_pos[*,i],list_max_val[i] 
    end
  end  

  ; Return results

  return, list_max_pos

end
