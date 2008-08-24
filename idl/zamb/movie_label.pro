pro movie_label,  _EXTRA=extrakeys, frame, $
                 NFRAMES = nframes, $			; Total Number of frames
                 RES = res, $				; Image Resolution
                 WINDOWTITLE = windowtitle, $	; Window Title
                 TITLE1 = stitle1, $			; Main Title
                 TITLE2 = stitle2, $			; Subtitle 1
                 TITLE3 = stitle3, $			; Subtitle 2
                 TIME = stime, $			; Time Label
                 SCALES = pscales, $			; Scales
                 FILEOUT = fileout			; output file
                 

  if (N_Elements(nframes) eq 0) then nframes = 0
  
  if (N_Elements(stitle1) eq 0) then stitle1 = ''
  if (N_Elements(stitle2) eq 0) then stitle2 = ''
  if (N_Elements(stitle3) eq 0) then stitle3 = ''
  if (N_Elements(stime) eq 0 ) then stime = ''
  
  if (N_Elements(res) eq 0) then res = [512,512]
  
  if (N_Elements(windowtitle) eq 0) then windowtitle = 'Movie Label'

  oView = OBJ_NEW('IDLgrView', Color = [0,0,0]) 
  oModel =  OBJ_NEW('IDLgrModel', LIGHTING = 0) 
  oModelLight =  OBJ_NEW('IDLgrModel', LIGHTING = 2) 
  
  oLight =  OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [1,1,1])
  oModelLight -> ADD, oLight
  oLight =  OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-1,-1,-1])
  oModelLight -> ADD, oLight
  oLight =  OBJ_NEW('IDLgrLight', TYPE = 0, Intensity  = 0.2)
  oModelLight -> ADD, oLight
 
  iInvColors = 0

  labelColors = [255b,255b,255b]
  if (iInvColors eq 1) then labelColors = 255 - labelColors
   FontSize = 1.75
   maxRES = MAX(Res)

   SizeFontTitle = float(FontSize*0.025*maxRES)
   SizeFontSubTitle = float(FontSize*0.022*maxRES)
   SizeFontTicks = float(FontSize*0.017*maxRES)

   FontTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontTitle)
   FontSubTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontSubTitle )
   FontTicks = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontTicks )

   ; start line
   
   posy = 0.9
   dy = 0.12
   

   ; --------------------------------------------------------- Labels ---

   oTitle1 = OBJ_NEW('IDLgrText', sTitle1, Location=[0.9,posy], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontTitle, /ENABLE_FORMATTING)
    
   posy = posy - dy

   oTitle2 = OBJ_NEW('IDLgrText', sTitle2, Location=[0.9,posy], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontSubTitle, /ENABLE_FORMATTING)

   posy = posy - 2.*dy

   oTitle3 = OBJ_NEW('IDLgrText', sTitle3, Location=[0.9,posy], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontSubTitle, /ENABLE_FORMATTING)

   posy = posy - dy

   oTitleTime = OBJ_NEW('IDLgrText', sTime, Location=[0.9,posy], COLOR = labelColors,$
                           Alignment = 1.0, FONT = FontSubTitle, /ENABLE_FORMATTING)

   oModel -> ADD, oTitle1
   oModel -> ADD, oTitle2
   oModel -> ADD, oTitle3
   oModel -> ADD, oTitleTime

   ; --------------------------------------------------------- Scales ---

  scaleColors = [255b,255b,255b]
  if (iInvColors eq 1) then scaleColors = 255 - scaleColors

   if N_Elements(pscales) ne 0 then begin
     s = size(pscales)
     nscales = s[1]
     print, 'Number of scales, ', nscales
     posy = posy - 3*dy
        
     for i=0, nscales-1 do begin
       case ( (*pscales[i]).type ) of
          0: begin		; Color Scale
               location = [-0.2-dy/3., posy]
               dimension = [1.2,dy/2.] 
              
               CT = (*pscales[i]).CT
               Min = (*pscales[i]).Min
               Max = (*pscales[i]).Max
               Title = (*pscales[i]).Title
               oPal = OBJ_NEW('IDLgrPalette')
               oPal -> LoadCT, CT
             
               ; Create the colorbar image. Get its size.

               bar = BINDGEN(256) # REPLICATE(1B,10)

               ; Create the colorbar image object. Add palette to it.

               oBar = Obj_New('IDLgrImage', bar, Palette=oPal )
               oBar -> SetProperty, Dimensions = dimension
               oBar -> SetProperty, Location = location
               
               oAxis1Bar = Obj_New('IDLgrAxis', 0, COLOR = scaleColors, /Exact)
               oAxis1Bar -> SetProperty, Range = [Min,Max]
               oAxis1Bar -> SetProperty, Location = location
               oAxis1Bar -> SetProperty, XCOORD_CONV = [location[0]-Min*dimension[0]/(Max-Min), dimension[0]/(Max-Min)]
               oAxis1Bar -> SetProperty, TICKLEN = 0.3*dimension[1]
               
               oAxis2Bar = Obj_New('IDLgrAxis', 0, COLOR = scaleColors, /Exact, /notext)
               oAxis2Bar -> SetProperty, Range = [Min,Max]
               oAxis2Bar -> SetProperty, Location = location + [0,dimension[1]]
               oAxis2Bar -> SetProperty, XCOORD_CONV = [location[0]-Min*dimension[0]/(Max-Min), dimension[0]/(Max-Min)]
               oAxis2Bar -> SetProperty, TICKLEN = 0.3*dimension[1]
               oAxis2Bar -> SetProperty, TICKDIR = 1
               
               oAxisTitle = Obj_New('IDLgrText', Title, /ENABLE_FORMATTING, Font =  FontSubTitle, ALIGNMENT = 1.0)
               oAxisTitle -> SetProperty, Locations = location - [ 0.2 - dy/3.,0]
               oAxisTitle -> SetProperty, Color = scaleColors
               
               oBoxBar1 = Obj_New('IDLgrPolyline', [location[0], location[0]], $
                                                  [location[1], location[1]+ dimension[1]])
               oBoxBar1 -> SetProperty, Color = scaleColors
               
               oBoxBar2 = Obj_New('IDLgrPolyline', [location[0], location[0]]+dimension[0], $
                                                  [location[1], location[1]+ dimension[1]])
               oBoxBar2 -> SetProperty, Color = scaleColors
               
               
               oModel -> Add, oBar
               oModel -> Add, oAxis1Bar
               oModel -> Add, oAxis2Bar
               oModel -> Add, oAxisTitle
               oModel -> Add, oBoxBar1
               oModel -> Add, oBoxBar2
             end       
          1: begin
               location = [-0.2, posy, 0]
   
               values = (*pscales[i]).values
               Colors = (*pscales[i]).colors
               Title = (*pscales[i]).Title
               s= size(values)
               nvalues = s[1]

               oSurfTitle = Obj_New('IDLgrText', Title, /ENABLE_FORMATTING, Font =  FontSubTitle, ALIGNMENT = 1.0)
               oSurfTitle -> SetProperty, Locations = location - [ 0.2,0,0]
               oSurfTitle -> SetProperty, Color = scaleColors
               oModel -> Add, oSurfTitle
               

               for j=0, nvalues-1 do begin                
                 position = location + [0.25*j,dy/5.,0] 
                 color = reform(Colors[*,j])                         
                 sphere, vert, poly, 50, position, dy / 3.
                 
                 if (color[3] eq 255b) then begin  ; Opaque IsoSurface
                    oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, STYLE = 2, Shading = 1, $
                                     COLOR = color , REJECT = 1) 
                 end else begin                        ; Transparent IsoSurface
                   alphaimgsurf = BytArr(4, 16, 16)
                   alphaimgsurf[0,*,*] = 255b
                   alphaimgsurf[1,*,*] = 255b
                   alphaimgsurf[2,*,*] = 255b  
                   alphaimgsurf[3,*,*] = color[3]  
  
                   oimgTranspSurf =  OBJ_NEW('IDLgrImage', alphaimgsurf)  
  
                   oPoly = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1, reject = 0, $
                                    COLOR = color, $
                                    Texture_Map = oimgTranspSurf )       
                 end
                 
                 oModelLight -> Add, oPoly 
                 ticktext = String(values[j],Format='(f4.2)')
                 oTickText = Obj_New('IDLgrText', TickText, /ENABLE_FORMATTING, Font =  FontTicks, ALIGNMENT = 0.0)
                 oTickText -> SetProperty, Locations = position + [ dy/3.+0.01,0,0]
                 oTickText -> SetProperty, Color = scaleColors
                 oModel -> Add, oTickText
                                        
               end          
             end
       
       else: print, 'Scales type ',(*pscales[i]).type,' not implemented'
       end               

       posy = posy - 2*dy

     end   
        
   end

   ; ----------------------------------------------------- Frame Information ---

   print, frame, nframes

   if (frame gt 0) then begin
   
     posy = -1. + 2.1*dy
   
     sFrameLabel = 'Frame: '+String(frame,Format='(i3)')
     
     if (nframes gt 0) then sFrameLabel = sFrameLabel+'/'+String(nframes,Format='(i3)')

     print, sframelabel

     oFrameLabel = OBJ_NEW('IDLgrText', sFrameLabel, Location=[0.9,posy], COLOR = labelColors,$
                             Alignment = 1.0, FONT = FontTicks, /ENABLE_FORMATTING)
                             
     oModel -> Add, oFrameLabel

     posy = posy - dy
     
     px0 = 0.52
     px1 = 0.9
     py0 = posy
     py1 = posy + dy/5.
         
     oPoly1 = OBJ_NEW('IDLgrPolyline', [px0,px0,px1,px1, px0], [py0,py1,py1,py0, py0], COLOR = labelColors)
     oModel -> Add, oPoly1

     px1 = px0 + (px1-px0)*float(frame)/nframes

     oPoly2 = OBJ_NEW('IDLgrPolygon', [px0,px0,px1,px1], [py0,py1,py1,py0], COLOR = labelColors)
     oModel -> Add, oPoly2
        
   end
 
   ; Add Models to view
  
   oView->ADD, oModel
   oView->ADD, oModelLight

   ; Render Model

   if (N_Elements(fileout) eq 0) then begin
     oWindow = OBJ_NEW('IDLgrWindow', DIMENSIONS = Res)
     oWindow-> Draw, oView
     SceneAntiAlias, oWindow, oView, 8
   end else begin
     oBuffer = OBJ_NEW('IDLgrWindow', DIMENSIONS = Res)
     oBuffer-> Draw, oView
     SceneAntiAlias, oBuffer, oView, 8
     
     myimage = oBuffer -> Read()
     myimage -> GetProperty, DATA = image

     Image = reverse(Image,3) 
     WRITE_TIFF, fileout, image, 1
     OBJ_DESTROY, oModel
     OBJ_DESTROY, oModelLight
     OBJ_DESTROY, myImage
     OBJ_DESTROY, oBuffer
     OBJ_DESTROY, oView       
   end

end