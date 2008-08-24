pro MovieColorData, Data, MIN = DataMin, MAX = DataMax, _EXTRA=extrakeys, FRAMELABELS = FLabels,$
                    LOG = UseLogScale
   
  S = Size(Data)
  
  if (S[0] ne 3) then begin
    res = Dialog_Message("Data must be an array with the [NFrames, NX, NY] format"+DirF1 , /Error)
    return
  end
  
  
  NFrames = S[1]
    if (NFrames le 1) then begin
    res = Dialog_Message("Number of frames must be greater than 1 "+DirF1 , /Error)
    return
  end
  
  
  FX = S[2]
  FY = S[3] 
  Print, " Number of frames ", NFrames

  ; Log Scale
   
  if N_Elements(UseLogScale) eq 0 then UseLogScale = 0
  
  if (UseLogScale eq 0) then begin
      ; Unless specified, autoscale DataMin
   
      if N_Elements(DataMin) eq 0 then begin
         DataMin = Min(Data)  
         print, " Autoscaled DataMin to ", DataMin
      end
   
      ; Unless specified, autoscale DataMax
   
      if N_Elements(DataMax) eq 0 then begin
         DataMax = Max(Data)  
         print, " Autoscaled DataMax to ", DataMax
      end 
   
   endif else begin
         
     if N_Elements(DataMax) eq 0 then DataMax = Max(abs(Data))  
    
     if (DataMax eq 0.0) then DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.
      
     if N_Elements(DataMin) eq 0 then begin       ; Autoscales min for the log plot     
         print, Format = '($,A)', " Autoscaling for log plot"
         DataMin = Min(abs(Data))
         if (DataMin eq 0.0) then begin
           idx = Where(abs(Data) gt 0.0, count)
           if (count gt 0) then begin
               logScale = DataMax/Min(abs(Data[idx]))           
               DataMin = DataMax/(2.0*logScale)
           endif else begin
               DataMin = DataMax / 10.0
           end     
           print, "!"
         end
     end    
          
   end
  
  ; Default frame labels
  
  if N_Elements(FLabels) eq 0 then FLabels="Frame " + String(IndGen(NFrames))
 
  Device, Get_Visual_Depth = thisDepth
  If (thisDepth GT 8) Then Device, Decomposed = 0
  Window, XSize = 480, YSize = 360, /Free

  XInterAnimate, Set = [ 480, 360 , NFrames ]

  Data0 = FltArr(FX,FY)
   
  For i=0, NFrames-1 do begin 
    Data0[*,*] = Data[i,*,*]
    
    tmin = DataMin
    tmax = DataMax
    
    if (UseLogScale eq 0) then begin
       PlotColorData, Data0 ,_EXTRA=extrakeys, MIN = tmin, MAX = tmax, SUBTITLE = Flabels[i]
    endif else begin 
       PlotColorData, Data0 ,_EXTRA=extrakeys, MIN = tmin, MAX = tmax, SUBTITLE = Flabels[i], /LOG                  
    end
                
    XInterAnimate, Frame = i, Window = !D.Window
  
    Print, " Created Frame ", i
  end


  WDelete, !D.Window

  ; Starts Animation

  Print, " Launching Animation..."
  XInterAnimate, 10, /Track, TITLE = " TItalo "

end