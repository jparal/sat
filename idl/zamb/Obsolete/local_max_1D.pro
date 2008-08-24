;---------------------------------------------- local_max_1D ---
; Returns an array with the indexes of the local maximums
; for a 1D array
;---------------------------------------------------------------

function local_max_1D, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck

  ; Implementation 1
  ;  list_max_pos = where(Data gt median(Data,3))  
  
  ; Implementation 2
  list_max_pos = where((data lt data(1:*)) and (data(1:*) gt data(2:*)))+1
  
  if not Keyword_set(noDerivCheck) then begin
     s = Size(Data)
     nxtop = S[1] - 2
    
     list_max_pos = list_max_pos[ where((list_max_pos gt 1) and (list_max_pos lt nxtop)) ] 

     ; OK but now remove the ones with wrong deriv
  
     list_max_pos = list_max_pos(where((Data[list_max_pos]-Data[list_max_pos - 2])* $
                                       (Data[list_max_pos+2] - Data[list_max_pos]) lt 0.))
  end
  
  s = Size(list_max_pos)
  n_max = s[1]
   
  ; Generate Values

  list_max_val = Data[list_max_pos]

  ; DEBUG
  window, /free
  plot, Data, /ylog, xrange = [450, 550], psym = -2
  oplot, list_max_pos, list_max_val, PSYM = 6    

  
  ; Sort Results

  if not Keyword_Set(nosort) then begin 
    sort_idx = reverse(sort(list_max_val))
    list_max_pos = list_max_pos[sort_idx]
    list_max_val = list_max_val[sort_idx]
  end
 
  ; Print Results   

  if KeyWord_Set(verbose) then begin
    print, 'local_max_1D'
    print, '------------------------------------------'
    print, ' Number of local maximums: ', n_max
    for i=0, MIN([3,n_max-1]) do begin
      print, ' Position, Value         : ', list_max_pos[i],list_max_val[i] 
    end
  end  

  ; Return results

  return, list_max_pos

end


function local_max, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic
  
  s = size(Data, /N_DIMENSIONS)
  
  case s of
    3: return,local_max_3D, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic
    2: return,local_max_2D, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic
    1: return,local_max_1D, Data, VALUES = list_max_val, NMAX = n_max, VERBOSE = verbose, $
                           NOSORT = nosort, NODERIVCHECK = noderivcheck, PERIODIC = periodic
  else: begin
          res = Error_Message('Data must be a 1, 2, or 3 Dimensional array.')        
          return, 0  
        end
  end

end