
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Movie_3D_Label, _EXTRA=extrakeys, $
                      ; Directory Information
                      DIRECTORY = DirName, DX = UseDx, DIROUT = dirout, IT0 = t0
      

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory, TITLE = 'Select Data')
  if (DirName eq '') then return
end


CD, DirName

GetOsirisMovieData, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = _N,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames,  $
                    ORIGIN = origin, DELTA = delta,$
                    DATAABSMAX = DATAAbsMax, DATAABSMIN = DATAAbsMin,$
                    DATAPABSMAX = DataPAbsMax, DATAPABSMIN = DATAPAbsMIN, $
                    DATAMAX = DataMax, DATAMIN = DataMin, $
                    DATAPMAX = DataPMax, DATAPMIN = DATAPMIN, DX = UseDX
                                          


; Makes the frame list

help, dirname
framelist = GenFrameList(DirName, IT0 = t0, IT1 = t1, NFRAMES = NFrames, $
                         FRAMEITERS = FrameIters, FRAMETIMES = FrameTimes )



framename = StrArr(NFrames)

if (N_Elements(DirOut) eq 0) then begin
  Dirout = Dialog_PickFile(/Directory, TITLE = 'Select Output folder')
end
cd, dirout

for frame=0, NFrames-1 do begin
  print, ' Frame = ',frame

  framename[frame] =  "label"+ String(byte([ byte('0') +  (frame/1000.0) mod 10 , $
                               byte('0') +  (frame/100.0)  mod 10 , $
                               byte('0') +  (frame/10.0)   mod 10 , $
                               byte('0') +  (frame/1.0)    mod 10 ])) + ".tif" 

  movie_label, _EXTRA=extrakeys, frame+1, NFRAMES = Nframes, FILEOUT = framename[frame] , $
                 Time = 'Time = ' + String( FrameTimes[frame] ,Format='(f8.2)') + ' [ 1 / !Mw!Dp!N ]'
       
  print, "Finished frame ",frame 
end


Print, " Done! "

END