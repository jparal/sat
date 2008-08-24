function GenFrameList, DirName, IT0 = t0, IT1 = t1, NFRAMES = NFrames, FRAMEITERS = FrameIters,$
                                DIMS = Dims, FRAMETIMES = FrameTimes, _EXTRA=extrakeys 


  CD, DirName

  If (N_Elements(Dims) eq 0) then Dims = 3
 
  print, 'GenFrameList, Dims = ', Dims
  
  case (Dims) of
   3:GetOsirisMovieData3D, DIRECTORY = DirName, /Silent, NFRAMES = NF0, $
                    ITERS = Iters, TIMES = times
   2:GetOsirisMovieData2D, DIRECTORY = DirName, /Silent, NFRAMES = NF0, $
                    ITERS = Iters, TIMES = times
   1:GetOsirisMovieData1D, DIRECTORY = DirName, /Silent, NFRAMES = NF0, $
                    ITERS = Iters, TIMES = times 
  end                  
                   
  deltaIters = intArr(NF0-1)
  
  for i=1, NF0-1 do deltaIters[i-1] = iters[i] - iters[i-1] 
  deltaiters = Min(deltaIters,min_pos)
  
  deltatime = times[min_pos+1]-times[min_pos]
  

  ; Initial iteration  
  
  if (N_Elements(t0) eq 0) then begin    
    t0 = iters[0]
    j0 = 0      ; start working on the first frame supplied
    NF1 = NF0  ; Use all the files supplied  
  end else begin
    if (t0 ge Iters[NF0 - 1]) then begin
      print, 'GenFrameList - IT0 must be less than the iteration number of the last frame supplied'
      return, 0 
    end
    
    _t0 = float(iters[0])
    _DT0 = float(t0 - _t0)/deltaIters
    
    if (_DT0 ne long(_DT0)) then begin
      print, 'GenFrameList - IT0 must be separated of the iteration number of the first frame supplied'
      print, '(_IT0) by an integer number of DeltaIter'
      print, 'IT0       =', t0
      print, '_IT0      =', _t0
      print, 'DeltaITer =', deltaIters
      return, 0 
    end
    
    if (_DT0 le 0.) then begin
      j0 = 0      ; start working on the first frame supplied
      NF1 = NF0  ; Use all the files supplied  
    end else begin
      j0 = 0
      while (iters[j0] lt t0) do j0 = j0+1 ; Start with the first file ge than t0
      NF1 = NF0 - j0 ; Use all the files minus the ones skipped
    end
  end  

  mintime = times[j0]

  ; Final iteration

  help, t1
  help, iters[NF0 - 1]
   
  if (N_Elements(t1) eq 0) then begin
    t1 = iters[NF0 - 1]
  end else begin
    if (t1 lt t0 + deltaiters) then begin
      print, 'GenFrameList - IT1 must be ge than IT0 + DeltaIter'
      return, 0 
    end
  end

  ; Calculate number of blank frames
  
  blankframes = 0
  t = t0
  j = j0  
;  repeat begin
;    if (iters[j] ne t) then repeat begin
;      blankframes = blankframes + 1
;      t = t + deltaIters
;      if (blankframes ge (10*NF0)) then begin
;        print, 'GenFrameList - Error, BlankFrames ge than 10 times the number of supplied frames' 
;        return, 0
;      end         
;    end until (iters[j] eq t)  
;    j = j + 1
;    t = t + deltaIters
;  end until (j eq NF0)

  NFrames = NF1 + blankframes
    
  ; Generate framelist
  
  framelist = LonArr(NFrames)
  
  frameIters = FindGen(NFrames) * deltaIters +  t0
  
  j = j0
  
  for i = 0, NFrames - 1 do begin
     if (frameIters[i] ne iters[j]) then begin
       framelist[i] = -1       
     end else begin
       framelist[i] = j       
       j = j + 1
     end
  end
  
  ; Remove excess frames

  i = 0
  
  while (frameiters[NFrames-1-i] gt t1) do i = i + 1
  NFrames = NFrames - i
  framelist = framelist[0 : NFrames-1]
  frameIters = frameIters[ 0 : NFrames-1]  
  
  frametimes = mintime + FIndGen(NFrames)*deltatime
  
  
  return, framelist
end