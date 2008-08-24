;
;
;  Y :  Arr(N) or Arr(N,2)
;
;
;



; ---------------------------------------------------------------------


; --------------------------------------------------- Plot1D_Redraw ---
;  Redraw the plot
; ---------------------------------------------------------------------

pro Plot1D_Redraw, sState
   widget_control, /hourglass
   sState.oWindow->Draw, sState.oView
end

; ---------------------------------------------------------------------

; ----------------------------------------------- Plot1D_UpdateAxis ---
;  Updates the axis
; ---------------------------------------------------------------------

pro Plot1D_UpdateAxis, sState

  ; Update Data Position

  if (sState.iAddLegend) then begin
    legend_width = (sState.oLegend -> ComputeDimensions(sState.oWindow))[0]
    PlotPosition = [0.15,0.15,0.96-legend_width,0.85]
    sState.oLegend -> SetProperty, Location = [0.98, 0.5], $
                      ALIGNMENT = 1.0, VERTICAL_ALIGNMENT = 0.5
       
  end else PlotPosition = [0.15,0.15,0.85,0.85]

  sState.DataPosition = PlotPosition
               
  ; Update Axis
  dimension = [ sState.DataPosition[2] - sState.DataPosition[0], $
                sState.DataPosition[3] - sState.DataPosition[1] ]
  location = [ sState.DataPosition[0], sState.DataPosition[1] ] 
   
  XMin = sState.xrange[0]
  XMax = sState.xrange[1]
  
  
  YMin = sState.yrange[0]
  YMax = sState.yrange[1]

  ; Set Location and coordinate conversion

  if (sState.iylog) then begin
    if (YMax lt 1e-37) then YMax = 1.0 else YMax = Alog10(YMax)
    if (YMin lt 1e-37) then YMin = YMax/4.0 else YMin = Alog10(YMin)
    sState.yAxis   -> SetProperty, RANGE = 10.0^[YMin, YMax], /exact, /LOG
    sState.yAxisOp -> SetProperty, RANGE = 10.0^[YMin, YMax], /exact, /LOG
  end else begin
    sState.yAxis   -> SetProperty, RANGE = [YMin, YMax], /exact, LOG = 0
    sState.yAxisOp -> SetProperty, RANGE = [YMin, YMax], /exact, LOG = 0
  end

  if (sState.ixlog) then begin
    if (XMax lt 1e-37) then XMax = 1.0 else XMax = Alog10(XMax)
    if (XMin lt 1e-37) then XMin = XMax/4.0 else XMin = Alog10(XMin)
    sState.xAxis   -> SetProperty, RANGE = 10.0^[XMin, XMax], /exact, /LOG 
    sState.xAxisOp -> SetProperty, RANGE = 10.0^[XMin, XMax], /exact, /LOG 
  end else begin
    sState.xAxis   -> SetProperty, RANGE = [XMin, XMax], /exact, LOG = 0
    sState.xAxisOp -> SetProperty, RANGE = [XMin, XMax], /exact, LOG = 0
  end

  ; Set Ranges
        


  ycconv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
  xcconv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
 
  sState.xAxis -> SetProperty, LOCATION = [XMin,YMin]
  xtl = 0.04 *(YMax-Ymin)
  sState.xAxis -> SetProperty, TICKLEN = xtl
  sState.xAxis -> SetProperty, YCOORD_CONV = ycconv
  sState.xAxis -> SetProperty, XCOORD_CONV = xcconv

  sState.xAxisOp -> SetProperty, LOCATION = [XMin,YMax]
  sState.xAxisOp -> SetProperty, TICKLEN = xtl
  sState.xAxisOp -> SetProperty, YCOORD_CONV = ycconv
  sState.xAxisOp -> SetProperty, XCOORD_CONV = xcconv


  sState.yAxis -> SetProperty, LOCATION = [XMin,YMin]
  ytl = 0.04 *(XMax-Xmin)
  sState.yAxis -> SetProperty, TICKLEN = ytl
  sState.yAxis -> SetProperty, YCOORD_CONV = ycconv
  sState.yAxis -> SetProperty, XCOORD_CONV = xcconv

  sState.yAxisOp -> SetProperty, LOCATION = [XMax,YMin]
  sState.yAxisOp -> SetProperty, TICKLEN = ytl
  sState.yAxisOp -> SetProperty, YCOORD_CONV = ycconv
  sState.yAxisOp -> SetProperty, XCOORD_CONV = xcconv

  ;note: this doesn't take into account the window size assimetry
  symbol_size = [ytl, xtl] /5.0
  ;symbol_size = symbol_size/max(symbol_size) 
  
  for i=0,sState.n_series-1 do begin
     (*sState.oPlots)[i] -> SetProperty, YCOORD_CONV = ycconv
     (*sState.oPlots)[i] -> SetProperty, XCOORD_CONV = xcconv

     y = *(*sState.ppData)[1,i] 
     x = *(*sState.ppData)[0,i] 

     if (sState.ixlog) then begin
       x = Alog10(x >1e-37)
       idx = where(x eq -37.0, count) 
       if (count gt 0) then x[temporary(idx)] = XMin-1.0
     end 

     if (sState.iylog) then begin
       y = Alog10(y >1e-37)
       idx = where(y eq -37.0, count) 
       if (count gt 0) then y[temporary(idx)] = YMin-1.0
     end 

     (*sState.oPlots)[i] -> SetProperty, DATAY = y 
     (*sState.oPlots)[i] -> SetProperty, DATAX = x

     (*sState.oPlots)[i] -> SetProperty, XRANGE = [Xmin, Xmax]
     (*sState.oPlots)[i] -> SetProperty, YRANGE = [Ymin, Ymax]

;     (*sState.oPlots)[i] -> SetProperty, MIN_VALUE= Ymin
;     (*sState.oPlots)[i] -> SetProperty, MAX_VALUE = Ymax
     
     (*sState.poSymbol)[i] -> SetProperty, SIZE = symbol_size
  end 
end

; ---------------------------------------------------------------------


; ------------------------------------------------ Plot1D_AddSeries ---
;  Add a series to the plot
; ---------------------------------------------------------------------

pro Plot1D_AddSeries, x, y, sState, $
              ; Plot options
              COLOR = color, HISTOGRAM = use_histogram, LINESTYLE = linestyle, SYMBOL = symbol, $
              THICK = thick, NSUM = nsum, NAME = name
              
  if N_Params() ne 3 then begin
    res = Error_Message('Invalid Number of parameters')
    return
  end
  
  ; COLOR
  ; 
  
  if N_Elements(color) eq 0 then begin
    def_colors = [ [255b,255b,255b], $	; white
                   [255b,  0b,  0b], $	; red
                   [ 63b, 63b,255b], $	; blue
                   [  0b,255b,  0b], $	; green
                   [  0b,255b,255b], $	; cyan
                   [255b,255b,  0b], $	; yellow
                   [191b,  0b,191b] ]		; purple
     
    color = reform(def_colors[*,(sState.n_series+1) mod 7]) 
  end else begin
    s = size(color, /n_dimensions)
    case (s) of
       1: begin
            s = size(color, /dimensions)
            if (s[0] ne 3) then begin
               res = Error_Message('COLOR must be a color in the form [R,G,B]')
               return    
            end
          end
    else: begin
            res = Error_Message('COLOR must be a color in the form [R,G,B]')
            return    
          end
    endcase
  end 

  ; HISTOGRAM
  
  use_histogram = Keyword_Set(use_histogram)

  ; LINESTYLE
  
  if N_Elements(linestyle) eq 0 then begin
    linestyle = 0
  end 

  ; SYMBOL
  
  if N_Elements(symbol) eq 0 then begin
    symbol = 0b
  end 

  ; THICK
  
  if N_Elements(thick) eq 0 then begin
    thick = 1b
  end 

  ; NSUM

  if N_Elements(nsum) eq 0 then begin
    nsum = 1
  end

  ; NAME

  if N_Elements(name) eq 0 then begin
    name = 'Series '+strtrim(sState.n_series+1,1)
  end
  
  ; Add the series
  
  sState.n_series = sState.n_series+1

  objPlot = Obj_New('IDLgrPlot')
  objPlot -> SetProperty, COLOR = color
  objPlot -> SetProperty, HISTOGRAM = use_histogram
  objPlot -> SetProperty, LINESTYLE = linestyle

  oSymbol = Obj_new('IDLgrSymbol', symbol, COLOR = color)
  sState.oContainer -> Add, oSymbol

  objPlot -> SetProperty, SYMBOL = oSymbol 
  objPlot -> SetProperty, THICK = thick
  objPlot -> SetProperty, NSUM = nsum
  objPlot -> SetProperty, NAME = name[0]
  sState.oModel -> Add, objPlot
  
  pdata = [ptr_new(x),ptr_new(y)]
  
  *sState.ppData       = [[*sState.ppData],[pdata]]  
  
  *sState.oPlots      = [*sState.oPlots,objPlot]  
  *sState.pname       = [*sState.pname,name]
  *sState.pColor      = [[*sState.pColor], [color]]
  *sState.pHistogram  = [*sState.pHistogram, use_histogram]
  *sState.plinestyle  = [*sState.plinestyle, linestyle]
  *sState.pthick      = [*sState.pthick,thick]
  *sState.pnsum       = [*sState.pnsum,nsum]
  *sState.poSymbol    = [*sState.poSymbol, oSymbol]
  
  ; Update the legend
  
  symbol_style = LonArr(sState.n_series)
   
  for i=0,sState.n_series-1 do begin
    (*sState.poSymbol)[i] -> GetProperty, DATA = temp
    symbol_style[i] = temp 
  end 

  sState.oLegend -> SetProperty, LABELS = *sState.pname, $
                       LINECOLOR = *sState.pColor, $
                       LINESTYLE = *sState.plinestyle, $
                       LINETHICK = *sState.pthick, $
                       SYMBOLCOLOR = *sState.pColor, $
                       SYMBOLSTYLE = symbol_style
  
  plot1D_UpdateAxis, sState

end
; ---------------------------------------------------------------------



; --------------------------------------------- Plot1D_GenerateView ---
;  Generates the plot
; ---------------------------------------------------------------------

pro Plot1D_GenerateView, sState
  
  widget_control, /hourglass

  ; The view is set to be the same as normal coordinates in direct graphics

  sState.oView -> SetProperty, VIEW = [0,0,1.,1.], PROJECTION = 1

   
  ; Generates plot(s)
   
  symbol_style = LonArr(sState.n_series)
  sState.oPlots = ptr_new(ObjArr(sState.n_series))
   
  for i=0,sState.n_series-1 do begin
    (*sState.oPlots)[i] = Obj_New('IDLgrPlot')
    (*sState.oPlots)[i] -> SetProperty, COLOR = (*sState.pColor)[*,i]
    (*sState.oPlots)[i] -> SetProperty, HISTOGRAM = (*sState.phistogram)[i]
    (*sState.oPlots)[i] -> SetProperty, LINESTYLE = (*sState.plinestyle)[i]
    (*sState.poSymbol)[i] -> GetProperty, DATA = temp
    symbol_style[i] = temp 
    (*sState.oPlots)[i] -> SetProperty, SYMBOL = (*sState.poSymbol)[i]
    (*sState.oPlots)[i] -> SetProperty, THICK = (*sState.pthick)[i]
    (*sState.oPlots)[i] -> SetProperty, NSUM = (*sState.pnsum)[i]
    (*sState.oPlots)[i] -> SetProperty, NAME = (*sState.pname)[i]
    sState.oModel -> Add, (*sState.oPlots)[i]
  end 
    
  ; Generate Axis and Axis Labels
   
  if (sState.iInvColors eq 0) then axisColor = [255b,255b,255b] $
  else axisColor = [0b,0b,0b]

  ; Adds Spatial Axis
 
  sState.xAxis -> SetProperty, COLOR = axisColor
  sState.oModelAxis -> Add, sState.xAxis

  sState.xAxisOp -> SetProperty, COLOR = axisColor, TICKDIR = 1
  sState.oModelAxis -> Add, sState.xAxisOp
   
  sState.yAxis -> SetProperty, COLOR = axisColor
  sState.oModelAxis -> Add, sState.yAxis

  sState.yAxisOp -> SetProperty, COLOR = axisColor, TICKDIR = 1
  sState.oModelAxis -> Add, sState.yAxisOp

  sState.y2Axis -> SetProperty, COLOR = axisColor, TICKDIR = 1, HIDE = 1
  sState.oModelAxis -> Add, sState.y2Axis

  ; Generate Legend
  
  
  sState.oLegend = obj_new('z_grLegend',*sState.pname, $
                       LINECOLOR = *sState.pColor, $
                       LINESTYLE = *sState.plinestyle, $
                       LINETHICK = *sState.pthick, $
                       SYMBOLCOLOR = *sState.pColor, $
                       SYMBOLSTYLE = symbol_style, $
                       /show_outline, OUTLINE_COLOR = axisColor, TEXT_COLOR = axisColor, $
                       FONT = sState.oFontAxis)
 
  sState.oLegend -> SetProperty, HIDE = 1-sState.iAddLegend

  sState.oModelAxis -> Add, sState.oLegend 
     
  ; Update Title Position   

  sState.oTitle-> SetProperty, LOCATION = [0.5,0.95], ALIGNMENT = 0.5
  sState.oSubTitle-> SetProperty, LOCATION = [0.5, 0.90], ALIGNMENT = 0.5

  ; Update Ranges
  
  Plot1D_UpdateAxis, sState
end


; -------------------------------------------- Draw_Visualize_Event ---
;  Handles draw widget events
; ---------------------------------------------------------------------

pro Plot1D_Draw_Visualize_Event, sEvent
  
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
       Plot1D_Redraw, sState
    ENDIF

    ; Button press
    IF (sEvent.type EQ 0) THEN BEGIN
        sState.tool_pos0 = double([sEvent.x ,sEvent.y])
        x0 = sState.tool_pos0[0]/sState.window_size[0] 
        y0 = sState.tool_pos0[1]/sState.window_size[1] 

        if ((x0 ge sState.DataPosition[0]) and $
            (x0 le sState.DataPosition[2]) and $
            (y0 ge sState.DataPosition[1]) and $
            (y0 le sState.DataPosition[3])) then begin

          sState.btndown = 1b
          case (sState.iTool) of 
            0: $ ; Zoom
              begin
                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                sState.oZoomBox -> SetProperty, Hide = 0
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x0,y0]] 
      
                clWhite = [255b,255b,255b]
                clBlack = [0b,0b,0b]
                if (sState.iInvColors eq 1) then begin
                  sState.oZoomBox -> SetProperty, COLOR = clBlack
                end else begin
                  sState.oZoomBox -> SetProperty, COLOR = clWhite
                end
                sState.oWindow->Draw, sState.oViewTools, /CREATE_INSTANCE
              end
            2: $ ; Scalings
               begin
                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                sState.oScalingLine -> SetProperty, Hide = 0
                sState.oScalingLine -> SetProperty, Data = [[x0,y0], [x0,y0]] 
      
                if (sState.iInvColors eq 1) then sState.oScalingLine -> SetProperty, COLOR = [255b,255b,0] $
                else sState.oScalingLine -> SetProperty, COLOR = [63b,63b,255b]
                
                sState.oWindow->Draw, sState.oViewTools, /CREATE_INSTANCE
              end

            1: ; Data Picking
          else:
          endcase
        end
    end

    ; Motion with button pressed
    if (sEvent.type EQ 2) and (sState.btndown EQ 1b) then begin
       tool_pos1 = double([ sEvent.x ,sEvent.y])
       x0 = sState.tool_pos0[0]/sState.window_size[0]
       y0 = sState.tool_pos0[1]/sState.window_size[1]
       x1 = tool_pos1[0]/sState.window_size[0]
       y1 = tool_pos1[1]/sState.window_size[1]
       case (sState.iTool) of 
         0: $ ; Zoom
              begin
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x1,y0], [x1,y1], [x0,y1], [x0,y0] ] 
                sState.oWindow->Draw, sState.oViewTools, /DRAW_INSTANCE
              end
         2: $ ; Scalings
               begin
                sState.oScalingLine -> SetProperty, Data = [[x0,y0], [x1,y1]] 
                sState.oWindow->Draw, sState.oViewTools, /DRAW_INSTANCE
              end

         1: ; Data Picking
       else:
       endcase
    end

    ; Button Release
    IF (sEvent.type EQ 1) THEN BEGIN
        IF (sState.btndown EQ 1b) THEN BEGIN
          sState.oZoomBox -> SetProperty, Hide = 1
          sState.oScalingLine -> SetProperty, Hide = 1
        
          tool_pos1 = double([ sEvent.x ,sEvent.y]) 

          dataXL = double(sState.DataPosition[2]-sState.DataPosition[0])
          dataYL = double(sState.DataPosition[3]-sState.DataPosition[1])
          dataXmin = double(sState.DataPosition[0])
          dataYmin = double(sState.DataPosition[1])

          if (sState.ixlog) then begin
            viewXL = alog10(sState.Xrange[1]/sState.Xrange[0])
            x0 = sState.xrange[0] *  10.0^((sState.tool_pos0[0]/sState.window_size[0]-dataXmin)/dataXL * viewXL)
            x1 = sState.xrange[0] *  10.0^((tool_pos1[0]/sState.window_size[0]-dataXmin)/dataXL * viewXL)
          end else begin
            viewXL = sState.Xrange[1] - sState.Xrange[0]
            x0 = sState.xrange[0] +  (sState.tool_pos0[0]/sState.window_size[0]-dataXmin)/dataXL * viewXL
            x1 = sState.xrange[0] +  (tool_pos1[0]/sState.window_size[0]-dataXmin)/dataXL * viewXL
          end


          if (sState.iylog) then begin
            viewYL = alog10(sState.Yrange[1]/ sState.Yrange[0])
            y0 = sState.yrange[0] *  10.0^((sState.tool_pos0[1]/sState.window_size[1]-dataYmin)/dataYL * viewYL)
            y1 = sState.yrange[0] *  10.0^((tool_pos1[1]/sState.window_size[1]-dataYmin)/dataYL * viewYL)
          end else begin
            viewYL = sState.Yrange[1] - sState.Yrange[0]
            y0 = sState.yrange[0] +  (sState.tool_pos0[1]/sState.window_size[1]-dataYmin)/dataYL * viewYL
            y1 = sState.yrange[0] +  (tool_pos1[1]/sState.window_size[1]-dataYmin)/dataYL * viewYL
          end
                    
          if (x1 lt sState.xrange[0]) then x1 = sState.xrange[0]
          if (x1 gt sState.xrange[1]) then x1 = sState.xrange[1]
          if (y1 lt sState.yrange[0]) then y1 = sState.yrange[0]
          if (y1 gt sState.yrange[1]) then y1 = sState.yrange[1]
                    
          case (sState.iTool) of
             0: $ ; Zoom
                if total(abs(tool_pos1-sState.tool_pos0)) gt 6 then begin
                  if (x0 gt x1) then swap, x0, x1
                  if (y0 gt y1) then swap, y0, y1
                  sState.xrange = [x0,x1]
                  sState.yrange = [y0,y1]
                  plot1d_UpdateAxis, sState
                end
             1: $ ; Data Picking
                begin
                  obj = sState.oWindow -> Select(sState.oView,[sEvent.x,sEvent.y])
                  if (obj_valid(obj[0])) then if (obj_isa(obj[0], 'IDLgrPlot')) then begin
                    res = sState.oWindow -> PickData(sState.oView, obj[0], [sEvent.x,sEvent.y], value)
                    if (res eq 1) then begin
                      obj[0] -> GetProperty, NAME = name
                      x = (sState.ixlog)?10^value[0]:value[0]
                      y = (sState.iylog)?10^value[1]:value[1]
                      
                      print, name,': ', strtrim(x,1),',',strtrim(y,1)
                    end
                  end else begin
                    print, 'No series selected!'
                  end 
                end
             2: $ ; Scalings
                if (x0 ne x1) then begin
                  if (sState.ixlog) then begin
                    text_x = 'Ln'
                    xrange = alog(x1/x0)
                  end else begin
                    text_x = 'Linear'
                    xrange = x1 - x0
                  end

                  if (sState.iylog) then begin
                    text_y = 'Ln'
                    yrange = alog(y1/y0)
                  end else begin
                    text_y = 'Linear'
                    yrange = y1 - y0
                  end
                  
                  text = (sState.ixlog or sState.iylog)?text_y+'-'+text_x:'Linear'
                  
                  x0 = float(x0)
                  x1 = float(x1)
                  y0 = float(y0)
                  y1 = float(y1)
                  
                  print, ' '
                  print, 'Scaling ',text
                  print, '------------------------------------------'
                  print, '('+strtrim(x0,1)+','+strtrim(y0,1)+') -> ('+strtrim(x1,1)+','+strtrim(y1,1)+')
                  print, 's = ', float(yrange/xrange)
                  print, ' '
                  
                end
             
          else:
          endcase
                  
          plot1d_redraw, sState 
         ENDIF
         sState.btndown = 0b
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF
     
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
end
; ---------------------------------------------------------------------

; --------------------------------------- SavePlotTIFF_Plot1D_Event ---
;  Handles SavePlotTIFF events
; ---------------------------------------------------------------------

pro SavePlotTIFF_Plot1D_Event, sEvent

   tifffileout = Dialog_PickFile(/write, FILTER = '*.tif',$
                        TITLE = 'Save plot TIFF file as...', GET_PATH = tifffilepath)
   if (tifffileout ne '') then begin
     cd, tifffilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
             
     myimage = sState.oWindow -> Read()
     myimage -> GetProperty, DATA = imageout
     Obj_Destroy, myimage
        
     imageout = reverse(imageout,3)
     WRITE_TIFF, tifffileout, imageout, 1
         
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end

; ---------------------------------------------------------------------

; --------------------------------------- PageSetup_Plot1D_Event ---
;  Handles Page Setup events
; ---------------------------------------------------------------------

pro PageSetup_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  res = Dialog_PrinterSetup(sState.oPrinter) 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ------------------------------------------- Print_Plot1D_Event ---
;  Handles Print events
; ---------------------------------------------------------------------

pro Print_Plot1D_Event, sEvent
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

    temp = sState.oWindow
    sState.oWindow = sState.oPrinter
    Plot1D_Redraw, sState
    sState.oWindow = temp 
    
    ; Restore the view
    sState.oView -> Setproperty, UNITS = ViewUnits
    sState.oView -> Setproperty, DIMENSIONS = ViewDimensions
    
    ; Start the printing job
    sState.oPrinter-> NewDocument
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; --------------------------------------- ClipCopyPlot_Plot1D_Event ---
;  Handles Copy Plot events
; ---------------------------------------------------------------------

pro ClipCopyPlot_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oWindow -> GetProperty, Dimension = ImageResolution
  temp = sState.oWindow             
  oClipboard = obj_new('IDLgrClipboard',DIMENSIONS=ImageResolution)

  sState.oWindow = oClipboard
  
  Plot1D_Redraw, sState
  
  sState.oWindow = temp 
    
  Obj_Destroy, oClipboard

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end

; ---------------------------------------------------------------------


; --------------------------------- Visualize_UpdateInvColors_Event ---
;  Handles Changes to the Invert Color setting
; ---------------------------------------------------------------------

pro Plot1D_UpdateInvColors_Event, sEvent

  clWhite = [255b,255b,255b]
  clBlack = [0b,0b,0b]

  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  sState.iInvColors = 1 - Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))
  
  if (sState.iInvColors eq 1) then begin
    oObjects = sState.oModelAxis -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    oObjects = sState.oModelTitles -> Get(/ALL, COUNT = nObjects) 
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clBlack
    end
    sState.oView -> SetProperty, COLOR = clWhite
    
    for i=0,sState.n_series-1 do begin
      (*sState.oPlots)[i] -> GetProperty, COLOR = color
      if (total(long(color)) eq 765) then $
        (*sState.oPlots)[i] -> SetProperty, COLOR = [0b,0b,0b]
    end 
    
  end else begin
    oObjects = sState.oModelAxis -> Get(/ALL, COUNT = nObjects)    
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clWhite
    end
    oObjects = sState.oModelTitles -> Get(/ALL, COUNT = nObjects)    
    for i=0,nObjects-1 do begin
      oObjects[i] -> SetProperty, COLOR = clWhite
    end
    sState.oView -> SetProperty, COLOR = clBlack

    for i=0,sState.n_series-1 do begin
      (*sState.oPlots)[i] -> GetProperty, COLOR = color
      if (total(long(color)) eq 0) then $
        (*sState.oPlots)[i] -> SetProperty, COLOR = [0b,0b,0b]
    end 

  end

  Plot1D_Redraw, sState                    
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------

; ---------------------------------------------- XAxis_Plot1D_Event ---
;  Handles changes to the X-Axis
; ---------------------------------------------------------------------

pro XAxis_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  Autoscale = 0b
  
  data = { $
           Autoscale : 0b, $
           Logarithmic : Byte(sState.ixlog), $
           Minimum : sState.xrange[0], $
           Maximum : sState.xrange[1] $
           }           
           
  labels = [ $
           'Autoscale', $
           'Use Log Scale', $
           'Minimum', $
           'Maximum' $
           ]  

  res = InputValues( data, $
                     labels = labels, $
                     Title = 'X Axis', $
                     group_leader = sEvent.top )
  
  if (res eq 1) then begin
     sState.ixlog = data.Logarithmic
 
     if (data.Autoscale eq 0) then begin
        sState.xrange[0] = data.Minimum
        sState.xrange[1] = data.Maximum 
        
        if (sState.ixlog eq 1) then $ 
          sState.xrange = abs(sState.xrange)
        
        if (sState.xrange[0] gt sState.xrange[1]) then begin
          temp = sState.xrange[1]
          sState.xrange[1] = sState.xrange[0]
          sState.xrange[0] = temp
        end else if (sState.xrange[0] eq sState.xrange[1]) then begin
          sState.xrange[0] = sState.xrange[0]*0.9
          sState.xrange[1] = sState.xrange[1]*1.1
        end
           
     end else begin
        xmin = MinN0(*(*sState.ppData)[0,0], max = xmax, MINN0 = xmin_n0)
        for i = 0, sState.n_series-1 do $
          xmin = MinN0([*(*sState.ppData)[0,i],xmin,xmax], max = xmax, MINN0 = xmin_n0)
              
        if (sState.ixlog) then begin
          if (xmax lt 1e-37) then xmax = 1.0
          if (xmin_n0 lt 1e-37) then xmin_n0 = xmax/10.0
          sState.xrange = [xmin_n0*0.9,xmax*1.1]
        end else begin
          lx_off = (xmax-xmin)*0.05
          sState.xrange = [xmin-lx_off,xmax+lx_off]
        end           
     end

     Plot1D_UpdateAxis, sState
     Plot1D_Redraw, sState 
  end
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ---------------------------------------------- YAxis_Plot1D_Event ---
;  Handles changes to the Y-Axis
; ---------------------------------------------------------------------

pro YAxis_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  Autoscale = 0b
  
  data = { $
           Autoscale : 0b, $
           Logarithmic : Byte(sState.iylog), $
           Minimum : sState.yrange[0], $
           Maximum : sState.yrange[1] $
           }           
           
  labels = [ $
           'Autoscale', $
           'Use Log Scale', $
           'Minimum', $
           'Maximum' $
           ]  

  res = InputValues( data, $
                     labels = labels, $
                     Title = 'Y Axis', $
                     group_leader = sEvent.top )
  
  if (res eq 1) then begin
     sState.iylog = data.Logarithmic
 
     if (data.Autoscale eq 0) then begin
        sState.yrange[0] = data.Minimum
        sState.yrange[1] = data.Maximum 
        
        if (sState.iylog eq 1) then $ 
          sState.yrange = abs(sState.yrange)
        
        if (sState.yrange[0] gt sState.yrange[1]) then begin
          temp = sState.yrange[1]
          sState.yrange[1] = sState.yrange[0]
          sState.yrange[0] = temp
        end else if (sState.yrange[0] eq sState.yrange[1]) then begin
          sState.yrange[0] = sState.yrange[0]*0.9
          sState.yrange[1] = sState.yrange[1]*1.1
        end
           
     end else begin
        ymin = MinN0(*(*sState.ppData)[1,0], max = ymax, MINN0 = ymin_n0)
        for i = 0, sState.n_series-1 do $
          ymin = MinN0([*(*sState.ppData)[1,i],ymin,ymax], max = ymax, MINN0 = ymin_n0)
              
        if (sState.iylog) then begin
          if (ymax lt 1e-37) then ymax = 1.0
          if (ymin_n0 lt 1e-37) then ymin_n0 = ymax/10.0
          sState.yrange = [ymin_n0*0.9,ymax*1.1]
        end else begin
          ly_off = (ymax-ymin)*0.05
          sState.yrange = [ymin-ly_off,ymax+ly_off]
        end           
     end

     Plot1D_UpdateAxis, sState
     Plot1D_Redraw, sState 
  end
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ------------------------------------------- LocalMax_Plot1D_Event ---
;  Handles Local Max Events
; ---------------------------------------------------------------------

pro LocalMax_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
    
  threshvalue = 0.0
  
  ; Byte values are used for toggle fields
  
  T_BYTE = 1
  if (size(threshvalue, /type) eq T_BYTE) then $
    threshvalue = long(threshvalue)
  
  data = { $
           threshvalue : threshvalue, $
           usethreshold: 0b, $
           noderivcheck : 0b, $
           nosort : 0b, $
           periodic:0b, $
           series_names:[*sState.pname,''] $
           }           
           
  labels = [ $
           "Threshold Value", $
           "Use Threshold", $
           "Don't check derivatives", $
           "Don't Sort", $
           'Periodic', $
           'Series' $
           ]  

  res = InputValues( data, $
                     labels = labels, $
                     Title = 'Local Max', $
                     group_leader = sEvent.top, xsize = 150 )

  if (res eq 1) then begin
    threshvalue = data.threshvalue
    if (not data.usethreshold) then undefine, threshvalue

    series = (where(*sState.pname eq data.series_names[0]))[0]
    
    help, series
        
    x = Local_Max(*(*sState.ppData)[1,series], VALUES = y, NMAX = n_max, $
                  NOSORT = data.nosort, NODERIVCHECK = data.noderivcheck, $
                  PERIODIC = data.periodic, THRESHOLD = threshvalue, /verbose)
    
    if (n_max gt 0) then begin
       x = (*(*sState.ppData)[0,series])[temporary(x)]
     
       help, n_max
       help, x,y
     
       text = StrArr(n_max+4)
       text[0] = ' Series : '+(*sState.pname)[series]
       text[1] = ' '
       text[2] = ' Local Maxima found : '+strtrim(n_max,1)
       text[3] = ' --------------------------------------------------------- '
       for i=0, n_max-1 do $
         text[i+4] = ' ('+strtrim(x[i],1)+') -> '+strtrim(y[i]) 
      
      
       XDisplayText, text, TITLE = 'Local Max', GROUP = sEvent.top, /no_block     

       Plot1D_AddSeries, x, y, sState, $
          COLOR = reform((*sState.pColor)[*,series]), LINESTYLE = 6, SYMBOL = 6, $
          NAME = 'Local Max '+(*sState.pname)[series]

       Plot1D_Redraw, sState                    

    end else res = Dialog_Message('No local maxima found.', /information)
  end

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ------------------------------------------ ZoomReset_Plot2D_Event ---
;  Handles zoom reset events
; ---------------------------------------------------------------------

pro ZoomReset_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  ymin = MinN0(*(*sState.ppData)[1,0], max = ymax, MINN0 = ymin_n0)
  for i = 0, sState.n_series-1 do $
    ymin = MinN0([*(*sState.ppData)[1,i],ymin,ymax], max = ymax, MINN0 = ymin_n0)
              
  if (sState.iylog) then begin
    if (ymax lt 1e-37) then ymax = 1.0
    if (ymin_n0 lt 1e-37) then ymin_n0 = ymax/10.0
    sState.yrange = [ymin_n0*0.9,ymax*1.1]
  end else begin
    ly_off = (ymax-ymin)*0.05
    sState.yrange = [ymin-ly_off,ymax+ly_off]
  end           

  xmin = MinN0(*(*sState.ppData)[0,0], max = xmax, MINN0 = xmin_n0)
  for i = 0, sState.n_series-1 do $
    xmin = MinN0([*(*sState.ppData)[0,i],xmin,xmax], max = xmax, MINN0 = xmin_n0)
              
  if (sState.ixlog) then begin
    if (xmax lt 1e-37) then xmax = 1.0
    if (xmin_n0 lt 1e-37) then xmin_n0 = xmax/10.0
    sState.xrange = [xmin_n0*0.9,xmax*1.1]
  end else begin
    lx_off = (xmax-xmin)*0.05
    sState.xrange = [xmin-lx_off,xmax+lx_off]
  end           
  
  ; Reset the Axis and the data
  Plot1D_UpdateAxis, sState
  Plot1D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end
; ---------------------------------------------------------------------

; --------------------------------------------- ZoomIn_Plot1D_Event ---
;  Handles zoom in events
; ---------------------------------------------------------------------

pro ZoomIn_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  if (sState.ixlog) then begin
    lx = 10.0^(alog10(sState.xrange[1] / sState.xrange[0]) /3.0)
    sState.xrange[0] = sState.xrange[0] * lx
    sState.xrange[1] = sState.xrange[1] / lx
  end else begin
    lx = (sState.xrange[1] - sState.xrange[0])/4.0
    sState.xrange[0] = sState.xrange[0] + lx
    sState.xrange[1] = sState.xrange[1] - lx
  end

  if (sState.iylog) then begin
    ly = 10.0^(alog10(sState.yrange[1] / sState.yrange[0]) /3.0)
    sState.yrange[0] = sState.yrange[0] * ly
    sState.yrange[1] = sState.yrange[1] / ly
  end else begin
    ly = (sState.yrange[1] - sState.yrange[0])/4.0
    sState.yrange[0] = sState.yrange[0] + ly
    sState.yrange[1] = sState.yrange[1] - ly
  end

  Plot1D_UpdateAxis, sState
  Plot1D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------

; -------------------------------------------- ZoomOut_Plot1D_Event ---
;  Handles zoom out events
; ---------------------------------------------------------------------

pro ZoomOut_Plot1D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  if (sState.ixlog) then begin
    lx = sState.xrange[1] / sState.xrange[0] 
    sState.xrange[0] = sState.xrange[0] / lx
    sState.xrange[1] = sState.xrange[1] * lx
  end else begin
    lx = (sState.xrange[1] - sState.xrange[0])/2.0
    sState.xrange[0] = sState.xrange[0] - lx
    sState.xrange[1] = sState.xrange[1] + lx
  end

  if (sState.iylog) then begin
    ly = sState.yrange[1] / sState.yrange[0]
    sState.yrange[0] = sState.yrange[0] / ly
    sState.yrange[1] = sState.yrange[1] * ly
  end else begin
    ly = (sState.yrange[1] - sState.yrange[0])/2.0
    sState.yrange[0] = sState.yrange[0] - ly
    sState.yrange[1] = sState.yrange[1] + ly
  end

  Plot1D_UpdateAxis, sState
  Plot1D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------

; ----------------------------------------- SelectTool_Plot1D_Event ---
;  Selects the tool in use
; ---------------------------------------------------------------------

pro SelectTool_Plot1D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iTool = Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; ----------------------------------------- Plot1D_UpdateLegend ---
;  Shows/Hides Legend
; ---------------------------------------------------------------------

pro Plot1D_UpdateLegend, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iAddLegend = 1 - Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  sState.oLegend -> SetProperty, HIDE = 1-sState.iAddLegend
  plot1D_updateaxis, sState
  plot1D_redraw, sState                                


  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------


; ---------------------------------------------- Plot1D_Menu_Events ---
;  Handles menu events
; ---------------------------------------------------------------------

pro Plot1D_Menu_Events, sEvent
  
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue ; Menu events

  case eventUValue of
    ; Menu Options
    '|File|Save Plot Tiff...'		: SavePlotTIFF_Plot1D_Event, sEvent 
    '|File|Page Setup...'			: PageSetup_Plot1D_Event, sEvent
    '|File|Print...'				: Print_Plot1D_Event, sEvent
    '|File|Quit'				: WIDGET_CONTROL, sEvent.top, /DESTROY
    '|Edit|Copy Plot'				: ClipCopyPlot_Plot1D_Event, sEvent
    '|Plot|Invert Colors|On'		: Plot1D_UpdateInvColors_Event, sEvent
    '|Plot|Invert Colors|Off'		: Plot1D_UpdateInvColors_Event, sEvent
    '|Plot|X-Axis'				: XAxis_Plot1D_Event, sEvent     
    '|Plot|Y-Axis'				: YAxis_Plot1D_Event, sEvent     
;    '|Plot|Y2-Axis'				: Y2Axis_Plot1D_Event, sEvent     
    '|Plot|Legend|Off'			: Plot1D_UpdateLegend, sEvent
    '|Plot|Legend|On'				: Plot1D_UpdateLegend, sEvent
    
    
     
    ; Analysis
    '|Tool|Local Max'				: LocalMax_Plot1D_Event, sEvent

    ; Zoom
    '|Tool|Zoom|In'				: ZoomIn_Plot1D_Event, sEvent
    '|Tool|Zoom|Out'				: ZoomOut_Plot1D_Event, sEvent
    '|Tool|Zoom|Reset'			: ZoomReset_Plot1D_Event, sEvent

    ; Tool Selection

    '|Tool|Tool|Zoom'				: SelectTool_Plot1D_Event, sEvent
    '|Tool|Tool|Scalings'			: SelectTool_Plot1D_Event, sEvent
    '|Tool|Tool|Data Picking'		: SelectTool_Plot1D_Event, sEvent
              
    '|About|About Plot 1D'	: XDisplayText, 'About Plot 1D not implemented yet' , $
                               /MODAL, TITLE = 'About Plot 1D'
                                           
     else: begin
               print, "'"+eventUvalue+"'"+' not found, returning'
               print, 'Widget_Button Event'
               print, 'id      = ', sEvent.id
               print, 'top     = ', sEvent.top
               print, 'handler = ', sEvent.Handler
               print, 'select  = ', sEvent.Select
             end             
     endcase

end

; ---------------------------------------------------------------------

; ------------------------------------------ Resize_Visualize_Event ---
;  Handles resize events
; ---------------------------------------------------------------------

pro Plot1D_Resize_Visualize_Event, sEvent
  ; Get sState structure from base widget
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  wsx =  sEvent.x - 12   
  wsy =  sEvent.y - 12 
        
  ; Resize the draw widget.
        
  sState.oWindow->SetProperty, Dimensions=[wsx, wsy]
  sState.window_size = [wsx, wsy]
  
  ; Resize the fonts
  maxRES = Max(sState.window_size)
  SizeFontAxis = float(sState.FontSize*0.022*maxRES)
  sState.oFontAxis -> SetProperty, SIZE = SizeFontAxis
  SizeFontTitle = float(sState.FontSize*0.025*maxRES)
  SizeFontSubTitle = float(sState.FontSize*0.022*maxRES)
  sState.oFontTitle -> SetProperty, SIZE = SizeFontTitle
  sState.oFontSubTitle -> SetProperty, SIZE = SizeFontSubTitle

  ; Resize the Legend
  if (sState.iAddLegend) then Plot1D_UpdateAxis, sState
        
  ; Redisplay the plot.
  Plot1D_Redraw, sState
        
  ;Put the info structure back.
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------


; -------------------------------------------- Base_Visualize_Event ---
;  Handles base events
; ---------------------------------------------------------------------

pro Plot1D_Base_Visualize_Event, sEvent
  eventName = TAG_NAMES(sEvent, /STRUCTURE_NAME) 

  case eventName of
   'WIDGET_BASE'  : Plot1D_Resize_Visualize_Event, sEvent  ; Note: Only resize events are caught here
  
   'WIDGET_BUTTON':
   
; the widget calls this function directly
;   'WIDGET_DRAW':  Plot1D_Draw_Visualize_Event, sEvent
   
  else: begin
           print, 'Event Name: ',eventName
        end
  endcase
end

; ---------------------------------------------------------------------

pro Plot1D_cleanup, sState

     ; Destroy container objects
     Obj_Destroy, sState.oContainer

     ; Destroy Models and Views         
     Obj_Destroy, sState.oView
     OBJ_DESTROY, sState.oModelTitles
     Obj_Destroy, sState.oModelAxis
     Obj_Destroy, sState.oModel

     ; Cleanup Tools Objects 
     Obj_Destroy, sState.oViewTools
     Obj_Destroy, sState.oModelTools

     ; Free Data
     ptr_free, sState.oPlots
     ptr_free, sState.poSymbol
     
     ptr_free, sState.pname
     ptr_free, sState.pColor
     ptr_free, sState.pHistogram
     ptr_free, sState.pLinestyle
     ptr_free, sState.pThick
     ptr_free, sState.pNsum
     
     if (sState.iFreeData eq 1) then ptr_free, *sState.ppData
     ptr_free, sState.ppData
end


; ----------------------------------------------- Visualize_Cleanup ---
;  Handles cleanup events. Called when window is closed
; ---------------------------------------------------------------------

PRO Plot1D_Visualize_Cleanup, tlb


   ; Come here when program dies. Free all created objects.

   Widget_Control, tlb, Get_UValue=sState, /No_Copy
   if N_Elements(sState) ne 0 then begin     

     plot1D_cleanup, sState

     ; Cleanup Menu Objects

     ptr_free, sState.pMenuItems
     ptr_free, sState.pMenuButtons
     
;     print, 'Cleaning up Done!'

    s = size(sState.notifyID)
    if (s[0] eq 1) then count = 0 else count = s[2]-1
    for j=0,count do begin
        Plot1DEvent = { PLOT1D_CLOSE, $            
                  ID:sState.notifyID[0,j], $   
                  TOP:sState.notifyID[1,j], $
                  HANDLER:0L, $
                  plotID:sState.plotID}
      if Widget_Info(sState.notifyID[0,j], /Valid_ID) THEN $
        Widget_Control, sState.notifyID[0,j], Send_Event=Plot1DEvent
    end
      
   end
END

pro plot1d, $ ; Data to be plotted
              _pData, _pData2, $
              NO_SHARE = no_share, NO_COPY = no_copy, INFO_STRUCT = sInfo, $
              LABEL = datalabels, $
              ; Data Ranges
              YRANGE = yrange, XRANGE = xrange, $
              ; Data Ranges for secondary axis
              Y2RANGE = y2range, $
              ; Titles and labels
              TITLE = Title1, SUBTITLE = Title2, $
              ; Axis Data and information
              XLOG = xlog, YLOG = ylog, Y2LOG = y2log, $
              XTITLE = XAxisTitle, YTITLE = YAxisTitle, Y2TITLE = YAxis2Title,$
              XTICKFORMAT = XTickFormat, YTICKFORMAT = YTickFormat, Y2TICKFORMAT = Y2TickFormat, $
              ; Plot options
              COLOR = color, HISTOGRAM = use_histogram, LINESTYLE = linestyle, SYMBOL = symbol, $
              THICK = thick, NSUM = nsum, NAME = name, LEGEND = legend, $
              ; Window Options
              WINDOWTITLE = WindowTitle, RES = ImageResolution, INVCOLORS = iInvColors, $
              ; Output Options
              IMAGE = imageout, FILEOUT = imagefile, DG = direct_graphics, $
              ; Widget Options
              NOTIFYID = notifyID, PLOTID = plotID, GROUP_LEADER= group_leader, $
              XOFFSET = xoffset, YOFFSET = yoffset
    
  if N_Elements(_pData) eq 0 then begin
    res = Error_Message('No data supplied.')
    return
  end            
      
  T_POINTER = 10l
  datatype = size(_pData, /type)
  pData = ptr_new()

  ; Check input data types
  
  if (datatype ne T_POINTER) then begin       
    if (datatype lt 1) or (datatype gt 5) then begin
       res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                           'Precision Floating Point')
       return
    end

    n_dims = size(reform(_pData), /n_dimensions)
    nx = size(reform(_pData), /dimensions)
    n_series = 1
    case (n_dims) of
       1: begin
            if (N_Elements(_pData2) eq 0) then begin ; no x data supplied
              pData = PtrArr(2,1)
              pData[1,0] = ptr_new(reform(_pData), NO_COPY = no_copy)
              pData[0,0] = ptr_new(lindgen(nx[0]), /NO_COPY)
            end else begin ; x data supplied
              n_dims2 = size(reform(_pData2), /n_dimensions)
              nx2 = size(reform(_pData2), /dimensions)
              if (n_dims2 ne 1) or (nx2[0] ne nx[0]) then begin
                res = Error_Message('X Data is not compatible with Y data')
                return
              end
              pData = PtrArr(2,1)
              pData[0,0] = ptr_new(reform(_pData), NO_COPY = no_copy)
              pData[1,0] = ptr_new(reform(_pData2), /NO_COPY)
            end
          end
       2: begin
            if (nx[0] ne 2) then begin
              res = Error_Message('Data must be a vector or a [2, num_points] array')
              return
            end
            if (N_Elements(_pData2) ne 0) then begin 
              res = Error_Message('If Data is a [2, num_points array] you can only specify one parameter')
              return
            end

            pData = PtrArr(2,1)
            pData[0,0] = ptr_new(_pData[0,*], NO_COPY = no_copy)
            pData[1,0] = ptr_new(_pData[1,*], NO_COPY = no_copy)
            *pData[0,0] = reform(temporary(*pData[0,0]))
            *pData[1,0] = reform(temporary(*pData[1,0]))
          end   
    else: begin
            res = Error_Message('Data must be a vector or a [2, num_points] array')
            return
          end
    endcase 
    freedata = 1b      
  end else begin       ; Pointer
    if (N_Elements(_pData2) ne 0) then begin 
      res = Error_Message('If Data is of type pointer you can only specify one parameter')
      return
    end
  
    s1 = size(_pData, /n_dimensions)
    s2 = size(_pData, /dimensions)
  
    if ((s1 lt 1) or (s1 gt 2)) or $
       ((s2[0] ne 2)) then begin
      res = Error_Message('Data must be a pointer array in the form PtrArr(2) or PtrArr(2,n_series)')
      return
    end
  
    if (s1 eq 1) then begin ; 1 series
      npoints = LonArr(2)
  
      for j=0,1 do begin
        if not ptr_valid(_pData[j]) then begin
          res = Error_Message('Invalid Pointer, pData')
          return
        end
        datatype = size(*_pData[j], /type)
        if (datatype lt 1) or (datatype gt 5) then begin
          res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                              'Precision Floating Point')
          return
        end
        s = size(*_pData[j], /n_dimensions)
        if (s ne 1) then begin
          res = Error_Message('Data must be a vector')
          return
        end
        npoints[j] = N_Elements(*_pData[j])
      end
    
      if (npoints[0] ne npoints[1]) then begin
          res = Error_Message("Number of points in X and Y coordinates don't match.")
          return
      end
    
      n_series = 1
      pData = PtrArr(2,1)
  
      if (Keyword_Set(no_share)) then begin
        for j=0,1 do pData[j,0] = ptr_new((*_pData[j]))
        ptr_free, _pData
        freedata = 1b
      end else begin
        for j=0,1 do pData[j,0] = _pData[j]
        freedata = 0b
      end  
  
    end else begin ; Multiple Series
      n_series = s2[1]
  
      for i=0, n_series-1 do begin
        npoints = LonArr(2)
      
        for j=0,1 do begin  

          if not ptr_valid(_pData[j,i]) then begin
            res = Error_Message('Invalid Pointer, pData')
            return
          end
          datatype = size(*_pData[j,i], /type)
          if (datatype lt 1) or (datatype gt 5) then begin
            res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                                'Precision Floating Point')
            return
          end
          s = size(*_pData[j,i], /n_dimensions)
          if (s ne 1) then begin
            res = Error_Message('Data must be a vector')
            return
          end
          npoints[j] = N_Elements(*_pData[j,i])

        end
        
        if (npoints[0] ne npoints[1]) then begin
          res = Error_Message("Number of points in X and Y coordinates don't match.")
          return
        end

      end
  
      pData = PtrArr(2,n_series)
      if (Keyword_Set(no_share)) then begin
        for i=0,n_series-1 do for j=0,1 do $
            pData[j,i] = ptr_new((*_pData[j,i]), /no_copy)
        ptr_free, _pData
        freedata = 1b
      end else begin
        for i=0,n_series-1 do for j=0,1 do $
            pData[j,i] = _pData[j,i]
        freedata = 0b
      end  
    end
  end

  ; ######################################################################################################
 
  ; (XYY2)LOG
  ;
  ; Uses a log scale for the X,Y,Y2 axis
  ;
  ; Set this keyword to use a log scale for the X,Y,Y2 Axis. The default is to use a linear scale.

  xLog = Keyword_Set(xlog)
  yLog = Keyword_Set(ylog)
  y2Log = Keyword_Set(y2log)
 
  ; (XYY2)RANGE 
  ;
  ; Axis Ranges
 
  if (N_Elements(xrange) eq 0) then begin
    xmin = MinN0(*pData[0,0], max = xmax, MINN0 = xmin_n0)
    for i = 0, n_series-1 do $
      xmin = MinN0([*pData[0,i],xmin,xmax], max = xmax, MINN0 = xmin_n0)
    if (xlog) then begin
      if (xmax lt 1e-37) then xmax = 1.0
      if (xmin_n0 lt 1e-37) then xmin_n0 = xmax/10.0
      xrange = [xmin_n0*0.9,xmax*1.1]
    end else begin
      lx_off = (xmax-xmin)*0.05
      xrange = [xmin-lx_off,xmax+lx_off]
    end           
  end else begin
    if (N_Elements(xrange) ne 2) then begin
      res = Error_Message('XRANGE must be a two element vector')
      return
    end
    
    if (xrange[0] ge xrange[1]) then begin
      res = Error_Message('XRANGE is invalid')
      return
    end
  end
  
  if (N_Elements(yrange) eq 0) then begin
    ymin = MinN0(*pData[1,0], max = ymax, MINN0 = ymin_n0)
    for i = 0, n_series-1 do $
      ymin = MinN0([*pData[1,i],ymin,ymax], max = ymax, MINN0 = ymin_n0)
    if (ylog) then begin
      if (ymax lt 1e-37) then ymax = 1.0
      if (ymin_n0 lt 1e-37) then ymin_n0 = ymax/10.0
      yrange = [ymin_n0*0.9,ymax*1.1]
    end else begin
      ly_off = (ymax-ymin)*0.05
      yrange = [ymin-ly_off,ymax+ly_off]
    end           
  end else begin
    if (N_Elements(yrange) ne 2) then begin
      res = Error_Message('YRANGE must be a two element vector')
      return
    end
    
    if (yrange[0] ge yrange[1]) then begin
      res = Error_Message('YRANGE is invalid')
      return
    end
  end
  
  ; Plot Options
  
  ; FONTSIZE
  ;
  ; Font size for titles and axis labels as a fraction of the reference size. Default is 1.0
  if N_Elements(fontsize) eq 0 then fontsize = 1.0

  
  
  ; Plot Titles

  ; [XYY2]TITLE
  ;
  ; X,Y and Y2 axis titles
  ;
  ; Set these parameters to the string you want to use as axis title

  if N_Elements(XAxisTitle) eq 0 then XAxisTitle = ''
  if N_Elements(YAxisTitle) eq 0 then YAxisTitle = ''
  if N_Elements(Y2AxisTitle) eq 0 then Y2AxisTitle = ''

  ; [XYY2]TICKFORMAT
  ;
  ; X,Y and Y2 axis tick format
  ;
  ; Set these parameters to the string to be used to format the axis tick mark (IDL Standard)

  if N_Elements(XTickFormat) eq 0 then XTickFormat = ''
  if N_Elements(YTickFormat) eq 0 then YTickFormat = ''
  if N_Elements(Y2TickFormat) eq 0 then Y2TickFormat = ''

  ; TITLE
  ;
  ; Plot Title
  ;
  ; Use this parameter to set the plot Title. The default is no plot title

  if N_Elements(Title1) eq 0 then Title1 = ''

  ; SUBTITLE
  ;
  ; Plot Sub Title
  ;
  ; Use this parameter to set the plot Sub Title. The default is no plot title
 
  if N_Elements(Title2) eq 0 then Title2 = ''

  
  ; WINDOWTITLE
  ;
  ; The title for the plot window
  
  if (N_Elements(WindowTitle) eq 0) then WindowTitle = 'Plot 1D'
  
  ; INVCOLORS
  ;
  ; Invert the colors for the background and the axis and labels. Default is white on black
  
  iInvColors = Keyword_Set(iInvColors)

  ; RES
  ;
  ; The resolution for the image. Default is [600,400]
   
  if (not Keyword_Set(direct_graphics)) then begin
     if (N_Elements(ImageResolution) eq 0) then ImageResolution = [600,400] $
     else begin
       s = size(ImageResolution)
       if (s[0] ne 1) or (s[1] ne 2) then begin
         temp = Error_Message('RES must be a 1D 2 element array with the dimension of the image to display')
         if (freedata) then ptr_free, pData
         return
       end
     end
     xdim = ImageResolution[0]
     ydim = ImageResolution[1]
  end else begin
     ; Find Direct Graphics Output sizes 
     if (Total(!P.Multi) eq 0) then  begin
        xdim = !D.X_VSIZE
        ydim = !D.Y_VSIZE
     end else begin
        temp = !P.Multi
        Plot, Findgen(11), XStyle=4, YStyle=4, /NoData
        !P.Multi = temp
        xdim = !D.X_VSIZE*(!X.Region[1] - !X.Region[0]) 
        ydim = !D.Y_VSIZE*(!Y.Region[1] - !Y.Region[0])
     end
  end
    
  maxRES = Max([xdim, ydim])

  ; COLOR
  ; 
  
  if N_Elements(color) eq 0 then begin
    def_colors = [ [255b,255b,255b], $	; white
                   [255b,  0b,  0b], $	; red
                   [ 63b, 63b,255b], $	; blue
                   [  0b,255b,  0b], $	; green
                   [  0b,255b,255b], $	; cyan
                   [255b,255b,  0b], $	; yellow
                   [191b,  0b,191b] ]		; purple
     
    color = BytArr(3, n_series)
    color_idx = 0
    for i=0, n_series-1 do begin
      color[*,i] = def_colors[*,color_idx]
      color_idx = (color_idx lt 6)?color_idx+1:0
    end  
  end else begin
    s = size(color, /n_dimensions)
    case (s) of
       2: begin
            s = size(color, /dimensions)
            if (s[0] ne 3) or (s[1] ne n_series) then begin
               res = Error_Message('COLOR must be either one color in the form [R,G,B] or a vector of '+$
                                   'colors with the same number of elements as there are series')
               return    
            end
          end
       1: begin
            s = size(color, /dimensions)
            if (s[0] ne 3) then begin
               res = Error_Message('COLOR must be either one color in the form [R,G,B] or a vector of '+$
                                   'colors with the same number of elements as there are series')
               return    
            end
            temp_color = color
            color = BytArr(3, n_series)
            for i=0, n_series-1 do color[*,i] = temp_color
          end
    else: begin
            res = Error_Message('COLOR must be either one color in the form [R,G,B] or a vector of '+$
                                'colors with the same number of elements as there are series')
            return    
          end
    endcase
  end 

  ; HISTOGRAM
  
  if N_Elements(use_histogram) eq 0 then begin
    use_histogram = BytArr(n_series)
  end else begin
    case N_Elements(use_histogram) of
      n_series: 
             1: use_histogram = BytArr(n_series) + use_histogram
          else: begin
                  res = Error_Message('HISTOGRAM must be either a scalar or a vector with as many elements as there '+$
                                      'are series.')
                  return
                end
    endcase
  end

  ; LINESTYLE
  
  if N_Elements(linestyle) eq 0 then begin
    linestyle = BytArr(n_series)
  end else begin
    case N_Elements(linestyle) of
      n_series: 
             1: linestyle = BytArr(n_series) + linestyle
          else: begin
                  res = Error_Message('LINESTYLE must be either a scalar or a vector with as many elements as there '+$
                                      'are series.')
                  return
                end
    endcase
  end

  ; SYMBOL
  
  if N_Elements(symbol) eq 0 then begin
    symbol = BytArr(n_series)
  end else begin
    case N_Elements(symbol) of
      n_series: 
             1: symbol = BytArr(n_series) + symbol
          else: begin
                  res = Error_Message('SYMBOL must be either a scalar or a vector with as many elements as there '+$
                                      'are series.')
                  return
                end
    endcase
  end


  ; THICK
  
  if N_Elements(thick) eq 0 then begin
    thick = BytArr(n_series)
  end else begin
    case N_Elements(thick) of
      n_series: 
             1: thick = BytArr(n_series) + thick
          else: begin
                  res = Error_Message('THICK must be either a scalar or a vector with as many elements as there '+$
                                      'are series.')
                  return
                end
    endcase
  end

  ; NSUM

  if N_Elements(nsum) eq 0 then begin
    nsum = BytArr(n_series)
  end else begin
    case N_Elements(nsum) of
      n_series: 
             1: nsum = BytArr(n_series) + nsum
          else: begin
                  res = Error_Message('THICK must be either a scalar or a vector with as many elements as there '+$
                                      'are series.')
                  return
                end
    endcase
  end

  ; NAME

  if N_Elements(name) eq 0 then begin
    name = StrArr(n_series)
    for i=0, n_series-1 do name[i] = 'Series '+strtrim(i+1,1)
  end else if N_Elements(name) ne n_series then begin
    res = Error_Message('NAME must be a vector with as many elements as there are series.')
    return
  end

  ; NOTIFYID
  ;
  ; Id of the widget to notify when certain events occur  

  IF N_Elements(notifyID) EQ 0 THEN notifyID = [-1L, -1L]

  ; PLOTID
  ;
  ; Plot Id to return when the widget closes  

  ;help, plotID
  IF N_Elements(plotID) EQ 0 THEN plotID = 'Plot 1D'


  ; LEGEND

  if (N_Elements(legend) ne 0) then iAddLegend = Keyword_Set(legend) $
  else iAddLegend = (n_series gt 1)?1:0

;##########################################################################################################

   ;----------------------------- Container ----------------------------------------
 
   oContainer = OBJ_NEW('IDLgrContainer')
   
   ;------------------------------ Fonts -------------------------------------------

   SizeFontTitle = float(FontSize*0.025*maxRES)
   SizeFontSubTitle = float(FontSize*0.022*maxRES)
   SizeFontAxis = float(FontSize*0.022*maxRES)

   oFontTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontTitle)
   oContainer -> Add, oFontTitle

   oFontSubTitle = OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontSubTitle)
   oContainer -> Add, oFontSubTitle

   oFontAxis =  OBJ_NEW('IDLgrFont','Helvetica', SIZE = SizeFontAxis)
   oContainer -> Add, oFontAxis

   ;--------------------------- Axis and Axis Labels ----------------------------------------

   xAxis = OBJ_NEW('IDLgrAxis',0, TICKFORMAT = XTickFormat)
   xAxisOp = OBJ_NEW('IDLgrAxis',0, /notext)

   xLabel = OBJ_NEW('IDLgrText', XAxisTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   xLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   xAxis -> SetProperty, TITLE = xLabel
   oContainer -> Add, xLabel
   xAxis -> GetProperty, TICKTEXT = xAxistickLabels
   xAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   xAxisTickLabels -> SetProperty, FONT = oFontAxis

   yAxis = OBJ_NEW('IDLgrAxis',1, TICKFORMAT = YTickFormat)
   yAxisOp = OBJ_NEW('IDLgrAxis',1, /notext)

   yLabel = OBJ_NEW('IDLgrText', YAxisTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   yLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   yAxis -> SetProperty, TITLE = yLabel
   oContainer -> Add, yLabel
   yAxis -> GetProperty, TICKTEXT = yAxistickLabels
   yAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   yAxisTickLabels -> SetProperty, FONT = oFontAxis

   y2Axis = OBJ_NEW('IDLgrAxis',1, TICKFORMAT = YTickFormat)

   y2Label = OBJ_NEW('IDLgrText', YAxisTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   y2Label-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   y2Axis -> SetProperty, TITLE = y2Label
   oContainer -> Add, y2Label
   y2Axis -> GetProperty, TICKTEXT = y2AxistickLabels
   y2AxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   y2AxisTickLabels -> SetProperty, FONT = oFontAxis

   ;--------------------------- Plot Labels ----------------------------------------

   oModelTitles = Obj_New('IDLgrModel')

   if (iInvColors) then TitleColor = [0b,0b,0b]  $
   else TitleColor = [255b,255b,255b]

   oTitle = Obj_New('IDLgrText', Title1, Color = TitleColor, /ENABLE_FORMATTING)
   oTitle-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   oTitle-> SetProperty, FONT = oFontTitle
  
   oSubTitle = Obj_New('IDLgrText', Title2, Color = TitleColor, /ENABLE_FORMATTING)
   oSubTitle-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   oSubTitle-> SetProperty, FONT = oFontSubTitle
 
   oModelTitles -> Add, oTitle
   oModelTitles -> Add, oSubTitle
          
   ; Create the view

   if (iInvColors) then ViewColor = [255b,255b,255b]  $
   else ViewColor = [0b,0b,0b]

   oView = OBJ_NEW('IDLgrView', COLOR = ViewColor)

   ; Create the Plot Model
   oModel = OBJ_NEW('IDLgrModel')   

   ; Create the Axis Model
   oModelAxis =  OBJ_NEW('IDLgrModel')
   
   ; Add all models to the view
   oView -> Add, oModel
   oView -> Add, oModelAxis
   oView -> Add, oModelTitles

   ; Create the tools objects
   
   oModelTools = OBJ_NEW('IDLgrModel')
   oZoomBox = OBJ_NEW('IDLgrPolyline', HIDE = 1, THICK = 2, LINESTYLE = 2)
   oScalingLine = OBJ_NEW('IDLgrPolyline', HIDE = 1, THICK = 2, LINESTYLE = 2)
   
   oModelTools -> Add, oZoomBox
   oModelTools -> Add, oScalingLine

   oViewTools = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0], $
                        /Transparent )
   oViewTools -> Add, oModelTools

   ; Create Symbols for the plot

   oSymbol = ObjArr(n_series)
   for i=0, n_series-1 do oSymbol[i] = Obj_new('IDLgrSymbol', symbol[i], COLOR = color[*,i])
   oContainer -> Add, oSymbol
  
   ;------------------------ Create the Widget ---------------------------------

   ; Create Widget
   
   wBase = Widget_Base(TITLE = WindowTitle, /TLB_Size_Events,$
                        APP_MBAR = menuBase, $
                        XPAD = 0, YPAD = 0, /Column, GROUP_LEADER = group_leader, $
                        XOFFSET = xoffset, YOFFSET = yoffset)
   
   ; Create the Draw Widget
          
   wDraw = Widget_Draw(wBase, XSIZE = xdim, YSIZE = ydim, $
                       Graphics_Level = 2, /Button_Events, $
                       /Expose_Events, Retain = 0, $
                        FRAME = 1, EVENT_PRO = 'Plot1D_Draw_Visualize_Event')

   ; Create the menu
  
   MenuItemsFile = [ $
             '1File', $
                '0Save Plot Tiff...', $
                '8Page Setup...',$
                '0Print...',$
                'AQuit',$
              '1Edit',$
                '2Copy Plot']
                   
   MenuItemsPlot = [ $
              '1Plot',$
                '0X-Axis',$
                '0Y-Axis',$
                '9Legend',$
                   '4On', '2Off', $
;                '0Y2-Axis',$
                'BInvert Colors', $
                   '4On', '2Off'  $
                 ]
   
   MenuItemsTools = [ $
            '1Tool', $
             '0Local Max',$
             '1Zoom', $
                '0In', $
                '0Out', $
                '2Reset', $
             'BTool', $
                '4Zoom', $
                '0Data Picking', $
                '2Scalings'  $ 
               ]
   
   MenuItemsAbout = [ $
             '1About', $
                '2About Plot 1D' $
              ]


   ; Create Menu
   
   MenuItems = [MenuItemsFile, $
                MenuItemsPlot, $
                MenuItemsTools, $
                MenuItemsAbout]              
 
   Create_Menu, MenuItems, MenuButtons, menuBase, $
                event_pro = 'Plot1D_Menu_Events'

   ; Create the printer object

   oPrinter = OBJ_NEW('IDLgrPrinter')
   if (oPrinter ne Obj_New()) then begin
      oContainer -> ADD, oPrinter
   end else begin
      Disable_Menu_Choice, '|File|Print...', MenuItems, MenuButtons 
      Disable_Menu_Choice, '|File|Page Setup...', MenuItems, MenuButtons 
   end

   ; Update Invert Colors sub-menu to reflect initial iInvColors 
   sOnOff=['On','Off']
   eventval = '|Plot|Invert Colors|'+sOnOff[1-iInvColors]
   temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)

  eventval = '|Plot|Legend|'+sOnOff[1-iAddLegend]
   temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)
  

  ; Realize the widget
  Widget_Control, wBase, /REALIZE
       
  ; Create the window object
  Widget_Control, wDraw, Get_Value = oWindow
;  oWindow -> SetCurrentCursor, 'CROSSHAIR'
  
  sState = { $
              ; Plot Data
              n_series         :n_series, $			; Number of series to plot
              ppData           :ptr_new(pData), $		; Data for the plot values
              iFreeData        :freedata, $			; Free the data when widget closes
              xrange           :xrange, $				; x range of values to display
              yrange           :yrange, $				; y range of values to display
;              y2range          :y2range, $				; y range of values to display on 2nd axis

              ; Plot Objects and Options
              oPlots           :ptr_new(), $			; Array of plot objects (pointer to)
              oLegend          :obj_new(), $
              iAddLegend       :iAddLegend, $
              pname            :ptr_new(name), $		; name for each plot object
              iInvColors       :iInvColors, $			; Inverted Colors
              ixlog            :xlog, $				; Use Log scale for x axis
              iylog            :ylog, $				; Use Log scale for y axis
              iy2log           :y2log, $				; Use Log scale for 2nd yaxis
              pColor           :ptr_new(Color), $		; Series Color
              pHistogram       :ptr_new(use_histogram), $	; Do a histogram style plot
              plinestyle       :ptr_new(linestyle), $		; Linestyle for the plot
              pthick           :ptr_new(thick), $		; line thickness for the plot
              pnsum            :ptr_new(nsum), $		; number of points to average before plotting
              poSymbol         :ptr_new(oSymbol), $		; Symbol objects for each series
                            
              ; Plot Titles
              oTitle           :oTitle, $				; Plot Title
              oSubTitle        :oSubTitle, $			; Plot Sub-Title
              
              ; Plot Axis
              xAxis            :xAxis, $				; Axis object for X 
              yAxis            :yAxis, $				; Axis object for Y 
              y2Axis           :y2Axis, $				; Axis object for 2nd Y Axis
              xAxisOp          :xAxisOp, $				; Oposing Axis object for X 
              yAxisOp          :yAxisOp, $				; Oposing Axis object for Y
                               
              ; Tools related variables
              iTool            :0b, $					; Active Tool
              btndown          :0b,$					; button 1 down
              window_size      :[xdim,ydim], $			; window size
              oViewTools       :oViewTools, $			; View object for tools
              oModelTools      :oModelTools, $
              DataPosition     :FltArr(4), $			; Screen position of data region
              Tool_Pos0        :[0.,0.], $				; position of initial button press
              oZoomBox         :oZoomBox, $			; Zoom Box object
              oScalingLine     :oScalingLine, $			; Scaling Line object
              
              ; Widget variables
              wDraw            :wDraw,$				; Draw widget
              oWindow          :oWindow,$				; Window Object
              oView            :oView,$				; View Object                   
              oContainer       :oContainer, $			; Container for object destruction
              oPrinter         :oPrinter, $			; Printer Object
              pMenuItems       :ptr_new(MenuItems),$		; Menu Items
              pMenuButtons     :ptr_new(MenuButtons),$	; Menu Buttons
              notifyID         :notifyID, $			; notification widget IDs
              plotID           :plotID, $				; plot ID to return when window closes
              
              ; Models
              oModelAxis       :oModelAxis,$			; Axis Models 
              oModelTitles     :oModelTitles, $			; Axis Models 
              oModel           :oModel, $				; Plot Model  
              
              ; Font Variables
              FontSize         :FontSize, $			; Font size
              oFontTitle       :oFontTitle, $			; Title Font object
              oFontSubTitle    :oFontSubTitle, $		; Sub-Title Font object
              oFontAxis        :oFontAxis $			; Axis Font object
            }
 
   Plot1D_GenerateView, sState
              
   ; Save state to widget
   Widget_Control, wBase, SET_UVALUE=sState, /No_Copy
   
   XManager, 'Plot1D_Visualize', Event_Handler='Plot1D_Base_Visualize_event', $
                              Cleanup ='Plot1D_Visualize_Cleanup', $
                              wBase, /NO_BLOCK

end