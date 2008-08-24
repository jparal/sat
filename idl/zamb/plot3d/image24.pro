; --------------------------------------------------------- image24 ---
; returns a 24 bit image from an 8-bit image and
; a palette
; ---------------------------------------------------------------------

function image24, image, ct, INV_ORDER = inv_order
  s = Size(image)  

  GetCTColors, ct, RED = rr, GREEN = gg, BLUE = bb

  if Keyword_Set(inv_order) then begin
    image24bit = BytArr(s[1], s[2],3)
    image24bit[*,*,0] = rr(image[*,*])
    image24bit[*,*,1] = gg(image[*,*])
    image24bit[*,*,2] = bb(image[*,*])
  end else begin
    image24bit = BytArr(3, s[1], s[2])
    image24bit[0,*,*] = rr(image[*,*])
    image24bit[1,*,*] = gg(image[*,*])
    image24bit[2,*,*] = bb(image[*,*])
  end
; IMPLEMENT NEW CODE!!!!!!!!!

  return, image24bit
end
; ---------------------------------------------------------------------
