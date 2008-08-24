;+
; NAME:
;    PLOT2D
;
; PURPOSE:
;
;    The purpose of this function is to plot 2D data (scalar or vector) using object graphics, creating a new
;    widget for the vizualisation of the data. All plot options can be set with the command line. Most options
;    can also be changed interactively using the widget created
;
; AUTHOR:
;
;   Ricardo Fonseca
;   E-mail: zamb@physics.ucla.edu
;
; CATEGORY:
;
;    Graphics.
;
; CALLING SEQUENCE:
;
;    plot2D, Data2D
;
; INPUTS:
;
;    Data2D: For scalar data this is either an two dimensional Byte, Integer, Longword Integer, Floating Point
;       or Double Precision Floating Point array or a pointer to such array containing the data we want to plot.
;       For vector data this must be a two element pointer vector pointing to the two components of the vector
;       field, which must also be of one of the data types mentioned above.
;       The widget generated needs to keep the data values; if the argument is an array the default behaviour 
;       is to copy the data to an internal buffer, but if the argument is a pointer the default behaviour is to
;       only keep a copy of that pointer, sharing the data with other routines. If no argument is present the
;       routine returns quietly.
;       See also VECTOR, NO_COPY and NO_SHARE
;
; KEYWORDS:
;
;    ADDCONTOUR: Set this keyword to add a contour level plot. See also CONTOURLEVELS and N_LEVELS.
;
;    (XY)AXIS: Set this keyword to an array containing the values for the axis. If the dimensions
;       of this array doesn't match the dimensions of Data2D the routine issues an error message.
;
;    BOTTOM: Set this keyword to a three element byte array [R,G,B] containing the color for the bottom side
;       of the surface. If not specified the routine will use either the color specified by COLOR or the vertex
;       colors if VERT_COLORS is set. If both BOTTOM and VERT_COLORS are specified, the routine will draw the
;       top surface using vertex coloring but will respect the BOTTOM color setting. This keyword has no 
;       immediate effect if TYPE <> 1 and is ignored quietly, but the value is stored and if you switch to a
;       surface plot using the widget interface it will remember the color specified here. See also COLOR,
;       VERT_COLORS and TYPE.
;
;    COLOR: Set this keyword to a three element byte array [R,G,B] containing the color for the top side
;       of the surface. The default is red [255b,0b,0b]. If BOTTOM was not specified then this color will
;       also be used for the bottom side of the surface. If VERT_COLORS is set this keyword has no effect.  
;       This keyword has no immediate effect if TYPE = 0 and is ignored quietly, but the value is stored
;       and if you switch to a surface plot using the widget interface it will remember the color specified
;       here. See also BOTTOM, VERT_COLORS and TYPE.
;
;    CONTOURLEVELS: Set this keyword to a vector containing the isolevels to be used for the contour
;       plot. If this keyword is set the number of levels drawn will be the same as the number of 
;       elements in the vector and N_LEVELS will have no effect. If not specified the routine will
;       chose N_LEVELS levels automatically. If ZLOG is not set these values will be evenly spaced
;       over the data values range. If ZLOG is set a logarithmic set of values is chosen. See also
;       ADDCONTOUR, N_LEVELS, ZMIN, ZMAX, and ZLOG.
;
;    CT: Set this keyword to the color table you wish to use for both color mapped and rubber sheet
;       (surface) plots with VERT_COLORS set. The default is 25, Mac Style. See also VERT_COLORS.
;
;    DG: Set this keyword to display the output of the plot as if it was a Direct Graphics routine. The
;       routine will respect the !P.MULTI system variable allowing you to combine multiple plots generated
;       by this or other direct graphics routines. Note that at the moment only screen output is supported
;       and that OPLOT and similar routines will not work, and that system variables are not set according
;       to the plot created. Setting this keyword results in not displaying the widget. However, both the
;       FILEOUT and IMAGE keywords can be used together with this keyword. See Also FILEOUT and IMAGE
;
;    FILEOUT: Set this keyword to the name of the file for saving the plot as a 24-bit tiff file. 
;       Setting this keyword results in not displaying the widget. However, both the FILEOUT and DG keyword
;       can be used together with this keyword. See Also IMAGE and DG
;
;    FONTSIZE: Set this keyword to the fontsize (relative to the default fontsize) you wish to use.
;
;    HIDDEN_LINES: Set this keyword if you want to do hidden line removal. This keyword has no immediate
;       effect if TYPE = 0 and is ignored quietly, but the value is stored and if you switch to a surface
;       plot using the widget interface it will remember the hidden line setting specified here. See 
;       also TYPE.
;
;    IMAGE: Set this keyword to the variable name for returning the plot as a 24-bit image. If the
;       variable cannot be overwritten this keyword will be ignored. Setting this keyword results
;       in not displaying the widget. However, both the FILEOUT and DG keyword can be used together
;       with this keyword. See Also FILEOUT and DG
;
;    INTERP: Setting this keyword results in interpolating the data provided to the screen resolution 
;       before plotting.  This keyword has no immediate effect if TYPE <> 0 and is ignored quietly, but the
;       value is stored and if you switch to a color map plot using the widget interface it will remember
;       this setting. See also TYPE. 
;
;    INVCOLORS: Set this keyword to use black axis on white background. The default is white axis on
;       black background.
;
;    N_LEVELS: Set this keyword to the number of levels to use for the contour plot. The default is 7.
;       If CONTOURLEVELS is set this keyword has no effect. See also ADDCONTOUR and CONTOURLEVELS.
;
;    NO_COPY: If Data2D is an array and this keyword is set, rather than copying the data from the
;       input parameter into the internal buffer the routine will take the data away from the input
;       parameter and attach it directly to the internal buffer, resulting in the Data2D argument 
;       becoming undefined. This keyword has no effect if Data2D is a pointer and is ignored quietly.
;       See also NO_SHARE (and NO_COPY keyword under PTR_NEW and WIDGET_CONTROL) 
;
;    NO_SHARE: If Data2D is a pointer, rather than copying the pointer from the input parameter into
;       an internal pointer and keeping the data attached to Data2D the routine will also detach the
;       data from the input pointer and then free it. This is effectively the same as doing:
;         plot2D, (*pData), /NO_COPY & ptr_free, pData
;       and is provided only for convinience. This keyword has no effect if Data2D is an array and
;       is ignored quietly. See also NO_COPY
;
;    (XY)RANGE: Set this keyword to the axis range to use. At the moment this feature is limited 
;       to color mapped plots.
;
;    RES: Set this keyword to a two element vector containing the plot resolution in pixels. The defaults
;       are [600,400] for TYPE = 0 and [600,600] for TYPE = 1. See also TYPE.
;
;    SHADING: Set this keyword to the lighting styly to use. Available options are:
;               0 - Flat
;               1 - Gouraud (default)
;       This keyword has no immediate effect if TYPE = 0 and is ignored quietly, but the value is stored
;       and if you switch to a surface plot using the widget interface it will remember the lighting style
;       specified here. See also TYPE.
;
;    STYLE: Set this keyword to the surface style to use. Available options are:
;               0 - Points
;               1 - Wire Mesh
;               2 - Filled (default)
;               3 - Ruled XZ
;               4 - Ruled YZ
;               5 - Lego
;               6 - Lego Filled
;       This keyword has no immediate effect if TYPE = 0 and is ignored quietly, but the value is stored
;       and if you switch to a surface plot using the widget interface it will remember the surface style
;       specified here. See also TYPE.
;
;    SUBTITLE: Set this keyword to a string containing the plot sub-title you wish to use. The default
;       is no title.
;
;    (XYZ)TICKFORMAT: Set this keyword to a standard IDL format string to be used to format the axis tick
;       mark label (see chapter 11 of 'Building IDL Applications' for details on format codes. The default is
;       '', the null string, indicating that IDL will determine the appropriate format for each value.
;
;    TITLE: Set this keyword to a string containing the plot title you wish to use. The default is
;       no title.
;
;    (XYZ)TITLE: Set this keyword to a string containing the axis title you wish to use. The default is
;       no title.
;
;    TRAJCOLOR: Set this keyword to the color you want to use for the plotting of the trajectory in the form
;       [R,G,B]. The default is black [0b,0b,0b]. If TRAJVERT has not been set this keyword has no effect and is
;       ignored quietly. See also TRAJVERT, TRAJPOINTS, TRAJSTYLE and TRAJTHICK
;
;    TRAJPOINTS: Set this keyword to an array of polyline descriptions for the trajectory specified by
;       TRAJVERT. A polyline description is an integer or longword array in the form [n, i0, i1, ..., in-1], 
;       where n is the number of vertices that define the polyline and i0 ... in-1 are indices into the 
;       vertices array specified in TRAJVERT. If not specified the routine will connect all the points 
;       specified in TRAJVERT sequentially. If TRAJVERT has not been set this keyword has no effect and is
;       ignored quietly. See also TRAJVERT, TRAJCOLOR, TRAJSTYLE and TRAJTHICK
;
;    TRAJSTYLE: Set this keyword to the line style  you want to use for the plotting of the trajectory. Available
;       options are:
;               0 - Solid (default)
;               1 - Dotted
;               2 - Dashed
;               3 - Dash Dot
;               4 - Dash Dot Dot Dot
;               5 - Long Dash
;               6 - No Line Drawn
;       If TRAJVERT has not been set this keyword has no effect and is ignored quietly. See also TRAJVERT, TRAJPOINTS,
;       TRAJCOLOR and TRAJTHICK
;
;    TRAJTHICK: Set this keyword to the thickness of the line you want to use for the plotting of the trajectory
;       from 1 to 10. The default is 1. If TRAJVERT has not been set this keyword has no effect and is ignored quietly.
;       See also TRAJVERT, TRAJPOINTS, TRAJSTYLE and TRAJCOLOR
;
;    TRAJVERT: Set this keyword to a [2,N] array containing the list of points making up the trajectory
;       to be overplotted. If TRAJPOINTS is not specified the routine will connect all the points sequentially.
;       If not specified no trajectory is plotted. See also TRAJPOINTS, TRAJCOLOR, TRAJSTYLE and TRAJTHICK
;
;    TYPE: Set this keyword to the plot type to use. Available options are:
;              0 - Color Mapped (default)
;              1 - Rubber Sheet (Surface)
;
;    VECTOR: Setting this keyword results in the routine expecting vector data in the form of a two element pointer
;       vector in Data2D, and then plotting the vector field on top of the field intensity. Note that if you set
;       this switch the routine will only accept this kind of Data2D; the keyword NO_SHARE maintains its 
;       functionality and NO_COPY has no effect. See also NO_SHARE.
; 
;    VERT_COLORS: Set this keyword if you want to color the vertex of the surface plot according to the 
;       data value at their point using the color table specified by CT. If this keywprd is set it will
;       override the COLOR keyword (but not the BOTTOM keyword). This keyword has no immediate effect if
;       TYPE = 0 and is ignored quietly, but the value is stored and if you switch to a surface plot using
;       the widget interface it will remember the setting specified here. See also CT, COLOR, BOTTOM and TYPE.
;
;    WINDOWTITLE: Set this keyword to a string containing the title for the widget window. The default
;       is 'Plot 2D'.
;
;    ZMIN: Set this keyword to the minimum value to be plotted. If not supplied and ZLOG is no set
;       the routine will autoscale to the minimum value of the data. If not supplied and ZLOG is set
;       then the routine will autoscale to the minimum absolute value different from 0. See also ZLOG.
;
;    ZMAX: Set this keyword to the maximum value to be plotted. If not supplied and ZLOG is no set
;       the routine will autoscale to the maximum value of the data. If not supplied and ZLOG is set
;       then the routine will autoscale to the maximum absolute value. See also ZLOG.
;
;    ZLOG: Set this keyword to use a log scale on the Z (data) axis. The routine will automatically
;       take the absolute value of the data supplieded if this keyowrd is set. Setting this keyword
;       affects the autoscale values. See also ZMIN and ZMAX.
;    
; OUTPUTS:
;
;    The routine generates a widget with the plot of the supplied data. The kewyords (XY)RANGE return
;       the actual ranges used. If IMAGE is set then the routine will not create the widget and
;       will return a 24-bit image with the plot on that variable. if FILEOUT is set the routine
;       will not create a widget and will save a tiff file with a 24-bit image of the plot. If DG
;       is set then the routine does not create a widget and will display the plot using direct
;       graphics. 
;
; RESTRICTIONS:
;
;    This routine works only with two dimensional Byte, Integer, Longword Integer, Floating Point
;       or Double Precision Floating Point. If the dataset to plot is very large you should consider
;       either passing it as a pointer or using the NO_COPY keyword
;
; EXAMPLE:
;
;    a = randomu(seed, 8, 10)	; create a 2D array of random numbers
;    b = min_curve_surf(a)		; smooth the dataset before plotting
;    plot2D, b    			; plot it
;
; MODIFICATION HISTORY:
;
;    Written by: Ricardo Fonseca, 9 Sep 2000.
;    Added Trajectory Support, 22 Sep 2000, zamb.
;    Added IMAGE, FILEOUT and DG keywords, 23 Sep 2000 zamb.
;    Fixed the autoscaling so now it works with uniform plots, added check if DataMin > DataMax,
;     fixed the INVCOLOR switch, corrected title positioning, added INTERP keyword, fixed 
;     surface geometry for xres <> yres,  25 Sep 2000 zamb.
;    Added support for vector data, 29 Sep 2000 zamb.
;    Changed the profile routines, 2 Oct 2000 zamb
;          
;-
;###########################################################################

; --------------------------------------------------- Plot2D_Redraw ---
;  Redraw the plot
; ---------------------------------------------------------------------

pro Plot2D_Redraw, sState
   widget_control, /hourglass
   sState.oWindow->Draw, sState.oView

   sState.oWindow->Draw, sState.oViewProfile

   if (sState.iAddContourPlot) then sState.oWindow->Draw, sState.oViewContour
   if (sState.iAddTrajectory) then sState.oWindow->Draw, sState.oViewTrajectory
   if (sState.iAddVector) then sState.oWindow->Draw, sState.oViewVector
end

; ---------------------------------------------------------------------

; ----------------------------------------------- Plot2D_UpdateAxis ---
;  Updates the axis after zoom changes and oversample image if
;  necessary
; ---------------------------------------------------------------------

pro Plot2D_UpdateAxis, sState
  
  x0 = sState.dataXrange[0]
  x1 = sState.dataXrange[1]
  y0 = sState.dataYrange[0]
  y1 = sState.dataYrange[1]
           
  sState.xrange = sState.XAxisData[sState.dataXrange]
  sState.yrange = sState.YAxisData[sState.dataYrange]
  
  ; Update Image (and oversample if necessary)
           
  if (obj_valid(sState.oImage)) then begin
    if (sState.iInterp) then begin
      sState.oWindow -> GetProperty, Units = Units
      sState.oWindow -> SetProperty, Units = 0
      sState.oWindow -> GetProperty, Dimensions = dims
      sState.oWindow -> SetProperty, Units = Units

      dims[0] = long(dims[0]*(sState.DataPosition[2] - sState.DataPosition[0]))
      dims[1] = long(dims[1]*(sState.DataPosition[3] - sState.DataPosition[1]))
            
      sState.oImage -> SetProperty, Data = Congrid((*(sState.pByteData))[x0:x1,y0:y1], $
                                                   dims[0], dims[1], /interp)
    end else begin
      sState.oImage -> SetProperty, DATA = (*(sState.pByteData))[x0:x1,y0:y1]
    end
  end
           
  ; Update Axis
  dimension = [ sState.DataPosition[2] - sState.DataPosition[0], $
                sState.DataPosition[3] - sState.DataPosition[1] ]
  location = [ sState.DataPosition[0], sState.DataPosition[1] ] 

  DeltaX = sState.XAxisData[1] - sState.XAxisData[0]
  DeltaY = sState.YAxisData[1] - sState.YAxisData[0]
   
  XMin = sState.xrange[0] - DeltaX/2.0
  XMax = sState.xrange[1] + DeltaX/2.0
  YMin = sState.yrange[0] - DeltaY/2.0
  YMax = sState.yrange[1] + DeltaY/2.0
 
  ycconv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
  xcconv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
        
  sState.xAxis -> SetProperty, RANGE = [XMin, XMax], /exact
  sState.xAxis -> SetProperty, LOCATION = [XMin,YMin]
  xtl = 0.04 *(YMax-Ymin)
  sState.xAxis -> SetProperty, TICKLEN = xtl
  sState.xAxis -> SetProperty, YCOORD_CONV = ycconv
  sState.xAxis -> SetProperty, XCOORD_CONV = xcconv

  sState.xAxisOp -> SetProperty, RANGE = [XMin, XMax], /exact
  sState.xAxisOp -> SetProperty, LOCATION = [XMin,YMax]
  sState.xAxisOp -> SetProperty, TICKLEN = xtl
  sState.xAxisOp -> SetProperty, YCOORD_CONV = ycconv
  sState.xAxisOp -> SetProperty, XCOORD_CONV = xcconv


  sState.yAxis -> SetProperty, RANGE = [YMin, YMax], /exact
  sState.yAxis -> SetProperty, LOCATION = [XMin,YMin]
  ytl = 0.04 *(XMax-Xmin)
  sState.yAxis -> SetProperty, TICKLEN = ytl
  sState.yAxis -> SetProperty, YCOORD_CONV = ycconv
  sState.yAxis -> SetProperty, XCOORD_CONV = xcconv

  sState.yAxisOp -> SetProperty, RANGE = [YMin, YMax], /exact
  sState.yAxisOp -> SetProperty, LOCATION = [XMax,YMin]
  sState.yAxisOp -> SetProperty, TICKLEN = ytl
  sState.yAxisOp -> SetProperty, YCOORD_CONV = ycconv
  sState.yAxisOp -> SetProperty, XCOORD_CONV = xcconv

 ; nx = (size(sState.XaxisData, /dim))[0]
 ; ny = (size(sState.YaxisData, /dim))[0]  

;  lx = sState.XaxisData[nx-1] - sState.XaxisData[0]
;  ly = sState.YaxisData[ny-1] - sState.YaxisData[0]
  
;  v0x = (sState.XAxisData[x0] - sState.XAxisData[0])/lx
;  v1x = (sState.XAxisData[x1] - sState.XAxisData[0])/lx
;  v0y = (sState.YAxisData[y0] - sState.YAxisData[0])/ly
;  v1y = (sState.YAxisData[y1] - sState.YAxisData[0])/ly

  ; Update Contour View

  if (sState.iAddContourPlot) and (obj_valid(sState.oContour)) then $  
    Plot2D_UpdateGeometryContourPlot, sState
  
  ; Update Trajectory View
  if (sState.iAddTrajectory eq 1) and (obj_valid(sState.oTrajectory)) then $  
    Plot2D_UpdateGeometryTrajectory, sState

  ; Update Vector View
  if (sState.iAddVector eq 1) and (obj_valid(sState.oVector)) then begin  
    if (sState.iRegenVector) and (sState.iShowVector) then Plot2D_RegenVector, sState
    Plot2D_UpdateGeometryVector, sState
  end
end

; ---------------------------------------------------------------------

pro RemoveProfile_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  obj = sState.oModelProfile -> GetByName(sEvent.plotID)
  if (obj ne obj_new()) then begin
    sState.oModelProfile -> Remove, obj
    obj_destroy, obj 
    Plot2D_Redraw, sState
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ------------------------------------------------- Plot2D_DataPick ---
;  Picks Data values
; ---------------------------------------------------------------------

pro Plot2D_DataPick, x1, y1, sState
  
  print, ' '
  print, 'Data Value'
  print, '----------------------------------'
  print, 'Position    : (',strtrim(sState.XAxisData[x1],1),',', $
                           strtrim(sState.YAxisData[y1],1),')'
  
  if (sState.iAddVector) then begin
    print, 'Value       : (',strtrim((*sState.pVData[0])[x1,y1],1),',', $
                             strtrim((*sState.pVData[1])[x1,y1],1),')'
    print, '||Value||   : ',strtrim((*sState.pData)[x1,y1],1)
  end else $
    print, 'Value       : ',strtrim((*sState.pData)[x1,y1],1)

end
; ---------------------------------------------------------------------

; -------------------------------------------------- Plot2D_Profile ---
;  Generates Profile
; ---------------------------------------------------------------------

pro Plot2D_Profile, x1, y1, sEvent, sState

  oProfile = obj_new('IDLgrPolyline', THICK = 2, LINESTYLE = 2)

  def_colors = [   [255b,  0b,  0b], $	; red
                   [ 63b, 63b,255b], $	; blue
                   [  0b,255b,  0b], $	; green
                   [  0b,255b,255b], $	; cyan
                   [255b,255b,  0b], $	; yellow
                   [191b,  0b,191b] ]		; purple

  color = reform(def_colors[*, sState.ProfileNum mod 6])

  oProfile -> SetProperty, COLOR = color

  sState.ProfileNum = sState.ProfileNum + 1L
  plotID = 'Plot2D_Profile_'+strtrim(sState.ProfileNum,1)

  oProfile -> SetProperty, NAME = plotID
  
  sState.xAxis -> GetProperty, RANGE = xrange, XCOORD_CONV = xcconv
  sState.yAxis -> GetProperty, RANGE = yrange, YCOORD_CONV = ycconv
    
  oProfile -> SetProperty, XCOORD_CONV = xcconv, YCOORD_CONV = ycconv
  
  sState.oModelProfile -> Add, oProfile
  
  case (sState.iTool) of
    1: $ ; X Profile
       begin
         axis = sState.XAxisData
         data = reform((*(sState.pData))[*, y1])
         windowtitle = 'Y = '+string(sState.YAxisData[y1])
         xtitle = sState.XTitle
         ytitle = sState.ZTitle
         oProfile -> SetProperty, DATA =[ [xrange[0], sState.yAxisData[y1]], $
                                          [xrange[1], sState.yAxisData[y1]] ]
         
         range = xrange
       end
    2: $ ; Y Profile
       begin
         axis = sState.YAxisData
         data = reform((*(sState.pData))[x1, *])
         windowtitle = 'X = '+string(sState.XAxisData[x1])
         xtitle = sState.YTitle
         ytitle = sState.ZTitle
         oProfile -> SetProperty, DATA =[ [sState.xAxisData[x1],yrange[0]], $
                                          [sState.xAxisData[x1],yrange[1]] ]
         range = yrange
       end
  else:return
  endcase 

  plot2d_redraw, sState

  plot1d, axis, data, WINDOWTITLE = windowtitle, COLOR = color, $
          TITLE = sState.Title1, SUBTITLE = sState.Title2, $
          XTITLE = xtitle, YTITLE = ytitle, YLOG = sState.UseLogScale, $
          XRANGE = range, YRANGE = [sState.Datamin, sState.DataMax] , $
          NOTIFYID = [sEvent.top, sEvent.top], PLOTID = plotID, GROUP_LEADER = sEvent.top, $
          RES = [400,300], XOFFSET = sState.window_size[0]/2, YOFFSET = sState.window_size[1]/2 
end
; ---------------------------------------------------------------------

; -------------------------------- Plot2D_UpdateZAxisColorIndexPlot ---
;  Updates the ZAxis for a color index plot
; ---------------------------------------------------------------------

pro Plot2D_UpdateZAxisColorIndexPlot, sState

   case (sState.zscale_pos) of
     2: begin
         ImagePosition = [0.15,0.26,0.85,0.85]
         BarPosition = [0.15,0.12,0.85,0.16]
        end
     1: begin
         ImagePosition = [0.15,0.15,0.79,0.85]
         BarPosition = [0.82,0.15,0.85,0.85]
        end
   else:begin
         ImagePosition = [0.15,0.15,0.85,0.85]
         BarPosition = [0.82,0.15,0.85,0.85]
        end
   end

   ZMin = sState.DataMin
   ZMax = sState.DataMax

   DeltaX_2 = (sState.XAxisData[1] - sState.XAxisData[0])/2.0
   DeltaY_2 = (sState.YAxisData[1] - sState.YAxisData[0])/2.0

   XMin = sState.xrange[0] - DeltaX_2
   XMax = sState.xrange[1] + DeltaX_2  

   YMin = sState.yrange[0] - DeltaY_2
   YMax = sState.yrange[1] + DeltaY_2  

   dimension = [ ImagePosition[2] - ImagePosition[0], ImagePosition[3] - ImagePosition[1] ]
   location = [ ImagePosition[0], ImagePosition[1] ] 
 
   ; Update Image

   sState.oImage -> SetProperty, YCOORD_CONV = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
   sState.oImage -> SetProperty, XCOORD_CONV = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
   sState.oImage -> SetProperty, Dimensions = [XMax-Xmin, YMax-YMin]
   sState.oImage -> SetProperty, Location = [XMin,YMin] 


   if (sState.UseLogScale gt 0) then begin
      tempdata =  ALog10(abs(*(sState.pData)) > 1e-37)     
      tempmin = (Alog10(ZMin) - 1.0)
      idx = where(tempdata eq -37.0, count) 
      if (count gt 0) then tempdata[temporary(idx)] = tempmin
      
      *(sState.pByteData) = BytScl( temporary(tempdata) ,$
                               Max = Alog10(ZMax), Min = Alog10(ZMin))
                                     
   end else begin
      *(sState.pByteData) = BytScl(*(sState.pData), Max = ZMax, Min = ZMin)
   end
  
   ; Add byte data to image (active region only)
  
   sState.oImage -> SetProperty, DATA = (*(sState.pByteData))[sstate.dataxrange[0]:sstate.dataxrange[1],$
                  sstate.datayrange[0]:sstate.datayrange[1]]

   ; Update Z-Axis

   sState.zcAxis -> SetProperty, Range = [ZMin,ZMax], LOG = sState.UseLogScale
   sState.zcAxisOp -> SetProperty, Range = [ZMin,ZMax], LOG = sState.UseLogScale

   if (sState.zscale_pos gt 0) then begin

     sState.oColorAxis -> SetProperty, HIDE = 0
  
     dimension = [ BarPosition[2] - BarPosition[0], BarPosition[3] - BarPosition[1] ]
     location = [ BarPosition[0], BarPosition[1],0 ] 
     sState.ocBar -> SetProperty, Dimensions = dimension
     sState.ocBar -> SetProperty, Location = location

     case (sState.zscale_pos) of
       1: begin 
            sState.ocBar -> SetProperty, Data = REPLICATE(1B,10) # BINDGEN(256)
            
            if (sState.UseLogScale eq 0) then begin
              ycconv = [location[1]-ZMin*dimension[1]/(ZMax-ZMin), $
                        dimension[1]/(ZMax-ZMin)] 
            end else begin
              ycconv = [location[1]-Alog10(ZMin)*dimension[1]/(Alog10(ZMax/ZMin)), $
                        dimension[1]/(Alog10(ZMax/ZMin))] 
            end  
 
            sState.zcAxis -> SetProperty, YCOORD_CONV = ycconv 
            sState.zcAxis -> SetProperty, TICKLEN = 0.3*dimension[0]
            sState.zcAxis -> SetProperty, XCOORD_CONV = [0.0,1.0]
            sState.zcAxis -> SetProperty, Location = location + [dimension[0],0,0]
            sState.zcAxis -> SetProperty, TICKDIR = 1, Direction = 1, TEXTPOS = 1
 
            sState.zcAxisOp -> SetProperty, YCOORD_CONV = ycconv
            sState.zcAxisOp -> SetProperty, TICKLEN = 0.3*dimension[0]
            sState.zcAxisOp -> SetProperty, XCOORD_CONV = [0.0,1.0]
            sState.zcAxisOp -> SetProperty, Location = location 
            sState.zcAxisOp -> SetProperty, TICKDIR = 0, Direction = 1

            sState.ocBoxBar1 -> SetProperty, Data =[ [location[0], location[1]], $
                                         [location[0]+ dimension[0], location[1]]]

            sState.ocBoxBar2 -> SetProperty, Data =[ [location[0], location[1]+ dimension[1]], $
                                         [location[0]+dimension[0], location[1]+ dimension[1]]]
          end
       2: begin 

            sState.ocBar -> SetProperty, Data =  BINDGEN(256) # REPLICATE(1B,10)

            if (sState.UseLogScale eq 0) then begin
              xcconv = [location[0]-ZMin*dimension[0]/(ZMax-ZMin), $
                        dimension[0]/(ZMax-ZMin)] 
            end else begin
              xcconv = [location[0]-Alog10(ZMin)*dimension[0]/(Alog10(ZMax/ZMin)), $
                        dimension[0]/(Alog10(ZMax/ZMin))] 
            end  
 
            sState.zcAxis -> SetProperty, YCOORD_CONV = [0.0,1.0]
            sState.zcAxis -> SetProperty, TICKLEN = 0.3*dimension[1]
            sState.zcAxis -> SetProperty, XCOORD_CONV = xcconv
            sState.zcAxis -> SetProperty, Location = location 
            sState.zcAxis -> SetProperty, TICKDIR = 0, Direction = 0, TEXTPOS = 0
 
            sState.zcAxisOp -> SetProperty, YCOORD_CONV = [0.0,1.0]
            sState.zcAxisOp -> SetProperty, TICKLEN = 0.3*dimension[1]
            sState.zcAxisOp -> SetProperty, XCOORD_CONV = xcconv
            sState.zcAxisOp -> SetProperty, Location = location + [0,dimension[1]]
            sState.zcAxisOp -> SetProperty, TICKDIR = 1, Direction = 0

            sState.ocBoxBar1 -> SetProperty, Data =[ [location[0], location[1]], $
                                         [location[0], location[1]+dimension[1]]]

            sState.ocBoxBar2 -> SetProperty, Data =[ [location[0]+dimension[0], location[1]], $
                                         [location[0]+dimension[0], location[1]+ dimension[1]]]
         end
     else: sState.oColorAxis -> SetProperty, HIDE = 1 ; invalid position
     endcase
   end else sState.oColorAxis -> SetProperty, HIDE = 1

   ; Update Data Position

   sState.DataPosition = ImagePosition

end
; ---------------------------------------------------------------------


; ----------------------------------------- Plot2D_CreateZColorAxis ---
;  Creates the ZAxis for a color bar
; ---------------------------------------------------------------------

pro Plot2D_CreateZColorAxis, sState

  if (not obj_valid(sState.oColorAxis)) then begin
    sState.oColorAxis = Obj_New('IDLgrModel')
    sState.oView -> Add, sState.oColorAxis

    axisColor = (sState.iInvColors)?[0b,0b,0b]:[255b,255b,255b]

    sState.ocBar = Obj_New('IDLgrImage', Palette = sState.oPalette )
    sState.oColorAxis -> Add, sState.ocBar
                     
    sState.zcAxis -> SetProperty, COLOR = axisColor, /Exact
   
    sState.oColorAxis -> Add, sState.zcAxis
               
    sState.zcAxisOp -> SetProperty, COLOR = axisColor, /Exact, /notext

    sState.oColorAxis -> Add, sState.zcAxisOp
                             
    sState.ocBoxBar1 = Obj_New('IDLgrPolyline')
    sState.ocBoxBar1 -> SetProperty, Color = axisColor
               
    sState.ocBoxBar2 = Obj_New('IDLgrPolyline')
    sState.ocBoxBar2 -> SetProperty, Color = axisColor
               
    sState.oColorAxis -> Add, sState.ocBoxBar1
    sState.oColorAxis -> Add, sState.ocBoxBar2

    sState.oColorAxis -> SetProperty, HIDE = (sState.zscale_pos eq 0)?1:0
  end
end
; ---------------------------------------------------------------------


; ----------------------------------- Plot2D_GenerateColorIndexPlot ---
;  Generates a Color Index Plot
; ---------------------------------------------------------------------

pro Plot2D_GenerateColorIndexPlot, sState
   widget_control, /hourglass

   ; The view is set to be the same as normal coordinates in direct graphics

   sState.oView -> SetProperty, VIEW = [0,0,1.,1.], PROJECTION = 1

   ; Initializes local variables
    
   DeltaX_2 = (sState.XAxisData[1] - sState.XAxisData[0])/2.0
   DeltaY_2 = (sState.YAxisData[1] - sState.YAxisData[0])/2.0

   XMin = sState.xrange[0] - DeltaX_2
   XMax = sState.xrange[1] + DeltaX_2  

   YMin = sState.yrange[0] - DeltaY_2
   YMax = sState.yrange[1] + DeltaY_2  
      
   ; Generates image
    
   sState.oImage =  OBJ_NEW('IDLgrImage' )  
   sState.oImage -> SetProperty, PALETTE = sState.oPalette

   sState.oModel -> Add, sState.oImage   

   ;--------------------------- Axis and Axis Labels ----------------------------------------

   axisColor = (sState.iInvColors)?[0b,0b,0b]:[255b,255b,255b]

   ; Adds Spatial Axis
 
   sState.xAxis -> SetProperty, COLOR = axisColor
   sState.oModelAxis -> Add, sState.xAxis

   sState.xAxisOp -> SetProperty, COLOR = axisColor, TICKDIR = 1
   sState.oModelAxis -> Add, sState.xAxisOp

   sState.yAxis -> SetProperty, COLOR = axisColor
   sState.oModelAxis -> Add, sState.yAxis

   sState.yAxisOp -> SetProperty, COLOR = axisColor, TICKDIR = 1
   sState.oModelAxis -> Add, sState.yAxisOp

   ; Adds spatial z Axis to the container so it can be destroyed
   
   sState.oContainer -> Add, sState.zAxis
 

   ; Add ColorBar
   
   Plot2D_CreateZColorAxis, sState

   ; Update Title Position   

   sState.oTitle-> SetProperty, LOCATION = [0.5,0.95], ALIGNMENT = 0.5
   sState.oSubTitle-> SetProperty, LOCATION = [0.95, 0.90], ALIGNMENT = 1.0

   ; Update Axis Info
   
   Plot2D_UpdateZAxisColorIndexPlot, sState
   Plot2D_UpdateAxis, sState


end

; ---------------------------------------------------------------------

; -------------------------------------- Plot2D_CleanColorIndexPlot ---
;  Cleans a Color Index Plot
; ---------------------------------------------------------------------

pro Plot2D_CleanColorIndexPlot, sState

   ; Destroy Color Index Plot specific objects
   Obj_Destroy,sState.oImage
   
   ; Remove from models axis objects
   sState.oModelAxis -> Remove, sState.xAxis
   sState.oModelAxis -> Remove, sState.xAxisOp
   sState.oModelAxis -> Remove, sState.yAxis
   sState.oModelAxis -> Remove, sState.yAxisOp
   
  
   ; Remove spatial z Axis from container
   sState.oContainer -> Remove, sState.zAxis

   
end
; ---------------------------------------------------------------------

; ------------------------------------------- Plot2D_Vcolor_Surface ---
;  sets the vertex colors for the surface
; ---------------------------------------------------------------------

pro Plot2D_VColor_Surface, sState

  if (sState.iVColors gt 0) then begin
    if (sState.UseLogScale gt 0) then begin
      ZMin = Alog10(sState.DataMin)
      ZMax = Alog10(sState.DataMax)
      tempdata =  ALog10(abs(*(sState.pData)) > 1e-37)     
      tempmin = (ZMin - 1.0)
      idx = where(tempdata eq -37.0, count) 
      if (count gt 0) then tempdata[temporary(idx)] = tempmin
      
      ByteData = BytScl( temporary(tempdata) ,$
                               Max = ZMax, Min = ZMin)
    end else begin
        ByteData = BytScl(*(sState.pData), Max = sState.DataMax, Min = sState.DataMin)
    end
 
    s = Size(ByteData, /dim)
    numVerts = s[0]*s[1]
    sState.oSurface -> SetProperty, VERT_COLORS = Reform(ByteData, numVerts),$
                       Palette = sState.oPalette
  end else begin
    sState.oSurface -> SetProperty, VERT_COLORS = 0
  end
end

; ---------------------------------------------------------------------

; ----------------------------------- Plot2D_UpdateZAxisSurfacePlot ---
;  Updates Z Axis for a Surface plot
; ---------------------------------------------------------------------

pro Plot2D_UpdateZAxisSurfacePlot,sState

   s = size(*(sState.pData), /Dimensions)
   
   NX = s[0]
   NY = s[1]

   XMin = sState.XAxisData[0]
   XMax = sState.XAxisData[NX-1]   

   YMin = sState.YAxisData[0]
   YMax = sState.YAxisData[NY-1]   

   ZMin = sState.DataMin
   ZMax = sState.DataMax

   ZLoc = -0.25
   ZDim = 0.8

   ; The view is set to be the usual 2.x2. square centered at the origin
   ; correcting for assymetric window
   
   sState.oWindow -> GetProperty, Units = Units
   sState.oWindow -> SetProperty, Units = 0
   sState.oWindow -> GetProperty, Dimensions = dims
   sState.oWindow -> SetProperty, Units = Units

   xdim = dims[0]
   ydim = dims[1]

   ; Change ViewPlane to account for assimetry

   case (sState.zscale_pos) of
     0: begin
          if (xdim lt ydim) then begin
            xsize = 2.
            ysize = 2. * ydim / float(xdim)
          end else begin
            xsize = 2. * xdim / float(ydim)
            ysize = 2.
          end
          sState.ViewPlaneRect = [-xsize/2.,-ysize/2., xsize, ysize] 
        end   
     1: begin
          ydim = ydim * 1.25
          if (xdim lt ydim) then begin
            xsize = 2.5
            ysize = 2. * ydim / float(xdim)
          end else begin
            xsize = 2.5 * xdim / float(ydim)
            ysize = 2.
          end
          print,-2*xsize/3.,xsize
          sState.ViewPlaneRect = [-2*xsize/5.,-ysize/2., xsize, ysize]  
          BarPosition = [1.06,-0.4,1.12,0.4]
        end
     2: begin
          xdim = xdim * 1.25
          if (xdim lt ydim) then begin
            xsize = 2.
            ysize = 2.5 * ydim / float(xdim)
          end else begin
            xsize = 2. * xdim / float(ydim)
            ysize = 2.5
          end
          sState.ViewPlaneRect = [-xsize/2.,-3*ysize/5., xsize, ysize]
          BarPosition = [-0.6,-1.12,0.6,-1.05]
        end
     else:
   endcase

   sState.oView -> SetProperty, VIEW = sState.ViewPlaneRect  
   sState.oView -> SetProperty,  PROJECTION = 2
   SurfacePosition = [-1.,-1.,1.,1.]*0.6
 
   dimension = [ SurfacePosition[2] - SurfacePosition[0], SurfacePosition[3] - SurfacePosition[1] ]
   location = [ SurfacePosition[0], SurfacePosition[1] ] 
  
   ycconv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
   xcconv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
   zcconv = [ZLoc-ZMin*ZDim/(ZMax-ZMin), ZDim/(ZMax-ZMin)]

   sState.oSurface -> SetProperty, YCOORD_CONV = ycconv
   sState.oSurface -> SetProperty, XCOORD_CONV = xcconv
   sState.xAxis    -> SetProperty, YCOORD_CONV = ycconv
   sState.xAxis    -> SetProperty, XCOORD_CONV = xcconv
   sState.xAxis    -> SetProperty, ZCOORD_CONV = zcconv
   sState.xAxisOp  -> SetProperty, YCOORD_CONV = ycconv
   sState.xAxisOp  -> SetProperty, XCOORD_CONV = xcconv
   sState.xAxisOp  -> SetProperty, ZCOORD_CONV = zcconv
   sState.yAxis    -> SetProperty, YCOORD_CONV = ycconv
   sState.yAxis    -> SetProperty, XCOORD_CONV = xcconv
   sState.yAxis    -> SetProperty, ZCOORD_CONV = zcconv
   sState.yAxisOp  -> SetProperty, YCOORD_CONV = ycconv
   sState.yAxisOp  -> SetProperty, XCOORD_CONV = xcconv
   sState.yAxisOp  -> SetProperty, ZCOORD_CONV = zcconv
   sState.zAxis    -> SetProperty, YCOORD_CONV = ycconv
   sState.zAxis    -> SetProperty, XCOORD_CONV = xcconv

   sState.oBoxBar1 -> SetProperty, XCOORD_CONV = xcconv, YCOORD_CONV = ycconv, ZCOORD_CONV = zcconv 
   sState.oBoxBar2 -> SetProperty, XCOORD_CONV = xcconv, YCOORD_CONV = ycconv, ZCOORD_CONV = zcconv 
   sState.oBoxBar3 -> SetProperty, XCOORD_CONV = xcconv, YCOORD_CONV = ycconv, ZCOORD_CONV = zcconv 
   sState.oBoxBar4 -> SetProperty, XCOORD_CONV = xcconv, YCOORD_CONV = ycconv, ZCOORD_CONV = zcconv 

   
   ; Set Surface Properties
   
   if (sState.UseLogScale gt 0) then begin
     _ZMax = ALog10(ZMax)
     _ZMin = ALog10(ZMin)
     tempdata =  ALog10(abs(*(sState.pData)) > 1e-37)     
     tempmin = _ZMin - 1.0
     idx = where(tempdata eq -37.0, count) 
     if (count gt 0) then tempdata[temporary(idx)] = tempmin
     sState.oSurface -> SetProperty, DATAZ = temporary(tempdata)
     sState.oSurface -> SetProperty, MAX_VALUE = _ZMax, MIN_VALUE = _ZMin
     zcconv = [ZLoc-_ZMin*ZDim/(_ZMax-_ZMin), ZDim/(_ZMax-_ZMin)]
   end else begin
     sState.oSurface -> SetProperty, DATAZ = *(sState.pData)
     sState.oSurface -> SetProperty, MAX_VALUE = ZMax, MIN_VALUE = ZMin
;     zcconv = [ZLoc-ZMin*ZDim/(ZMax-ZMin), ZDim/(ZMax-ZMin)]
   end

   sState.oSurface -> SetProperty, ZCOORD_CONV = zcconv

   ; Set Z Axis Properties

   sState.zAxis -> SetProperty, ZCOORD_CONV = zcconv

   sState.zAxis -> SetProperty, Range = [ZMin,ZMax], LOG = sState.UseLogScale
   
   sState.zAxis -> GetProperty, Location = loc
   sState.zAxis -> SetProperty, LOCATION = [loc[0],loc[1], ZMin]

   ; Set Z Color Axis Properties

   if (sState.zscale_pos gt 0) then begin
     sState.zcAxis -> SetProperty, Range = [ZMin,ZMax], LOG = sState.UseLogScale
     sState.zcAxisOp -> SetProperty, Range = [ZMin,ZMax], LOG = sState.UseLogScale

     sState.oColorAxis -> SetProperty, HIDE = 0
  
     dimension = [ BarPosition[2] - BarPosition[0], BarPosition[3] - BarPosition[1] ]
     location = [ BarPosition[0], BarPosition[1],0 ] 
     sState.ocBar -> SetProperty, Dimensions = dimension
     sState.ocBar -> SetProperty, Location = location

     case (sState.zscale_pos) of
       1: begin 
            sState.ocBar -> SetProperty, Data = REPLICATE(1B,10) # BINDGEN(256)
            
            if (sState.UseLogScale eq 0) then begin
              ycconv = [location[1]-ZMin*dimension[1]/(ZMax-ZMin), $
                        dimension[1]/(ZMax-ZMin)] 
            end else begin
              ycconv = [location[1]-Alog10(ZMin)*dimension[1]/(Alog10(ZMax/ZMin)), $
                        dimension[1]/(Alog10(ZMax/ZMin))] 
            end  
 
            sState.zcAxis -> SetProperty, YCOORD_CONV = ycconv 
            sState.zcAxis -> SetProperty, TICKLEN = 0.3*dimension[0]
            sState.zcAxis -> SetProperty, XCOORD_CONV = [0.0,1.0]
            sState.zcAxis -> SetProperty, Location = location + [dimension[0],0,0]
            sState.zcAxis -> SetProperty, TICKDIR = 1, Direction = 1, TEXTPOS = 1
 
            sState.zcAxisOp -> SetProperty, YCOORD_CONV = ycconv
            sState.zcAxisOp -> SetProperty, TICKLEN = 0.3*dimension[0]
            sState.zcAxisOp -> SetProperty, XCOORD_CONV = [0.0,1.0]
            sState.zcAxisOp -> SetProperty, Location = location 
            sState.zcAxisOp -> SetProperty, TICKDIR = 0, Direction = 1

            sState.ocBoxBar1 -> SetProperty, Data =[ [location[0], location[1], 0], $
                                         [location[0]+ dimension[0], location[1], 0]]

            sState.ocBoxBar2 -> SetProperty, Data =[ [location[0], location[1]+ dimension[1], 0], $
                                         [location[0]+dimension[0], location[1]+ dimension[1], 0]]
          end
       2: begin 

            sState.ocBar -> SetProperty, Data =  BINDGEN(256) # REPLICATE(1B,10)

            if (sState.UseLogScale eq 0) then begin
              xcconv = [location[0]-ZMin*dimension[0]/(ZMax-ZMin), $
                        dimension[0]/(ZMax-ZMin)] 
            end else begin
              xcconv = [location[0]-Alog10(ZMin)*dimension[0]/(Alog10(ZMax/ZMin)), $
                        dimension[0]/(Alog10(ZMax/ZMin))] 
            end  
 
            sState.zcAxis -> SetProperty, YCOORD_CONV = [0.0,1.0]
            sState.zcAxis -> SetProperty, TICKLEN = 0.3*dimension[1]
            sState.zcAxis -> SetProperty, XCOORD_CONV = xcconv
            sState.zcAxis -> SetProperty, Location = location 
            sState.zcAxis -> SetProperty, TICKDIR = 0, Direction = 0, TEXTPOS = 0
 
            sState.zcAxisOp -> SetProperty, YCOORD_CONV = [0.0,1.0]
            sState.zcAxisOp -> SetProperty, TICKLEN = 0.3*dimension[1]
            sState.zcAxisOp -> SetProperty, XCOORD_CONV = xcconv
            sState.zcAxisOp -> SetProperty, Location = location + [0,dimension[1]]
            sState.zcAxisOp -> SetProperty, TICKDIR = 1, Direction = 0

            sState.ocBoxBar1 -> SetProperty, Data =[ [location[0], location[1]], $
                                         [location[0], location[1]+dimension[1]]]

            sState.ocBoxBar2 -> SetProperty, Data =[ [location[0]+dimension[0], location[1]], $
                                         [location[0]+dimension[0], location[1]+ dimension[1]]]
         end
     else: sState.oColorAxis -> SetProperty, HIDE = 1 ; invalid position
     endcase
   end else if (obj_valid(sState.oColorAxis)) then sState.oColorAxis -> SetProperty, HIDE = 1

   ; Update Title Position   

   sState.oTitle -> SetProperty, LOCATION = [0.9*(xsize/2.0),0.9*(ysize/2.0)], ALIGNMENT = 1.0
   sState.oSubTitle -> SetProperty, LOCATION = [0.9*(xsize/2.0), 0.8*(ysize/2.0)], ALIGNMENT = 1.0

   ; Update Contour Position
 
   if (sState.iAddContourPlot) and (obj_valid(sState.oContour)) then $  
     Plot2D_UpdateGeometryContourPlot, sState
  
   ; Map Colors
   
   Plot2D_VColor_Surface, sState

   ; Update Data Position for tools

   sState.DataPosition = SurfacePosition

end

; ---------------------------------------------------------------------

; -------------------------------------- Plot2D_GenerateSurfacePlot ---
;  Generates a Surface Plot
; ---------------------------------------------------------------------

pro Plot2D_GenerateSurfacePlot, sState
   widget_control, /hourglass


   ; Generates Surface
   sState.oSurface = Obj_New('IDLgrSurface')
   sState.oSurface -> SetProperty, BOTTOM = (sState.iUseBottomColor)?sState.BottomColor:-1  
   sState.oSurface -> SetProperty, COLOR = sState.Color
   sState.oSurface -> SetProperty, SHADING = sState.iShading
   sState.oSurface -> SetProperty, STYLE = sState.iStyle
   sState.oSurface -> SetProperty, HIDDEN_LINES = sState.iHidden

   ; Initializes local variables

   s = size(*(sState.pData), /Dimensions)
   
   NX = s[0]
   NY = s[1]

   XMin = sState.XAxisData[0]
   XMax = sState.XAxisData[NX-1]   

   YMin = sState.YAxisData[0]
   YMax = sState.YAxisData[NY-1]   

   ZMin = sState.DataMin
   ZMax = sState.DataMax
      
   ; Add surface to model
 
   sState.oModel -> Add, sState.oSurface
 
   
   ; Create Axis
  
   axisColor = (sState.iInvColors)?[0b,0b,0b]:[255b,255b,255b]

   ; Create Axis
   sState.xAxis -> SetProperty, LOCATION = [XMin,YMin, ZMin]
   sState.xAxis -> SetProperty, Range = [XMin,XMax], /Exact, $
                     COLOR = axisColor
   xtl = 0.04 *(YMax-Ymin)

   sState.xAxis -> SetProperty, TICKLEN = xtl
   sState.oModelAxis -> Add, sState.xAxis

   sState.xAxisOp -> SetProperty, Range = [XMin,XMax], /Exact, $
                    LOCATION = [XMin,YMax, ZMin], COLOR = axisColor, TICKDIR = 1
   sState.xAxisOp -> SetProperty, TICKLEN = xtl
   sState.oModelAxis -> Add, sState.xAxisOp
  
   sState.yAxis -> SetProperty, Range = [YMin,YMax], /Exact, $
                    LOCATION = [XMin,YMin, ZMin], COLOR = axisColor
   ytl = 0.04 *(XMax-Xmin)

   sState.yAxis -> SetProperty, TICKLEN = ytl
   sState.oModelAxis -> Add, sState.yAxis

   sState.yAxisOp -> SetProperty, Range = [YMin,YMax], /Exact, $
                    LOCATION = [XMax,YMin, ZMin], COLOR = axisColor, TICKDIR = 1

   sState.yAxisOp -> SetProperty, TICKLEN = ytl
   sState.oModelAxis -> Add, sState.yAxisOp


   sState.zAxis -> SetProperty,/Exact, Direction = 2, LOCATION = [XMin,YMax, 0.0], $
                   COLOR = axisColor, TICKDIR = 0, TEXTPOS = 0
                   
                   
   ztl = 0.04 *(XMax-Xmin)

   sState.zAxis -> SetProperty, TICKLEN = ztl
   sState.oModelAxis -> Add, sState.zAxis

   ; Create box arround the plot

   sState.oBoxBar1 = Obj_New('IDLgrPolyline', [XMin, XMin, XMax, XMax, XMin], [YMin, YMax, YMax, YMin, YMin], $
                                       [ZMax, ZMax, ZMax, ZMax, ZMax], Color = axisColor)
   sState.oBoxBar2 = Obj_New('IDLgrPolyline', [XMin, XMin], [YMin, YMin], $
                                       [ZMin, ZMax], Color = axisColor)
   sState.oBoxBar3 = Obj_New('IDLgrPolyline', [XMax, XMax], [YMin, YMin], $
                                       [ZMin, ZMax], Color = axisColor)
   sState.oBoxBar4 = Obj_New('IDLgrPolyline', [XMax, XMax], [YMax, YMax], $
                                       [ZMin, ZMax], Color = axisColor)  
   sState.oModelAxis -> Add, sState.oBoxBar1
   sState.oModelAxis -> Add, sState.oBoxBar2
   sState.oModelAxis -> Add, sState.oBoxBar3
   sState.oModelAxis -> Add, sState.oBoxBar4

   ; Add ColorBar
   
   Plot2D_CreateZColorAxis, sState

   ; Update Z Axis related data
   
   Plot2D_UpdateZAxisSurfacePlot, sState  

   ; Add XY axis data
  
   sState.oSurface -> SetProperty, DATAX = sState.XAxisData, DATAY = sState.YAxisData

   ; Nudge Axis to make them visible

   ;sState.oModelAxis -> Translate, 0, 0, 0.001
   
;   oModelSurface -> Translate, - (location[0] + dimension[0]/2.), - (location[1] + dimension[1]/2.), 0 
  
   sState.oModel -> Rotate, [1,0,0], -90
   sState.oModel -> Rotate, [0,1,0], 30
   sState.oModel -> Rotate, [1,0,0], 30

   sState.oModelAxis -> Rotate, [1,0,0], -90
   sState.oModelAxis -> Rotate, [0,1,0], 30
   sState.oModelAxis -> Rotate, [1,0,0], 30

   sState.oModelContour -> Rotate, [1,0,0], -90
   sState.oModelContour -> Rotate, [0,1,0], 30
   sState.oModelContour -> Rotate, [1,0,0], 30



;   oModelSurface -> Translate,  (location[0] + dimension[0]/2.),  (location[1] + dimension[1]/2.), 0 

   sState.oLight1 = OBJ_NEW('IDLgrLight', TYPE = 2, LOCATION = [-0.75,-1,1])
   sState.oModel -> ADD, sState.oLight1
   sState.oLight2 = OBJ_NEW('IDLgrLight', TYPE = 0, INTENSITY = 0.2)
   sState.oModel -> ADD, sState.oLight2

end

; ---------------------------------------------------------------------

; ------------------------------------ Plot2D_CleanColorSurfacePlot ---
;  Cleans a Color SurfacePlot
; ---------------------------------------------------------------------

pro Plot2D_CleanColorSurfacePlot, sState
   
   ; Destroy Color Index Plot specific objects
   Obj_Destroy, sState.oSurface
   Obj_Destroy, sState.oLight1
   Obj_Destroy, sState.oLight2
   Obj_Destroy, sState.oBoxBar1
   Obj_Destroy, sState.oBoxBar2
   Obj_Destroy, sState.oBoxBar3
   Obj_Destroy, sState.oBoxBar4
   
   ; Remove from models axis objects
   sState.oModelAxis -> Remove, sState.xAxis
   sState.oModelAxis -> Remove, sState.yAxis
   sState.oModelAxis -> Remove, sState.zAxis
   sState.oModelAxis -> Remove, sState.xAxisOp
   sState.oModelAxis -> Remove, sState.yAxisOp
 
   ; Reset Model and Axis Transformations
   sState.oModel -> Reset
   sState.oModelAxis -> Reset
   
end
; ---------------------------------------------------------------------

; -------------------------------- Plot2D_UpdateGeometryContourPlot ---
;  Updates the geometry of the Contour Plot
; ---------------------------------------------------------------------

pro Plot2D_UpdateGeometryContourPlot, sState

   print, 'In Plot2D_UpdateGeometryContourPlot'
 
   ZLoc = -0.25
   ZDim = 0.8

   s = size(*(sState.pData), /Dimensions)
   
   NX = s[0]
   NY = s[1]
   
   ZMin = sState.DataMin
   ZMax = sState.DataMax

   case (sState.iType) of 
     0: begin
          sState.oViewContour -> SetProperty, VIEW = [0.,0.,1.,1.], PROJECTION = 1
          
          view_dimension = [ sState.DataPosition[2] - sState.DataPosition[0], $
                        sState.DataPosition[3] - sState.DataPosition[1] ]
          view_location = [ sState.DataPosition[0], sState.DataPosition[1] ] 

          sState.oViewContour -> SetProperty,  DIMENSIONS = view_dimension, $
                                LOCATION = view_location , UNITS = 3
          sState.oModelContour -> Reset

          DeltaX = sState.XAxisData[1] - sState.XAxisData[0]
          DeltaY = sState.YAxisData[1] - sState.YAxisData[0]

          dimension = [1.,1.]
          location = [0.,0.]

          XMin = sState.xrange[0] - DeltaX/2.0
          XMax = sState.xrange[1] + DeltaX/2.0  

          YMin = sState.yrange[0] - DeltaY/2.0
          YMax = sState.yrange[1] + DeltaY/2.0  

          sState.oContour -> SetProperty, /PLANAR, GEOMZ = 0
          sState.oContour -> SetProperty, ZCOORD_CONV = [0.0,1.0]
        end
     1: begin
          print, 'ViewContour -> ', sState.ViewPlaneRect

          sState.oViewContour -> SetProperty, VIEW = sState.ViewPlaneRect, PROJECTION = 2
          sState.oViewContour -> SetProperty,  DIMENSIONS = [0.0, 0.0], LOCATION = [0.0,0.0] 

          XMin = sState.XAxisData[0]
          XMax = sState.XAxisData[NX-1] 

          YMin = sState.YAxisData[0] 
          YMax = sState.YAxisData[NY-1]

          dimension = [ sState.DataPosition[2] - sState.DataPosition[0], $
                        sState.DataPosition[3] - sState.DataPosition[1] ]
          location = [ sState.DataPosition[0], sState.DataPosition[1] ] 

          if (sState.UseLogScale eq 1) then begin
            sState.oContour -> GetProperty, DATA_VALUES = tempdata
            zcconv = [ZLoc-Alog10(ZMin)*ZDim/(Alog10(ZMax/ZMin)), ZDim/(Alog10(ZMax/ZMin))]
            sState.oContour -> SetProperty, GEOMZ = temporary(tempdata)
          end else begin         
            zcconv = [ZLoc-ZMin*ZDim/(ZMax-ZMin), ZDim/(ZMax-ZMin)]
            sState.oContour -> SetProperty, GEOMZ = *(sState.pData)
          end
          sState.oContour -> SetProperty, ZCOORD_CONV = zcconv 
          
          ; Nudge model to make it visible
          ; sState.oModelContour -> Translate, 0, 0, 0.01

        end
   end

   ycconv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
   xcconv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
   
   sState.oContour -> SetProperty, YCOORD_CONV = ycconv
   sState.oContour -> SetProperty, XCOORD_CONV = xcconv   

end
; ---------------------------------------------------------------------


; ------------------------------------------- Plot2D_AddContourPlot ---
;  Generates a Contour Plot
; ---------------------------------------------------------------------

pro Plot2D_AddContourPlot, sState
   widget_control, /hourglass
      
   ; Set Contour Values
   
   if (sState.UseLogScale gt 0) then begin
      ZMin = sState.DataMin
      tempdata =  ALog10(abs(*(sState.pData)) > 1e-37)     
      tempmin = (Alog10(ZMin) - 1.0)
      idx =  where(tempdata eq -37.0, count)
      if (count gt 0) then tempdata[temporary(idx)] = tempmin
      sState.oContour = Obj_New('IDLgrContour', tempdata)
   end else begin
      sState.oContour = Obj_New('IDLgrContour', *(sState.pData))
   end

   sState.oContour -> SetProperty, C_VALUE = [*(sState.pContourLevels)]
   sState.oContour -> SetProperty, N_LEVELS = (size(*(sState.pContourLevels), /dimensions))[0]
   
   sState.oContour -> SetProperty, GEOMX = sState.XAxisData
   sState.oContour -> SetProperty, GEOMY = sState.YAxisData

   sState.oContour -> SetProperty, COLOR = sState.ContourColor

   ; Add Contour to model
   
   sState.oModelContour -> Add, sState.oContour

end

; ---------------------------------------------------------------------

; --------------------------------- Plot2D_UpdateGeometryTrajectory ---
;  Updates the geometry of the Contour Plot
; ---------------------------------------------------------------------

pro Plot2D_UpdateGeometryTrajectory, sState
   
   ImagePosition = [0.0,0.0,1.0,1.0]

   SurfacePosition = [-1.,-1.,1.,1.]*0.6
   ZLoc = -0.25
   ZDim = 0.8

   s = size(*(sState.pData), /Dimensions)
   
   NX = s[0]
   NY = s[1]
   
   ZMin = sState.DataMin
   ZMax = sState.DataMax

   case (sState.iType) of 
     0: begin

          sState.oViewTrajectory -> SetProperty, VIEW = [0.,0.,1.,1.], PROJECTION = 1
          
          view_dimension = [ sState.DataPosition[2] - sState.DataPosition[0], $
                        sState.DataPosition[3] - sState.DataPosition[1] ]
          view_location = [ sState.DataPosition[0], sState.DataPosition[1] ] 

          sState.oViewTrajectory -> SetProperty,  DIMENSIONS = view_dimension, $
                                LOCATION = view_location , UNITS = 3

          sState.oModelTrajectory -> Reset
          dimension = [ ImagePosition[2] - ImagePosition[0], $
                        ImagePosition[3] - ImagePosition[1] ]
          location = [ ImagePosition[0], ImagePosition[1] ] 

          DeltaX = sState.XAxisData[1] - sState.XAxisData[0]
          DeltaY = sState.YAxisData[1] - sState.YAxisData[0]

          XMin = sState.xrange[0] - DeltaX/2.0
          XMax = sState.xrange[1] + DeltaX/2.0  

          YMin = sState.yrange[0] - DeltaY/2.0
          YMax = sState.yrange[1] + DeltaY/2.0  

          sState.oTrajectory -> SetProperty, ZCOORD_CONV = [0.0,1.0]
        end
     1: begin
          sState.oViewTrajectory -> SetProperty, VIEW = [-1.,-1.,2.,2.], PROJECTION = 2
          sState.oViewTrajectory -> SetProperty,  DIMENSIONS = [0.0, 0.0], $
                                LOCATION = [0.0,0.0] 

          XMin = sState.xrange[0]
          XMax = sState.xrange[1] 

          YMin = sState.yrange[0] 
          YMax = sState.yrange[1]

          dimension = [ SurfacePosition[2] - SurfacePosition[0], $
                        SurfacePosition[3] - SurfacePosition[1] ]
          location = [ SurfacePosition[0], SurfacePosition[1] ] 

          if (sState.UseLogScale eq 1) then begin
            zcconv = [ZLoc-Alog10(ZMin)*ZDim/(Alog10(ZMax/ZMin)), ZDim/(Alog10(ZMax/ZMin))]
          end else begin         
            zcconv = [ZLoc-ZMin*ZDim/(ZMax-ZMin), ZDim/(ZMax-ZMin)]
          end
          sState.oTrajectory -> SetProperty, ZCOORD_CONV = zcconv 
          
          ; Nudge model to make it visible
          ;sState.oModelTrajectory -> Translate, 0, 0, 0.01

        end
   end

   ycconv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
   xcconv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]
   
   sState.oTrajectory -> SetProperty, YCOORD_CONV = ycconv
   sState.oTrajectory -> SetProperty, XCOORD_CONV = xcconv   

end
; ---------------------------------------------------------------------


; ---------------------------------------- Plot2D_AddTrajectory -------
;  Adds a trajectory to the plot
; ---------------------------------------------------------------------

pro Plot2D_AddTrajectory, sState
   widget_control, /hourglass
      
   sState.oTrajectory = obj_new('IDLgrPolyline', sState.TrajVert)
   
   if (N_Elements(sState.TrajPoints) gt 1) then $
       sState.oTrajectory -> SetProperty, POLYLINES = sState.TrajPoints  
      
   sState.oTrajectory -> SetProperty, COLOR = sState.TrajColor
   sState.oTrajectory -> SetProperty, THICK = sState.TrajThick
   sState.oTrajectory -> SetProperty, LINESTYLE = sState.TrajStyle

   ; Add Trajectory to model
   
   sState.oModelTrajectory -> Add, sState.oTrajectory
end

; ---------------------------------------------------------------------

; ------------------------------------- Plot2D_UpdateGeometryVector ---
;  Updates the geometry of the Vector Plot
; ---------------------------------------------------------------------

pro Plot2D_UpdateGeometryVector, sState
   
   ImagePosition = [0.0,0.0,1.0,1.0]

   SurfacePosition = [-1.,-1.,1.,1.]*0.6
   ZLoc = -0.25
   ZDim = 0.8

   s = size(*(sState.pData), /Dimensions)
   
   NX = s[0]
   NY = s[1]
   
   ZMin = sState.DataMin
   ZMax = sState.DataMax

   case (sState.iType) of 
     0: begin
          sState.oViewVector -> SetProperty, VIEW = [0.,0.,1.,1.], PROJECTION = 1
          sState.oViewVector -> SetProperty,  DIMENSIONS = [0.64, .7], $
                                LOCATION = [.15,.15] , UNITS = 3
          sState.oModelVector -> Reset
          dimension = [ ImagePosition[2] - ImagePosition[0], $
                        ImagePosition[3] - ImagePosition[1] ]
          location = [ ImagePosition[0], ImagePosition[1] ] 

          DeltaX = sState.XAxisData[1] - sState.XAxisData[0]
          DeltaY = sState.YAxisData[1] - sState.YAxisData[0]

          XMin = sState.xrange[0] - DeltaX/2.0
          XMax = sState.xrange[1] + DeltaX/2.0  

          YMin = sState.yrange[0] - DeltaY/2.0
          YMax = sState.yrange[1] + DeltaY/2.0  

          zcconv = [0.0,1.0] 
        end
     1: begin
          sState.oViewVector -> SetProperty, VIEW = [-1.,-1.,2.,2.], PROJECTION = 2
          sState.oViewVector -> SetProperty,  DIMENSIONS = [0.0, 0.0], $
                                LOCATION = [0.0,0.0] 

          XMin = sState.xrange[0]
          XMax = sState.xrange[1] 

          YMin = sState.yrange[0] 
          YMax = sState.yrange[1]

          dimension = [ SurfacePosition[2] - SurfacePosition[0], $
                        SurfacePosition[3] - SurfacePosition[1] ]
          location = [ SurfacePosition[0], SurfacePosition[1] ] 
            
          nudge = 0.01

          if (sState.UseLogScale eq 1) then begin
            zcconv = [ZLoc-Alog10(ZMin)*ZDim/(Alog10(ZMax/ZMin)), ZDim/(Alog10(ZMax/ZMin))]
          end else begin         
            zcconv = [ZLoc-ZMin*ZDim/(ZMax-ZMin), ZDim/(ZMax-ZMin)]
          end
          
          ; Nudge model to make it visible
          sState.oModelVector -> Translate, 0, 0, 0.01

        end
   end

   ycconv = [location[1]-YMin*dimension[1]/(YMax-YMin), dimension[1]/(YMax-YMin)]
   xcconv = [location[0]-XMin*dimension[0]/(XMax-XMin), dimension[0]/(XMax-XMin)]

   ; Set coord conv of all the vectors inside oVector   
   
   obj = sState.oVector -> Get(/ALL, COUNT = count)
   for i=0l, count-1 do begin
     obj[i] -> SetProperty, ZCOORD_CONV = zcconv
     obj[i] -> SetProperty, YCOORD_CONV = ycconv
     obj[i] -> SetProperty, XCOORD_CONV = xcconv   
   end
   
end
; ---------------------------------------------------------------------

; ------------------------------------------ Plot2D_RegenVector -------
;  Regenerates the vector plot
; ---------------------------------------------------------------------

pro Plot2D_RegenVector, sState
   widget_control, /hourglass

   obj_destroy, sState.oVector
   
   sState.oVector = obj_new('IDLgrModel')
 
   Vector2D, sState.pVData, sState.oVector, $
             XAXIS = sState.XAxisData, $
             YAXIS = sState.YAxisData, $
             XRANGE = sState.xrange, $
             YRANGE = sState.yrange, $
             LREF = sState.lref   
   
   sState.oModelVector -> Add, sState.oVector
end

; ---------------------------------------------------------------------


; -------------------------------------------- Plot2D_AddVector -------
;  Adds vectors to the plot
; ---------------------------------------------------------------------

pro Plot2D_AddVector, sState
   widget_control, /hourglass

   sState.oVector = obj_new('IDLgrModel')
 
   Vector2D, sState.pVData, sState.oVector, $
             XAXIS = sState.XAxisData, $
             YAXIS = sState.YAxisData, $
             XRANGE = sState.xrange, $
             YRANGE = sState.yrange, $
             LREF = sstate.lref   
   
   sState.oModelVector -> Add, sState.oVector
end

; ---------------------------------------------------------------------


; --------------------------------------------- Plot2D_GenerateView ---
;  Generates the view
; ---------------------------------------------------------------------

pro Plot2D_GenerateView, sState

  case (sState.iType) of
       1: Plot2D_GenerateSurfacePlot, sState
       0: Plot2D_GenerateColorIndexPlot, sState
    else: begin
            print, 'Plot2D, invalid type, ', sState.iType, ', using default type' 
            Plot2D_GenerateColorIndexPlot, sState
          end
  endcase

  if (sState.iAddContourPlot eq 1) then begin
    if not obj_valid(sState.oContour) then Plot2D_AddContourPlot, sState
    Plot2D_UpdateGeometryContourPlot, sState
  end
  
  if (sState.iAddTrajectory) then begin
    if not obj_valid(sState.oTrajectory) then Plot2D_AddTrajectory, sState
    Plot2D_UpdateGeometryTrajectory, sState
  end 

  if (sState.iAddVector) then begin
    if not obj_valid(sState.oVector) then Plot2D_AddVector, sState
    Plot2D_UpdateGeometryVector, sState
  end 
  
end



; ------------------------------------ ColorMapPlot_Visualize_Event ---
;  Handles draw widget events for the Color Map Plot
; ---------------------------------------------------------------------

pro ColorMapPlot_Visualize_Event, sEvent

    ; Get sState structure from base widget
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /No_Copy
    
    ; Button press
    IF (sEvent.type EQ 0) THEN BEGIN
        sState.tool_pos0 = double([ sEvent.x ,sEvent.y])/(sState.window_size-2) 
        x0 = sState.tool_pos0[0]
        y0 = sState.tool_pos0[1]

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
            1: $ ; X Profile
              begin
               def_colors = [[255b,  0b,  0b], $	; red
                             [ 63b, 63b,255b], $	; blue
                             [  0b,255b,  0b], $	; green
                             [  0b,255b,255b], $	; cyan
                             [255b,255b,  0b], $	; yellow
                             [191b,  0b,191b] ]		; purple

                color = reform(def_colors[*, sState.ProfileNum mod 6])

                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                sState.oZoomBox -> SetProperty, Hide = 0
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x0,y0]] 
                sState.oZoomBox -> SetProperty, COLOR = color
                sState.oWindow->Draw, sState.oViewTools, /CREATE_INSTANCE
              end
            2: $ ; Profile
              begin
               def_colors = [[255b,  0b,  0b], $	; red
                             [ 63b, 63b,255b], $	; blue
                             [  0b,255b,  0b], $	; green
                             [  0b,255b,255b], $	; cyan
                             [255b,255b,  0b], $	; yellow
                             [191b,  0b,191b] ]		; purple

                color = reform(def_colors[*, sState.ProfileNum mod 6])

                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                sState.oZoomBox -> SetProperty, Hide = 0
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x0,y0]] 
                sState.oZoomBox -> SetProperty, COLOR = color
                sState.oWindow->Draw, sState.oViewTools, /CREATE_INSTANCE
              end
          else:
          endcase
        end
    end

    ; Motion with button pressed
    if (sEvent.type EQ 2) and (sState.btndown EQ 1b) then begin
       tool_pos1 = double([ sEvent.x ,sEvent.y])/(sState.window_size -2)
       if (tool_pos1[0] gt sState.DataPosition[0]) and (tool_pos1[0] lt sState.DataPosition[2]) and $
          (tool_pos1[1] gt sState.DataPosition[1]) and (tool_pos1[1] lt sState.DataPosition[3]) then begin
         x0 = sState.tool_pos0[0]
         y0 = sState.tool_pos0[1]
         x1 = tool_pos1[0]
         y1 = tool_pos1[1]
         case (sState.iTool) of 
           0: $ ; Zoom
              begin
                sState.oZoomBox -> SetProperty, Data = [[x0,y0], [x1,y0], [x1,y1], [x0,y1], [x0,y0] ] 
                sState.oWindow->Draw, sState.oViewTools, /DRAW_INSTANCE
              end
           1: $ ; X Profile
              begin
                sState.oZoomBox -> SetProperty, Data = [[sState.DataPosition[0],y1],[sState.DataPosition[2],y1]] 
                sState.oWindow->Draw, sState.oViewTools, /DRAW_INSTANCE
              end
           2: $ ; Y Profile
              begin
                sState.oZoomBox -> SetProperty, Data = [[x1,sState.DataPosition[1]],[x1,sState.DataPosition[3]]]
                sState.oWindow->Draw, sState.oViewTools, /DRAW_INSTANCE
              end
         else:
         endcase
       end
    end

    ; Button Release
    IF (sEvent.type EQ 1) THEN BEGIN
        IF (sState.btndown EQ 1b) THEN BEGIN
           sState.oZoomBox -> SetProperty, Hide = 1
           
           tool_pos1 = double([ sEvent.x ,sEvent.y])/(sState.window_size-2) 
           
           if (tool_pos1[0] gt sState.DataPosition[0]) and (tool_pos1[0] lt sState.DataPosition[2]) and $
              (tool_pos1[1] gt sState.DataPosition[1]) and (tool_pos1[1] lt sState.DataPosition[3]) then begin

             dataXL = double(sState.DataPosition[2]-sState.DataPosition[0])
             dataYL = double(sState.DataPosition[3]-sState.DataPosition[1])
             dataXmin = double(sState.DataPosition[0])
             dataYmin = double(sState.DataPosition[1])

             viewXL = sState.dataXrange[1] - sState.dataXrange[0]
             viewYL = sState.dataYrange[1] - sState.dataYrange[0]

             x0 = sState.dataXrange[0] +  Long((sState.tool_pos0[0]-dataXmin)/dataXL * viewXL+0.5)
             y0 = sState.dataYrange[0] +  Long((sState.tool_pos0[1]-dataYmin)/dataYL * viewYL+0.5)
             x1 = sState.dataXrange[0] +  Long((tool_pos1[0]-dataXmin)/dataXL * viewXL+0.5)
             y1 = sState.dataYrange[0] +  Long((tool_pos1[1]-dataYmin)/dataYL * viewYL+0.5)

             case (sState.iTool) of 
                0: $ ; Zoom
                   begin
                     sState.oZoomBox -> SetProperty, Hide = 1
                     if ((x0 ne x1) and (y0 ne y1)) then begin
                       if (x0 gt x1) then begin
                          t = x1
                          x1 = x0
                          x0 = t
                       end

                       if (y0 gt y1) then begin
                         t = y1
                         y1 = y0
                         y0 = t
                       end
                       if (x0 lt 0) then x0 = 0
                       if (y0 lt 0) then y0 = 0
                       sState.dataXrange = [x0,x1]
                       sState.dataYrange = [y0,y1]
                       Plot2D_UpdateAxis, sState
                     end
                   end
                 1: $; Profile (X Lineout)
                    Plot2D_Profile, x1, y1, sEvent, sState
                 2: $; Profile (Y Lineout)
                    Plot2D_Profile, x1, y1, sEvent, sState
                 3: $; Data Picking
                    Plot2D_DataPick, x1, y1, sState
               else:
             endcase
           end  
           Plot2D_Redraw, sState
         ENDIF
         sState.btndown = 0b
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

end

; ------------------------------------- SurfacePlot_Visualize_Event ---
;  Handles draw widget events for the Color Map Plot
; ---------------------------------------------------------------------

pro SurfacePlot_Visualize_Event, sEvent

    ; Get sState structure from base widget
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /No_Copy
    
    ; Button press
    IF (sEvent.type EQ 0) THEN BEGIN
           sState.btndown = 1b
           sState.oWindow->SetProperty, QUALITY=1
           sState.oModel->SetProperty, HIDE =1

           WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
           sState.oWindow->Draw, sState.oView  
    end

    ; Motion with button pressed
    if (sState.btndown EQ 1b) then begin
       ; Rotation Tool
       ; Handle trackball updates.
       bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat, MOUSE = 1b )
       IF (bHaveTransform NE 0) THEN BEGIN
          sState.oModelAxis->GetProperty, TRANSFORM=t
          sState.oModelAxis->SetProperty, TRANSFORM=t#qmat
          sState.oWindow->Draw, sState.oView
       ENDIF
    end

    ; Button Release
    IF (sEvent.type EQ 1) THEN BEGIN
        IF (sState.btndown EQ 1b) THEN BEGIN
             sState.oModelAxis->GetProperty, TRANSFORM=t
             sState.oModel->SetProperty, TRANSFORM=t
             sState.oModelContour -> SetProperty, TRANSFORM=t
             sState.oModel->SetProperty, HIDE =0
             sState.oWindow->SetProperty, QUALITY=2
             Plot2D_Redraw, sState
         ENDIF
         sState.btndown = 0b
         WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
    ENDIF

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

end


; -------------------------------------------- Draw_Visualize_Event ---
;  Handles draw widget events
; ---------------------------------------------------------------------

pro Plot2D_Draw_Visualize_Event, sEvent
  
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
       Plot2D_Redraw, sState
    ENDIF
    
    type = sState.iType
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

    
    case (type) of
      0: ColorMapPlot_Visualize_Event, sEvent
      1: SurfacePlot_Visualize_Event, sEvent
    else:
    endcase
        
end
; ---------------------------------------------------------------------


; --------------------------------------- SavePlotTIFF_Plot2D_Event ---
;  Handles SavePlotTIFF events
; ---------------------------------------------------------------------

pro SavePlotTIFF_Plot2D_Event, sEvent

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


; -------------------------------------- SaveImageTIFF_Plot2D_Event ---
;  Handles SaveImageTIFF events
; ---------------------------------------------------------------------

pro SaveImageTIFF_Plot2D_Event, sEvent

   tifffileout = Dialog_PickFile(/write, FILTER = '*.tif',$
                        TITLE = 'Save image TIFF file as...', GET_PATH = tifffilepath)
   if (tifffileout ne '') then begin
     cd, tifffilepath

     Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

     sState.oImage -> GetProperty, DATA = imageout
     
     ; imageout is an 8-bit image
     
     sState.oPalette -> GetProperty, RED_VALUES = r
     sState.oPalette -> GetProperty, GREEN_VALUES = g
     sState.oPalette -> GetProperty, BLUE_VALUES = b
     
        
     imageout = reverse(imageout,0)
     WRITE_TIFF, tifffileout, imageout, RED = r, GREEN = g, BLUE = b, 1
         
     Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
   end
end

; ---------------------------------------------------------------------


; --------------------------------------- PageSetup_Plot2D_Event ---
;  Handles Page Setup events
; ---------------------------------------------------------------------

pro PageSetup_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  res = Dialog_PrinterSetup(sState.oPrinter) 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------


; ------------------------------------------- Print_Plot2D_Event ---
;  Handles Print events
; ---------------------------------------------------------------------

pro Print_Plot2D_Event, sEvent
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
    Plot2D_Redraw, sState
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

; -------------------------------------- ClipCopyImage_Plot2D_Event ---
;  Handles Copy Image events
; ---------------------------------------------------------------------

pro ClipCopyImage_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oImage -> GetProperty, DATA = data
  
  ImageResolution = size(data, /dimensions)
  
  oImage = obj_new('IDLgrImage', data, PALETTE = sState.oPalette, DIMENSIONS = [1,1])
  
  oModel = obj_new('IDLgrModel')
  oView = obj_new('IDLgrView', Dimensions = ImageResolution, VIEWPLANE_RECT = [0,0,1,1])
  oModel -> Add, oImage
  oView -> Add, oModel           

  oClipboard = obj_new('IDLgrClipboard',DIMENSIONS=ImageResolution)
  oClipboard-> Draw, oView
  
  Obj_Destroy, oClipboard
  Obj_Destroy, oView
  Obj_Destroy, oModel

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end

; ---------------------------------------------------------------------


; --------------------------------------- ClipCopyPlot_Plot2D_Event ---
;  Handles Copy Plot events
; ---------------------------------------------------------------------

pro ClipCopyPlot_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oWindow -> GetProperty, Dimension = ImageResolution
  temp = sState.oWindow             
  oClipboard = obj_new('IDLgrClipboard',DIMENSIONS=ImageResolution)

  sState.oWindow = oClipboard
  
  Plot2D_Redraw, sState
  
  sState.oWindow = temp 
    
  Obj_Destroy, oClipboard

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy 
end

; ---------------------------------------------------------------------

; --------------------------------- Visualize_UpdateInvColors_Event ---
;  Handles Changes to the Invert Color setting
; ---------------------------------------------------------------------

pro Plot2D_UpdateInvColors_Event, sEvent

  clWhite = [255b,255b,255b]
  clBlack = [0b,0b,0b]

  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  sState.iInvColors = 1 - Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  if (sState.iInvColors) then begin
     color_line = clBlack
     color_view = clWhite
  end else begin
     color_line = clWhite
     color_view = clBlack
  end
  
  oObjects = sState.oModelAxis -> Get(/ALL, COUNT = nObjects) 
  for i=0,nObjects-1 do $
    oObjects[i] -> SetProperty, COLOR = color_line
  
  oObjects = sState.oModelTitles -> Get(/ALL, COUNT = nObjects) 
  for i=0,nObjects-1 do $
    oObjects[i] -> SetProperty, COLOR = color_line

  oObjects = sState.oColorAxis -> Get(/ALL, COUNT = nObjects) 
  for i=0,nObjects-1 do $
    if (not obj_isa(oObjects[i],'IDLgrImage')) then $
        oObjects[i] -> SetProperty, COLOR = color_line
 
  
  
  sState.oView -> SetProperty, COLOR = color_view

  Plot2D_Redraw, sState                    
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------

; ----------------------------------------------- Tool_Plot2D_Event ---
;  Handles Changes to the selected tool
; ---------------------------------------------------------------------

pro Tool_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.iTool = Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------


; ------------------------------------- UpdateSubMenuOptions_Plot2D ---
;  Updates the options in the submenu to reflect the sState variable
; ---------------------------------------------------------------------

pro UpdateSubMenuOptions_Plot2D, sState
   
   sOnOff=['On','Off']
   case (sState.iType) of
      1: begin
          
          sStyle = ['Points',$
                    'Wire Mesh',$
                    'Filled',$
                    'Ruled XZ',$
                    'RuledYZ',$
                    'Lego',$
                    'Lego Filled']
          
          ; Update Plot Style sub-menu to reflect initial iStyle
          eventval = '|Plot|Surface|Style|'+sStyle[sState.iStyle]
          temp = Map_Menu_Choice(eventval, *(sState.pMenuItems), *(sState.pMenuButtons))

          ; Update Hidden lines sub-menu to reflect initial iHidden
          eventval = '|Plot|Surface|Hidden Line (point) Removal|'+sOnOff[1-sState.iHidden]
          temp = Map_Menu_Choice(eventval, *(sState.pMenuItems), *(sState.pMenuButtons))

          ; Update Vertex Colors sub-menu to reflect initial iVColors
          eventval = '|Plot|Surface|Vertex Colors|'+sOnOff[1-sState.iVColors]
          temp = Map_Menu_Choice(eventval, *(sState.pMenuItems), *(sState.pMenuButtons))

          ; Update Shading sub-menu to reflect initial iShading
          sShadingValues = ['Flat','Gouraud']
          eventval = '|Plot|Surface|Shading|'+sShadingValues[sState.iShading]
          temp = Map_Menu_Choice(eventval,*(sState.pMenuItems),*(sState.pMenuButtons))

          ; Update Use Bottom Color sub-menu to reflect initial iUseBottomColor
          eventval = '|Plot|Surface|Use Bottom Color|'+sOnOff[1-sState.iUseBottomColor]
          temp = Map_Menu_Choice(eventval, *(sState.pMenuItems), *(sState.pMenuButtons))
          
        end
      0:begin
          ; Update Oversample sub-menu to reflect initial iInterp
          eventval = '|Plot|Color Map|Oversample|'+sOnOff[1-sState.iInterp]
          temp = Map_Menu_Choice(eventval, *(sState.pMenuItems), *(sState.pMenuButtons))
         
        end
   else:
   endcase
end

; ---------------------------------------------------------------------

; ------------------------------------- UpdatePlotType_Plot2D_Event ---
;  Handles Changes to the Plot Type setting
; ---------------------------------------------------------------------

pro UpdatePlotType_Plot2D_Event, sEvent

  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.iType = Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  ; Clean old plot and select new sub-menu
  case (sState.iType) of
      1: begin
           Plot2D_CleanColorIndexPlot, sState
           Disable_Menu_Choice, '|Edit|Copy Image',*(sState.pMenuItems), *(sState.pMenuButtons) 
           Disable_Menu_Choice, '|Plot|Color Map', *(sState.pMenuItems), *(sState.pMenuButtons)
           Enable_Menu_Choice, '|Plot|Surface',*(sState.pMenuItems), *(sState.pMenuButtons)
           if (sState.ivcolors) then begin
               if (sState.zscale_pos eq 0) then sState.zscale_pos = 2
           end else sState.zscale_pos = 0 
         end
      0: begin
           Plot2D_CleanColorSurfacePlot, sState
           Enable_Menu_Choice, '|Edit|Copy Image', *(sState.pMenuItems), *(sState.pMenuButtons) 
           Enable_Menu_Choice, '|Plot|Color Map', *(sState.pMenuItems), *(sState.pMenuButtons)
           Disable_Menu_Choice, '|Plot|Surface', *(sState.pMenuItems), *(sState.pMenuButtons)
           if (sState.zscale_pos eq 0) then sState.zscale_pos = 1
         end
    else:
  endcase
  
  ; Update sub-menu options
  UpdateSubMenuOptions_Plot2D, sState
  
  ; Regenerate View
  Plot2D_GenerateView, sState
  
  ; Render Image
  Plot2D_Redraw, sState 
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; -------------------------------------- UpdateSPStyle_Plot2D_Event ---
;  Handles Changes to the Surface Plot style setting
; ---------------------------------------------------------------------

pro UpdateSPStyle_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iStyle = Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  sState.oSurface -> SetProperty, STYLE = sState.iStyle
  Plot2D_Redraw, sState
 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; ------------------------------------- UpdateSPHidden_Plot2D_Event ---
;  Handles Changes to the Surface Plot hidden setting
; ---------------------------------------------------------------------

pro UpdateSPHidden_Plot2D_Event, sEvent

  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iHidden = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  sState.oSurface -> SetProperty, HIDDEN_LINES = sState.iHidden
  Plot2D_Redraw, sState 
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; ---------------------------------------------------------------------

; ------------------------------------ UpdateSPShading_Plot2D_Event ---
;  Handles Changes to the Surface Plot shading setting
; ---------------------------------------------------------------------

pro UpdateSPShading_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iShading = Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  sState.oSurface -> SetProperty, SHADING = sState.iShading
  Plot2D_Redraw, sState
 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ------------------------------------ UpdateSPVColors_Plot2D_Event ---
;  Handles Changes to the Surface Plot VColors setting
; ---------------------------------------------------------------------

pro UpdateSPVColors_Plot2D_Event, sEvent

  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iVColors = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  Plot2D_VColor_Surface, sState 
  Plot2D_Redraw, sState 
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

pro UpdateSPUseBottomColors_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iUseBottomColor = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  if (sState.iUseBottomColor eq 1) then begin
   sState.oSurface -> SetProperty, BOTTOM = sState.BottomColor
  end else begin
   sState.oSurface -> SetProperty, BOTTOM = -1
  end
  
  Plot2D_Redraw, sState
 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end

; --------------------------------------- ContourColor_Plot2D_Event ---
;  Opens the Color Dialog Box
; ---------------------------------------------------------------------

pro ContourColor_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  TVLCT, reform(sState.ContourColor,1,3), 0
  local_color = pickcolor(0,Title = 'Choose Contour Color', cancel = cancel)
  if (cancel eq 0) then begin
    sState.ContourColor = local_color
    if (obj_valid(sState.oContour)) then begin
      sState.oContour -> SetProperty, COLOR = sState.ContourColor
      Plot2D_Redraw, sState
    end
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------


; ---------------------------------------------- Color_Plot2D_Event ---
;  Opens the Color Dialog Box
; ---------------------------------------------------------------------

pro Color_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  TVLCT, reform(sState.Color,1,3), 0
  local_color = pickcolor(0,Title = 'Choose Top Color', cancel = cancel)
  if (cancel eq 0) then begin
    sState.Color = local_color
    sState.oSurface -> SetProperty, COLOR = sState.Color
    Plot2D_Redraw, sState
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ---------------------------------------- BottomColor_Plot2D_Event ---
;  Opens the Bottom Color Dialog Box
; ---------------------------------------------------------------------

pro BottomColor_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  TVLCT, reform(sState.BottomColor,1,3), 0
  local_color = pickcolor(0,Title = 'Choose Bottom Color', cancel = cancel)
  if (cancel eq 0) then begin
    sState.BottomColor = local_color
    sState.oSurface -> SetProperty, Bottom = sState.BottomColor
    Plot2D_Redraw, sState
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------


; -------------------------------------------- Palette_Plot2D_Event ---
;  Opens the Palette Dialog Box
; ---------------------------------------------------------------------

pro Palette_Plot2D_Event, sEvent

  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oPalette-> GetProperty, RED_VALUES = R
  sState.oPalette-> GetProperty, GREEN_VALUES = G
  sState.oPalette-> GetProperty, BLUE_VALUES = B

  TVLCT, temporary(R), temporary(G), temporary(B)

;  print, 'calling xcolors'  
  
  XColors, NColors=256, Bottom=0, Group_Leader=sEvent.top, $
           NotifyID=[sEvent.top, sEvent.top]

;  print, 'calling widget_control'


  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

;  print, 'Returning'

end
; ---------------------------------------------------------------------

; -------------------------------------- ChangePallete_Plot2D_Event ---
;  Handles palette change events
; ---------------------------------------------------------------------

pro ChangePallete_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  sState.oPalette-> SetProperty, RED_VALUES = sEvent.R
  sState.oPalette-> SetProperty, GREEN_VALUES = sEvent.G
  sState.oPalette-> SetProperty, BLUE_VALUES = sEvent.B
  
  Plot2D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------

; -------------------------------------- ZoomReset_Plot2D_Event ---
;  Handles zoom reset events
; ---------------------------------------------------------------------

pro ZoomReset_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  s = size(*(sState.pByteData), /dimensions)

  sState.dataXrange[0] = 0
  sState.dataXrange[1] = s[0]-1
  sState.dataYrange[0] = 0
  sState.dataYrange[1] = s[1]-1
  
  ; Reset the Axis and the image
  Plot2D_UpdateAxis, sState
  
  Plot2D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end
; ---------------------------------------------------------------------

; -------------------------------------- ZoomIn_Plot2D_Event ---
;  Handles zoom in events
; ---------------------------------------------------------------------

pro ZoomIn_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  s = size(*(sState.pByteData), /dimensions)

  lx = long(double(sState.dataXrange[1]-sState.dataXrange[0])/4.)
  ly = long(double(sState.dataYrange[1]-sState.dataYrange[0])/4.)
  
  sState.dataXrange[0] = sState.dataXrange[0] + lx
  sState.dataXrange[1] = sState.dataXrange[1] - lx
  sState.dataYrange[0] = sState.dataYrange[0] + ly
  sState.dataYrange[1] = sState.dataYrange[1] - ly

  Plot2D_UpdateAxis, sState
  
  Plot2D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------

; -------------------------------------- ZoomOut_Plot2D_Event ---
;  Handles zoom out events
; ---------------------------------------------------------------------

pro ZoomOut_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  s = size(*(sState.pByteData), /dimensions)

  lx = long(double(sState.dataXrange[1]-sState.dataXrange[0])/2.)
  ly = long(double(sState.dataYrange[1]-sState.dataYrange[0])/2.)
  
  sState.dataXrange[0] = Max([0,sState.dataXrange[0] - lx])
  sState.dataXrange[1] = Min([s[0]-1,sState.dataXrange[1] + lx])
  sState.dataYrange[0] = Max([0,sState.dataYrange[0] - ly])
  sState.dataYrange[1] = Min([s[1]-1,sState.dataYrange[1] + ly])

  Plot2D_UpdateAxis, sState
  
  Plot2D_Redraw, sState                    

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
  
end

; ---------------------------------------------------------------------


; -------------------------------------- UpdOversample_Plot2D_Event ---
;  Handles update oversample events
; ---------------------------------------------------------------------

pro UpdOversample_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  if (sState.iType eq 0) then begin
    Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
    sState.iInterp = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))
    Plot2D_UpdateAxis, sState
    Plot2D_Redraw, sState                    
  end
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------- ZAxis_Plot2D_Event ---
;  Handles changes to the Z-Axis
; ---------------------------------------------------------------------

pro ZAxis_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  Autoscale = 0b
  
  zscale_pos_labels = ['(none)', 'Right', 'Bottom']
  
  data = { $
           Autoscale : 0b, $
           Logarithmic : Byte(sState.UseLogScale), $
           Minimum : sState.DataMin, $
           Maximum : sState.DataMax, $
           zscale_pos: zscale_pos_labels $
           }           
           
  labels = [ $
           'Autoscale', $
           'Use Log Scale', $
           'Minimum', $
           'Maximum', $
           'Position' $
           ]  

  extra_data = [0,0,0,0,sState.zscale_pos]

  res = InputValues( data, extra_data = extra_data, $
                     labels = labels, $
                     Title = 'Z Axis', $
                     group_leader = sEvent.top )
  
  if (res eq 1) then begin
     sState.UseLogScale = data.Logarithmic
     sState.zscale_pos = (where(data.zscale_pos[0] eq zscale_pos_labels))[0]
 
     if (data.Autoscale eq 0) then begin
        sState.DataMin = data.Minimum
        sState.DataMax = data.Maximum 
        
        if (sState.UseLogScale eq 1) then begin
          sState.DataMin = abs(sState.DataMin)
          sState.DataMax = abs(sState.DataMax)
          
          if (sState.DataMin gt sState.DataMax) then begin
            temp = sState.DataMax
            sState.DataMax = sState.DataMin
            sState.DataMin = temp
          end
        end
           
     end else begin
        if (sState.UseLogScale eq 0) then begin
           sState.DataMin = Min(*sState.pData, Max = DataMax)
           sState.DataMax = DataMax
        end else begin
          temp = AbsMin(*sState.pData, Max = Max, MINN0 = MinN0)
          print, 'Minimum value = ', temp
          sState.DataMax = Max
          sState.DataMin = MinN0
          print, 'Autoscaling to [Min,Max] =',MinN0, Max          
          if (sState.DataMax eq 0.0) then sState.DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.
          if (sState.DataMin eq 0.0) then sState.DataMin = sState.DataMax/10.0            
        end
           
     end

     case (sState.iType) of
       0:begin 
           Plot2D_UpdateZAxisColorIndexPlot,sState
           Plot2D_UpdateAxis, sState
         end
       1:Plot2D_UpdateZAxisSurfacePlot,sState
     endcase
     Plot2D_Redraw, sState 
  end
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

; ---------------------------------------------------------------------

; ----------------------------------------- UpdContour_Plot2D_Event ---
;  Updates the add contour plot setting
; ---------------------------------------------------------------------

pro UpdContour_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iAddContourPlot = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  if (sState.iAddContourPlot eq 1) then begin
    if not obj_valid(sState.oContour) then begin
      Plot2D_AddContourPlot, sState
      Plot2D_UpdateGeometryContourPlot, sState  
    end
    sState.oContour -> SetProperty, HIDE = 0
  end else begin
    if obj_valid(sState.oContour) then sState.oContour -> SetProperty, HIDE = 1
  end
  
  Plot2D_Redraw, sState
 
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy

end
; ---------------------------------------------------------------------


; ----------------------------------- RegenerateVector_Plot2D_Event ---
;  Forces Regeneration of the vector plot
; ---------------------------------------------------------------------

pro RegenerateVector_Plot2D_Event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  Plot2D_RegenVector, sState
  Plot2D_UpdateGeometryVector, sState  
  Plot2D_Redraw, sState
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; ------------------------------ UpdateAutoRegenVector_Plot2D_Event ---
;  Updates auto Regeneration of the vector plot
; ---------------------------------------------------------------------

pro UpdateAutoRegenVector_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iRegenVector = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  if (sState.iRegenVector) and (sState.iShowVector) then begin
    Plot2D_RegenVector, sState
    Plot2D_UpdateGeometryVector, sState  
    Plot2D_Redraw, sState
  end

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------


; ---------------------------------- UpdateVectorsShow_Plot2D_Event ---
;  Updates visibility of the vector plot
; ---------------------------------------------------------------------

pro UpdateVectorsShow_Plot2D_Event, sEvent
  Widget_Control, sEvent.id,  GET_UVALUE=eventUValue
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  sState.iShowVector = 1-Map_Menu_Choice(eventUValue, *(sState.pMenuItems), $
                                  *(sState.pMenuButtons))

  if (sState.iShowVector) then begin
    if (sState.iRegenVector) then begin
      Plot2D_RegenVector, sState
      Plot2D_UpdateGeometryVector, sState  
    end
    sState.oModelVector -> SetProperty, HIDE = 0
  end else sState.oModelVector -> SetProperty, HIDE = 1

  Plot2D_Redraw, sState

  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; ---------------------------------------------- Plot2D_Menu_Events ---
;  Handles menu events
; ---------------------------------------------------------------------

pro Plot2D_Menu_Events, sEvent
  
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue ; Menu events

  case eventUValue of
    ; Menu Options
    '|File|Save Plot Tiff...'		: SavePlotTIFF_Plot2D_Event, sEvent 
    '|File|Save Image Tiff...'		: SaveImageTIFF_Plot2D_Event, sEvent 
    '|File|Page Setup...'			: PageSetup_Plot2D_Event, sEvent
    '|File|Print...'				: Print_Plot2D_Event, sEvent
    '|File|Quit'				: WIDGET_CONTROL, sEvent.top, /DESTROY
    '|Edit|Copy Plot'				: ClipCopyPlot_Plot2D_Event, sEvent
    '|Edit|Copy Image'			: ClipCopyImage_Plot2D_Event, sEvent
    '|Plot|Palette...'    			: Palette_Plot2D_Event, sEvent
    '|Plot|Invert Colors|On'		: Plot2D_UpdateInvColors_Event, sEvent
    '|Plot|Invert Colors|Off'		: Plot2D_UpdateInvColors_Event, sEvent
    '|Plot|Z-Axis'				: ZAxis_Plot2D_Event, sEvent     
       
    ; Contour Plot
    '|Plot|Add Contours|On'		: UpdContour_Plot2D_Event, sEvent
    '|Plot|Add Contours|Off'		: UpdContour_Plot2D_Event, sEvent
    '|Plot|Contour Color'			: ContourColor_Plot2D_Event, sEvent
    
    ; Color Map Plot
    '|Plot|Color Map|Oversample|On' 	: UpdOversample_Plot2D_Event, sEvent
    '|Plot|Color Map|Oversample|Off'	: UpdOversample_Plot2D_Event, sEvent
    '|Plot|Color Map|Oversample'  	: Oversample_Plot2D_Event, sEvent
    '|Plot|Color Map|Zoom|In'		: ZoomIn_Plot2D_Event, sEvent
    '|Plot|Color Map|Zoom|Out'		: ZoomOut_Plot2D_Event, sEvent
    '|Plot|Color Map|Zoom|Reset'	: ZoomReset_Plot2D_Event, sEvent
    '|Plot|Color Map|Tool|X Lineout'	: Tool_Plot2D_Event, sEvent
    '|Plot|Color Map|Tool|Y Lineout'	: Tool_Plot2D_Event, sEvent
    '|Plot|Color Map|Tool|Zoom'		: Tool_Plot2D_Event, sEvent
    '|Plot|Color Map|Tool|Data Picking': Tool_Plot2D_Event, sEvent      
    
    ; Surface Plot
    '|Plot|Surface|Style|Points'		: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Style|Wire Mesh'		: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Style|Filled'		: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Style|Ruled XZ'		: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Style|Ruled YZ'		: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Style|Lego'			: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Style|Lego Filled'		: UpdateSPStyle_Plot2D_Event, sEvent
    '|Plot|Surface|Hidden Line (point) Removal|On' : UpdateSPHidden_Plot2D_Event, sEvent
    '|Plot|Surface|Hidden Line (point) Removal|Off': UpdateSPHidden_Plot2D_Event, sEvent
    '|Plot|Surface|Vertex Colors|On'		: UpdateSPVColors_Plot2D_Event, sEvent
    '|Plot|Surface|Vertex Colors|Off'		: UpdateSPVColors_Plot2D_Event, sEvent
    '|Plot|Surface|Shading|Flat'		: UpdateSPShading_Plot2D_Event, sEvent
    '|Plot|Surface|Shading|Gouraud'		: UpdateSPShading_Plot2D_Event, sEvent
    '|Plot|Surface|Color'				: Color_Plot2D_Event, sEvent
    '|Plot|Surface|Bottom Color'		: BottomColor_Plot2D_Event, sEvent
    '|Plot|Surface|Use Bottom Color|On'	: UpdateSPUseBottomColors_Plot2D_Event, sEvent
    '|Plot|Surface|Use Bottom Color|Off'	: UpdateSPUseBottomColors_Plot2D_Event, sEvent
       
    ; Vector Plots
    '|Vector|Show Vectors|On'			: UpdateVectorsShow_Plot2D_Event, sEvent
    '|Vector|Show Vectors|Off'			: UpdateVectorsShow_Plot2D_Event, sEvent
    '|Vector|Regenerate'				: RegenerateVector_Plot2D_Event, sEvent
    '|Vector|Auto Regenerate|On'		: UpdateAutoRegenVector_Plot2D_Event, sEvent
    '|Vector|Auto Regenerate|Off'		: UpdateAutoRegenVector_Plot2D_Event, sEvent
       
    ; Plot Type
    '|Plot Type|Surface Plot'	: UpdatePlotType_Plot2D_Event, sEvent
    '|Plot Type|Color Mapped'	: UpdatePlotType_Plot2D_Event, sEvent
              
    '|About|About Plot 2D'	: XDisplayFile, /MODAL, $
                                       TITLE = 'About Plot 2D', Text = $
                                       'About Plot 2D not implemented yet'     
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

pro Resize_Visualize_Event, sEvent
  ; Get sState structure from base widget
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy

  wsx =  sEvent.x - 12   
  wsy =  sEvent.y - 12 
        
  ; Resize the draw widget.
        
  sState.oWindow->SetProperty, Dimensions=[wsx, wsy]
  sState.window_size = [wsx, wsy]
  
  if (obj_valid(sState.oImage)) and (sState.iInterp) then begin
    x0 = sState.dataXrange[0]
    x1 = sState.dataXrange[1]
    y0 = sState.dataYrange[0]
    y1 = sState.dataYrange[1]
      
    dims = LonArr(2)

    sState.oWindow -> GetProperty, Units = Units
    sState.oWindow -> SetProperty, Units = 0
    sState.oWindow -> GetProperty, Dimensions = dims
    sState.oWindow -> SetProperty, Units = Units

    dims[0] = long(wsx*(sState.DataPosition[2] - sState.DataPosition[0]))
    dims[1] = long(wsy*(sState.DataPosition[3] - sState.DataPosition[1]))
            
    sState.oImage -> SetProperty, Data = Congrid((*(sState.pByteData))[x0:x1,y0:y1], $
                                                 dims[0], dims[1], /interp)
  end

  if (sState.iType eq 1) then Plot2D_UpdateZAxisSurfacePlot,sState
        
  ; Resize the fonts
  maxRES = Max(sState.window_size)
  SizeFontAxis = float(sState.FontSize*0.022*maxRES)
  sState.oFontAxis -> SetProperty, SIZE = SizeFontAxis
  SizeFontTitle = float(sState.FontSize*0.025*maxRES)
  SizeFontSubTitle = float(sState.FontSize*0.022*maxRES)
  sState.oFontTitle -> SetProperty, SIZE = SizeFontTitle
  sState.oFontSubTitle -> SetProperty, SIZE = SizeFontSubTitle

  ; Update the trackball objects location in the center of the
  ; window.
  sState.oTrack->Reset, [sEvent.x/2., sEvent.y/2.], $
          (sEvent.y/2.) < (sEvent.x/2.)
        
  ; Redisplay the graphic.
  Plot2D_Redraw, sState
        
  ;Put the info structure back.
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end
; ---------------------------------------------------------------------

; -------------------------------------------- Base_Visualize_Event ---
;  Handles base events
; ---------------------------------------------------------------------

pro Plot2D_Base_Visualize_Event, sEvent

 eventName = TAG_NAMES(sEvent, /STRUCTURE_NAME) 

 case eventName of
  'WIDGET_BASE'  : Resize_Visualize_Event, sEvent  ; Note: Only resize events are caught here
  
  'WIDGET_BUTTON': 
            
  'XCOLORS_LOAD' : ChangePallete_Plot2D_Event, sEvent
     
  'PLOT1D_CLOSE' : RemoveProfile_Plot2D_Event, sEvent

  
  else: print, 'Event Name: ',eventName
 endcase
 
                    
end

; ---------------------------------------------------------------------


pro Plot2D_cleanup, sState

     ; Destroy Models and Views         
     Obj_Destroy, sState.oView
     OBJ_DESTROY, sState.oModelTitles
     Obj_Destroy, sState.oModelAxis
     Obj_Destroy, sState.oModel
     Obj_Destroy, sState.oViewContour
     Obj_Destroy, sState.oModelContour
     Obj_Destroy, sState.oViewTrajectory
     Obj_Destroy, sState.oModelTrajectory
     Obj_Destroy, sState.oViewVector
     Obj_Destroy, sState.oModelVector

     ; Cleanup Tools Objects 
     Obj_Destroy, sState.oViewTools
     Obj_Destroy, sState.oModelTools
     Obj_Destroy, sState.oViewProfile
     Obj_Destroy, sState.oModelProfile
  
     ; Destroy remaining objects
     Obj_Destroy, sState.oContainer

     ; Free Data
     ptr_free, sState.pByteData
     ptr_free, sState.pContourLevels
     if (sState.iFreeData eq 1) then ptr_free, sState.pData
     if (sState.iFreeVData eq 1) then ptr_free, sState.pVData
     

end


; ----------------------------------------------- Visualize_Cleanup ---
;  Handles cleanup events. Called when window is closed
; ---------------------------------------------------------------------

PRO Plot2D_Visualize_Cleanup, tlb


   ; Come here when program dies. Free all created objects.

   Widget_Control, tlb, Get_UValue=sState, /No_Copy
   if N_Elements(sState) ne 0 then begin     

     plot2D_cleanup, sState

     ; Cleanup Menu Objects

     ptr_free, sState.pMenuItems
     ptr_free, sState.pMenuButtons
     
;     print, 'Cleaning up Done!'
      
   end
END

; ---------------------------------------------------------------------

Pro Plot2D, _EXTRA=extrakeys, $
                   ; Data to be plotted
                   _pData, NO_COPY = no_copy, NO_SHARE = no_share, INFO_STRUCT = sInfo, $
                   ; Data Ranges
                   ZMIN = DataMin, ZMAX = DataMax, XRANGE = xrange, YRANGE = yrange, $
                   ; Titles and labels
                   TITLE = Title1, SUBTITLE = Title2, $
                   ; Axis Data and information
                   XAXIS =  XAxisDataOrg, YAXIS = YAxisDataOrg, ZLOG = UseLogScale, $
                   XTITLE = XAxisTitle, YTITLE = YAxisTitle, ZTITLE = ZAxisTitle, $
                   XTICKFORMAT = XTickFormat, YTICKFORMAT = YTickFormat, ZTICKFORMAT = ZTickFormat, $
                   ; Plot options
                   TYPE = type, $
                   STYLE = style, HIDDEN_LINES = hidden_lines, VERT_COLORS = vert_colors, SHADING = shading, $
                   COLOR = color, BOTTOM = bottom, FONTSIZE = fontsize, INTERP = interp, $
                   ZSCALE_POS = zscale_pos, $
                   ; Color Table Options
                   CT = ColorTable, BOTTOM_CT = BottomStretch, TOP_CT = TopStretch, GAMMA_CT = GammaCorrection, $
                   ; Additional contour plot
                   ADDCONTOUR = AddContourPlot, CONTOURLEVELS = ContourLevels, N_LEVELS = n_levels, $
                   ; Vector Plot
                   VECTOR = Vector, LREF = lref, $
                   ; Trajectories
                   TRAJVERT = TrajVert, TRAJPOINTS = TrajPoints, TRAJCOLOR = TrajColor, $
                   TRAJTHICK = TrajThick, TRAJSTYLE = TrajStyle, $
                   ; Window Options
                   WINDOWTITLE = WindowTitle, RES = ImageResolution, INVCOLORS = iInvColors, $
                   ; Output Options
                   IMAGE = imageout, FILEOUT = imagefile, DG = direct_graphics

                   
 if (N_Elements(_pData) ne 0) then begin
   
   T_POINTER = 10l
   datatype = size(_pData, /type)
   pData = ptr_new()
   pVData = ptr_new()
   freedata = 0
   freevdata = 0
   
   if (not Keyword_Set(Vector)) then begin ; Scalar Plot
     if (datatype eq T_POINTER) then begin       ; Pointer
       n = N_Elements(_pData)
       
       if (n ne 1) then begin
         res = Error_Message('pData must be a scalar pointer for scalar plots')
         return
       end
       not_pointer = 0b
       if not ptr_valid(_pData) then begin
         res = Error_Message('Invalid Pointer, pData')
         return
       end
       datatype = size(*_pData, /type)
     end else not_pointer =1b
     if (datatype lt 1) or (datatype gt 5) then begin
       res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                           'Precision Floating Point')
       return
     end
     if (not_pointer eq 1) then begin
       pData = ptr_new(_pData, no_copy = no_copy)
       freedata = 1b 
     end else begin 
       if (Keyword_Set(no_share)) then begin
         pData = ptr_new((*_pData), /no_copy)
         ptr_free, _pData
         freedata = 1b
       end else begin
         pData = _pData
         freedata = 0b
       end
     end
     S = Size((*pData), /n_dimensions)
     if (S ne 2) then begin
        res = Error_Message("Data must be a 2D array")
        if (freedata) then ptr_free, pData
        return
     end
     s = Size((*pData), /dimensions) 
     NX = S[0]
     NY = S[1]

     iAddVector = 0b

   end else begin                        ; Vector Plot
   
     if (N_Elements(_pData) ne 2) then begin
       res = Error_Message('pData must be a two element array of pointers for VECTOR plots')
       return
     end

     if (not ptr_valid(_pData[0])) or (not ptr_valid(_pData[1])) then begin
       res = Error_Message('Invalid pointer, pData')
       return
     end
  
     type0 = size(*_pData[0], /type)
     type1 = size(*_pData[1], /type)

     if (type1 ne type0) then begin
       res = Error_Message('pData must point to two fields of the same numeric type for VECTOR plots')
       return
     end

     if (type1 lt 1) or (type1 gt 5) then begin
        res = Error_Message('Data must be of type Byte, Integer, Longword Integer, Floating Point or Double '+$
                            'Precision Floating Point')
        return
     end

     s0 = size(*_pData[0], /n_dimensions) 
     s1 = size(*_pData[1], /n_dimensions)
    
     if ((s0 ne 2) or (s1 ne 2)) then begin
       res = Error_Message('Both datasets must be two dimensional for VECTOR plots')
       return
     end  

     s = size(*_pData[0], /dimensions)
     nx = s[0]
     ny = s[1]  

     if ((nx lt 3) or (ny lt 3)) then begin
       res = Error_Message('Data must be at least 3x3 for VECTOR plots')
       return
     end  

     s = size(*_pData[1], /dimensions)
     nx1 = s[0]
     ny1 = s[1]  
  
     if ((nx ne nx1) or (ny ne ny1)) then begin
       res = Error_Message('Both datasets must have the same dimensions for VECTOR plots')
       return
     end
      
     pVData = ptrarr(2)

     if (Keyword_Set(no_share)) then begin
        pVData[0] = ptr_new((*_pData[0]), /no_copy)
        pVData[1] = ptr_new((*_pData[1]), /no_copy)
        ptr_free, _pData
        freeVdata = 1b
     end else begin
        pVData[0] = _pData[0]
        pVData[1] = _pData[1]
        freeVdata = 0b
     end
     
     pData = ptr_new(sqrt((*pVData[0])^2+(*pVData[1])^2), /no_copy)
     freedata = 1b
     iAddVector = 1b
   end

; ##############################################################################################################


   ; TRAJVERT
   ;
   ; Adds a trajectory to the plot passing trough the points specified

   If N_elements(TrajVert) eq 0 then begin
     iAddTrajectory = 0b
     fTrajVert = 0b
   end else begin
     iAddTrajectory = 1b
     fTrajVert = TrajVert
   end

   ; TRAJPOINTS
   ;
   ; Conections for the trajectory (optional)

   If N_Elements(TrajPoints) eq 0 then lTrajPoints = 0b $
   else lTrajPoints = TrajPoints 
   
   ; TRAJCOLOR
   ;
   ; Color for the trajectory 
   
   if N_Elements(TrajColor) eq 0 then TrajColor = [0b,0b,0b] $
   else begin
     s = size(TrajColor)
     if (s[0] ne 1) or (s[1] ne 3) then begin
       res = Error_Message('TRAJCOLOR must be in the form [R,G,B] in byte values')
       if (freedata) then ptr_free, pData
       if (freeVdata) then ptr_free, pVData
       return
     end 
   end
   
   ; TRAJTHICK 
   ; 
   ; Thickness of the trajectory lines
    
   If N_Elements(TrajThick) eq 0 then TrajThick = 1l

   ; TRAJSTYLE 
   ; 
   ; Thickness of the trajectory lines
    
   If N_Elements(TrajStyle) eq 0 then TrajStyle = 0l
   
   ; INVCOLORS
   ;
   ; Invert the colors for the background and the axis and labels. Default is white on black
   
   if N_Elements(iInvColors) eq 0 then begin
     iInvColors = 0
   end else begin
     if (iInvColors ne 0) then iInvColors = 1
   end    
   
   ; FONTSIZE
   ;
   ; Font size for titles and axis labels as a fraction of the reference size. Default is 1.0

   if N_Elements(fontsize) eq 0 then fontsize = 1.0


   ; WINDOWTITLE
   ;
   ; The title for the plot window
   
   if (N_Elements(WindowTitle) eq 0) then WindowTitle = 'Plot 2D'

   ; ADDCONTOUR
   ;
   ; Adds a Contour plot in top of a color density plot
   ;
   ; Set this keyword to add a contour plot on top of a color density plot. This keyword only works with
   ; color density plots

   if N_Elements(AddContourPlot) eq 0 then AddContourPlot = 0

   ; FONT
   ;
   ; Font selection
   ;
   ; Set this parameter to -1 (default), 0 or 1 to use Hershey, Hardware or true Type fonts

   if N_Elements(FontType) eq 0 then FontType = 1

   if (FontType eq 1) then Charsize = 2.0 else Charsize = 1.0

   ; [XYZ]TITLE
   ;
   ; X,Y and Z axis titles
   ;
   ; Set these parameters to the string you want to use as axis title

   if N_Elements(XAxisTitle) eq 0 then XAxisTitle = ''
   if N_Elements(YAxisTitle) eq 0 then YAxisTitle = ''
   if N_Elements(ZAxisTitle) eq 0 then ZAxisTitle = ''

   ; [XYZ]TICKFORMAT
   ;
   ; X,Y and Z axis tick format
   ;
   ; Set these parameters to the string to be used to format the axis tick mark (IDL Standard)

   if N_Elements(XTickFormat) eq 0 then XTickFormat = ''
   if N_Elements(YTickFormat) eq 0 then YTickFormat = ''
   if N_Elements(ZTickFormat) eq 0 then ZTickFormat = ''

   ; XAXIS
   ;
   ; X Axis Data
   ;
   ; Use this parameter to provide the X Axis Data. The default is just the data col number

   if N_Elements(XAxisDataOrg) eq 0 then Begin
         XAxisData = FIndGen(NX)
   end else XAxisData = XAxisDataOrg

   ; YAXIS
   ;
   ; Y Axis Data
   ;
   ; Use this parameter to provide the X Axis Data. The default is just the data row number

   if N_Elements(YAxisDataOrg) eq 0 then Begin
         YAxisData = FIndGen(NY)
   end else YAxisData = YAxisDataOrg
 
   ; TYPE
   ;
   ;

   if (N_Elements(type) ne 0) then iType = type else iType = 0				

   ; RES
   ;
   ; The resolution for the image. Default is [512,384]
   
   if (not Keyword_Set(direct_graphics)) then begin
   
     if (N_Elements(ImageResolution) eq 0) then begin
       case (iType) of
         0:ImageResolution = [512,384]
         1:ImageResolution = [512,512]
       endcase 
     end else begin
       s = size(ImageResolution)
       if (s[0] ne 1) or (s[1] ne 2) then begin
         temp = Error_Message('RES must be a 1D 2 element array with the dimension of the image to display')
         if (freedata) then ptr_free, pData
         if (freeVdata) then ptr_free, pVData
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
 
   ; [XY]RANGE
   ;
   ; XY Range for the plot

   xmin = min(xaxisdata, max = xmax)
   ymin = min(yaxisdata, max = ymax)
   
   if (N_Elements(xrange) eq 0) then begin
     xrange = [xmin,xmax]
   end else begin
     if (xrange[1] le xrange[0]) then begin
       temp = Error_Message('Invalid XRANGE.')
       if (freedata) then ptr_free, pData
       if (freeVdata) then ptr_free, pVData
       return
     end      
     if (xrange[0] lt xmin) then xrange[0] = xmin
     if (xrange[1] gt xmax) then xrange[1] = xmax
   end

   if (N_Elements(yrange) eq 0) then begin
     yrange = [ymin,ymax]
   end else begin
     if (yrange[1] le yrange[0]) then begin
       temp = Error_Message('Invalid XRANGE.')
       if (freedata) then ptr_free, pData
       if (freeVdata) then ptr_free, pVData
       return
     end      
     if (yrange[0] lt ymin) then yrange[0] = ymin
     if (yrange[1] gt ymax) then yrange[1] = ymax
   end
   
   xrange = float(xrange)
   yrange = float(yrange)
   
   dataXrange = long((NX-1)*(xrange-xmin)/(xmax-xmin))
   dataYrange = long((NY-1)*(yrange-ymin)/(ymax-ymin))   
   
   xrange = XAxisData[dataXrange]
   yrange = YAxisData[dataYrange]

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

   ; Default Color Table

   if N_Elements(ColorTable) eq 0 then begin
     ColorTable = 13
   end

   ; INFO_STRUCT
   ;
   ; Info Structure for saving lineouts

   if N_Elements(sInfo) eq 0 then begin
           sInfo = { time:0.0, $
                     timestep:0, $
                     name:Title1, $
                     format:'', $
                     label:'', $
                     units:'', $
                     x1name:XAxisTitle, $
                     x1format:'', $
                     x1label:XAxisTitle, $
                     x1units:'', $
                     x2name:YAxisTitle, $
                     x2format:'', $
                     x2label:YAxisTitle, $
                     x2units:'' }
   end else begin
     def_Info_tag_names = strupcase(['time', 'timestep', 'name', 'format', 'label', 'units', $
                        'x1name', 'x1format', 'x1label', 'x1units', $
                        'x2name', 'x2format', 'x2label', 'x2units' ])
                        
     Info_tag_names = tag_names(sInfo)
     num_tags = N_Elements(Info_tag_names)
     
     if num_tags ne N_Elements( def_Info_tag_names) then begin
       res = Error_Message('Invalid number of tags in INFO_STRUCT')
       return
     end 
    
     for i=0, num_tags-1 do begin
       idx = where(def_Info_tag_names eq Info_tag_names[i], count) 
       if (count ne 1) then begin
         res = Error_Message('Invalid tags or tags missing in INFO_STRUCT')
         return
       end    
     end
   end


   ; ZLOG
   ;
   ; Uses a log scale for the Z axis
   ;
   ; Set this keyword to use a log scale for the Z Axis. The default is to use a linear scale.

   if N_Elements(UseLogScale) eq 0 then UseLogScale = 0

   ; ZMIN
   ;
   ; Minimum value of z to be plotted
   ;
   ; Use this parameter to set the minimum value of Z to be plotted. The default is to use an autoscale value

   ; ZMAX
   ;
   ; Maximum value of z to be plotted
   ;
   ; Use this parameter to set the maximum value of Z to be plotted. The default is to use an autoscale value

   ; Z Autoscaling

   if (UseLogScale eq 0) then begin
      ; Unless specified, autoscale DataMin

      if N_Elements(DataMin) eq 0 then begin
         DataMin = Min(*pData)
      end

      ; Unless specified, autoscale DataMax

      if N_Elements(DataMax) eq 0 then begin
         DataMax = Max(*pData)
      end

   endif else begin
     ; For Log scale use abs(Data)
     Data = abs(*pData)

     if N_Elements(DataMax) eq 0 then DataMax = Max(Data)

     if (DataMax eq 0.0) then DataMax = 1.0       ; If Data consists of 0 values do DataMax = 1.

     if N_Elements(DataMin) eq 0 then begin       ; Autoscales min for the log plot
         DataMin = Min(Data)
         if (DataMin eq 0.0) then begin
             idx = Where(Data gt 0.0, count)
             if (count gt 0) then begin
               DataMin = Min(Data[idx])
;               logScale = DataMax/DataMin
;               DataMin = DataMax/(2.0*logScale)
             end else DataMin = DataMax / 10.0
         end
     end
     Data = 0
   end

  
   ; Compensates for 0 range

   if (DataMin eq DataMax) then begin
     print, 'WARNING, Plot2D, zero-lenght range, compensating...'
     DataMax=DataMax+0.5
     DataMin=DataMin-0.5
   end

   ; Swap Ranges if DataMin > DataMax
   
   if (DataMin gt DataMax) then begin
     print, 'WARNING, Plot2D, DataMin > DataMax, swapping values...'
     temp = DataMax
     DataMax = DataMin
     DataMin = temp
   end 

   
   if Keyword_Set(Vector) then begin
     ; LREF
     
     if N_Elements(lref) eq 0 then lref = Max(*pData)
   end

   if N_Elements(lref) eq 0 then lref = 0b

   ; ADDCONTOUR
   ;
   ; Adds a Contour plot in top of a color density plot
   ;
   ; Set this keyword to add a contour plot on top of a color density plot. This keyword only works with
   ; color density plots

   if Keyword_Set(AddContourPlot) then begin
      iAddContourPlot = 1
   end else begin
      iAddContourPlot = 0
   end

   if N_Elements(N_Levels) eq 0 then N_Levels = 7

   ; CONTOURLEVELS
   
   If N_Elements(ContourLevels) eq 0 then begin
     if (UseLogScale eq 0) then begin
       fContourLevels = (findgen(N_Levels)+1.0)*(DataMax-DataMin)/float(n_levels+1)+ DataMin
     end else begin
       fContourLevels = (findgen(n_levels)+1.0)*(Alog10(DataMax/DataMin))/float(n_levels+1) + Alog10(DataMin)
       fContourLevels = 10.0 ^ fContourLevels
     end
   end else begin
     fContourLevels = ContourLevels
   end

   ; Plot Options


   if (N_Elements(style) ne 0) then iStyle = style else iStyle = 2			; STYLE
   iHidden = Keyword_Set(hidden_lines)								; HIDDEN_LINES
   iVcolors = Keyword_Set(vert_colors)								; VERT_COLORS
   if (N_Elements(shading) ne 0) then iShading = shading else iShading = 1		; SHADING
   iInterp = Keyword_Set(Interp)									; INTERP
   
   if (N_Elements(color) eq 0) then Color = [255b,0b,0b]					; COLOR
   
   if (N_Elements(Bottom) eq 0) then begin								; BOTTOM
     BottomColor = [0b,0b,255b]
     iUseBottomColor = 0
   end else begin
     BottomColor= Bottom
     iUseBottomColor = 1  
   end

   contourcolor = [0,0,0]
   
   ; ZSCALE_POS
   
   if (N_Elements(zscale_pos) eq 0) then begin
     case (iType) of
       1: zscale_pos = iVColors?2:0 ; if vcolors on do right side scale, else no scale
       0: zscale_pos = 1            ; rigth side scale
     endcase
   end else begin
     zscale_pos = zscale_pos[0]
     if (zscale_pos lt 0) or (zscale_pos gt 2) then begin
       res = Error_Message('ZSCALE_POS must be 0,1 or 2')
       return
     end
   end
   
   ;----------------------------- Show Widget --------------------------------------
   
   if (Arg_Present(imageout) or $
       N_Elements(imagefile) ne 0 or $
       Keyword_Set(Direct_Graphics)) then show_widget = 0b $
   else show_widget = 1b
   
   ;----------------------------- Container ----------------------------------------
 
   oContainer = OBJ_NEW('IDLgrContainer')
   
   ;------------------------------ Palettes ----------------------------------------

   oPalette = OBJ_NEW('IDLgrPalette')
;   Init_Palette, oPalette, ColorTable, BOTTOM_STRETCH = BottomStretch, $
;       TOP_STRETCH = TopStretch, GAMMA_CORRECTION = GammaCorrection 
;oPalette=OBJ_NEW('IDLgrPalette',$
;BOTTOM_STRETCHSet=BottomStretch , GAMMASet=GammaCorrection,$
; TOP_STRETCHSet=TopStretch)
oPalette -> LoadCT, ColorTable

   oContainer -> Add, oPalette

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

   zAxis = Obj_New('IDLgrAxis', 1, TICKFORMAT = ZTickFormat)
   zcAxis = Obj_New('IDLgrAxis', 1, TICKFORMAT = ZTickFormat)
   
   zcAxisOp = OBJ_NEW('IDLgrAxis',1, /notext)

   zLabel = OBJ_NEW('IDLgrText', ZAxisTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   zLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   zcAxis -> SetProperty, TITLE = zLabel
   oContainer -> Add, zLabel
  
   zLabel = OBJ_NEW('IDLgrText', ZAxisTitle, /ENABLE_FORMATTING, FONT = oFontAxis)
   zLabel-> SetProperty, RECOMPUTE_DIMENSIONS = 2
   zAxis -> SetProperty, TITLE = zLabel
   oContainer -> Add, zLabel

   zcAxis -> GetProperty, TICKTEXT = zAxistickLabels
   zAxisTickLabels -> SetProperty, RECOMPUTE_DIMENSIONS = 2
   zAxisTickLabels -> SetProperty, FONT = oFontAxis

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

   ; Create the Trackball
   oTrack = OBJ_NEW('TrackBall', [xdim/2.,ydim/2.], ydim/2. < xdim/2.)
   oContainer -> ADD, oTrack

   ; Create the tools objects
   
   oModelProfile = Obj_New('IDLgrModel')
   oViewProfile = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0] , $
                        /Transparent )
   oViewProfile -> Add, oModelProfile
   
   
   oModelTools = OBJ_NEW('IDLgrModel')
   oZoomBox = OBJ_NEW('IDLgrPolyline', HIDE = 1, THICK = 2, LINESTYLE = 2)
   oModelTools -> Add, oZoomBox

   oViewTools = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0], $
                        /Transparent )
   oViewTools -> Add, oModelTools
   
   ;--------------------------- Contour ----------------------------------------

   ; Create the contour model and view
    
   oModelContour = OBJ_NEW('IDLgrModel')
   oViewContour = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0], $
                          /Transparent)
   oViewContour -> SetProperty,  DIMENSIONS = [0.64, .7], LOCATION = [.15,.15] , UNITS = 3
   oViewContour -> Add, oModelContour
   
   ;--------------------------- Vector Field -----------------------------------

   oModelVector = OBJ_NEW('IDLgrModel')
   oViewVector = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0], $
                          /Transparent)
   oViewVector -> SetProperty,  DIMENSIONS = [0.64, .7], LOCATION = [.15,.15] , UNITS = 3
   oViewVector -> Add, oModelVector

   ;--------------------------- Trajectory -------------------------------------

   ; Create the contour model and view
    
   oModelTrajectory = OBJ_NEW('IDLgrModel')
   oViewTrajectory = OBJ_NEW('IDLgrView', VIEW = [0,0,1.,1.], COLOR = [0,0,0], $
                          /Transparent)
   oViewTrajectory -> SetProperty,  DIMENSIONS = [0.64, .7], LOCATION = [.15,.15] , UNITS = 3
   oViewTrajectory -> Add, oModelTrajectory


   ;------------------------ Create the Widget ---------------------------------

   if (show_widget eq 1) then begin 

   ; Create Widget
   
   wBase = Widget_Base(TITLE = WindowTitle, /TLB_Size_Events, APP_MBAR = menuBase, $
                           XPAD = 0, YPAD = 0, /Column)
   
   ; Create the Draw Widget
          
   wDraw = Widget_Draw(wBase, XSIZE = xdim, YSIZE = ydim, $
                       Graphics_Level = 2, /Button_Events, $
                       /Expose_Events, Retain = 0, $
                       EVENT_PRO = 'Plot2D_Draw_Visualize_Event', FRAME = 1)

   ; Create the menu
  
   MenuItemsFile = [ $
             '1File', $
                '0Save Plot Tiff...', $
                '0Save Image Tiff...', $
                '8Page Setup...',$
                '0Print...',$
                'AQuit',$
              '1Edit',$
                '0Copy Plot', $
                '2Copy Image']
                
   
   MenuItemsPlotCM = [ $
                '1Oversample',$
                   '4On','2Off', $ 
                '1Zoom', $
                   '0In','0Out','2Reset', $
                'BTool', $
                   '4Zoom','0X Lineout','0Y Lineout','2Data Picking' ]

   MenuItemsPlotSPStyle = [$
                '1Style',$
                   '4Points',$
                   '0Wire Mesh',$
                   '0Filled',$
                   '0Ruled XZ',$
                   '0Ruled YZ',$
                   '0Lego',$
                   '2Lego Filled']
   
   MenuItemsPlotSP = [ $
                MenuItemsPlotSPStyle,$
                '9Hidden Line (point) Removal',$
                   '4On','2Off',$
                '1Shading',$
                   '4Flat',$
                   '2Gouraud',$
                '9Vertex Colors',$
                   '4On', $
                   '2Off',$
                '0Color',$
                '0Bottom Color',$
                '3Use Bottom Color',$
                   '4On', '2Off' ]
   
   MenuItemsPlot = [ $
              '1Plot',$
                '0Z-Axis',$
                '0Palette...',$
                '9Color Map', $
                   MenuItemsPlotCM, $
                '1Surface',$
                   MenuItemsPlotSP, $
                '9Add Contours',$
                   '4On',$
                   '2Off',$
                '0Contour Levels...', $
                '0Contour Color',$
                'BInvert Colors', $
                   '4On', '2Off'  $
                 ]
   
   MenuItemsVector = [ $
             '1Vector', $
                '1Show Vectors', $
                   '4On','2Off', $
                '8Regenerate', $
                '3Auto Regenerate',$
                   '4On','2Off' $
                   ]
   
   MenuItemsPlotType = [ $
             '1Plot Type', $
                   '4Color Mapped','2Surface Plot']
   
   MenuItemsAbout = [ $
             '1About', $
                '2About Plot 2D' $
              ]
   
   if Keyword_Set(Vector) then begin  
     MenuItems = [MenuItemsFile, $
                MenuItemsPlot, $
                MenuItemsVector, $
                MenuItemsPlotType, $
                MenuItemsAbout]              
   end else begin
     MenuItems = [MenuItemsFile, $
                MenuItemsPlot, $
                MenuItemsPlotType, $
                MenuItemsAbout]              
   end

   ; Create Menu

   Create_Menu, MenuItems, MenuButtons, menuBase, $
                event_pro = 'Plot2D_Menu_Events'

   ; Create the printer object

   oPrinter = OBJ_NEW('IDLgrPrinter')
   if (oPrinter ne Obj_New()) then begin
      oContainer -> ADD, oPrinter
   end else begin
      Disable_Menu_Choice, '|File|Print...', MenuItems, MenuButtons 
      Disable_Menu_Choice, '|File|Page Setup...', MenuItems, MenuButtons 
   end

   ; Update Plot Type sub-menu to reflect initial iType
   eventval = '|'+STRMID(MenuItemsPlotType[0],1,100)+'|'+STRMID(MenuItemsPlotType[iType+1],1,100)
   temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)

   ; Update Contour sub-menu to reflect initial iAddContourPlot 
   sOnOff=['On','Off']
   eventval = '|Plot|Add Contours|'+sOnOff[1-iAddContourPlot]
   temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)

   ; Update Invert Colors sub-menu to reflect initial iInvColors 
   eventval = '|Plot|Invert Colors|'+sOnOff[1-iInvColors]
   temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)

   if Keyword_Set(Vector) then begin
     eventval = '|Vector|Show Vectors|On'
     temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)

     eventval = '|Vector|Auto Regenerate|Off'
     temp = Map_Menu_Choice(eventval, MenuItems, MenuButtons)
   end

   ; Realize the widget
   Widget_Control, wBase, /REALIZE

   ; Disable Plot menu -> this must be done after the widget is realized
   ; or else all submenu items will also be disabled
   
   case (iType) of
     1: begin
           Disable_Menu_Choice, '|Plot|Color Map', MenuItems, MenuButtons 
           Disable_Menu_Choice, '|Edit|Copy Image', MenuItems, MenuButtons 
        end
     0: Disable_Menu_Choice, '|Plot|Surface', MenuItems, MenuButtons 
   endcase   

       
   ; Create the window object
   Widget_Control, wDraw, Get_Value = oWindow
  ; oWindow -> SetCurrentCursor, 'CROSSHAIR'
     
   sState = { $
              ; Plot Data
              pData            :pData, $				; Data for plotting
              pVData           :pVData, $				; Data for plotting Vector Field
              iFreeData        :freedata, $			; Free the data when widget closes
              iFreeVData       :freeVdata, $			; Free the vector data when widget closes
              XAxisData        :XAxisData, $			; Axis Data for X
              YAxisData        :YAxisData, $			; Axis Data for Y
              XTitle           :XAxisTitle, $			; Axis Title
              YTitle           :YAxisTitle, $			; Axis Title
              ZTitle           :ZAxisTitle, $			; Axis Title

              ; Plot Options
              iInvColors       :iInvColors, $			; Inverted Colors
              oPalette         :oPalette, $			; Palette object for the plots
              iType            :iType, $				; Plot Type
              DataMin          :DataMin, $				; Max value for plot range
              DataMax          :DataMax, $				; Min value for plot range
              xrange           :xrange, $				; x range of values to display
              yrange           :yrange, $				; y range of values to display
              dataXrange       :dataXrange, $			; x range of cells to display
              dataYrange       :dataYrange, $			; y range of cells to display
              UseLogScale      :UseLogScale, $			; Use Log Scale for the plot 
              zscale_pos       :zscale_pos, $			; Position for zscale              
              
              ; Plot Titles
              oTitle           :oTitle, $				; Plot Title
              Title1           :Title1, $
              oSubTitle        :oSubTitle, $			; Plot Sub-Title
              Title2           :Title2, $
              
              ; Plot Axis
              xAxis            :xAxis, $				; Axis object for X 
              yAxis            :yAxis, $				; Axis object for Y 
              zAxis            :zAxis, $				; Axis object for Z (spatial)

              xAxisOp          :xAxisOp, $				; Oposing Axis object for X 
              yAxisOp          :yAxisOp, $				; Oposing Axis object for Y

              oColorAxis       :Obj_New(), $			; Color Axis Model  
              zcAxis           :zcAxis, $				; Axis object for Z (color bar)
              zcAxisOp         :zcAxisOp, $			; Oposing Axis object for Z (color bar)
              ocBar            :Obj_New(), $			; Color Bar object
              ocBoxBar1        :Obj_New(), $			; 
              ocBoxBar2        :Obj_New(), $			;

              
              ; ColorMap Plot related variables
              pByteData        :ptr_new(BytArr(NX,NY)),$	; Byte scaled data (for zooming)
              iInterp          :iInterp, $				; Interpolate Image
              oImage           :Obj_New(), $			; Color-mapped Image object (for zooming)
                            
              ; Surface Plot related variables
              iStyle           :iStyle, $				; Plot style
              iHidden          :iHidden, $				; Hidden line removal
              iVColors         :iVColors, $			; Use vert colors
              iShading         :iShading, $			; Shading (flat or gouraud)
              Color            :Color, $				; Top surface color
              BottomColor      :BottomColor, $			; Bottom surface color
              iUseBottomColor  :iUseBottomColor, $		; Use Bottom Surface color
              oSurface         :Obj_New(), $			; Surface Object 	
              oLight1          :Obj_New(), $			; Light 1
              oLight2          :Obj_New(), $			; Light 2
              oBoxBar1         :Obj_New(), $			; 
              oBoxBar2         :Obj_New(), $			;
              oBoxBar3         :Obj_New(), $			; 
              oBoxBar4         :Obj_New(), $			;
              ViewPlaneRect    :FltArr(4), $ 
              
              ; Trajectories related variables
              
              oTrajectory      :Obj_New(), $			; IDLgrPolyline Trajectory Object
              oModelTrajectory :oModelTrajectory, $		; IDLgrModel with the Trajectory
              oViewTrajectory  :oViewTrajectory, $		; IDLgrView with the Trajectory
              iAddTrajectory   :iAddTrajectory, $		;
              TrajVert         :fTrajVert, $			;
              TrajPoints       :lTrajPoints, $			;
              TrajColor        :TrajColor, $			;
              TrajThick        :TrajThick, $			;
              TrajStyle        :TrajStyle, $			;
              
              ; Additional contour plot related variables
              oContour         :Obj_New(), $			; Contour plot object
              ContourColor     :ContourColor, $			; Color For Contour
              iAddContourPlot  :iAddContourPlot, $		; Use Contour Plot
              pContourLevels   :ptr_new(fContourLevels), $	; Contour Levels
              oModelContour    :oModelContour, $		; IDLgrModel with the contour plot
              oViewContour     :oViewContour, $			; IDLgrView with the contour plot

              ; Vector plot related variables
              oVector          :Obj_New(), $			; Vector object
              lref             :lref, $				; Reference length for vectors
              iAddVector       :iAddVector, $			; Add vectors
              oModelVector     :oModelVector, $			; IDLgrModel with the vector plot
              oViewVector      :oViewVector, $			; IDLgrView with the vector plot
              iShowVector      :1b, $					; Show the vectors
              iRegenVector     :0b, $					; Auto Regen vectors on zoom
                 
              ; Tools related variables
              iTool            :0b, $					; Active Tool
              btndown          :0b,$					; button 1 down
              window_size      :[xdim,ydim], $			; window size
              oViewTools       :oViewTools, $			; View object for tools
              oModelTools      :oModelTools, $			; Model for tools 
              oViewProfile     :oViewProfile, $			; View object for tools
              oModelProfile    :oModelProfile, $		; Model to hold Profile lines
              profilenum       :0L, $					; Profile number
              DataPosition     :FltArr(4), $			; Screen position of data region
              Tool_Pos0        :[0.,0.], $				; position of initial button press
              oZoomBox         :oZoomBox, $			; Zoom Box object
              oTrack           :oTrack, $				; TrackBall object
              
              ; Widget variables
              wDraw            :wDraw,$				; Draw widget
              oWindow          :oWindow,$				; Window Object
              oView            :oView,$				; View Object                   
              oContainer       :oContainer, $			; Container for object destruction
              oPrinter         :oPrinter, $			; Printer Object
              pMenuItems       :ptr_new(MenuItems),$		; Menu Items
              pMenuButtons     :ptr_new(MenuButtons),$	; Menu Buttons
              
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


   UpdateSubMenuOptions_Plot2D, sState
   Plot2D_GenerateView, sState

   ; Save state to widget
   Widget_Control, wBase, SET_UVALUE=sState, /No_Copy
   
   XManager, 'Plot2D_Visualize', Event_Handler='Plot2D_Base_Visualize_event', $
                              Cleanup ='Plot2D_Visualize_Cleanup', $
                              wBase, /NO_BLOCK

   end else begin
      
   ;------------------------ Create the non-Widget Plot -------------------------------
   
   sState = { $
              ; Plot Data
              pData            :pData, $				; Data for plotting
              pVData           :pVData, $				; Data for plotting Vector Field
              iFreeData        :freedata, $			; Free the data when widget closes
              iFreeVData       :freeVdata, $			; Free the vector data when widget closes
              XAxisData        :XAxisData, $			; Axis Data for X
              YAxisData        :YAxisData, $			; Axis Data for Y

              ; Plot Options
              iInvColors       :iInvColors, $			; Inverted Colors
              oPalette         :oPalette, $			; Palette object for the plots
              iType            :iType, $				; Plot Type
              DataMin          :DataMin, $				; Max value for plot range
              DataMax          :DataMax, $				; Min value for plot range
              xrange           :xrange, $				; x range of values to display
              yrange           :yrange, $				; y range of values to display
              dataXrange       :dataXrange, $			; x range of cells to display
              dataYrange       :dataYrange, $			; y range of cells to display
              UseLogScale      :UseLogScale, $			; Use Log Scale for the plot
              zscale_pos       :zscale_pos, $			; Position for zscale              
              
              ; Plot Axis
              xAxis            :xAxis, $				; Axis object for X 
              yAxis            :yAxis, $				; Axis object for Y 
              zAxis            :zAxis, $				; Axis object for Z (spatial)

              xAxisOp          :xAxisOp, $				; Oposing Axis object for X 
              yAxisOp          :yAxisOp, $				; Oposing Axis object for Y

              oColorAxis       :Obj_New(), $			; Color Axis Model  
              zcAxis           :zcAxis, $				; Axis object for Z (color bar)
              zcAxisOp         :zcAxisOp, $			; Oposing Axis object for Z (color bar)
              ocBar            :Obj_New(), $			; Color Bar object
              ocBoxBar1        :Obj_New(), $			; 
              ocBoxBar2        :Obj_New(), $			;
              
              ; Plot Titles
              oTitle           :oTitle, $				; Plot Title
              Title1           :Title1, $
              oSubTitle        :oSubTitle, $			; Plot Sub-Title
              Title2           :Title2, $
              
              ; ColorMap Plot related variables
              pByteData        :ptr_new(BytArr(NX,NY)),$	; Byte scaled data (for zooming)
              iInterp          :iInterp, $				; Interpolate Image
              oImage           :Obj_New(), $			; Color-mapped Image object (for zooming)
                             
              ; Surface Plot related variables
              iStyle           :iStyle, $				; Plot style
              iHidden          :iHidden, $				; Hidden line removal
              iVColors         :iVColors, $			; Use vert colors
              iShading         :iShading, $			; Shading (flat or gouraud)
              Color            :Color, $				; Top surface color
              BottomColor      :BottomColor, $			; Bottom surface color
              iUseBottomColor  :iUseBottomColor, $		; Use Bottom Surface color
              oSurface         :Obj_New(), $			; Surface Object 	
              oLight1          :Obj_New(), $			; Light 1
              oLight2          :Obj_New(), $			; Light 2
              oBoxBar1         :Obj_New(), $			; 
              oBoxBar2         :Obj_New(), $			;
              oBoxBar3         :Obj_New(), $			; 
              oBoxBar4         :Obj_New(), $			;
              ViewPlaneRect    :FltArr(4), $ 
              
              ; Trajectories related variables
              
              oTrajectory      :Obj_New(), $			; IDLgrPolyline Trajectory Object
              oModelTrajectory :oModelTrajectory, $		; IDLgrModel with the Trajectory
              oViewTrajectory  :oViewTrajectory, $		; IDLgrView with the Trajectory
              iAddTrajectory   :iAddTrajectory, $		;
              TrajVert         :fTrajVert, $			;
              TrajPoints       :lTrajPoints, $			;
              TrajColor        :TrajColor, $			;
              TrajThick        :TrajThick, $			;
              TrajStyle        :TrajStyle, $			;
              
              ; Additional contour plot related variables
              oContour         :Obj_New(), $			; Contour plot object
              ContourColor     :ContourColor, $			; Color For Contour
              iAddContourPlot  :iAddContourPlot, $		; Use Contour Plot
              pContourLevels   :ptr_new(fContourLevels), $	; Contour Levels
              oModelContour    :oModelContour, $		; IDLgrModel with the contour plot
              oViewContour     :oViewContour, $			; IDLgrView with the contour plot

              ; Vector plot related variables
              oVector          :Obj_New(), $			; Vector object
              lref             :lref, $				; Reference length for vectors
              iAddVector       :iAddVector, $			; Add vectors
              oModelVector     :oModelVector, $			; IDLgrModel with the vector plot
              oViewVector      :oViewVector, $			; IDLgrView with the vector plot
              iShowVector      :1b, $					; Show the vectors
              iRegenVector     :0b, $					; Auto Regen vectors on zoom
                               
              ; Models
              oModelAxis       :oModelAxis,$			; Axis Models 
              oModelTitles     :oModelTitles, $			; Axis Models 
              oModel           :oModel, $				; Plot Model  
              
              ; Font Variables
              FontSize         :FontSize, $			; Font size
              oFontTitle       :oFontTitle, $			; Title Font object
              oFontSubTitle    :oFontSubTitle, $		; Sub-Title Font object
              oFontAxis        :oFontAxis, $			; Axis Font object
              
              oWindow          :obj_new(), $			; Window Object
              oView            :oView, $				; View Object                   
              oContainer       :oContainer, $			; Container for object destruction
              DataPosition     :FltArr(4), $			; Screen position of data region
              oViewTools       :oViewTools, $			; View object for tools
              oViewProfile     :oViewProfile, $			; View object for tools
              oModelProfile    :oModelProfile, $		; Model to hold Profile lines
              oModelTools      :oModelTools $

            }

     oBuffer = OBJ_NEW('IDLgrBuffer', DIMENSIONS = [xdim,ydim])
     
     sState.oWindow = oBuffer
     Plot2D_GenerateView, sState
     Plot2D_Redraw, sState
     
     ; Get Image Data
     
     myimage = oBuffer -> Read()
     myimage -> GetProperty, DATA = imageout
      
     ; Save TIFF file

     if (N_Elements(imagefile) ne 0) then begin
       imageout = reverse(imageout,3)
       WRITE_TIFF, imagefile, imageout, 1
       imageout = reverse(imageout,3)
     end

     ; Direct Graphics output
     if (keyword_set(direct_graphics)) then begin

       temp = !P.multi
       
       tvimage, imageout

;       !P.multi = temp

       ; Now you need to set all the !X and !Y variables to work with OPLOT
       ; and similar functions

       position = sState.DataPosition
       
       if (total(!p.multi) ne 0) then begin
         position[0] = !X.REGION[0] + (!X.REGION[1]-!X.REGION[0])*position[0]
         position[1] = !Y.REGION[0] + (!Y.REGION[1]-!Y.REGION[0])*position[1]
         position[2] = !X.REGION[0] + (!X.REGION[1]-!X.REGION[0])*position[2]
         position[3] = !Y.REGION[0] + (!Y.REGION[1]-!Y.REGION[0])*position[3]
       end        

       sState.xAxis -> GetProperty, RANGE = xrange 
       sState.yAxis -> GetProperty, RANGE = yrange 
       Plot, Findgen(11), XStyle=5, YStyle=5, /noerase, $
            xrange = xrange, yrange = yrange, /NoData, $
            POSITION = position
       
     end
     
     OBJ_DESTROY, myimage
     OBJ_DESTROY, oBuffer
     plot2D_cleanup, sState
   end



  End

End
