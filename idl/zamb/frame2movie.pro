;
;  Program:  
;
;  Frame2Movie
;
;  Description:
;
;  Opens a list a frames from a directory and uses XINTERANIMATE to generate
;  a movie with them
;
; ---------------------------------------------------------------------- Main Program -------------

PRO Frame2Movie, $
                ; Directory to Open
                DIRECTORY = DirName, $
                ; Dimensions of the image
                SIZE = movieSize, $
                ; Filter for file selection
                FILTER = FileFilter, $ 
                ; Filenames for the frames
                FILES = filenames, $
                ; FIle types (for forcing a file type)
                TIFF = tiff, JPEG = jpeg, GIF = gif
    
    ; Directory
    
    if N_Elements(DirName) eq 0 then begin  
     DirName = Dialog_PickFile(/Directory)
     if (DirName eq '') then return
    end
    
    CD, DirName

    ; Files Filter
    if N_Elements(FileFilter) eq 0 then FileFilter = '*.gif'
    filefilter = StrLowCase(filefilter)
   
    ; File type
    if KeyWord_Set(tiff) then begin
       filetype = 2
       filefilter = ['*.tif', '*.tiff'] 
    end else if KeyWord_Set(jpeg) then begin
       filetype = 1
       filefilter = ['*.jpg', '*.jpeg']
    end else if KeyWord_Set(gif) then begin
       filetype = 0
       filefilter = ['*.gif']
    end else begin
       case (FileFilter) of
           '.gif': filetype = 0
           '.jpg': filetype = 1
           '.jpeg': filetype = 1
           '.tif': filetype = 2
           '.tiff': filetype = 2
           else: filetype = 0
       endcase
    end

    
    ; File Names

    if N_Elements(FileNames) eq 0 then begin
      count1 = 0
      FileNames = FindFile(FileFilter[0], COUNT = count1)
      if (count1 eq 0) and (N_Elements(FileFilter) gt 1) then begin
        FileNames = FindFile(FileFilter[1], COUNT = count1)
      end
      if (count1 eq 0) then begin
        res = Error_Message('No files found!')
        return
      end 
    end

    ; Inicializa
    
    s = Size(FileNames)
    
    if ((s[0] eq 1) and (s[1] gt 0)) then begin
       
       NFrames = s[1]
       
       case (filetype) of
             0: begin
                  device, get_visual_depth = thisDepth
                  if thisDepth gt 8 then device, decomposed = 0

                  print, 'Reading GIF files...'
                  
                  Read_Gif, FileNames[0], frame, rr, gg, bb
                  TVLCT, rr, gg, bb
                  if N_Elements(movieSize) eq 0 then begin
                    s = size(Frame)
                    movieSize = [s[1],s[2]]
                  end
                  XInterAnimate, Set = [ MovieSize[0], MovieSize[1] , NFrames ], /ShowLoad
 
                  XInterAnimate, Frame = 0, Image = frame
       
                  for i=1, NFrames-1 do begin
                    Read_Gif, FileNames[i], frame, rr, gg, bb      
                    TVLCT, rr, gg, bb
                    XInterAnimate, Frame = i, Image = frame
                  end
                end   
             1: begin
                  print, 'Reading JPEG files...'
                  
                  Read_JPEG, filenames[0], frame
                                  
                  if N_Elements(movieSize) eq 0 then begin
                    s = size(Frame)
                    movieSize = [s[2],s[3]]
                  end
                  Window, /FREE, TITLE = 'Generating movie from JPEG frames...', $
                                 xsize = movieSize[0],ysize = movieSize[1] 
                
                  ;TV, Frame, TRUE = 1
                  tvimage, frame
                  
                  XInterAnimate, Set = [ MovieSize[0], MovieSize[1] , NFrames ]

                  XInterAnimate, Frame = 0, Window = !D.Window
       
                  for i=1, NFrames-1 do begin
                    Read_JPEG, FileNames[i],frame
                    ;TV, Frame, TRUE = 1
                    tvimage, frame
                    XInterAnimate, Frame = i, Window = !D.Window
                  end
                  wdelete
                end   

             2: begin
                  print, 'Reading TIFF files...'
                  Frame = Read_Tiff(FileNames[0], ORDER = order)
                  if (order eq 1) then begin
                     Frame = reverse(temporary(frame),3)
                  end
                
                  if N_Elements(movieSize) eq 0 then begin
                    s = size(Frame)
                    movieSize = [s[2],s[3]]
                  end
                  Window, /FREE, TITLE = 'Generating movie from TIFF frames...', $
                                 xsize = movieSize[0],ysize = movieSize[1] 
                  
                
                  ;TV, Frame, TRUE = 1
                  tvimage, frame
                  
                  XInterAnimate, Set = [ MovieSize[0], MovieSize[1] , NFrames ]

                  XInterAnimate, Frame = 0, Window = !D.Window
       
                  for i=1, NFrames-1 do begin
                    Frame = Read_Tiff( FileNames[i])
                    if (order eq 1) then begin
                     Frame = reverse(temporary(frame),3)
                    end
                    TV, Frame, TRUE = 1
                    XInterAnimate, Frame = i, Window = !D.Window
                  end
                  wdelete
                end   
          else: begin
                  print, 'Filetype ', filetype,' not supported, returning'
                  return
                end
       endcase
     
       
       XInterAnimate, 10, /Track
                 
    end

END