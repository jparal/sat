pro plt_bullet, x, y, radi, color, BGCOLOR=bgcolor, BGTHICK=bgthick, $
                TEXT=text, TXTOFFSET=txtoffset, TXTCOLOR=txtcolor, $
                CHARSIZE=charsize

  imi=findgen(501)/500*!pi*2
  imx=radi*sin(imi)
  imy=radi*cos(imi)

  polyfill, imx+x, imy+y, color=FSC_COLOR(color) ,/data

  IF NOT KEYWORD_SET(bgcolor) THEN bgcolor = 'Black'
  IF NOT KEYWORD_SET(bgthick) THEN bgthick = 1
  oplot, imx+x, imy+y, color=FSC_COLOR(bgcolor), thick=bgthick

  IF KEYWORD_SET(text) THEN BEGIN
     IF NOT KEYWORD_SET(txtoffset) THEN txtoffset = [radi, radi]
     IF NOT KEYWORD_SET(txtcolor) THEN txtcolor = 'Black'
     utl_check_size, txtoffset, ss=[1,2]

     xyouts, x+txtoffset(0), y+txtoffset(1), text, color=FSC_COLOR(txtcolor), $
             charsize=charsize
  ENDIF

return
end
