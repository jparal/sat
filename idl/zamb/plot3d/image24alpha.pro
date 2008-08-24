; ---------------------------------------------------- image24alpha ---
; returns a 24 bit + alpha image from an 8-bit image a palette, and
; an alpha value
; ---------------------------------------------------------------------

function image24alpha, image, CT, alpha
  GetCTColors, ct, RED = rr, GREEN = gg, BLUE = bb
  
  s = Size(Data8bit)
    
  AlphaChannel = make_array(size=s, value=alpha)
  AlphaImage = [rr[Data8bit], gg[Data8bit], bb[Data8bit], AlphaChannel]
  AlphaImage = reform(AlphaImage, s[1], 4, s[2], /overwrite)
  AlphaImage = transpose(AlphaImage, [1,0,2])
  
  return, AlphaImage
  
end
; ---------------------------------------------------------------------
