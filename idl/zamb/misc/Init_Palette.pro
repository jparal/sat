pro Init_Palette, oPalette, $
                  ColorTable, $
                  BOTTOM_STRETCH = BottomStretch, $
                  TOP_STRETCH = TopStretch, $
                  GAMMA_CORRECTION = GammaCorrection
                  
  if (N_Params() ne 2) then begin
    res = Error_Message('Invalid number of parameters')
    return
  end
  
  if (not obj_isa(oPalette, 'IDLgrPalette')) then begin
    res = Error_Message('Invalid object type, oPalette')
    return
  end
  
  if (N_Elements(BottomStretch) eq 0) then BottomStretch = 0
  if (N_Elements(TopStretch) eq 0) then TopStretch = 255
  if (N_Elements(GammaCorrection) eq 0) then GammaCorrection = 1.0
  
  getCTColors, ColorTable, RED = r, GREEN = g, BLUE = b 
  oPalette -> SetProperty, RED = r, GREEN = g, BLUE = b
  
  oPalette -> SetProperty, BOTTOM_STRETCH = BottomStretch*100.0/255.0  
  oPalette -> SetProperty, TOP_STRETCH = TopStretch*100.0/255.0  
  oPalette -> SetProperty, GAMMA = GammaCorrection  
               
end