;
;  Program:  
;
;  Plot3Dvector
;
;  Description:
;
;  Opens a 3D array of 3D vectors and plots it using object graphics
;
; ---------------------------------------------------------------------


;**********************************************************************
;******************************************************** Main Code ***
;**********************************************************************

Pro Plot3Dvector, _EXTRA = extrakeys, pData,$
            XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
            ; Projections
            NOPROJ = noProjections, PMAX = ProjMax, PMIN = ProjMin, PROJCT = projCT,$
            ; IsoLevel
            ISOLEVELS = isolevels, ABSISOLEVEL = absisolevel, NOISOLEVELS = noisolevels, LOW = lows, $
            COLOR = Colors, BOTTOM = BottomColors, $
            ;Slices
            SLICES = SlicePos, SLICECT = sliceCT, $
            ; Vector Field 
            NOVECTORFIELD = noVectorField, VFCT = vfieldCT, VFTYPECOLOR = vfieldTypeColor, $
            VFCOLOR = vfieldColor, VFPROJ = vfdoProjections, $
            ; Field Lines 
            FIELDLINES = doFieldLines, FLCT = flinesCT, FLTYPECOLOR = flinesTypeColor, $
            FLCOLOR = flinesColor, FLARROW = fldoArrow, FLPROJ = fldoProjections, $
            ; Volume Rendering
            RENDER_VOLUME = Render_Volume, VOLCT = volCT, VOLOPAC = volOpac, VOLGLOBALOPAC = volGlobalOpac, $
            ; Visualization (parameters to visualize)
            WIDGET_ID = wBase_ID, RATIO = AxisScale


if Arg_Present(pData) then Begin

   ; -------------------------------------------------- Initialising
    
   S = Size(pData)

   if ((s[0] ne 1) or (s[1] ne 3) or (s[2] ne 10)) then begin
     res = Dialog_Message('pData must be an array of 3 pointers', /Error)
     return       
   end    

   s = Size(*(pData[0]))      
   if (s[0] ne 3) then begin
     res = Dialog_Message('Data pointed to must be a 3D array', /Error)
     return       
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]

   for i=1,2 do begin
     s =  Size(*(pData[i]))  
     if (s[0] ne 3) then begin
       res = Dialog_Message('Data pointed to must be a 3D array', /Error)
       return 
     end
     if ((s[1] ne NX) or (s[2] ne NY) or (s[3] ne NZ)) then begin
       res = Dialog_Message('all Data pointed to must have the same dimensions', /Error)
       return 
     end
   end
   
   ; Window Title
   
   if N_Elements(windowTitle) eq 0 then windowTitle = 'Plot3Dvector'
     
   ; Vertex shading (vertex shading is currently disabled)
   
   if N_Elements(vshades) eq 0 then vshades = -1
   
   ; Ratio for the Axis
   
   if N_Elements(AxisScale) eq 0 then AxisScale = [1,1,1]
  
   AxisScale = Abs(AxisScale)/float(Max(Abs(AxisScale)))
  
   ; Angles of rotation for 3D view
   
   If N_Elements(angleAX) eq 0 then angleAX = 0
   If N_Elements(angleAY) eq 0 then angleAY = 0  
   If N_Elements(angleAZ) eq 0 then angleAZ = 0 

   ; Image Resolution
   
   if N_Elements(ImageResolution) ne 0 then begin
       S = Size(ImageResolution)
       if ((S[0] ne 1) or (S[1] ne 2)) then begin
          res = Dialog_Message("The RES keyword must be in the form [X resolution, Y Resolution]", /Error)
          return           
       end
   
   end else begin
       ImageResolution = [600,600]  
   end  
  
   ; Data Smoothing
  
   if N_Elements(SmoothFact) eq 0 then SmoothFact = 0
   if (SmoothFact eq 1) then SmoothFact = 2
   
   if (SmoothFact ge 2) then begin
      for i=0,2 do begin
         *(pData[i]) = Smooth(*(pData[i]),SmoothFact,/Edge_Truncate)
      end
   end

   ; Projections
   
   if N_Elements(noProjections) eq 0 then begin
     noProjections = 0
   endif

   ; Default Axis
      
   If N_Elements(XAxisData) eq 0 then XAxisData = -1. + IndGen(NX)*2.0/(NX-1) 
   If N_Elements(YAxisData) eq 0 then YAxisData = -1. + IndGen(NY)*2.0/(NY-1) 
   If N_Elements(ZAxisData) eq 0 then ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
      
   ; Spatial Range
    
   XMax = XAxisData[NX-1]
   XMin = XAxisData[0]

   YMax = YAxisData[NY-1]
   YMin = YAxisData[0]

   ZMax = ZAxisData[NZ-1]
   ZMin = ZAxisData[0]
       
   ; ------------------------------------------- Data Values Ranging ---

   ; Unless specified, autoscale DataMin
   

   ; ---------------------------------------------------- Plot Model ---
   
   oModelIsoSurf = OBJ_NEW('IDLgrModel',UVALUE = 'Iso-Surfaces')      ; IsoSurfaces
   oModelVolume = OBJ_NEW('IDLgrModel',UVALUE = 'Volume Rendering')   ; Volume Rendering
   oModelProj = OBJ_NEW('IDLgrModel', UVALUE = 'Projections')         ; Projections  
   oModelSlice = OBJ_NEW('IDLgrModel', UVALUE = 'Slices')             ; Slices  
   oModelVectorField = OBJ_NEW('IDLgrModel', UVALUE = 'Vector Field') ; VectorField
   oModelFieldLines = OBJ_NEW('IDLgrModel', UVALUE = 'FieldLines')    ; FieldLines
   
   oContainer = Obj_New('IDLgrContainer')						; Container for non-graphics objects
 
   ; -------------------------------------------------- Isosurfaces ---

   if not Keyword_Set(noisolevels) then begin

     ModData = reform(sqrt(*(pData[0])^2+*(pData[1])^2+*(pData[2])^2))
     If N_Elements(DataMin) eq 0 then DataMin = Min(ModData)  
     if N_Elements(DataMax) eq 0 then DataMax = Max(ModData)  
     pModData = PTR_NEW(ModData, /NO_COPY)

     if N_Elements(isolevels) ne 0 then $
       if not Keyword_Set(absisolevels) then $
          isolevels = DataMin + (DataMax - DataMin)*isolevels

     print, 'Generating IsoSurfaces...' 
     
     GenIsoSurface, pModData, oModelIsoSurf, ISOLEVELS = isolevels, COLOR = Colors, BOTTOM = BottomColors, $
                    LOW = lows, $
                    XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                    CONTAINER = oContainer, RANGES = SliceRanges, DATARANGE = [DataMin, DataMax]
          
     print, 'done'
   end  
  
   ; --------------------------------------------- Volume Rendering ---


   if Keyword_Set(Render_Volume) then begin  
     print, 'Rendering Volume '
     
     if N_Elements(pModData) eq 0 then begin
       ModData = reform(sqrt(*(pData[0])^2+*(pData[1])^2+*(pData[2])^2))
       If N_Elements(DataMin) eq 0 then DataMin = Min(ModData)  
       if N_Elements(DataMax) eq 0 then DataMax = Max(ModData)  
       pModData = PTR_NEW(ModData, /NO_COPY)
     end
   
     Volumes, pModData, oModelVolume, MAX = DataMax, MIN = DataMin, $
                    CT = volCT, OPAC = volOpac, GLOBALOPAC = volGlobalOpac,$
                    XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData
      
     print, 'Done'
   end

   ; -------------------------------------------------- Projections ---
   
   if (noProjections eq 0) then begin
     print, 'Generating projections...'

     if N_Elements(ModData) eq 0 then begin
       ModData = reform(sqrt(*(pData[0])^2+*(pData[1])^2+*(pData[2])^2))
       If N_Elements(DataMin) eq 0 then DataMin = Min(ModData)  
       if N_Elements(DataMax) eq 0 then DataMax = Max(ModData)  
       pModData = PTR_NEW(ModData, /NO_COPY)
     end

     Projections, pModData, oModelProj, CT = projCT, PMIN = ProjMin, PMAX = ProjMax, $
                  XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData , $
                  CONTAINER = oContainer
     print, 'Done'
   end
  

   ; clear ModData memory
   
   if N_Elements(pModData) ne 0 then ptr_free, pModData   

   ; ------------------------------------------------------- Slices ---
    
   if N_Elements(SlicePos) ne 0 then begin

     print, 'Generating Slices...'
       
     SliceVector, pData, SlicePos,$
             oModelSlice, CT = SliceCT,$
             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, MIN = DataMin, MAX = DataMax, $
                  CONTAINER = oContainer
     print, 'Done'

   end


   ; ------------------------------------------------ Vector Field ---
   
   if not KeyWord_Set(noVectorField) then begin
      print, 'Generating Vector Field model...'
      VectorField, pData, oModelVectorField, _EXTRA=extrakeys,$
                  XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData,$
                  COLOR = vfieldColor, CT = vfieldCT, TYPECOLOR = vfieldTYPECOLOR, $
                  AXISRATIO = AxisScale, PROJ = vfdoProjections
      print, 'Done'
   end

   ; -------------------------------------------------- FieldLines ---

  
   if KeyWord_Set(doFieldLines) then begin
     print, 'Generating Field Lines model...'   
     FieldLines, pData, oModelFieldLines, _EXTRA=extrakeys,$
                XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData,$
                COLOR = flinesColor, CT = flinesCT, TYPECOLOR = flinesTYPECOLOR, $
                AXISRATIO = AxisScale, ARROW = fldoArrow, PROJ = fldoProjections
     print, 'Done'
   end

  ; ----------------------------------------- Call visualize procedure ---

   oVisualizeModels = OBJ_NEW('IDLgrModel')  ; models that can be transformed but are not visible
                                          ; during transformations  

   oVisualizeModels -> ADD, oModelProj
   oVisualizeModels -> ADD, oModelVectorField
   oVisualizeModels -> ADD, oModelFieldLines
   oVisualizeModels -> ADD, oModelSlice
   oVisualizeModels -> ADD, oModelIsoSurf
   oVisualizeModels -> ADD, oModelVolume


   
   ; Add Lighting
   
   oLight = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,1]) 
   oVisualizeModels -> ADD, oLight
   oLight = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,-1]) 
   oVisualizeModels -> ADD, oLight
   oLight = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2) 
   oVisualizeModels -> ADD, oLight

   Visualize, _EXTRA = extrakeys, oVisualizeModels, CONTAINER = oContainer, WIDGET_ID = wBase_ID, $
              RATIO = AxisScale, XRANGE = [Xmin, XMax], YRANGE = [Ymin, YMax], ZRANGE = [Zmin, ZMax]
              ;AX = ax, AZ = az, $
              ;XRANGE = [Xmin, XMax], YRANGE = [Ymin, YMax], ZRANGE = [Zmin, ZMax], $
              ; WINDOWTITLE = WindowTitle,RES = ImageResolution, $
              ;ANTIALIAS = AntiAlias, VRMLFILEOUT = vrmlfileout, IMAGE = imageout, $
              ;FILEOUT = imagefile, TITLE1 = Title1, TITLE2 = Title2, $
              ;XTITLE = XTitle, YTITLE = YTitle, ZTITLE = ZTitle, FONTSIZE = fontsize, $
              ;ZOOM = zoomfactor, CONTAINER = oContainer

  
   print, 'Done!'
              
 End else begin
   
   print, 'No data supplied!'
   
 end
  
End