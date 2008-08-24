;
;  Program:
;
;  Visualize
;
;  Description:
;
;  Takes a set of graphics containers as parameters and provides the 
;  tool for visualization



;**********************************************************************
;************************************** Auxiliary Graphics Routines ***
;**********************************************************************

pro Visualize_Redraw, sState
   widget_control, /hourglass
   sState.oWindow->Draw, sState.oView
end

; --------------------------------- Visualize_UpdateInvColors_Event ---
;  Handles Changes to the Invert Color setting
; ---------------------------------------------------------------------

pro Visualize_UpdateInvColors_Event, sEvent

  clWhite = [255b,255b,255b]
  clBlack = [0b,0b,0b]

  Widget_Control, sEvent.id, GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  sState.iInvColors = Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)
  
  if (sState.iInvColors eq 1) then begin
    oObjects = sState.oBoxModel -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    oObjects = sState.oAxisModel -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    oObjects = sState.oLabelModel -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    sState.oView -> SetProperty, COLOR = clWhite
  end else begin
    oObjects = sState.oAxisBoxModel -> Get(/ALL, COUNT = nObjects)    
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clWhite
    end
    oObjects = sState.oLabelModel -> Get(/ALL, COUNT = nObjects)    
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clWhite
    end
    sState.oView -> SetProperty, COLOR = clBlack
  end

  Visualize_Redraw, sState                    
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; --------------------------------- Visualize_UpdateProjection_Event ---
;  Handles Changes to the Projection setting
; ---------------------------------------------------------------------

pro Visualize_UpdateProjection_Event, sEvent

  Widget_Control, sEvent.id, GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  sState.iProjection = Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)
  
  if (sState.iProjection eq 1) then begin
    sState.oView -> SetProperty, PROJECTION = 1
  end else begin
    sState.oView -> SetProperty, PROJECTION = 2
  end

  Visualize_Redraw, sState                    
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ----------------------------------------------- Visualize_Cleanup ---
;  Handles cleanup events. Called when window is closed
; ---------------------------------------------------------------------

PRO Visualize_Cleanup, tlb

  ;  print, 'Cleaning up 1'

   ; Come here when program dies. Free all created objects.

   Widget_Control, tlb, Get_UValue=sState, /No_Copy
   if N_Elements(sState) ne 0 then begin     
     ; print, 'Cleaning up 2'
     
     ; Destroy Models     

     Obj_Destroy, sState.oView

     Obj_Destroy, sState.oContainer
     OBJ_DESTROY, sState.oLabelModel
     OBJ_DESTROY, sState.oAxisBoxModel
     OBJ_DESTROY, sState.oVisualizeModels

     ; print, 'Cleaning up Done!'
      
   end
END


; ---------------------------------------- SaveTIFF_Visualize_Event ---
;  Handles SaveTIFF events
; ---------------------------------------------------------------------

pro SaveTIFF_Visualize_Event, sEvent

   tifffileout = Dialog_PickFile(/write, FILTER = '*.tif',$
           TITLE = 'Save TIFF file as...', GET_PATH = tifffilepath)
                        
   if (tifffileout ne '') then begin
     cd, tifffilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oWindow -> GetProperty, Dimension = ImageResolution
             
     myimage = sState.oWindow -> Read()
     myimage -> GetProperty, DATA = imageout
     Obj_Destroy, myimage
        
     imageout = reverse(imageout,3)
     WRITE_TIFF, tifffileout, imageout, 1
         
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end


; ---------------------------------------- SaveVRML_Visualize_Event ---
;  Handles SaveVRML events
; ---------------------------------------------------------------------

pro SaveVRML_Visualize_Event, sEvent
;   print, 'Save Vrml not implemented yet'

   vrmlfileout = Dialog_PickFile(/write, FILTER = '*.vrml',$
                        TITLE = 'Save VRML file as...', GET_PATH = vrmlfilepath)
   if (vrmlfileout ne '') then begin
     cd, vrmlfilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oWindow -> GetProperty, Dimension = ImageResolution
               
     oVRML = obj_new('IDLgrVRML',DIMENSIONS=ImageResolution)
     oVRML-> SetProperty, FILENAME = vrmlfileout
     oVRML-> SetProperty, WORLDTITLE = sState.Title1
     oVRML-> SetProperty, WORLDINFO = sSate.Title2
     oVRML-> Draw, sState.oView
     Obj_Destroy, oVRML
     
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end

; --------------------------------------- PageSetup_Visualize_Event ---
;  Handles Page Setup events
; ---------------------------------------------------------------------

pro PageSetup_Visualize_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  res = Dialog_PrinterSetup(sState.oPrinter) 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ------------------------------------------- Print_Visualize_Event ---
;  Handles Print events
; ---------------------------------------------------------------------

pro Print_Visualize_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  res = Dialog_PrintJob(sState.oPrinter) 
  if (res ne 0) then begin
    sState.oPrinter -> SetProperty, Units = 2
    sState.oPrinter -> GetProperty, Dimensions = DimPrinter
;    print, 'Printer Dimensions [cm]: ', DimPrinter

    ; Get the correct aspect ratio
    sState.oWindow -> GetProperty, Dimension = DimImage
    ratios = float(DimImage)/DimPrinter
    NewViewDimensions = ratios/Max(Ratios)
    sState.oView -> Getproperty, UNITS = ViewUnits
    sState.oView -> Getproperty, DIMENSIONS = ViewDimensions
    sState.OView -> SetProperty, UNITS = 3
    sState.oView -> SetProperty, DIMENSIONS = NewViewDimensions   
    
    ; Draw the view
    sState.oPrinter-> Draw, sState.oView
    
    ; Restore the view
    sState.oView -> Setproperty, UNITS = ViewUnits
    sState.oView -> Setproperty, DIMENSIONS = ViewDimensions
    
    ; Start the printing job
    sState.oPrinter-> NewDocument
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------- ClipCopy_Visualize_Event ---
;  Handles Copy events
; ---------------------------------------------------------------------

pro ClipCopy_Visualize_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oWindow -> GetProperty, Dimension = ImageResolution
             
  oClipboard = obj_new('IDLgrClipboard',DIMENSIONS=ImageResolution)
  oClipboard-> Draw, sState.oView
  Obj_Destroy, oClipboard

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end


; ---------------------------------------- AntiAlias_Visualize_Event ---
;  Handles AntiAlias events
; ---------------------------------------------------------------------

pro AntiAlias_Visualize_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  SceneAntiAlias, sState.oWindow, sState.oView, sState.iAntiAlias
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ------------------------------------------ Resize_Visualize_Event ---
;  Handles resize events
; ---------------------------------------------------------------------

pro Resize_Visualize_Event, sEvent
        ; Get sState structure from base widget
        Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

        wsx =  sEvent.x - 12   
        wsy =  sEvent.y - 12 - 2*20 
        
        ; Resize the draw widget.
        
        sState.oWindow->SetProperty, Dimensions=[wsx, wsy]
        
        ; Change ViewPlane to account for assimetry
        if (sEvent.x lt sEvent.y) then begin
           xsize = 2.
           ysize = 2. * wsy / float(wsx)
        end else begin
           xsize = 2. * wsx / float(wsy)
           ysize = 2.
        end
        sState.oView->SetProperty, ViewPlane_Rect=[-xsize/2.,-ysize/2., xsize, ysize]  
        ; Update Label Positions
        oObjects = sState.oLabelModel -> Get(/ALL, COUNT = nObjects) 
        for i=0,nObjects-1 do begin
           oObjects[i] -> GetProperty, Location = location
           location = location * [xsize/float(sState.view_size[0]),ysize/float(sState.view_size[1]), 1.] 
           oObjects[i] -> SetProperty, Location = location
        end
        sState.view_size = [xsize, ysize]
        sState.window_size = [wsx, wsy]
        
        ; Update Font Sizes
        maxRES = MAX(sState.window_size)
        SizeFontTitle = float(sState.FontSize*0.025*maxRES)
        SizeFontSubTitle = float(sState.FontSize*0.022*maxRES)
        SizeFontAxis = float(sState.FontSize*0.022*maxRES)
        sState.FontTitle -> SetProperty, SIZE = SizeFontTitle
        sState.FontSubTitle -> SetProperty, SIZE = SizeFontSubTitle
        sState.FontAxis -> SetProperty, SIZE = SizeFontAxis

        ; Redisplay the graphic.
        Visualize_Redraw, sState
        ; Update the trackball objects location in the center of the
        ; window.
        sState.oTrack->Reset, [sEvent.x/2., sEvent.y/2.], $
            (sEvent.y/2.) < (sEvent.x/2.)
        
        ;Put the info structure back.
        Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ------------------------------------ Visualize_Update_Tools_Event ---
;  Handles update tools events
; ---------------------------------------------------------------------

pro Visualize_Update_Tools_Event, sEvent
    Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
    sState.iTool = sEvent.value
    ;print, 'Selected tool number ', sState.itool
    Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; -------------------------------------- Visualize_Default_Position ---
;  Moves and scales the object to the default values
; ---------------------------------------------------------------------

pro Visualize_Default_Position, oModel, $
						Xmin,Xmax,Ymin,Ymax, Zmin, Zmax, $
						zoomfactor, AxisScale

print, 'In Visualize Default Position'

  ; Translates to the center of universe and scales to [-1,1]

  oModel -> Translate, - (Xmin + Xmax)/2., - (Ymin + YMax)/2., - (Zmin + Zmax)/2.
  oModel -> Scale, 1.15*zoomfactor*AxisScale[0]/(Xmax-Xmin),$
                   1.15*zoomfactor*AxisScale[1]/(Ymax-Ymin),$
                   1.15*zoomfactor*AxisScale[2]/(Zmax-Zmin)
end

; -------------------------------------- Visualize_Default_Rotation ---
;  Moves and scales the object to the default values
; ---------------------------------------------------------------------

pro Visualize_Default_Rotation, oModel, $
						ax,az

print, 'In Visualize Default Rotation'

  ; Rotates in a manner similar to direct graphics

   oModel -> Rotate, [1,0,0], -90
   oModel -> Rotate, [0,1,0], ax
   oModel -> Rotate, [1,0,0], az

end


; --------------------------------------- Visualize_ViewReset_Event ---
;  Handles View Reset events
; ---------------------------------------------------------------------

pro Visualize_ViewReset_Event, sEvent
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

   sState.oVisualizeModels -> Reset
   sState.oAxisBoxModel -> Reset
   
   Visualize_Default_Scale, sState.oVisualizeModels, sState.zoomfactor, sState.AxisScale
   Visualize_Default_Scale, sState.oAxisBoxModel, sState.zoomfactor, sState.AxisScale
   
   ; Rotates the Model
  
   Visualize_Default_Rotation, sState.oAxisBoxModel, sState.ax, sState.az
   Visualize_Default_Rotation, sState.oVisualizeModels, sState.ax, sState.az
   
   Visualize_Redraw, sState                    
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ------------------------------------- Visualize_ViewReverse_Event ---
;  Handles View Reverse events
; ---------------------------------------------------------------------

pro Visualize_ViewReverse_Event, sEvent
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

   sState.oVisualizeModels -> Rotate, [0,1,0], -180
   sState.oAxisBoxModel -> Rotate, [0,1,0], -180
      
   Visualize_Redraw, sState                    
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------- Visualize_ViewSide_Event ---
;  Handles View Side events
; ---------------------------------------------------------------------

pro Visualize_ViewSide_Event, sEvent
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

   sState.oVisualizeModels -> Reset
   sState.oAxisBoxModel -> Reset
   
   Visualize_Default_Scale, sState.oVisualizeModels, sState.zoomfactor, sState.AxisScale
   Visualize_Default_Scale, sState.oAxisBoxModel, sState.zoomfactor, sState.AxisScale

   ; Rotates the Model
  
   Visualize_Default_Rotation, sState.oAxisBoxModel, 0, 0
   Visualize_Default_Rotation, sState.oVisualizeModels, 0, 0

      
   Visualize_Redraw, sState                    
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ----------------------------------------- Visualize_ViewTop_Event ---
;  Handles View top events
; ---------------------------------------------------------------------

pro Visualize_ViewTop_Event, sEvent

   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

   sState.oVisualizeModels -> Reset
   sState.oAxisBoxModel -> Reset
   
   Visualize_Default_Scale, sState.oVisualizeModels, sState.zoomfactor, sState.AxisScale
   Visualize_Default_Scale, sState.oAxisBoxModel, sState.zoomfactor, sState.AxisScale

   ; Rotates the Model (not necessary; this rotation doesn't do anything)
  
   ; Visualize_Default_Rotation, sState.oAxisBoxModel, 0, 90
   ; Visualize_Default_Rotation, sState.oVisualizeModels, 0, 90
   
      
   Visualize_Redraw, sState                    
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; --------------------------------------- Visualize_ViewFront_Event ---
;  Handles View Front events
; ---------------------------------------------------------------------

pro Visualize_ViewFront_Event, sEvent

   print, 'View Front'
  
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

   sState.oVisualizeModels -> Reset
   sState.oAxisBoxModel -> Reset
   
   Visualize_Default_Scale, sState.oVisualizeModels, sState.zoomfactor, sState.AxisScale
   Visualize_Default_Scale, sState.oAxisBoxModel, sState.zoomfactor, sState.AxisScale
   
   ; Rotates the Model
  
   Visualize_Default_Rotation, sState.oAxisBoxModel, 90, 0
   Visualize_Default_Rotation, sState.oVisualizeModels, 90, 0
   
   Visualize_Redraw, sState                    
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------


; ------------------------------------- Visualize_AnimRotateZ_Event ---
;  Handles Rotate (Z) animation events
; ---------------------------------------------------------------------

pro Visualize_AnimRotateZ_Event, sEvent
    
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
   
   NumFramesAnimation = 48
   delta_angle = 360.0/(NumFramesAnimation)
   framename = StrArr(NumFramesAnimation)

   ; Get Axis of rotation

   sState.oVisualizeModels -> GetProperty, Transform = tmatrix    
   zaxis = reform([0,0,1,0] # tmatrix)
   zaxis = zaxis[0:2]

   oProgressBar = Obj_New("SHOWPROGRESS", sEvent.top,$
                          /cancelbutton, $
                          TITLE = 'Animating...', $
                          MESSAGE = 'Rotating Models' $
                           )
begin_loop:
 
   oProgressBar -> Start
 
   for i = 0, NumFramesAnimation-1 do begin
     framename[i] =  "anim"+ String(byte([ byte('0') +  (i/1000.0) mod 10 , $
                              byte('0') +  (i/100.0)  mod 10 , $
                              byte('0') +  (i/10.0)   mod 10 , $
                              byte('0') +  (i/1.0)    mod 10 ])) + ".tiff" 

     sState.oVisualizeModels -> Rotate, zaxis, delta_angle
     sState.oAxisBoxModel    -> Rotate, zaxis, delta_angle
     
     Visualize_Redraw, sState                    

     if (oProgressBar -> CheckCancel()) then goto, end_loop

     if (sState.iSaveFrames eq 1) then begin             
       myimage = sState.oWindow -> Read()
       myimage -> GetProperty, DATA = imageout
       Obj_Destroy, myimage
        
       imageout = reverse(imageout,3)
       WRITE_TIFF, framename[i], imageout, 1
     end
     oProgressBar -> Update, (100.0*i)/(NumFramesAnimation-1)
   end

   if (sState.iLoopAnimate eq 1b) and (sState.iSaveFrames eq 0) then goto, begin_loop
end_loop:

   oProgressBar -> Destroy
   Obj_Destroy, oProgressBar

   if (sState.iSaveFrames eq 1) then begin             
     cd, current = path
     Frame2Movie, DIRECTORY = path, FILES = framename, /tiff
   end
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; ------------------------------------- Visualize_AnimRotateY_Event ---
;  Handles Rotate (Y) animation events
; ---------------------------------------------------------------------

pro Visualize_AnimRotateY_Event, sEvent
    
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
   
   NumFramesAnimation = 48
   delta_angle = 360.0/(NumFramesAnimation)
   framename = StrArr(NumFramesAnimation)

   ; Get Axis of rotation

   sState.oVisualizeModels -> GetProperty, Transform = tmatrix    
   yaxis = reform([0,1,0,0] # tmatrix)
   yaxis = yaxis[0:2]

   oProgressBar = Obj_New("SHOWPROGRESS", sEvent.top,$
                          /cancelbutton, $
                          TITLE = 'Animating...', $
                          MESSAGE = 'Rotating Models' $
                           )
begin_loop:
 
   oProgressBar -> Start
 
   for i = 0, NumFramesAnimation-1 do begin
     framename[i] =  "anim"+ String(byte([ byte('0') +  (i/1000.0) mod 10 , $
                              byte('0') +  (i/100.0)  mod 10 , $
                              byte('0') +  (i/10.0)   mod 10 , $
                              byte('0') +  (i/1.0)    mod 10 ])) + ".tiff" 

     sState.oVisualizeModels -> Rotate, yaxis, delta_angle
     sState.oAxisBoxModel    -> Rotate, yaxis, delta_angle
     
     Visualize_Redraw, sState                    

     if (oProgressBar -> CheckCancel()) then goto, end_loop
             
     if (sState.iSaveFrames eq 1) then begin             
       myimage = sState.oWindow -> Read()
       myimage -> GetProperty, DATA = imageout
       Obj_Destroy, myimage
        
       imageout = reverse(imageout,3)
       WRITE_TIFF, framename[i], imageout, 1
     end

     oProgressBar -> Update, (100.0*i)/(NumFramesAnimation-1)
   end

   if (sState.iLoopAnimate eq 1b) and (sState.iSaveFrames eq 0) then goto, begin_loop
end_loop:

   oProgressBar -> Destroy
   Obj_Destroy, oProgressBar


   if (sState.iSaveFrames eq 1) then begin             
     cd, current = path
     Frame2Movie, DIRECTORY = path, FILES = framename, /tiff
   end
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; ------------------------------------- Visualize_AnimRotateX_Event ---
;  Handles Rotate (X) animation events
; ---------------------------------------------------------------------

pro Visualize_AnimRotateX_Event, sEvent
    
   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
   
   NumFramesAnimation = 48
   delta_angle = 360.0/(NumFramesAnimation)
   framename = StrArr(NumFramesAnimation)

   ; Get Axis of rotation

   sState.oVisualizeModels -> GetProperty, Transform = tmatrix    
   xaxis = reform([1,0,0,0] # tmatrix)
   xaxis = xaxis[0:2]
 
   oProgressBar = Obj_New("SHOWPROGRESS", sEvent.top,$
                          /cancelbutton, $
                          TITLE = 'Animating...', $
                          MESSAGE = 'Rotating Models' $
                           )
begin_loop:
 
   oProgressBar -> Start

   for i = 0, NumFramesAnimation-1 do begin

     sState.oVisualizeModels -> Rotate, xaxis, delta_angle
     sState.oAxisBoxModel    -> Rotate, xaxis, delta_angle
     
     Visualize_Redraw, sState                    
     
     if (oProgressBar -> CheckCancel()) then goto, end_loop
     
     if (sState.iSaveFrames eq 1) then begin             
     framename[i] =  "anim"+ String(byte([ byte('0') +  (i/1000.0) mod 10 , $
                              byte('0') +  (i/100.0)  mod 10 , $
                              byte('0') +  (i/10.0)   mod 10 , $
                              byte('0') +  (i/1.0)    mod 10 ])) + ".tiff" 

        myimage = sState.oWindow -> Read()
        myimage -> GetProperty, DATA = imageout
        Obj_Destroy, myimage
        
       imageout = reverse(imageout,3)
       WRITE_TIFF, framename[i], imageout, 1
     end
     oProgressBar -> Update, (100.0*i)/(NumFramesAnimation-1)
   end
   
   if (sState.iLoopAnimate eq 1b) and (sState.iSaveFrames eq 0) then goto, begin_loop
end_loop:

   oProgressBar -> Destroy
   Obj_Destroy, oProgressBar

   if (sState.iSaveFrames eq 1) then begin             
     cd, current = path
     Frame2Movie, DIRECTORY = path, FILES = framename, /tiff
   end
   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------- Visualize_AnimUpdateLoop_Event ---
;  Handles Loop Animation  toggle
; ---------------------------------------------------------------------

pro Visualize_AnimUpdateLoop_Event, sEvent

   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
   WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

   sState.iLoopAnimate = 1-Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)

   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------

; ----------------------------- Visualize_AnimUpdateSaveFrame_Event ---
;  Handles Save Animation Frame toggle
; ---------------------------------------------------------------------

pro Visualize_AnimUpdateSaveFrame_Event, sEvent

   Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
   WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

   sState.iSaveFrames = 1-Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)

   Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------

; ------------------------------ Visualize_SaveTransformation_Event ---
;  Handles SaveTransformation events
; ---------------------------------------------------------------------

pro Visualize_SaveTransformation_Event, sEvent

   transfileout = Dialog_PickFile(/write, FILTER = '*.vtf',$
           TITLE = 'Choose Transformation (*.vtf) file', GET_PATH = transfilepath)
                        
   if (transfileout ne '') then begin
     cd, transfilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oAxisBoxModel -> GetProperty, TRANSFORM = transform
     save, transform, FILE = transfileout      
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end
; ---------------------------------------------------------------------

; ------------------------------ Visualize_LoadTransformation_Event ---
;  Handles LoadTransformation events
; ---------------------------------------------------------------------

pro Visualize_LoadTransformation_Event, sEvent
  
   transfile = Dialog_PickFile(FILTER = '*.vtf',$
           TITLE = 'Choose Transformation file...', GET_PATH = transfilepath)
                        
   if (transfile ne '') then begin
     cd, transfilepath
     restore, FILE = transfile      

     if (N_Elements(transform) eq 0) then begin
       res = Error_Message('File does not contain a transform matrix')
       return
     end
     
     help, transform
     
     s = size(transform, /type)
     if (s ne 4) then begin
       res = Error_Message('Invald transform matrix, must be of floating point type')
       return
     end

     s = size(transform)
     if (s[0] ne 2) then begin
       res = Error_Message('Invald transform matrix, must be an 2 Dimensional array')
       return
     end

     if ((s[1] ne 4) or (s[2] ne 4)) then begin
       res = Error_Message('Invald transform matrix, must be an 4x4 array')
       return
     end
          
     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oAxisBoxModel -> SetProperty, TRANSFORM = transform
     sState.oVisualizeModels -> SetProperty, TRANSFORM = transform
     
     Visualize_Redraw, sState
         
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end

end
; ---------------------------------------------------------------------

; ------------------------------------ Visualize_ObjectUpdate_Event ---
;  Handles Object Update events (shows/hides objects)
; ---------------------------------------------------------------------

pro Visualize_ObjectUpdate_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

  idx = where(sState.MenuItems eq eventUvalue)
  idx = idx[0] - sState.Object_Menu_Idx

  if (idx ge 0 and idx lt sState.n_obj_menu_items) then begin
    hide = Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)
    (sState.ModelReferences)[idx] -> SetProperty, HIDE = hide
    Visualize_Redraw, sState
  end

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; --------------------------------------- Visualize_BoxUpdate_Event ---
;  Handles box Update events (shows/hides box)
; ---------------------------------------------------------------------

pro Visualize_BoxUpdate_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

  hide = Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)
  sState.oBoxModel -> SetProperty, HIDE = hide
  Visualize_Redraw, sState

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; --------------------------------------- Visualize_BoxUpdate_Event ---
;  Handles Axis Update events (shows/hides axis)
; ---------------------------------------------------------------------

pro Visualize_AxisUpdate_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

  hide = Map_Menu_Choice(eventUValue, sState.MenuItems, $
                                  sState.MenuButtons)
  sState.oAxisModel-> SetProperty, HIDE = hide
  Visualize_Redraw, sState

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; -------------------------------------------- Base_Visualize_Event ---
;  Handles base events
; ---------------------------------------------------------------------

pro Base_Visualize_Event, sEvent

 if TAG_NAMES(sEvent, /STRUCTURE_NAME) eq 'WIDGET_BASE' then begin 
  ; Note: Only resize events are caught here
  Resize_Visualize_Event, sEvent
  return
 end
 
 WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue
                    
 case eventUValue of
     ; Menu Options
     '|File|Save Tiff...'			: SaveTIFF_Visualize_Event, sEvent
     '|File|Save Vrml...'			: SaveVRML_Visualize_Event, sEvent
     '|File|Page Setup...'			: PageSetup_Visualize_Event, sEvent
     '|File|Print...'				: Print_Visualize_Event, sEvent
     '|File|Quit'				: WIDGET_CONTROL, sEvent.top, /DESTROY
     '|Edit|Copy'				: ClipCopy_Visualize_Event, sEvent
     '|Image|AntiAlias'			: AntiAlias_Visualize_Event, sEvent
     '|Image|Invert Colors|On'		: Visualize_UpdateInvColors_Event, sEvent
     '|Image|Invert Colors|Off'		: Visualize_UpdateInvColors_Event, sEvent
     '|Image|Projection|Orthogonal'	: Visualize_UpdateProjection_Event, sEvent
     '|Image|Projection|Perspective'	: Visualize_UpdateProjection_Event, sEvent
     '|About|About Visualize 3D'	: XDisplayFile, /MODAL, $
                                       TITLE = 'About Visualize 3D', Text = $
                                       'About Visualize 3D not implemented yet'
     
     '|Image|View|Load Transformation...' : Visualize_LoadTransformation_Event, sEvent
     '|Image|View|Save Transformation...' : Visualize_SaveTransformation_Event, sEvent
     '|Image|View|Reset'			: Visualize_ViewReset_Event, sEvent
     '|Image|View|Reverse'			: Visualize_ViewReverse_Event, sEvent
     '|Image|View|Side      (x1,x3)'	: Visualize_ViewSide_Event, sEvent
     '|Image|View|Top       (x1,x2)'	: Visualize_ViewTop_Event, sEvent
     '|Image|View|Front     (x2,x3)'	: Visualize_ViewFront_Event, sEvent
     
     '|Animate|Save Frames|Off'		: Visualize_AnimUpdateSaveFrame_Event, sEvent
     '|Animate|Save Frames|On'		: Visualize_AnimUpdateSaveFrame_Event, sEvent
     '|Animate|Loop|Off'			: Visualize_AnimUpdateLoop_Event, sEvent
     '|Animate|Loop|On'			: Visualize_AnimUpdateLoop_Event, sEvent

     '|Animate|Rotate (X)'			: Visualize_AnimRotateX_Event, sEvent
     '|Animate|Rotate (Y)'			: Visualize_AnimRotateY_Event, sEvent
     '|Animate|Rotate (Z)'			: Visualize_AnimRotateZ_Event, sEvent
     
     '|Objects|Box|Hide'			: Visualize_BoxUpdate_Event, sEvent
     '|Objects|Box|Show'			: Visualize_BoxUpdate_Event, sEvent
     '|Objects|Axis|Hide'			: Visualize_AxisUpdate_Event, sEvent
     '|Objects|Axis|Show'			: Visualize_AxisUpdate_Event, sEvent
     
      ; Tools Radio Box
      'TOOLS'					: Visualize_Update_Tools_Event, sEvent                                 
      else: begin
              Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
              idx = where(sState.MenuItems eq eventUvalue)
              Object_Menu_Idx = sState.Object_Menu_Idx
              n_obj_menu_items = sState.n_obj_menu_items
              Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
              
              if (idx[0] ge Object_Menu_Idx) and $
                 (idx[0] lt Object_Menu_Idx+n_obj_menu_items) then begin
                    Visualize_ObjectUpdate_Event, sEvent
              end else print, "'"+eventUvalue+"'"+' not found, returning'
            end             
 endcase
                    
end

; -------------------------------------------- Draw_Visualize_Event ---
;  Handles draw widget events
; ---------------------------------------------------------------------

pro Draw_Visualize_Event, sEvent
  
    ; Get sState structure from base widget
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /No_Copy
  
    ; Meaning of sEvent.type
    ; from the WIDGET_DRAW help
    ;
    ; 0 - Button Press
    ; 1 - Button Release
    ; 2 - Motion
    ; 3 - ViewPort Moved (Scrollbars)
    ; 4 - Visibility Changed (Exposed)

    ; Expose (first draw of window)
    IF (sEvent.type EQ 4) THEN BEGIN
       Visualize_Redraw, sState
       WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
       RETURN
    ENDIF

    ; Button press
    IF (sEvent.type EQ 0) THEN BEGIN
        sState.btndown = 1b
        sState.oWindow->SetProperty, QUALITY=1 ; Medium quality for motion
        sState.oVisualizeModels->SetProperty, HIDE =1

        WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
        sState.oWindow->Draw, sState.oView

        sState.tool_pos0 =[sEvent.x,sEvent.y] - sState.window_size/2.
    end
    
    
    if (sState.iTool eq 0) then begin
       ; Rotation Tool
       ; Handle trackball updates.
       bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat, MOUSE = 1b )
       IF (bHaveTransform NE 0) THEN BEGIN
;          sState.oVisualizeModels->GetProperty, TRANSFORM=t
;          sState.oVisualizeModels->SetProperty, TRANSFORM=t#qmat
          sState.oAxisBoxModel->GetProperty, TRANSFORM=t
          sState.oAxisBoxModel->SetProperty, TRANSFORM=t#qmat
          sState.oWindow->Draw, sState.oView
       ENDIF
    end else if (sEvent.type EQ 2) and (sState.btndown EQ 1b) then begin
      tool_pos1 = [sEvent.x,sEvent.y] - sState.window_size/2.
     
      case (sState.iTool) of
        0: ; Rotation is handled above
        1: begin  
            ; Zoom Tool
            lz0 = sqrt(total(sState.tool_pos0 *sState.tool_pos0 ))
            if (lz0 gt 0.) then begin
               lz1 = sqrt(total(tool_pos1 * tool_pos1 ))
               s1 = lz1/lz0
               sState.oVisualizeModels-> scale, s1, s1, s1
               sState.oAxisBoxModel->scale, s1, s1, s1
            end
           end
        2: begin
            ; XY Translation tool
            delta = sState.tool_pos0 - tool_pos1
            if (sqrt(total(delta*delta)) gt 0.) then begin
              delta[0] = delta[0] / float(sState.window_size[0]) * sState.view_size[0]
              delta[1] = delta[1] / float(sState.window_size[1]) * sState.view_size[1]
              sState.oVisualizeModels-> Translate, -delta[0], -delta[1], 0
              sState.oAxisBoxModel-> Translate, -delta[0], -delta[1], 0
            end 
           end
        3:  begin
            ; Z Translation tool
            delta = sState.tool_pos0 - tool_pos1
            if (sqrt(total(delta*delta)) gt 0.) then begin
              ;delta[0] = delta[0] / float(sState.window_size[0]) * sState.view_size[0]
              delta[0] = 0.
              delta[1] = delta[1] / float(sState.window_size[1]) * sState.view_size[2]
              sState.oVisualizeModels-> Translate, -delta[0], 0, delta[1]
              sState.oAxisBoxModel-> Translate, -delta[0], 0, delta[1]
            end 
           end
       else: print, 'Tool #',sState.iTool, ' not implemented yet' 
      endcase

      sState.oWindow->Draw, sState.oView
      sState.tool_pos0 = tool_pos1
    end


    ; Button release.

    IF (sEvent.type EQ 1) THEN BEGIN
        IF (sState.btndown EQ 1b) THEN BEGIN
             sState.oAxisBoxModel->GetProperty, TRANSFORM=t
             sState.oVisualizeModels->SetProperty, TRANSFORM=t

             sState.oVisualizeModels->SetProperty, HIDE =0
             sState.oWindow->SetProperty, QUALITY=2
             Visualize_Redraw, sState
         ENDIF
         sState.btndown = 0b
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF

    ; Re-copy sState structure to base widget

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
end
; ---------------------------------------------------------------------

; ---------------------------------------- Visualize_Set_Coord_Conv ---
; Set The coord_Conv property of every graphic atom to display
; the models in the volume [-0.5,-0.5,-0.5] -> [0.5,0.5,0.5]
; ---------------------------------------------------------------------

pro Visualize_Set_Coord_Conv, oModel, $
                              Xmin, Xmax, $
                              Ymin, Ymax, $
                              Zmin, Zmax  

  models = oModel -> Get(/all, COUNT = n_models)
  
  if (n_models gt 0) then begin
    xcoord_conv = 0.5*[ -float(XMin+XMax)/(XMax-XMin), 2.0/(XMax-Xmin) ]
    ycoord_conv = 0.5*[ -float(YMin+YMax)/(YMax-YMin), 2.0/(YMax-Ymin) ]
    zcoord_conv = 0.5*[ -float(ZMin+ZMax)/(ZMax-ZMin), 2.0/(ZMax-Zmin) ]
    for i = 0, n_models -1 do begin
       if (obj_isa(models[i],'IDLgrModel')) then begin
       
         Visualize_Set_Coord_Conv, models[i], $
                              Xmin, Xmax, $
                              Ymin, Ymax, $
                              Zmin, Zmax
       
       end else if (obj_isa(models[i],'IDLgrVolume')) then begin 
         
         ; TEMPORARY FIX!!!!!
         
         (models[i]) -> GetProperty, XCOORD_CONV = xcconv_old
         (models[i]) -> GetProperty, YCOORD_CONV = ycconv_old
         (models[i]) -> GetProperty, ZCOORD_CONV = zcconv_old
         
         xcconv_new = xcconv_old
         xcconv_new[0] = xcoord_conv[0]
         xcconv_new[1] = xcconv_new[1] / (XMax-XMin) * 1.0
         ycconv_new = ycconv_old
         ycconv_new[0] = ycoord_conv[0]
         ycconv_new[1] = ycconv_new[1] / (YMax-YMin) * 1.0
         zcconv_new = zcconv_old
         zcconv_new[0] = zcoord_conv[0]
         zcconv_new[1] = zcconv_new[1] / (ZMax-ZMin) * 1.0
         
         (models[i]) -> SetProperty, XCOORD_CONV = xcconv_new
         (models[i]) -> SetProperty, YCOORD_CONV = ycconv_new
         (models[i]) -> SetProperty, ZCOORD_CONV = zcconv_new
          
         
       end else begin
         (models[i]) -> SetProperty, XCOORD_CONV = xcoord_conv  
         (models[i]) -> SetProperty, YCOORD_CONV = ycoord_conv  
         (models[i]) -> SetProperty, ZCOORD_CONV = zcoord_conv
       end         
    end
  end
end
; ---------------------------------------------------------------------

; ----------------------------------------- Visualize_Default_Scale ---
;  Scales the models applying the values specified by zoomfactor and
;  AxisScale
; ---------------------------------------------------------------------

pro Visualize_Default_Scale, oModel, ZoomFactor, AxisScale

  oModel -> Scale, zoomfactor*AxisScale[0], $
                   zoomfactor*AxisScale[1], $
                   zoomfactor*AxisScale[2] 

end
; ---------------------------------------------------------------------

; ------------------------------------- Visualize_Create_Model_Menu ---
;  Creates the Objects Sub-Menu Entries from the Model Supplied
; ---------------------------------------------------------------------

;pro Visualize_Create_Model_Menu, oModel, ModelMenuItems, ModelReferences, LEVEL = level
;  if (N_Elements(level) eq 0) then level = 0 
;
;  if (level eq 0) then begin
;     ModelMenuItems = 'Dummy'
;     ModelReferences = obj_new()
;  end  
;
;  models = oModel -> Get(/all, COUNT = n_models)
;  for i = 0, n_models -1 do begin
;    tag = 1
;    if ((i eq n_models-1) and (level ne 0)) then tag = tag + 2
;    if ((i eq 0) and (level ne 0)) then tag = tag + 8      
;    
;    models[i] -> GetProperty, UVALUE = name
;    name = (N_Elements(name) ne 0)?name:obj_class(models[i])
;    MenuEntry = hex_lon(tag)+name
;    ModelMenuItems = [ModelMenuItems, MenuEntry]
;    ModelReferences = [ModelReferences,models[i]]
;    if (obj_isa(models[i], 'IDLgrModel')) then begin
;       ModelMenuItems = [ModelMenuItems,'1Model','4Show','2Hide']
;       ModelReferences = [ModelReferences,models[i],models[i],models[i]]
;       Visualize_Create_Model_Menu, models[i], ModelMenuItems, ModelReferences, LEVEL = level+1
;    end else begin
;       ModelMenuItems = [ModelMenuItems,'4Show','2Hide']
;       ModelReferences = [ModelReferences,models[i],models[i]]
;    end
;  end
;    
;  if (level eq 0) then begin
;     ModelMenuItems = ModelMenuItems[1:*]
;     ModelReferences = ModelReferences[1:*]
;  end
;end

  
pro Visualize_Create_Model_Menu, oModel, ModelMenuItems, ModelReferences, LEVEL = level
  if (N_Elements(level) eq 0) then level = 0 

  if (level eq 0) then begin
     ModelMenuItems = '0Dummy'
     ModelReferences = obj_new()
  end  

  tmodels = oModel -> Get(/all)
  
  idx = where(obj_isa(tmodels, 'IDLgrModel'), n_models)
  if (n_models eq 0) then return
  models = tmodels[temporary(idx)]

  for i = 0, n_models -1 do begin
    tag = 1
    if ((i eq n_models-1) and (level ne 0)) then tag = tag + 2
    if ((i eq 0) and (level ne 0)) then tag = tag + 8      
    
    models[i] -> GetProperty, UVALUE = name
    name = (N_Elements(name) ne 0)?name:obj_class(models[i])+' '+strtrim(i,1)
    MenuEntry = hex_lon(tag)+name
    ModelMenuItems = [ModelMenuItems, MenuEntry]
    ModelReferences = [ModelReferences,models[i]]
    
    tmodels = models[i] -> Get(/all)
    idx = where(obj_isa(tmodels, 'IDLgrModel'), ns_models)
    
    if (ns_models eq 0) then begin
      ModelMenuItems = [ModelMenuItems,'4Show','2Hide']
      ModelReferences = [ModelReferences,models[i],models[i]]
    end else begin
      ModelMenuItems = [ModelMenuItems,'1Model','4Show','2Hide']
      ModelReferences = [ModelReferences,models[i],models[i],models[i]]
      Visualize_Create_Model_Menu, models[i], ModelMenuItems, ModelReferences, LEVEL = level+1
    end
  end
    
  if (level eq 0) then begin
     ModelMenuItems = ModelMenuItems[1:*]
     ModelReferences = ModelReferences[1:*]
  end
end
; ---------------------------------------------------------------------

; -------------------------------------------------- Visualize_Demo ---
;  Creates a Demo oVisualizeModels
; ---------------------------------------------------------------------
       
pro Visualize_Demo, oVisualizeModels
      oVisualizeModels = obj_new('IDLgrModel')
      oModelRed = obj_new('IDLgrModel', UVALUE = 'Red Balls')
      oModelBlue = obj_new('IDLgrModel', UVALUE = 'Blue Balls')
      oModelGreen = obj_new('IDLgrModel', UVALUE = 'Green Balls')
      n_balls = 20
      for i=0, n_balls-1 do begin
         color = [255b,0b,0b]
         radius = 0.02+0.05 * randomu(r)
         pos = randomu(p,3)*2.0 - 1.0
         name = 'Ball '+strtrim(string(i),1)
         Sphere,vert,poly, 10, pos, radius 
         oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                        COLOR = color , REJECT = 1, UVALUE = name)
         if oPoly ne OBJ_NEW() then oModelRed -> Add, oPoly
      end
      for i=0, n_balls-1 do begin
         color = [0b,255b,0b]
         radius = 0.01+0.1 * randomu(r)
         pos = randomu(p,3)*2.0 - 1.0
         name = 'Ball '+strtrim(string(i),1)
         Sphere,vert,poly, 10, pos, radius 
         oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                        COLOR = color , REJECT = 1, UVALUE = name)
         if oPoly ne OBJ_NEW() then oModelGreen -> Add, oPoly
      end
      for i=0, n_balls-1 do begin
         color = [0b,0b,255b]
         radius = 0.01+0.1 * randomu(r)
         pos = randomu(p,3)*2.0 - 1.0
         name = 'Ball '+strtrim(string(i),1)
         Sphere,vert,poly, 10, pos, radius 
         oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                        COLOR = color , REJECT = 1, UVALUE = name)
         if oPoly ne OBJ_NEW() then oModelBlue -> Add, oPoly
      end
      
      oVisualizeModels -> ADD, oModelRed
      oVisualizeModels -> ADD, oModelGreen
      oVisualizeModels -> ADD, oModelBlue
            
      oLight = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1], UVALUE = 'Light 1')
      oVisualizeModels -> ADD, oLight
      oLight = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1], UVALUE = 'Light 2')
      oVisualizeModels -> ADD, oLight
      oLight = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2, UVALUE = 'Light 3')
      oVisualizeModels -> ADD, oLight

end  


;**********************************************************************
;******************************************************** Main Code ***
;**********************************************************************

pro Visualize,  _EXTRA = extrakeys, $
               oVisualizeModels,  $       							; Container of the normal models (type Model)
               CONTAINER = oContain0, $							; Non-Visible objects that need to be destroyed later
               WIDGET_ID = wBase_ID, $							; ID of the widget created
               WINDOWTITLE = WindowTitle, $						; Title for the display window
               FORCE_DRAW = force_draw, $							; Force Draw of the display
               ; Output Options
               VRMLFILEOUT = vrmlfileout, $						; File for VRML output
               IMAGE = imageout, $								; Image for output
               FILEOUT = imagefile, $								; Image file for ouput
               ; Graphics Options
               RES = ImageResolution,$							; Resolution for the image
               ANTIALIAS = iAntiAlias, $							; AntiAliasing factor
               PERSPECTIVE = perspective, $						; Perspective to use
               FONTSIZE = fontsize, $								; Font size for the labels
               INVCOLORS = iInvColors, $							; Invert the colors (black on white)
               ; Titles
               TITLE = sTitle1, SUBTITLE = sTitle2, $					; Plot Titles to use
               XTITLE = sXTitle, YTITLE = sYTitle, ZTITLE = sZTitle, $	; Axis Titles to use
               ANIMATE = animate, $								; Animate the object
               ; Model Range
               XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange, $		; Spatial ranges
               ; Model Transformation 
               RATIO = AxisScale, $								; Axis Scale Ratio
               ZOOM = zoomfactor, $								; Initial Zoom Factor
               AX = ax, AY = ay, AZ = az, $    						; Initial angles
               DX = dx, DY = dy, DZ = dz, $						; Initial position shift
               TRANSFORMATIONFILE = transfile						; FIle containing the initial transformation
   
    
   if N_Elements(oVisualizeModels) eq 0 then begin
      sTitle1 = 'Visualize'
      sTitle2 = 'Demo Mode'
      AxisScale = [1,1,1]
      zoom = 1.0
      Visualize_Demo, oVisualizeModels
   end 
    
   n_obj = clean_model(oVisualizeModels)
   if (n_obj le 0) then begin
     if (obj_valid(oContain0)) then obj_destroy, oContain0
     res = Error_Message("Model doesn't contain any valid atom objects")
     return 
   end 
    
   ; AX
   ;
   ; Angle of rotation about the x-axis. Default is 30 degrees     

   if (N_Elements(ax) eq 0) then ax = 30

   ; AZ
   ;
   ; Angle of rotation about the z-axis. Default is 30 degrees     

   if (N_Elements(az) eq 0) then az = 30
   
   ; XRANGE
   ;
   ; limits of the visualization cube along the x-axis
   
   if (N_Elements(xrange) eq 0) then begin
     xrange = [-1,1]
   end else begin
     s = size(xrange)
     if (s[0] ne 1) or (s[1] ne 2) then begin
       print, 'Visualize, XRANGE must be a 1D 2 element array with the limits of the visualization cube'
       print, 'along the x-axis.'
       return
     end
   end
 
 
   ; YRANGE
   ;
   ; limits of the visualization cube along the y-axis
   
   if (N_Elements(yrange) eq 0) then begin
     yrange = [-1,1]
   end else begin
     s = size(yrange)
     if (s[0] ne 1) or (s[1] ne 2) then begin
       print, 'Visualize, YRANGE must be a 1D 2 element array with the limits of the visualization cube'
       print, 'along the y-axis.'
       return
     end
   end

   ; ZRANGE
   ;
   ; limits of the visualization cube along the x-axis
   
   if (N_Elements(zrange) eq 0) then begin
     zrange = [-1,1]
   end else begin
     s = size(zrange)
     if (s[0] ne 1) or (s[1] ne 2) then begin
       print, 'Visualize, ZRANGE must be a 1D 2 element array with the limits of the visualization cube'
       print, 'along the z-axis.'
       return
     end
   end

   ; RATIO
   ;
   ; Relative scaling of the axis regarding display size (not necessarily physical size)
   
   if (N_Elements(AxisScale) eq 0) then begin
     AxisScale = [1,1,1]
   end else begin
     s = size(AxisScale)
     if (s[0] ne 1) or (s[1] ne 3) then begin
       print, 'Visualize, RATIO must be a 1D 3 element array with the relative scaling of the axis'
       return
     end
     AxisScale = Abs(AxisScale)
     AxisScale = AxisScale / float(Max(AxisScale))
   end

   ; WINDOWTITLE
   ;
   ; The title for the plot window
   
   if (N_Elements(WindowTitle) eq 0) then WindowTitle = 'Visualize'
   
   ; RES
   ;
   ; The resolution for the image. Default is [600,600]
   
   if (N_Elements(ImageResolution) eq 0) then begin
     ImageResolution = [600,600]
   end else begin
     s = size(ImageResolution)
     if (s[0] ne 1) or (s[1] ne 2) then begin
       print, 'Visualize, RES must be a 1D 2 element array with the dimension of the image to display'
       return
     end
   end

   ; ANTIALIAS
   ;
   ; Antialiasing factor. See SCENEANTIALIAS for details
   
   if (N_Elements(iAntiAlias) eq 0) then iAntiAlias = 0

   ; PERSPECTIVE
   ;
   ; Type of perspective to use,  1 - Orthogonal, 2 - Perspective (default)
   ; See IDL help, for IDLgrView , Projection for further details.
 
   if (N_Elements(perspective) eq 0) then perspective = 2

   ; TITLE1
   ;
   ; Plot title
   
   if (N_Elements(sTitle1) eq 0) then sTitle1 = ''
   
   ; TITLE2
   ;
   ; Plot Sub title
   
   if (N_Elements(sTitle2) eq 0) then sTitle2 = ''
  
   ; [XYZ]Title
   ;
   ; Axis Titles  
  
   if N_Elements(sXTitle) eq 0 then sXTitle = 'X1'
   if N_Elements(sYTitle) eq 0 then sYTitle = 'X2'
   if N_Elements(sZTitle) eq 0 then sZTitle = 'X3'

   
   ; FONTSIZE
   ;
   ; Font size for titles and axis labels as a fraction of the reference size. Default is 1.0

   if N_Elements(fontsize) eq 0 then fontsize = 1.0
    
   ; INVCOLORS
   ;
   ; Invert the colors for the background and the axis and labels. Default is white on black
   
   if N_Elements(iInvColors) eq 0 then begin
     iInvColors = 0
   end else begin
     if (iInvColors ne 0) then iInvColors = 1
   end    

   ; ZOOM
   ;
   ; Initial Zoom factor to apply to the system
   
   if N_Elements(zoomfactor) eq 0 then zoomfactor = 1.0

   ; ------------------------------------------------- Find Extents ---
   
   XMin = XRange[0]
   XMax = XRange[1]
   YMin = YRange[0]
   YMax = YRange[1]
   ZMin = ZRange[0]
   ZMax = ZRange[1]
   
   ; --------------- Create a container for all the objects created ---
   
   oContainer = Obj_New('IDLgrContainer')
   
   If (N_Elements(oContain0) ne 0) then oContainer->Add, oContain0
   
   
   ; ---------------------------------------------- Create the View ---

   print, 'Adding Models to view...'

   viewColor = [0b,0b,0b]
   if (iInvColors eq 1) then viewColor = [255b,255b,255b]

   oView = OBJ_NEW('IDLgrView', COLOR = viewColor, PROJECTION = perspective)
   oContainer -> ADD, oView
   
   xdim = ImageResolution[0]
   ydim = ImageResolution[1]

   if (xdim lt ydim) then begin
        xsize = 2.
        ysize = 2. * ydim / float(xdim)
   end else begin
        xsize = 2. * xdim / float(ydim)
        ysize = 2.
   end

   ; Change ViewPlane to account for assimetry
   oView->SetProperty, ViewPlane_Rect=[-xsize/2.,-ysize/2., xsize, ysize]  
   print, 'ViewPlane_Rect', [-xsize/2.,-ysize/2., xsize, ysize] 

   zsize = 2.5
   
   ; Change the clipping plane for better viewing
   
   oView->SetProperty, ZClip=[zsize,-zsize]/2. 
      
   ; -------------------------------------------------- Plot Labels ---

   oLabelModel = OBJ_NEW('IDLgrModel',UVALUE = 'Labels')
   labelColors = [255b,255b,255b]
   if (iInvColors eq 1) then labelColors = [0b,0b,0b]

   maxRES = MAX(ImageResolution)

   SizeFontTitle = float(FontSize*0.025*maxRES)
   SizeFontSubTitle = float(FontSize*0.022*maxRES)

   FontTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontTitle)
   oContainer -> ADD, FontTitle
   PlotTitle    = OBJ_NEW('IDLgrText', sTitle1, Location=[0.9*(xsize/2.),0.9*(ysize/2.),0.0], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontTitle, /ENABLE_FORMATTING)
   PlotTitle -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   
   
   FontSubTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontSubTitle )
   oContainer -> ADD, FontSubTitle
   PlotSubTitle = OBJ_NEW('IDLgrText', sTitle2, Location=[0.9*(xsize/2.),0.8*(ysize/2.),0.0], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontSubTitle, /ENABLE_FORMATTING)
   PlotSubTitle -> SetProperty, RECOMPUTE_DIMENSIONS = 2

   oLabelModel -> ADD, PlotTitle
   oLabelModel -> ADD, PlotSubTitle
   oLabelModel -> SetProperty, LIGHTING = 0


   ; ------------------------------------------- Visualisation Cube ---

   oBoxModel = OBJ_NEW('IDLgrModel',UVALUE = 'Box')
   oAxisModel = OBJ_NEW('IDLgrModel',UVALUE = 'Axis')
   oAxisBoxModel = OBJ_NEW('IDLgrModel',UVALUE = 'Box and Axis')

   oAxisBoxModel -> Add, oBoxModel
   oAxisBoxModel -> Add, oAxisModel
   
 
   viscubeColor = [255b,255b,255b]
   if (iInvColors eq 1) then viscubeColor = [0b,0b,0b]

   solid, vert, poly, [XMin, YMin, ZMin], [XMax, YMax, ZMax]
   oPolygonVisCube = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 1, $
                       COLOR = viscubeColor)
   
   oBoxModel -> ADD, oPolygonVisCube

   
   
   ; ----------------------------------------- Axis and Axis Labels ---

   axisColor = [255b,255b,255b]

   if (iInvColors eq 1) then axisColor = [0b,0b,0b]


   SizeFontAxis = float(FontSize*0.022*maxRES)
   FontAxis =  OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontAxis)
   oContainer -> ADD, FontAxis
   
   xAxis = OBJ_NEW('IDLgrAxis',0, Range = [XMin,XMax], /Exact, $
                    LOCATION = [XMin,YMin,ZMin], COLOR = axisColor)
   xtl = 0.04 *(YMax-Ymin)/AxisScale[1]

   xAxis -> SetProperty, TICKLEN = xtl
   xAxis -> GetProperty, TICKTEXT = xtickLabels
   xtickLabels -> SetProperty, FONT = FontAxis
   xticklabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   xAxis -> SetProperty, TICKTEXT = xtickLabels
   xLabel = OBJ_NEW('IDLgrText',sXTITLE, FONT = FontAxis, /ENABLE_FORMATTING)
   xLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   xAxis -> SetProperty, TITLE = xLabel
   oContainer->Add, xlabel

   oAxisModel -> Add, xAxis

   yAxis = OBJ_NEW('IDLgrAxis',1, Range = [YMin,YMax], /Exact, $
                    LOCATION = [XMin,YMin,ZMin], COLOR = axisColor)
   ytl = 0.04 *(XMax-Xmin)/AxisScale[0]

   yAxis -> SetProperty, TICKLEN = ytl
   yAxis -> GetProperty, TICKTEXT = ytickLabels
   ytickLabels -> SetProperty, FONT = FontAxis
   yticklabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2

   yAxis -> SetProperty, TICKTEXT = ytickLabels
   yLabel = OBJ_NEW('IDLgrText',sYTITLE, FONT = FontAxis, /ENABLE_FORMATTING)
   yLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2

   yAxis -> SetProperty, TITLE = yLabel
   oContainer->Add, ylabel

   oAxisModel -> Add, yAxis

   zAxis = OBJ_NEW('IDLgrAxis',2, Range = [ZMin,ZMax], /Exact, $
                    LOCATION = [XMin,YMax,ZMin], COLOR = axisColor)
   ztl = 0.04 *(XMax-Xmin)/AxisScale[0]
   zAxis -> SetProperty, TICKLEN = ztl
   zAxis -> GetProperty, TICKTEXT = ztickLabels
   ztickLabels -> SetProperty, FONT = FontAxis
   zticklabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2

   zAxis -> SetProperty, TICKTEXT = ztickLabels
   zLabel = OBJ_NEW('IDLgrText',sZTITLE, FONT = FontAxis, /ENABLE_FORMATTING)
   zLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2

   zAxis -> SetProperty, TITLE = zLabel
   oContainer->Add, zlabel   

   oAxisModel -> Add, zAxis

   oAxisBoxModel -> SetProperty, LIGHTING = 0



   ; --------------------------------------- Rotation and Rendering ---

   ; Set (XYZ)Coord_Conv of the objects so they will be scaled to [-1,1] in all dimensions

   Visualize_Set_Coord_Conv, oVisualizeModels, $
                             Xmin, Xmax, $
                             Ymin, Ymax, $
                             Zmin, Zmax  

   Visualize_Set_Coord_Conv, oAxisBoxModel, $
                             Xmin, Xmax, $
                             Ymin, Ymax, $
                             Zmin, Zmax

   if (N_Elements(transfile) eq 0) then begin
       
     Visualize_Default_Scale, oVisualizeModels, $
                               ZoomFactor, AxisScale

     Visualize_Default_Scale, oAxisBoxModel, $
                              ZoomFactor, AxisScale
   
     ; Rotates the Model
  
     Visualize_Default_Rotation, oAxisBoxModel, ax, az   
     Visualize_Default_Rotation, oVisualizeModels , ax, az
  
   end else begin
      
     print, 'Loading Transformation File...'
     
     if (not file_exists(transfile)) then begin
       res = Error_Message('Transformation file '+transfile+' not found, returning')
       return
     end

     restore, FILE = transfile      

     if (N_Elements(transform) eq 0) then begin
       res = Error_Message(transfile+' does not contain a transform matrix')
       return
     end
          
     s = size(transform, /type)
     if (s ne 4) then begin
       res = Error_Message('Invald transform matrix, must be of floating point type')
       return
     end

     s = size(transform)
     if (s[0] ne 2) then begin
       res = Error_Message('Invald transform matrix, must be an 2 Dimensional array')
       return
     end

     if ((s[1] ne 4) or (s[2] ne 4)) then begin
       res = Error_Message('Invald transform matrix, must be an 4x4 array')
       return
     end
          
     oAxisBoxModel -> SetProperty, TRANSFORM = transform
     oVisualizeModels -> SetProperty, TRANSFORM = transform
   
   end

   ; Add Models to view   

   oView -> ADD, oLabelModel
   oView -> ADD, oAxisBoxModel
   oView -> ADD, oVisualizeModels

   ; Handles direct file output
   
   no_show = 0

   ; VRML file output
   
   if (N_Elements(vrmlfileout) ne 0) then begin
      oVRML = obj_new('IDLgrVRML',DIMENSIONS=ImageResolution)
      oVRML-> SetProperty, FILENAME = vrmlfileout
      oVRML-> SetProperty, WORLDTITLE = Title1
      oVRML-> SetProperty, WORLDINFO = Title2
      oVRML-> Draw, oView
      Obj_Destroy, oVRML
      no_show = 1
   end
   
   if ((N_Elements(imageout) ne 0) or (N_Elements(imagefile) ne 0)) then begin
     print, 'Rendering image...'
     oBuffer = OBJ_NEW('IDLgrBuffer', DIMENSIONS = ImageResolution)
     oBuffer-> Draw, oView

     ; Anti-Aliasing

     if (iAntiAlias gt 0) then begin
        print, 'Anti-Aliasing image...'
        SceneAntiAlias, oBuffer, oView, iAntiAlias
     end

     ; Saves output image

     myimage = oBuffer -> Read()
     myimage -> GetProperty, DATA = imageout

     if (N_Elements(imagefile) ne 0) then begin
       imageout = reverse(imageout,3)
       WRITE_TIFF, imagefile, imageout, 1
       imageout = reverse(imageout,3)
     end


     OBJ_DESTROY, myimage
     OBJ_DESTROY, oBuffer
     
     no_show = 1
   end 

   iAntiAlias = 8
   iProjection = 0
   iTool = 0
   
   if (no_show eq 0) then begin
       
       ; Create the base widget
       wBase = Widget_Base(TITLE = windowTitle, /TLB_Size_Events, APP_MBAR = menuBase, $
                           XPAD = 0, YPAD = 0, /Column)
       
       ; Create the menu
  
       MenuItems = [ $
             '1File', $
                '0Save Tiff...', $
                '0Save Vrml...', $
                '8Page Setup...',$
                '0Print...',$
                'AQuit', $
             '1Edit',$
                '2Copy',$
             '1Image', $
                '0AntiAlias', $
                '1Invert Colors', $
                   '4Off', '2On', $
                '1Projection', $
                   '4Perspective','2Orthogonal',$
                '3View', $
                   '0Load Transformation...',$
                   '0Save Transformation...',$
                   '8Side      (x1,x3)',$
                   '0Top       (x1,x2)',$
                   '0Front     (x2,x3)', $
                   '8Reverse',$
                   'AReset',$
             '1Animate',$
                '0Rotate (X)',$
                '0Rotate (Y)',$
                '0Rotate (Z)',$
                '9Loop',$
                   '4On',$
                   '2Off',$
                '3Save Frames',$
                   '4On',$
                   '2Off',$
             '1Objects']
        
        LocalObjects_MenuItems = [ $
                '9Box',$
                   '4Show',$
                   '2Hide',$
                '3Axis',$
                   '4Show',$
                   '2Hide' ]
        
        About_MenuItems = [ $
             '1About', $
                '2About Visualize 3D' $
        ]
  
       Visualize_Create_Model_Menu, oVisualizeModels, ModelMenuItems, ModelReferences
       n_obj_menu_items = N_Elements(ModelMenuItems)
       help, n_obj_menu_items
       print, ModelMenuItems
       MenuItems = [MenuItems,ModelMenuItems,LocalObjects_MenuItems,About_MenuItems]
 
      ; Debug
      ; MenuItems = [MenuItems,LocalObjects_MenuItems,About_MenuItems]
 
 
        Object_Menu_Idx = where(MenuItems eq '1Objects')+1

       Create_Menu, MenuItems, MenuButtons, menuBase
                 
       ; Create the Draw Widget
       
       wDraw = Widget_Draw(wBase, XSIZE = xdim, YSIZE = ydim, $
                           Graphics_Level = 2, /Button_Events, $
                           /Motion_Events, /Expose_Events, /viewport_events, Retain = 0, $
                           EVENT_PRO = 'Draw_Visualize_Event', FRAME = 1)

       ; Create the tool selection radio group
       
       subBase = Widget_Base(wBase, XPAD = 0, YPAD = 0, /Column, /BASE_ALIGN_CENTER, $
                             FRAME = 1, XOffSet = 2,YOffset = 0)
  
       RadioItems = ['Rotation', 'Zooming', 'Translation (XY)', 'Translation (Z)']
            
       wTools = cw_Bgroup(subBase, RadioItems, /Exclusive, Row = 1, Set_Value = 0, $
                          UValue = 'TOOLS', Label_Left='Tools:', /Return_Index, $
                          Frame = 0, YSize = 20, YOffset = 0)


       ; Realize the widget
       Widget_Control, wBase, /REALIZE
       
       ; Create the window object
       Widget_Control, wDraw, Get_Value = oWindow
       
       ; Create the Trackball
       oTrack = OBJ_NEW('TrackBall', [xdim/2.,ydim/2.], ydim/2. < xdim/2.)
       oContainer -> ADD, oTrack
       
       ; Create the printer object

       oPrinter = OBJ_NEW('IDLgrPrinter')
       if (oPrinter ne Obj_New()) then begin
          oContainer -> ADD, oPrinter
       end else begin
          Disable_Menu_Choice, '|File|Print...', MenuItems, MenuButtons 
          Disable_Menu_Choice, '|File|Page Setup...', MenuItems, MenuButtons 
       end
       
       iSaveFrames = 0b
       iLoopAnimate = 0b
  
       sOnOff=['On','Off']

       ; Update Animate|Loop sub-menu to reflect initial iLoopAnimate
       eventval = '|Animate|Loop|'+sOnOff[1-iLoopAnimate]
       temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)

       ; Update Contour sub-menu to reflect initial iAddContourPlot 
       eventval = '|Animate|Save Frames|'+sOnOff[1-iSaveFrames]
       temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)
      
       ; Save state.
       sState = { XMin:Xmin, XMax:Xmax, $
                  YMin:YMin, YMax:YMax, $
                  ZMin:ZMin, ZMax:ZMax, $
                  ax:ax, az:az, $
                  ZoomFactor:ZoomFactor, $
                  AxisScale:AxisScale, $
                  btndown: 0b,$						; button 1 down
                  window_size:[xdim,ydim], $			; window size
                  view_size:[xsize,ysize,zsize ], $			; viewport size
                  tool_pos0:lonarr(2), $				; Initial position for tools
                  dragq: 0,$
                  iTool:iTool, $					; Current Tool
                  oContainer : oContainer, $
                  oTrack:oTrack,$					; TrackBall Object
                  oPrinter:oPrinter, $				; Printer Object
                  wDraw: wDraw,$					; Draw widget
                  oWindow: oWindow,$					; Window Object
                  oView: oView,$					; View Object
                  sTitle1: sTitle1,$					; Plot Title
                  sTitle2: sTitle2, $					; Plot Sub-Title
                  FontSize:FontSize, $				; Reference Font Size
                  FontTitle:FontTitle, $				; Title Font
                  FontSubTitle:FontSubTitle, $			; Sub-Title Font
                  FontAxis:FontAxis, $				; Axis Font
                  iAntiAlias:iAntiAlias, $				; AntiAlias Value
                  iInvColors:iInvColors, $				; Inverted Colors
                  iProjection:iProjection, $			; Projection Type
                  MenuItems:MenuItems, $				; Menu Items
                  MenuButtons:MenuButtons, $			; Menu Buttons
                  oAxisBoxModel: oAxisBoxModel,$		; Axis and Box Model
                  oAxisModel : oAxisModel, $
                  oBoxModel : oBoxModel, $
                  oVisualizeModels: oVisualizeModels,$	; Visualization Models
                  oLabelModel: oLabelModel, $			; Labels Model
                  
                  ; Objects Sub Menu Variables
                  
                  ModelReferences: ModelReferences, $
                  n_obj_menu_items: n_obj_menu_items, $
                  Object_Menu_Idx: Object_Menu_Idx, $
                  
                  
                  iSaveFrames:iSaveFrames, $			; Save Animation Frames
                  iLoopAnimate:iLoopAnimate $			; Loop animation 
                }

       Widget_Control, wBase, SET_UVALUE=sState, /No_Copy

       wBase_ID = wBase
       XManager, 'Visualize', Event_Handler='Base_Visualize_event', $
                              Cleanup ='Visualize_Cleanup', $
                              wBase, /NO_BLOCK
        
       if Keyword_Set(force_draw) then oWindow -> Draw, oView                       

       if (N_Elements(animate) ne 0) then begin
         sEvent = {top:wBase_ID} 

         case animate of 
           2: Visualize_AnimRotateZ_Event, sEvent
           1: Visualize_AnimRotateY_Event, sEvent
           0: Visualize_AnimRotateX_Event, sEvent
         else: print, 'invalid axis for animation'
         end
       end
   end else begin

     OBJ_DESTROY, oContainer
     OBJ_DESTROY, oLabelModel
     OBJ_DESTROY, oAxisBoxModel
     OBJ_DESTROY, oVisualizeModels

     OBJ_DESTROY, oView

   end

   print, 'Done Visualize!'
   

end