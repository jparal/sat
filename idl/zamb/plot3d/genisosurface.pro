;+
; NAME:
;    GENISOSURFACE
;
; PURPOSE:
;
;    The purpose of this routine is to add to an the isosurfaces of the supplied data to an IDLgrModel
;    object. This routine uses the IDL routine SHADE_VOLUME for generating the isosurfaces.
;
; AUTHOR:
;
;   Ricardo Fonseca
;   E-mail: zamb@physics.ucla.edu
;
; CATEGORY:
;
;    Visualization.
;
; CALLING SEQUENCE:
;
;    GENISOSURFACE, pData, oModelIsoSurf
;
; INPUTS:
;
;    pData: This is a pointer to a 3 Dimensional float array containing the data to be visualized
;
;    oModelIsoSurf: This is a reference to the IDLgrModel object to which the isosurfaces will be added
;
; KEYWORDS:
;
;    BOTTOM: Set this keyword to a vector containing the bottom colors for each isosurface, with the 
;       same structure as COLOR. The alpha channel is ignored but must be specified. Note that the
;       bottom color of a surface is only active is the corresponfing top color is opaque (i.e. 
;       alpha = 255b). If this is not the case the bottom color is ignored quietly.  See the LOW 
;       keyword for details on how IDL distinguishes between the top side and bottom side (inner and
;       outer) of a surface. This vector must have as many colors as there are isolevels. if not 
;       specified the routine will use BOTTOM = COLOR/2 making the bottom colors 50% darker than the
;       top colors (See also COLOR and LOW)
;
;    COLOR: Set this keyword to a vector containing the colors for each isosurface. Each color is
;       specified as a 4 element byte vector in the form [R,G,B,alpha] with R = red color component,
;       G = green color component, B = blue color component and alpha = opacity. Setting alpha to 0
;       would make an isosurface invisible and setting it to 255b makes the isosurface opaque. In the
;       later case the surface will also have a bottom color. See the LOW keyword for details on how
;       IDL distinguishes between the top (outer) side and bottom (inner) side of a surface. This 
;       vector must have as many colors as there are isolevels. The default colors are the following:
;        i)   if all of the values have the same sign the colors will be [0,0,220,255], [255,255,0,64], 
;           and [0,255,0,32] for the first three levels and [255b, 255b, 255b, 64b] for the remaining
;           levels
;        ii)  else the colors will be [0,0,255,255],[255,0,0,255],[0,255,255,64],[255,255,0,64] and
;           [255b, 255b, 255b, 64b] for the remaining levels 
;       (See also BOTTOM and LOW)     
;
;    CONTAINER: Set this keyword to an object reference to an IDL_Container (or descendent) object
;       to hold the IDLgrImage objects used for transparancies for later destruction. Note: This is
;       the only way of later destroying these objects. If CONTAINER is not set the reference to the
;       IDLgrImage objects created will be lost.   
;
;    D2BOTTOM: Same as BOTTOM for the second dataset. If DATA2 is present and this keyword is not
;       specified the routine will use D2BOTTOM = D2COLOR/2. (See also DATA2 and BOTTOM)
;
;    D2COLOR: Same as COLOR for the second dataset. If DATA2 is present and this keyword is not specified
;       the routine will use the following default values:
;        i)   
;        ii)  
;       If DATA2 is not present this keyword has no effect and is ignored quietly. (See also DATA2 and 
;       COLOR)
;    
;    D2LOW: Same as LOW for the second dataset. If DATA2 is present, this keyword is not specified, and
;       the number of D2ISOLEVELS is the same as the number of ISOLEVELS the routine will use the values
;       specified in LOW. If DATA2 is present, this keyword is not specified and the number of D2ISOLEVELS
;       isn't the same as the number of ISOLEVELS the routine will set the values of D2LOW automatically
;       using the same rule as for LOW.  Finally, if DATA2 is not present this keyword has no effect and
;       is ignored quietly. (See also DATA2 and LOW)
; 
;    D2ISOLEVELS: Same as ISOLEVELS for the second dataset. If DATA2 is present and this keyword is 
;       not specified the routine will use the values specified in ISOLEVELS. If DATA2 is not present
;       this keyword has no effect and is ignored quietly. Note that each level for the second dataset
;       is drawn immediatly after the corresponding level for the first dataset, which is relevant for
;       the use of transparencies. The order for drawing 3 levels for the first dataset and 2 for the
;       second would be: (1st level, 1st dataset),(1st level, 2nd dataset),(2nd level, 1nd dataset),
;       (2nd level, 2nd dataset),(3rd level, 1st dataset). (See also DATA2 and ISOLEVELS)
;
;    DATA2: Set this keyword to a pointer to a second 3D float array containing data to be visualized. 
;       This array must have the same dimensions as *pData. (See also pData)
;
;    DATARANGE: Set this keyword to a 2 element vector containing the range of values to use
;       for scaling the default levels for the isosurfaces. If not specified the routine will set
;       the values to one of the following:
;        i)   if all of the values have the same sign DATARANGE is set to [Min(*pData), Max(*pData)]
;        ii)  else DATARANGE is set to [-a,a] with a = Max(abs(*pData))
;        If the ISOLEVELS keyword is set, this keyword has no effect and is ignored quietly.
;       (See also ISOLEVELS)
;
;    ISOLEVELS: Set this keyword to a vector containing the values for the isosurfaces, in 
;       units of the the data supplied. If not specified the routine will automatically select
;       a set of isolevels scaled to DATARANGE according to the following: 
;        i)   if all of the data is ge 0 the levels are set to [0.75,0.5,0.25]
;        ii)  if all of the data is le 0 the levels are set to [0.25,0.5,0.75]
;        iii) else values are set to ([-0.5,0.5,-0.25,0.25] + 1.0) / 2.0
;       (See also DATARANGE)
; 
;    LOW: Set this keyword to a byte vector or scalar containing the rules for defining the isosurface
;       normal direction. If LOW is a scalar the same value is used for all isosurfaces, otherwise for 
;       each isosurface the value of the corresponding LOW element controls the position of the bottom
;       (inner) surface. if LOW is 0 then the bottom (inner) surface is on the side with higher data
;       values; if LOW is 1 then the bottom (inner) surface in on the side with lower data values. The
;       default values for LOW are:
;        i)  if all of the ISOLEVELS are le 0 then LOW = 0
;        ii) else LOW = 1         
;       If the ISOLEVELS is not set the LOW keyword is quietly ignored and its valu will be set to one
;       of the following:
;        i)   if all of the data is ge 0 then LOW = 1
;        ii)  if all of the data is le 0 then LOW = 0
;        iii) else LOW = [0,1,0,1]
;       (See also, ISOLEVELS, COLOR, BOTTOM and the IDL routine SHADE_VOLUME)
;
;    RANGES: Set this keyword to a vector containing the subranges of data to be considered for generating
;       the surface. Each range is an array (2,3) in the form [[x0,x1],[y0,y1],[z0,z1]], where the values
;       are in the same units as specified on the (XYZ) axis keyword (real units)
;        
;
;    (XYZ)AXIS: Set this keyword to a vector containing the (xyz) axis data for the spatial positioning
;       of the isosurfaces generated. If not supplied the routine will assume evenly spaced points from 
;       -1.0 to 1.0. This vector must have the same number of elements as the corresponding dimension 
;       in (*pData)
;
; OUTPUTS:
;
;    The IDLgrPolygon models created are added to the oModelIsoSurface IDLgrModel object. If any transparent
;    surfaces are created their references are added to the IDLgrContainer object specified in CONTAINER.
;
; RESTRICTIONS:
;
;    There's a strange limitation in the IDL 3D renderer which causes transparent objects to be opaque
;    to other objects that are added later to the IDLgrModel. This means that the user should be carefull
;    in the other he supplies the levels for the isosurfaces; the innermost levels should be supplied first
;    or else won't show behind the outermost levels. For a single dataset with all values with the same 
;    it is sufficient to sort the isosurface levels properly. For oscillating fields obeying the above rule 
;    (e.g. ISOLEVELS = [-1,1,-0.5,0.5]) usually gives satisfactory results but the problem remains (so you 
;    won't see the -0.5 isosurface behind the 0.5 isosurface). As for the case with two different datasets
;    see the D2ISOLEVELS for details on the order that the surfaces for the two datasets are drawn.
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;
;    Written by: Ricardo Fonseca, 31 Mar 2000.
;    Added auto isolevels capability, changed default colors to accomodate for oscillating
;    fields, extended the default LOW values, corrected the RANGES behaviour, zamb, 14 Sep 2000
;    Added specific UVALUES to the objects generated for use with the VISUALIZE routine, 21 Sep 2000
;-
;###########################################################################

;**********************************************************************
;********************************************** IsoSurface Routines ***
;**********************************************************************


pro GenIsoSurface_Add_Poly, oModelIsoSurf, vert, poly, $
              minpos, deltapos, $
              COLOR = SurfColor, BOTTOM = SurfBottomColor, $
              CONTAINER = oContainer, UVALUE = uvalue

  S = Size(poly)
  if (S[0] ne 0) then begin ; If any polygons to draw
       If N_Elements(SurfColor) eq 0 then SurfColor = [255b,255b,255b,255b]
       If N_Elements(SurfBottomColor) eq 0 then SurfBottomColor = [0b,0b,0b,0b]
       
       vert[0,*] = minpos[0] + vert[0,*]*deltapos[0]   
       vert[1,*] = minpos[1] + vert[1,*]*deltapos[1]   
       vert[2,*] = minpos[2] + vert[2,*]*deltapos[2]   
       
       if (SurfColor[3] eq 255b) then begin  ; Opaque IsoSurface
   
         oPolygonIsoSurf = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1,$
                                    COLOR = SurfColor, BOTTOM = SurfBottomColor, reject = 0)
       end else begin                        ; Transparent IsoSurface
         alphaimgsurf = BytArr(4, 16, 16)
         alphaimgsurf[0,*,*] = 255b
         alphaimgsurf[1,*,*] = 255b
         alphaimgsurf[2,*,*] = 255b  
         alphaimgsurf[3,*,*] = SurfColor[3]  

         oimgTranspSurf =  OBJ_NEW('IDLgrImage', alphaimgsurf)  

         oPolygonIsoSurf = OBJ_NEW('IDLgrPolygon',vert, POLYGON = poly, SHADING = 1, reject = 0, $
                                    COLOR = SurfColor, $
                                    Texture_Map = oimgTranspSurf )
         if (N_Elements(oContainer) ne 0) then oContainer -> Add, oimgTranspSurf
       end 
       
       if (N_Elements(uvalue) ne 0) then oPolygonIsoSurf-> SetProperty, UVALUE = uvalue
       oModelIsoSurf -> ADD, oPolygonIsoSurf

  end else begin
    print, 'GenIsoSurface, no polygons to add!'
  end

end



;---------------------------------------------------- GenIsoSurface ---
; Generates the IsoSurface model from the data in parameter 
; Data[NX,NY,NZ], using the isovalues specified in the isolevels param.
; Note that the IsoLevels are in absolute (not relative) values.
; outputs the result to the parameter oModelIsoSurf
;----------------------------------------------------------------------

pro GenIsoSurface, pData, oModelIsoSurf, ISOLEVELS = IsoLevels, COLOR = Colors, BOTTOM = BottomColors, $
                         LOW = lows, D2LOW = lows2, D2ISOLEVELS = isolevels2, $
                         XAXIS =  XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                         DATA2 = pData2, D2COLOR = Colors2, D2BOTTOM = BottomColors2, $
                         RANGES = DataRanges, $
                         ; Range for setting the isolevels automatically
                         DATARANGE = ValueRange, $
                         ; Container for destroying non gaphic models later
                         CONTAINER = oContainer		
                         						

;   on_error, 2

   ; test validity of Data
    
   S = Size(*pData)
   
   If (S[0] ne 3) then begin
     print, 'IsoSurface, pData must be a pointer to 3 Dimensional Data...'
     return
   end

   NX = S[1]
   NY = S[2]
   NZ = S[3]

   
   ; test validity of data2

   if (N_Elements(pData2) ne 0) then begin
     s = size(*pData2)
     
     if (s[0] ne 3) then begin
       print, 'GenIsoSurface, Data2 must be 3 Dimensional'
       return
     end
   
     if (s[1] ne nx) or (s[2] ne ny) or (s[3] ne nz) then begin
       print, 'GenIsoSurface, Data must have the same dimensions as data'
       return
     end
     
     UseData2 = 1
   end else begin
     UseData2 = 0
   end
   
   def_color_type = 0b

   help, isolevels

   if (N_Elements(IsoLevels) eq 0) then begin
     if N_Elements(ValueRange) eq 0 then begin
       min = Min(*pData, max = max)
       ValueRange = [min, max]
     end
     
     if (ValueRange[0]*ValueRange[1] lt 0.0) then begin
       ; Oscillating data
       new_range = max(abs(valuerange))
       ValueRange = [ - new_range, new_range ]
       isolevels = ([-0.5, 0.5, -0.25, 0.25 ] + 1.0)/2.0
       lows = [0,1,0,1]
       def_color_type = 1b
     end else begin
       ; Non oscillating data
       if (ValueRange[1] gt 0) then begin
          isolevels = [0.75, 0.5, 0.25]   
          lows = [1,1,1]
       end else begin
          isolevels = [0.25, 0.5, 0.75]   
          lows = [0,0,0]
       endelse
       def_color_type = 0b
     end
     isolevels = valuerange[0] + (valuerange[1] - valuerange[0])*isolevels
   end

   help, isolevels
   print, isolevels

   ; Test Validity of IsoLevels

   S = Size(isolevels)
   if (S[0] eq 0) then begin
     isoval = isolevels
     isolevels = FltArr(1)
     isolevels[0] = isoval
     S = Size(isolevels)
   end else if (S[0] ne 1) then begin
     print, 'IsoSurface, IsoLevels must be a scalar or a one dimensional array...'
     return
   end
   NumIsoLevels = S[1]
   NumIsoLevels2 = 0

   ; Isolevels for second data set
   
   If N_Elements(IsoLevels2) eq 0 then begin
     isolevels2 = isolevels
     NumIsoLevels2 = NumIsoLevels
   end else begin
     s = Size(isolevels2, /N_DIMENSIONS)
     if ((s ne 0) and (s ne 1)) then begin
       print, 'IsoSurface, IsoLevels2 must be a scalar or a one dimensional array...'
       return
     end
     
     s = Size(isolevels2, /DIMENSIONS)
     NumIsoLevels2 = s[0]     
   end      


   ; Isosurfaces top colors
       
   if (N_elements(Colors) eq 0) then begin
        if (def_color_type eq 0) then begin			; Normal colors
           num_colors = 3
           DefColors = [ [000b,000b,220b,255b], $ 		; 86% Blue, opaque
                         [255b,255b,000b,064b], $		; 100% yellow, 50% opaque
                         [000b,255b,000b,064b]]			; 100% green, 25% opaque
                         
        end else begin							; Oscillating field colors
           num_colors = 4
           DefColors = [ [000b,000b,255b,255b], $ 		; 100% Blue, opaque
                         [255b,000b,000b,255b], $		; 100% Red, opaque
                         [000b,255b,255b,064b], $		; 100% Cyan, 50% opaque
                         [255b,255b,000b,064b] ]		; 100% yellow, 50% opaque
        end
        
        
        Colors = BytArr(4, NumIsoLevels)
        for i = 0, NumIsoLevels - 1 do begin
          if (i le num_colors) then Colors[*,i] = DefColors[*,i] $
          else Colors[*,i] = [255b, 255b, 255b, 64b] 
        end
   end else begin
        S = Size(Colors)
        if (NumIsoLevels eq 1) then begin
          if ((S[0] ne 1) or (S[1] ne 4)) then begin
          print, 'IsoSurface, COLOR must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
          end
        end else if ((S[0] ne 2) or (S[1] ne 4) or (S[2] ne NumIsoLevels)) then begin
          print, 'IsoSurface, COLOR must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. Note that alpha '
          print, 'equal to 255b means a opaque surface'
          return
        end   
   end

   ; Isosurface bottom colors

   if (N_elements(BottomColors) eq 0) then begin
        BottomColors = Colors/2
        BottomColors[3,*] = 255b
   end else begin
        S = Size(BottomColors)
        if (NumIsoLevels eq 1) then begin
          if ((S[0] ne 1) or (S[1] ne 4)) then begin
          print, 'IsoSurface, BOTTOM must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
          end
        end else if ((S[0] ne 2) or (S[1] ne 4) or (S[2] ne NumIsoLevels)) then begin
          print, 'IsoSurface, BOTTOM must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
        end   
   end

       
   if (UseData2 eq 1) then begin
     ; Data2 Isosurfaces top colors
   
     if (N_elements(Colors2) eq 0) then begin
        DefColors2 = [[220b,000b,000b,255b], $
                      [000b,255b,255b,128b], $
                      [000b,255b,000b,064b]]
        Colors2 = BytArr(4, NumIsoLevels2)
        for i = 0, NumIsoLevels2 - 1 do begin
          if (i le 2) then Colors2[*,i] = DefColors2[*,i] $
          else Colors2[*,i] = [255b, 255b, 255b, 64b] 
        end
     end else begin
        S = Size(Colors2)
        if (NumIsoLevels2 eq 1) then begin
          if ((S[0] ne 1) or (S[1] ne 4)) then begin
          print, 'IsoSurface, D2COLOR must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels2]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
          end
        end else if ((S[0] ne 2) or (S[1] ne 4) or (S[2] ne NumIsoLevels2)) then begin
          print, 'IsoSurface, D2COLOR must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels2]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. Note that alpha '
          print, 'equal to 255b means a opaque surface'
          return
        end   
     end

   ; Data2 Isosurface bottom colors

     if (N_elements(BottomColors2) eq 0) then begin
        BottomColors2 = Colors2/2
        BottomColors2[3,*] = 255b
     end else begin
        S = Size(BottomColors2)
        if (NumIsoLevels2 eq 1) then begin
          if ((S[0] ne 1) or (S[1] ne 4)) then begin
          print, 'IsoSurface, D2BOTTOM must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels2]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
          end
        end else if ((S[0] ne 2) or (S[1] ne 4) or (S[2] ne NumIsoLevels2)) then begin
          print, 'IsoSurface, D2BOTTOM must be an array in the form [Color1, Color2, ..., ColorNumIsoLevels2]'
          print, 'and each color must be in the form [R,G,B,alpha], with byte values. The alpha channel can'
          print, 'have any value'
          return
        end   
     end

   end
   
   ; Normal direction
   
   if N_Elements(lows) eq 0 then begin
     lows = BytArr(NumIsoLevels)
     if (max(isolevels) le 0.0) then lows = lows+1b
   end else begin
     S = Size(lows)
     if (S[0] eq 0) then begin
       lowval = lows
       lows = BytArr(NumIsoLevels) + lowval
     end else if ((S[0] ne 1) or (S[1] ne NumIsoLevels)) then begin
       print, 'IsoSurface, lows must be either a scalar or a 1D array with one element for each isosurface'
       return 
     end  
   end     

   ; Normal direction 2
   
   if N_Elements(lows2) eq 0 then begin
     If (NumIsoLevels eq NumIsoLevels2) then lows2 = lows $
     else lows2 = BytArr(NumIsoLevels2)
   end else begin
     S = Size(lows2)
     if (S[0] eq 0) then begin
       lowval = lows2
       lows = BytArr(NumIsoLevels2) + lowval
     end else if ((S[0] ne 1) or (S[1] ne NumIsoLevels2)) then begin
       print, 'IsoSurface, d2lows must be either a scalar or a 1D array with one element for each isosurface'
       return 
     end  
   end     

   ; Axis Information
    
   if N_Elements(XAxisData) eq 0 then begin
        XAxisData = -1. + IndGen(NX)*2.0/(NX-1)
   end else begin
       S = Size(XAxisData)
       if ((S[0] ne 1) or (S[1] ne NX)) then begin
         print, 'IsoSurface, XAXIS must be a 1D array with NX elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(YAxisData) eq 0 then begin
        YAxisData = -1. + IndGen(NY)*2.0/(NY-1)
   end else begin
       S = Size(YAxisData)
       if ((S[0] ne 1) or (S[1] ne NY)) then begin
         print, 'IsoSurface, YAXIS must be a 1D array with NY elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end 

   if N_Elements(ZAxisData) eq 0 then begin
        ZAxisData = -1. + IndGen(NZ)*2.0/(NZ-1)
   end else begin
       S = Size(ZAxisData)
       if ((S[0] ne 1) or (S[1] ne NZ)) then begin
         print, 'IsoSurface, ZAXIS must be a 1D array with NZ elements.'
         print, '(Data is an array with [NX,NY,NZ] dimensions)'
         return
       end
   end     

   ; Spatial extents
       
   XMin = XAxisData[0]
   XMax = XAxisData[NX-1]
   XRange = XMax - XMin

   YMin = YAxisData[0]
   YMax = YAxisData[NY-1]
   YRange = YMax - YMin

   ZMin = ZAxisData[0]
   ZMax = ZAxisData[NZ-1]
   ZRange = ZMax - ZMin

   ; Surface ranges

   If (N_Elements(DataRanges) eq 0) then begin
     nranges = 1
     DataRanges = [[Xmin,Xmax], [Ymin,Ymax],[Zmin,Zmax]]
     DataRanges = Reform(DataRanges,2,3,1, /overwrite)
   end else begin
     s = size(DataRanges)
     if (s[1] ne 2) or (s[2] ne 3) then begin
            print, 'GenIsoSurface, RANGES must be an array in the form 
            print, '[[[Xmin1, Xmax1],[Ymin1, Ymax1],[Zmin1, Zmax1]],...,[[XminN, XmaxN],[YminN, YmaxN],[ZminN, ZmaxN]]]'
            return
     end
     
     case (s[0]) of
     2: begin
          nranges = 1
          DataRanges = Reform(DataRanges,2,3,1, /overwrite)
        end
     3: begin
          nranges = s[3]
        end
     else: begin
            print, 'GenIsoSurface, RANGES must be an array in the form 
            print, '[[[Xmin1, Xmax1],[Ymin1, Ymax1],[Zmin1, Zmax1]],...,[[XminN, XmaxN],[YminN, YmaxN],[ZminN, ZmaxN]]]'
            return
        end
     endcase
       
   end


   ; Isosurfaces

   minpos = [Xmin, Ymin, Zmin]
   deltapos = [XRange/float(NX-1),YRange/float(NY-1),ZRange/float(NZ-1)]

   xr = LonArr(2)
   yr = LonArr(2)
   zr = LonArr(2)
   
   lim = Max([NumIsoLevels,NumIsoLevels2])
       
   for i=0, lim-1 do begin
     if (i lt NumIsoLevels) then begin
     isoval = isolevels[i]
     low = lows[i]    
     print, 'Generating Isosurface, isovalue = ', isoval
     for j=0,nranges-1 do begin
       xr[*] = ((NX-1)*(reform(DataRanges[*,0,j]) - Xmin)/Xrange)
       if (xr[0] lt 0) then xr[0] = 0
       if (xr[0] gt NX-1) then xr[0] = NX-1
       if (xr[1] lt 0) then xr[1] = 0
       if (xr[1] gt NX-1) then xr[1] = NX-1
       
       yr[*] = ((NY-1)*(reform(DataRanges[*,1,j]) - Ymin)/Yrange)
       if (yr[0] lt 0) then yr[0] = 0
       if (yr[0] gt NY-1) then yr[0] = NY-1
       if (yr[1] lt 0) then yr[1] = 0
       if (yr[1] gt NY-1) then yr[1] = NY-1

       zr[*] = ((NZ-1)*(reform(DataRanges[*,2,j]) - Zmin)/Zrange)
       if (zr[0] lt 0) then zr[0] = 0
       if (zr[0] gt NZ-1) then zr[0] = NZ-1
       if (zr[1] lt 0) then zr[1] = 0
       if (zr[1] gt NZ-1) then zr[1] = NZ-1

       ; Working implementation (memory inneficient)     

;       Shade_Volume, (*pData)[xr[0]:xr[1],yr[0]:yr[1],zr[0]:zr[1]] , isoval, vert, poly, LOW = low               
;       if (N_Elements(vert) ne 0) then begin
;         vert[0,*] = xr[0] + vert[0,*]   
;         vert[1,*] = yr[0] + vert[1,*]   
;         vert[2,*] = zr[0] + vert[2,*]   
;       end
         
       ; Reference Manual Compliant Implementation
       
       data = temporary(*pdata)
       vert = 0b
       poly = 0b
       Shade_Volume, data , isoval, vert, poly, LOW = low ;, XRANGE = xr, YRANGE = yr, ZRANGE = zr                
       pdata = ptr_new(data, /no_copy)
       
       name = 'Level     = '+ strtrim(string(isoval))
                                
       GenIsoSurface_Add_Poly, oModelIsoSurf, vert, poly, $
                                minpos, deltapos, $
               COLOR = Reform(Colors[*,i]), BOTTOM = Reform(BottomColors[*,i]), $
               CONTAINER = oContainer, UVALUE = name
       
       vert = 0
       poly = 0

       print, 'done' 
     end
     end     
     ; Data2

     help, usedata2
     help, NumIsoLevels2

     if ((UseData2 gt 0) and (i lt NumIsoLevels2)) then begin
       isoval = isolevels2[i]

       print, 'Generating Isosurface for Data 2, isovalue = ', isoval

       for j=0,nranges-1 do begin
         xr[*] = ((NX-1)*(reform(DataRanges[*,0,j]) - Xmin)/Xrange)
         if (xr[0] lt 0) then xr[0] = 0
         if (xr[0] gt NX-1) then xr[0] = NX-1
         if (xr[1] lt 0) then xr[1] = 0
         if (xr[1] gt NX-1) then xr[1] = NX-1
       
         yr[*] = ((NY-1)*(reform(DataRanges[*,1,j]) - Ymin)/Yrange)
         if (yr[0] lt 0) then yr[0] = 0
         if (yr[0] gt NY-1) then yr[0] = NY-1
         if (yr[1] lt 0) then yr[1] = 0
         if (yr[1] gt NY-1) then yr[1] = NY-1

         zr[*] = ((NZ-1)*(reform(DataRanges[*,2,j]) - Zmin)/Zrange)
         if (zr[0] lt 0) then zr[0] = 0
         if (zr[0] gt NZ-1) then zr[0] = NZ-1
         if (zr[1] lt 0) then zr[1] = 0
         if (zr[1] gt NZ-1) then zr[1] = NZ-1

         ; Working implementation (memory inneficient)     

;         Shade_Volume, (*pData2)[xr[0]:xr[1],yr[0]:yr[1],zr[0]:zr[1]] , isoval, vert, poly, LOW = low               
;         if (N_Elements(vert) ne 0) then begin
;           vert[0,*] = xr[0] + temporary(vert[0,*])   
;           vert[1,*] = yr[0] + temporary(vert[1,*])   
;           vert[2,*] = zr[0] + temporary(vert[2,*])   
;         end
         
         ; Reference Manual Compliant Implementation 

         Shade_Volume, *pData2, isoval, vert, poly, LOW = low ;, $
             ; XRANGE = xr, YRANGE = yr, ZRANGE = zr                

         name = 'Level (2) = '+ strtrim(string(isoval))
                         
         GenIsoSurface_Add_Poly, oModelIsoSurf, vert, poly, $
                                  minpos, deltapos, $
                 COLOR = Reform(Colors2[*,i]), BOTTOM = Reform(BottomColors2[*,i]), $
                 CONTAINER = oContainer
       
         vert = 0
         poly = 0

         print, 'done' 
       end

     end
     
   end


end

; ---------------------------------------------------------------------
