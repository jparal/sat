; ##########################################################################
;
;
; CreateLegend method

pro z_grLegend::CreateLegend

  ; Clear old elements
    
  if (self.pLabel ne ptr_new()) then begin
    for i=0, n_elements(*self.pLabel)-1 do begin
      self.oModel -> Remove, (*self.pLabel)[i] 
      obj_destroy, (*self.pLabel)[i]
    end
    ptr_free, self.pLabel
  end
    
  if (self.pSymbol ne ptr_new()) then begin
    for i=0, n_elements(*self.pSymbol)-1 do obj_destroy, (*self.pSymbol)[i]
    ptr_free, self.pSymbol
  end

  if (self.pGlyph ne ptr_new()) then begin
    for i=0, n_elements(*self.pGlyph)-1 do begin
      self.oModel -> Remove, (*self.pGlyph)[i]
      obj_destroy, (*self.pGlyph)[i]
    end
    ptr_free, self.pGlyph
  end
    
  numTags = n_elements(*self.pItem_Labels)
  
  
  ; If not enough elements in the following variables cycle trough them
  numTagsls = n_elements(*self.pItem_Linestyle)
  numTagslt = n_elements(*self.pItem_LineThick)
  numTagslc = n_elements(*self.pItem_LineColor)/3
  numTagsss = n_elements(*self.pItem_SymbolStyle)
  numTagssc = n_elements(*self.pItem_SymbolColor)/3
    
  self.pLabel = ptr_new(objarr(numTags))
  self.pSymbol = ptr_new(objarr(numTags))
  self.pGlyph = ptr_new(objarr(numTags))
  
  
  for i=0, numTags-1 do begin
    ; Create Labels
    (*self.pLabel)[i] = obj_new('IDLgrText', (*self.pItem_Labels)[i], FONT = self.oFont, $
                          COLOR = self.TextColor)
                          
    ; Create Symbols
    (*self.pSymbol)[i] = obj_new('IDLgrSymbol', (*self.pItem_SymbolStyle)[i mod numTagsss], $
                          COLOR = (*self.pItem_SymbolColor)[*,i mod numTagssc])
                              
    ; Create Glyphs
    (*self.pGlyph)[i] = obj_new('IDLgrPolyline', [[-1,0],[0,0],[1,0]], $
                          LINESTYLE = (*self.pItem_LineStyle)[i mod numTagsls], $
                          COLOR = (*self.pItem_LineColor)[*,i mod numTagslc], $
                          THICK = (*self.pItem_LineThick)[i mod numTagslt], $
                          SYMBOL = [self.oVoidSymbol,(*self.pSymbol)[i],self.oVoidSymbol]  )
    
    self.oModel -> Add, (*self.pLabel)[i]
    self.oModel -> Add, (*self.pGlyph)[i]
    
  end  
  
end

; ##########################################################################
;
;
; Constructor

function z_grLegend::Init, $
             aItemLabels, $
             ALIGNMENT = h_align, $
             BORDER_GAP = Border_Gap, $
             FILL_COLOR = Fill_Color, $
             FONT = Font, $
             GAP = Gap, $
             GLYPH_WIDTH = glyphWidth, $
             HIDE = Hide, $
             LABELS = Item_Labels, $
             LINECOLOR = Item_LineColor, $
             LINESTYLE = Item_Linestyle, $
             LINETHICK = Item_LineThick, $
             LOCATION = Location, $ 
             SYMBOLCOLOR = Item_SymbolColor, $
             SYMBOLSTYLE = Item_SymbolStyle, $
             NAME = Name, $
             OUTLINE_COLOR = Outline_Color, $
             OUTLINE_THICK = Outline_Thick, $
             SHOW_OUTLINE = Show_Outline, $
             SHOW_FILL = Show_Fill, $
             TEXTCOLOR = TextColor, $
             TITLE = Title, $
             UVALUE = Uvalue,$
             VERTICAL_ALIGNMENT = v_align, $
             XCOORD_CONV = Xcoord_Conv, $
             YCOORD_CONV = Ycoord_Conv, $
             ZCOORD_CONV = Zcoord_Conv, $
             _EXTRA = extra_keys, NO_COPY = no_copy

  ; Call parent object's constructor 
  if (self->IDLgrModel::Init(_EXTRA=extra_keys) ne 1) then return, 0
    
  self->IDLgrModel::SetProperty, /SELECT_TARGET
  if (Keyword_Set(Hide)) then self->IDLgrModel::SetProperty, Hide=1

  ; Process Item Labels
  if (n_elements(aItemLabels) le 0) then $
      aItemLabels = ''

  numTags = n_elements(Item_Labels)
  if (numTags le 0) then begin
      Item_Labels = aItemLabels
      numTags = n_elements(aItemLabels)
  endif

  ; Horizontal Alignment
  if (n_elements(h_align) eq 0) then h_align = 0.0
 
  ; Border Gap
  if (n_elements(Border_Gap) eq 0) then Border_Gap = 0.5

  ; Glyph width
  if (n_elements(glyphWidth) eq 0) then glyphWidth = 0.8

  ; Fill Color
  if (n_elements(Fill_Color) eq 0) then Fill_Color = [255,255,255]

  ; Container for object destruction
  oContainer = obj_new('IDL_container')

  ; Font
  if (n_elements(Font) ne 0) then begin
    if (not obj_isa(Font, 'IDLgrFont')) then begin
      message,'Unable to convert variable to type object reference.'
      return, 0
    end
  end else begin
    Font = obj_new('IDLgrFont')
    oContainer -> Add, Font
  end    

  ; Gap
  if (n_elements(Gap) eq 0) then Gap = 0.5

  ; Linestyle
  if (n_elements(Item_Linestyle) eq 0) then Item_Linestyle = LonArr(numTags)+6 $
  else begin
    if (n_elements(Item_Linestyle) ne numTags) then begin
      message,'Invalid number of elements in LINESTYLE.', /info
      return, 0
    end
  end

  ; LineThick
  if (n_elements(Item_LineThick) eq 0) then Item_LineThick = LonArr(numTags)+1 $
  else begin
    if (n_elements(Item_LineThick) ne numTags) then begin
      message,'Invalid number of elements in LINETHICK.', /info
      return, 0
    end
  end

  ; LineColor
  if (n_elements(Item_LineColor) eq 0) then begin
     Item_LineColor = BytArr(3,numTags)
     for i=0, numTags-1 do Item_LineColor[*,i] = [255b,255b,255b]
  end else begin
    nd = size(Item_LineColor, /n_dimensions)
    if (nd ne 2) and (nd ne 1) then begin
      message, 'Invalid LINECOLOR.', /info
      return, 0
    end
    s = size(Item_LineColor, /dimensions) 
    if (nd eq 1) then s = [s[0],1]
    if (s[0] ne 3) or (s[1] ne numTags) then begin
      message,'Invalid LINECOLOR.', /info
      return, 0
    end
  end

  ; Location
  if (n_elements(Location) eq 0) then begin
    Location = FltArr(3)  
  end else begin
    case (n_elements(location)) of
      3:
      2: location = [location, 0.0]
    else: begin
             message,'Invalid LOCATION.', /info
             return, 0
          end
    end
  end

  ; SymbolStyle
  if (n_elements(Item_SymbolStyle) eq 0) then Item_SymbolStyle = LonArr(numTags) $
  else begin
    if (n_elements(Item_SymbolStyle) ne numTags) then begin
      message,'Invalid number of elements in ITEM_SYMBOLSTYLE.'
      return, 0
    end
  end

  ; SymbolColor
  if (n_elements(Item_SymbolColor) eq 0) then begin
     Item_SymbolColor = BytArr(3,numTags)
     for i=0, numTags-1 do Item_SymbolColor[*,i] = [255b,255b,255b]
  end else begin
    nd = size(Item_SymbolColor, /n_dimensions)
    if (nd ne 2) and (nd ne 1) then begin
      message, 'Invalid ITEM_SYMBOLCOLOR.', /info
      return, 0
    end
    s = size(Item_LineColor, /dimensions) 
    if (nd eq 1) then s = [s[0],1]
    if (s[0] ne 3) or (s[1] ne numTags) then begin
      message,'Invalid ITEM_SYMBOLCOLOR.', /info
      return, 0
    end
  end

  ; Name
  if (n_elements(Name) gt 0) then $
     self->IDLgrModel::SetProperty, Name = Name

  ; Outline Color
  if (n_elements(Outline_Color) eq 0) then Outline_Color = [255,255,255]

  ; Outline Thick
  if (N_ELEMENTS(Outline_Thick) le 0) then Outline_Thick = 1

  ; Show Outline
  Show_Outline = Keyword_Set(Show_Outline)
  
  ; Show Fill
  Show_Fill = Keyword_Set(Show_Fill)

  ; Text Color
  if (n_elements(TextColor) eq 0) then TextColor = [255,255,255]

  ; Title
  if (n_elements(Title) gt 0) then begin
    if (not obj_isa(Title, 'IDLgrText')) then begin
       message,'Unable to convert variable to type object reference.'
       return, 0
    end
  end else begin
    Title = OBJ_NEW()
    oContainer -> Add, Title
  end

  ; Uvalue
  if (n_elements(Uvalue) gt 0) then $
      self->IDLgrModel::SetProperty, UVALUE = Uvalue, NO_COPY = no_copy

  ; Vertical Alignment
  if (n_elements(v_align) eq 0) then v_align = 0.0


  ; store the state of this object

  if (finite(h_align)) then self.h_align = h_align $
  else begin
    message, 'Infinite or invalid (NaN) operands not allowed.',/info
    return, 0
  end

  if (finite(v_align)) then self.v_align = v_align $
  else begin
    message, 'Infinite or invalid (NaN) operands not allowed.',/info
    return, 0
  end

  if (finite(Border_Gap)) then self.Border_Gap = Border_Gap $
  else begin
    message, 'Infinite or invalid (NaN) operands not allowed.',/info
    return, 0
  end

  if (finite(Border_Gap)) then self.Border_Gap = Border_Gap $
  else begin
    message, 'Infinite or invalid (NaN) operands not allowed.',/info
    return, 0
  end

  if (finite(Gap)) then self.Gap = Gap $
  else begin
    message, 'Infinite or invalid (NaN) operands not allowed.',/info
    return, 0
  end

  if (finite(glyphWidth)) then self.glyphWidth = glyphWidth $
  else begin
    message, 'Infinite or invalid (NaN) operands not allowed.',/info
    return, 0
  end

  self.Border_Gap = Border_Gap
  self.oContainer = oContainer

  self.oModel = Obj_New('IDLgrModel')
  self -> Add, self.oModel

  ; Create the polygon (Fill)
  self.oFill = OBJ_NEW('IDLgrPolygon', HIDE = (1-Show_Fill), $
                         COLOR = Fill_Color)

  self.oModel -> Add, self.oFill

  ; Create the polyline (Outline)
  self.oOutline = OBJ_NEW('IDLgrPolyline', HIDE = (1-Show_Outline), $
                         COLOR = Outline_Color, THICK = Outline_Thick)

  self.oModel -> Add, self.oOutline

  self.oFont             = Font
  self.Gap               = Gap  
  self.glyphWidth        = glyphWidth
  self.pItem_LineColor   = ptr_new(Item_LineColor)
  self.pItem_LineStyle   = ptr_new(Item_LineStyle)
  self.pItem_LineThick   = ptr_new(Item_LineThick)
  self.pItem_SymbolColor = ptr_new(Item_SymbolColor)
  self.pItem_SymbolStyle = ptr_new(Item_SymbolStyle)
  self.pItem_Labels      = ptr_new(Item_Labels)
  self.TextColor         = TextColor

  self.oVoidSymbol       = obj_new('IDLgrSymbol',0)
  self.oContainer -> Add, self.oVoidSymbol

  ; Legend Positioning
  self.location          = location
  self.h_align           = h_align
  self.v_align           = v_align

  ; Coordinate conversion.
  transform = [[1.0,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
  if(n_elements(Xcoord_Conv) gt 0) then begin
      transform[0,0] = Xcoord_Conv[1]
      transform[3,0] = Xcoord_Conv[0]
  endif
  if(n_elements(Ycoord_Conv) gt 0) then begin
      transform[1,1] = Ycoord_Conv[1]
      transform[3,1] = Ycoord_Conv[0]
  endif
  if(n_elements(Zcoord_Conv) gt 0) then begin
      transform[2,2] = Zcoord_Conv[1]
      transform[3,2] = Zcoord_Conv[0]
  endif
    
  self.oModel->SetProperty, TRANSFORM = transform

  ; Create the Legend
  self -> CreateLegend
  
  return, 1
END


; ##########################################################################
;
;
; SetProperty method

pro z_grLegend::SetProperty, $
             ALIGNMENT = h_align, $
             BORDER_GAP = Border_Gap, $
             FILL_COLOR = Fill_Color, $
             FONT = Font, $
             GAP = Gap, $
             GLYPH_WIDTH = glyphWidth, $
             HIDE = Hide, $
             LABELS = Item_Labels, $
             LINECOLOR = Item_LineColor, $
             LINESTYLE = Item_Linestyle, $
             LINETHICK = Item_LineThick, $
             LOCATION = Location, $ 
             SYMBOLCOLOR = Item_SymbolColor, $
             SYMBOLSTYLE = Item_SymbolStyle, $
             NAME = Name, $
             OUTLINE_COLOR = Outline_Color, $
             OUTLINE_THICK = Outline_Thick, $
             SHOW_OUTLINE = Show_Outline, $
             SHOW_FILL = Show_Fill, $
             TEXTCOLOR = TextColor, $
             TITLE = Title, $
             UVALUE = Uvalue,$
             VERTICAL_ALIGNMENT = v_align, $
             XCOORD_CONV = Xcoord_Conv, $
             YCOORD_CONV = Ycoord_Conv, $
             ZCOORD_CONV = Zcoord_Conv, $
             _EXTRA = extra_keys, NO_COPY = no_copy

  ; Pass extra keywords to superclass 
  self->IDLgrModel::SetProperty, _EXTRA=extra_keys

  regen = 0b

  ; Horizontal alignment
  if (n_elements(h_align) ne 0) then $ 
    if (finite(h_align)) then self.h_align = h_align $
    else message, 'ALIGNMENT, Infinite or invalid (NaN) operands not allowed.',/info

  ; Border Gap
  if (n_elements(Border_Gap) ne 0) then $ 
    if (finite(Border_Gap)) then self.Border_Gap = Border_Gap $
    else message, 'BORDER_GAP, Infinite or invalid (NaN) operands not allowed.',/info

  ; Font
  if (n_elements(Font) ne 0) then $
    if (obj_isa(Font, 'IDLgrFont')) then begin
       if (self.oContainer->IsContained(self.oFont)) then begin
         self.oContainer -> Remove, self.oFont
         obj_destroy, self.oFont
       end
       self.oFont = Font
    end else  message,'FONT, Unable to convert variable to type object reference.' 

  ; Gap
  if (n_elements(Gap) ne 0) then $
     if (finite(Gap)) then self.Gap = Gap $
     else message, 'GAP, Infinite or invalid (NaN) operands not allowed.',/info

  ; Glyph width
  if (n_elements(GlyphWidth) ne 0) then $
     if (finite(GlyphWidth)) then self.GlyphWidth = GlyphWidth $
     else message, 'GLYPH_WIDTH, Infinite or invalid (NaN) operands not allowed.',/info

  ; Hide    
  if (n_elements(hide) ne 0) then $
      self->IDLgrModel::SetProperty, Hide=keyword_set(hide)

  ; Name
  if (n_elements(Name) ne 0) then $
     self->IDLgrModel::SetProperty, Name = Name

  ; Outline Color
  if (n_elements(Outline_Color) ne 0) then $
    self.oOutline -> SetProperty, COLOR = Outline_Color

  ; Outline Thick
  if (n_elements(Outline_Thick) ne 0) then $ 
    if (finite(Outline_Thick)) then self.Outline_Thick = Outline_Thick $
    else message, 'OUTLINE_THICK, Infinite or invalid (NaN) operands not allowed.',/info

  ; Show Outline
  if (n_elements(show_outline) ne 0) then $
    self.oOutline -> SetProperty, Hide = 1-Keyword_Set(Show_Outline)
  
  ; Show Fill
  if (n_elements(show_fill) ne 0) then $
    self.oFill -> SetProperty, Hide = 1-Keyword_Set(Show_Fill)

  ; Fill Color
  if (n_elements(Fill_Color) ne 0) then $
    self.oFill -> SetProperty, COLOR = Fill_Color

  ; Text Color
  if (n_elements(Text_Color) ne 0) then $
    self.Text_Color = [255,255,255]

  ; Title
  if (n_elements(Title) ne 0) then begin
    if (obj_isa(Title, 'IDLgrText') or (Title eq Obj_new())) then begin
      if (obj_valid(self.oTitle)) then self.oModel -> Remove, self.oTitle
      self.oTitle = Title 
      if (obj_valid(self.oTitle)) then self.oModel -> Add, self.oTitle 
    end else message,'TITLE, Unable to convert variable to type object reference.'
  end 

  ; Uvalue
  if (n_elements(Uvalue) ne 0) then $
      self->IDLgrModel::SetProperty, UVALUE = Uvalue, NO_COPY = no_copy

  ; Vertical alignment
  if (n_elements(v_align) ne 0) then $ 
    if (finite(v_align)) then self.v_align = v_align $
    else message, 'VERTICAL_ALIGNMENT, Infinite or invalid (NaN) operands not allowed.',/info

  ; Coordinate conversion.
  self.oModel->GetProperty, TRANSFORM = transform
  if(n_elements(Xcoord_Conv) gt 0) then begin
      transform[0,0] = Xcoord_Conv[1]
      transform[3,0] = Xcoord_Conv[0]
  endif
  if(n_elements(Ycoord_Conv) gt 0) then begin
      transform[1,1] = Ycoord_Conv[1]
      transform[3,1] = Ycoord_Conv[0]
  endif
  if(n_elements(Zcoord_Conv) gt 0) then begin
      transform[2,2] = Zcoord_Conv[1]
      transform[3,2] = Zcoord_Conv[0]
  endif
  self.oModel->SetProperty, TRANSFORM = transform

  ; Process Item Labels
  if (n_elements(Item_Labels) ne 0) then begin
     *self.pItem_Labels = Item_Labels
     regen = 1
  end 
  numTags = n_elements(*self.pItem_Labels)

  ; Linestyle
  if (n_elements(Item_Linestyle) ne 0) then $
    if (n_elements(Item_Linestyle) eq numTags) then begin
       *self.pItem_Linestyle = Item_LineStyle
       if (regen ne 1) then for i=0,numTags-1 do $
            (*self.pGlyph)[i] -> SetProperty, LINESTYLE = (*self.pItem_LineStyle)[i]  
    end else message,'Invalid number of elements in LINESTYLE.'

  ; LineThick
  if (n_elements(Item_LineThick) ne 0) then $
    if (n_elements(Item_LineThick) eq numTags) then begin
      *self.pItem_LineThick = Item_LineThick 
       if (regen ne 1) then for i=0,numTags-1 do $
            (*self.pGlyph)[i] -> SetProperty, THICK = (*self.pItem_LineThick)[i]  
    end else message,'Invalid number of elements in LINETHICK.'

  ; LineColor
  if (n_elements(Item_LineColor) ne 0) then begin
    s = size(Item_LineColor, /n_dimensions)
    if (s eq 2) then begin
      s = size(Item_LineColor, /dimensions) 
      if (s[0] eq 3) and (s[1] eq numTags) then begin
         *self.pItem_LineColor = Item_LineColor
         if (regen ne 1) then for i=0,numTags-1 do $
            (*self.pGlyph)[i] -> SetProperty, COLOR = (*self.pItem_LineColor)[*,i] 
      end else message,'Invalid LINECOLOR.'
    end else message,'Invalid LINECOLOR.'
  end

  
  ; Location
  if (n_elements(Location) ne 0) then begin
    case (n_elements(location)) of
      3: self.location = location
      2: self.location = [location, 0.0]
    else: message,'Invalid LOCATION.', /info
    endcase
  end

  ; SymbolStyle
  if (n_elements(Item_Symbolstyle) ne 0) then $
    if (n_elements(Item_Symbolstyle) eq numTags) then begin
       *self.pItem_Symbolstyle = Item_SymbolStyle
       if (regen ne 1) then for i=0,numTags-1 do $
          (*self.pSymbol)[i] -> SetProperty, DATA = (*self.pItem_SymbolStyle)[i] 
    end else message,'Invalid number of elements in SYMBOLSTYLE.'

  ; SymbolColor
  if (n_elements(Item_SymbolColor) ne 0) then begin
    s = size(Item_SymbolColor, /n_dimensions)
    if (s eq 2) then begin
      s = size(Item_SymbolColor, /dimensions) 
      if (s[0] eq 3) and (s[1] eq numTags) then begin
         *self.pItem_SymbolColor = Item_SymbolColor
         if (regen ne 1) then for i=0,numTags-1 do $
            (*self.pSymbol)[i] -> SetProperty, COLOR = (*self.pItem_SymbolColor)[*,i] 
      end else message,'Invalid SYMBOLCOLOR.'
    end else message,'Invalid SYMBOLCOLOR.'
  end

  ; update the Legend
  if (regen eq 1) then self -> CreateLegend

end

; ##########################################################################
;
;
; GetProperty method


pro z_grLegend::GetProperty, $
             ALIGNMENT = h_align, $
             BORDER_GAP = Border_Gap, $
             FONT = Font, $
             GAP = Gap, $
             GLYPH_WIDTH = glyphWidth, $
             HIDE = Hide, $
             ITEM_LABELS = Item_Labels, $
             ITEM_LINECOLOR = Item_LineColor, $
             ITEM_LINESTYLE = Item_Linestyle, $
             ITEM_LINETHICK = Item_LineThick, $
             ITEM_SYMBOLCOLOR = Item_SymbolColor, $
             ITEM_SYMBOLSTYLE = Item_SymbolStyle, $
             NAME = Name, $
             OUTLINE_COLOR = Outline_Color, $
             OUTLINE_THICK = Outline_Thick, $
             SHOW_OUTLINE = Show_Outline, $
             SHOW_FILL = Show_Fill, $
             FILL_COLOR = Fill_Color, $
             TEXT_COLOR = Text_Color, $
             TITLE = Title, $
             UVALUE = Uvalue,$
             VERTICAL_ALIGNMENT = v_align, $
             XCOORD_CONV = Xcoord_Conv, $
             YCOORD_CONV = Ycoord_Conv, $
             ZCOORD_CONV = Zcoord_Conv, $
             XRANGE = Xrange, $
             YRANGE = Yrange, $
             ZRANGE = Zrange, $
             PARENT = parent, $
             NO_COPY = no_copy

  h_align = self.h_align
  Border_Gap = self.Border_Gap
  Font = self.oFont
  Gap = self.Gap
  glyphWidth = self.glyphWidth
  self->IDLgrModel::GetProperty, HIDE = hide, NAME = name
  self->IDLgrModel::GetProperty, UVALUE = uvalue, NO_COPY = no_copy
  Item_Labels = *self.pItem_Labels
  Item_LineColor = *self.pItemLineColor
  Item_LineStyle = *self.pItemLineStyle
  Item_LineThick = *self.pItemLineThick
  Item_SymbolColor = *self.pItemSymbolColor
  Item_SymbolStyle = *self.pItemSymbolStyle
  
  self.oOutline -> GetProperty, COLOR = Outline_Color, THICK = Outline_Thick, $
     HIDE = Show_Outline
     
  self.oOutline -> GetProperty, XRANGE = xrange
  self.oOutline -> GetProperty, YRANGE = yrange
  self.oOutline -> GetProperty, ZRANGE = zrange
  
  Show_Outline = 1-Show_Outline
  self.oFill -> GetProperty, COLOR = Fill_Color, HIDE = Show_Fill
  Show_Fill = 1 - Show_Fill
  Text_Color = *self.pText_Color
  Title = self.oTitle
  v_align = self.v_align 
  
  ; Get the transform matrix
  self.oModel->GetProperty, TRANSFORM = transform
  Xcoord_Conv = [transform[3,0],transform[0,0]]
  Ycoord_Conv = [transform[3,1],transform[1,1]]
  Zcoord_Conv = [transform[3,2],transform[2,2]]
  
  self->IDLgrModel::GetProperty, PARENT = Parent
end

; ##########################################################################
;
;
; Compute Location

pro z_grLegend::ComputeLocations

  numTags = n_elements(*self.pItem_Labels)

  x0 = self.location[0] - self.h_align * self.h_size
  y0 = self.location[1] - self.v_align * self.v_size
  z0 = self.location[2]

  ; Set glyph and label positions
 
  glx1 = x0 + self.hbordergap 
  glx2 = x0 + self.hbordergap + self.hGlyphWidth/2.0
  glx3 = x0 + self.hbordergap + self.hGlyphWidth
 
  tx1 = x0 + self.hbordergap + self.hGlyphWidth + self.glyphGap
  symbolsize = self.symbolsize
    
  for i=0, numTags-1 do begin
    ; Position Glyph
    gly1 = y0 + self.v_size - self.vbordergap - i*(self.textHeight + self.vgap) - self.textHeight/2.0
    (*self.pGlyph)[i] -> SetProperty, DATA = [[glx1,gly1],[glx2,gly1],[glx3,gly1]] 
    
    ; Position Label
    ty1 = y0 + self.v_size - self.vbordergap - i*(self.textHeight + self.vgap)
    (*self.pLabel)[i] -> SetProperty, LOCATION = [tx1, ty1], $
                   ALIGNMENT = 0.0, VERTICAL_ALIGNMENT = 1.0

    ; Size symbols
    (*self.pSymbol)[i] -> SetProperty, SIZE = symbolsize
    
  end


 ; Set outline dimensions
  self.oOutline->SetProperty, Data = [[x0,y0,0],$
                                      [x0+self.h_size,y0,0],$
                                      [x0+self.h_size,y0+self.v_size,0],$
                                      [x0,y0+self.v_size,0],$
                                      [x0,y0,0]]

  ; Set fill dimensions
  self.oFill->SetProperty, Data = [[x0,y0,0],$
                                   [x0+self.h_size,y0,0],$
                                   [x0+self.h_size,y0+self.v_size,0],$
                                   [x0,y0+self.v_size,0],$
                                   [x0,y0,0]]
  
end 

; ##########################################################################
;
;
; Compute Dimensions

function z_grLegend::ComputeDimensions, oSrcDest
   
  numTags = n_elements(*self.pItem_Labels)

  textWidth = 0.0
  textHeight = 0.0

  ; Get Max Label size
  for i=0, numTags-1 do begin
    (*self.pLabel)[i] -> SetProperty, CHAR_DIMENSIONS = [0,0]
    textSize = oSrcDest -> GetTextDimensions((*self.pLabel)[i])
    textWidth = textWidth > textSize[0]
    textHeight = textHeight > textSize[1]
  end   

  ; Get character size aspect ratio
  h_AspectRatio = 1.0
  v_AspectRatio = 1.0
  
  (*self.pLabel)[0] -> GetProperty, CHAR_DIMENSIONS = char_dim
  if (char_dim[0] gt char_dim[1]) then h_AspectRatio = char_dim[0]/char_dim[1] $
  else v_AspectRatio = char_dim[1]/char_dim[0]


  ; Get glyph sizes

  hGlyphWidth = textHeight * 2.0 * h_AspectRatio
  vGlyphWidth = textHeight * 0.8 * v_AspectRatio

  ; Get Symbol Size
  
  symbolsize = 0.2*[textHeight * h_AspectRatio, textHeight * v_AspectRatio]

  ; Get gap sizes
    
  hgap = self.Gap * textHeight * h_AspectRatio
  vgap = self.Gap * textHeight * v_AspectRatio
  
  hbordergap = self.Border_Gap * textHeight * h_AspectRatio
  vbordergap = self.Border_Gap * textHeight * v_AspectRatio
  glyphGap   = textHeight * 0.2 * v_AspectRatio
  
  ; Get Box Size
  
  v_size = vbordergap*2.0 + numTags*textHeight + vgap*(numTags-1)
  h_size = hbordergap*2.0 + textWidth + glyphgap + hGlyphWidth 

  ; Correct if Title present
  
;  if (self.oTitle ne obj_new()) then begin
;    self.oTitle -> SetProperty, CHAR_DIMENSIONS = [0,0]
;    titleSize = oScrDest -> GetTextDimensions(self.oTitle)
;    v_size = v_size + titleSize[1] + vgap
;    h_size = h_size > (hbordergap*2.0 + titleSize[0]) 
;  end 

  ; Save values
  
  self.TextWidth = TextWidth
  self.TextHeight = TextHeight

  self.hGlyphWidth = hGlyphWidth
  self.vGlyphWidth = vGlyphWidth
  self.symbolsize = symbolsize

  self.hgap = hgap
  self.vgap = vgap
  
  self.hbordergap = hbordergap
  self.vbordergap = vbordergap
  self.glyphgap = glyphgap
  
  self.v_size = v_size
  self.h_size = h_size

  ; Recompute location

  self -> ComputeLocations

  self.oFill -> GetProperty, xrange = xrange, yrange = yrange
     
  return, [xrange[1]-xrange[0], yrange[1]-yrange[0], 0] 
end

; ##########################################################################
;
;
; Draw Method

pro z_grLegend::Draw, oSrcDest, oView

    result = self->ComputeDimensions(oSrcDest)    
    self->IDLgrModel::Draw, oSrcDest, oView

end


; ##########################################################################
;
;
; Cleanup Method

pro z_grLegend::Cleanup
  
  ; Destroy objects
  
  for i=0, n_elements(*self.pLabel)-1 do $
     obj_destroy, (*self.pLabel)[i]

  for i=0, n_elements(*self.pSymbol)-1 do $
     obj_destroy, (*self.pSymbol)[i]
  obj_destroy, self.oVoidSymbol

  for i=0, n_elements(*self.pGlyph)-1 do $
     obj_destroy, (*self.pGlyph)[i]

  obj_destroy, self.oOutline
  obj_destroy, self.oFill
  obj_destroy, self.oModel
  
  obj_destroy, self.oContainer

  ; free pointers
  
  ptr_free, self.pLabel, self.pSymbol, self.pGlyph
  
  ptr_free, self.pItem_LineColor
  ptr_free, self.pItem_LineStyle
  ptr_free, self.pItem_LineThick
  ptr_free, self.pItem_SymbolColor
  ptr_free, self.pItem_SymbolStyle
  
  ptr_free, self.pItem_Labels

  ; call superclass destructor  
  self->IDLgrModel::Cleanup
end


; ##########################################################################
;
;
; Class definition

pro z_grLegend__Define
    struct = { z_grLegend, $
               INHERITS IDLgrModel, $
               oModel : Obj_New(), $
               Border_Gap: 0.1, $
               oContainer: Obj_New(), $
               oOutline: OBJ_New(), $
               oFill: Obj_New(), $
               oFont: Obj_New(), $
               Gap: 0.1, $
               glyphWidth: 0.8, $
               pItem_LineColor: Ptr_New(), $
               pItem_LineStyle: Ptr_New(), $
               pItem_LineThick: Ptr_New(), $
               pItem_SymbolColor: Ptr_new(), $
               pItem_SymbolStyle: Ptr_new(), $
               pItem_Labels: Ptr_New(), $
               pLabel: Ptr_new(), $
               pSymbol: Ptr_New(), $
               pGlyph:Ptr_New(), $

               TextColor: BytArr(3), $
               oVoidSymbol:obj_new(), $
               location:FltArr(3), $

               ; Internal variables for sizing and positioning
                 
               h_align:0.0,$
               v_align:0.0, $
               
               TextWidth:0.0,$
               TextHeight:0.0,$
               
               hGlyphWidth: 0.0, $
               vGlyphWidth: 0.0, $
               symbolsize: FltArr(2), $
               
               hgap:0.0, $
               vgap:0.0, $
               
               hbordergap:0.0, $
               vbordergap:0.0, $
               glyphgap:0.0, $
               h_size:0.0,$
               v_size:0.0 $
             }

end
