pro init_colors, CT = ct, numcolors = numcolors, $
                 maxcolor = maxcolor, clear = clear, $
                 truecol = truecol

  ; Initialize Color System

  MaxColor = !D.Table_Size
  numcolors = MaxColor - 9

  ; Load Color Table
 
  if (N_Elements(ct) eq 0) then ct = 25
  
  LoadCT, ct, NColors = numcolors, /Silent

  case !D.Name of
    'PS' : begin
             device, Bits_per_Pixel=8, color=1
             defcolor = MaxColor - 8
             truecol = 0
           end
    'MAC': begin
            defcolor = MaxColor - 1
            device, get_visual_depth = thisDepth
            if (thisDepth gt 8) then begin
              device, decomposed = 0
              truecol = 1
            end
           end
    'WIN': begin
            defcolor = MaxColor - 1
            device, get_visual_depth = thisDepth
            if (thisDepth gt 8) then begin
              device, decomposed = 0
              truecol = 1
            end
           end
     else: begin
            truecol = 0 ; Assume truecol = false
             defcolor = MaxColor - 1
           end
  endcase

  color_white  = LONG([255, 255, 255])
  color_yellow = LONG([255, 255,   0])
  color_cyan   = LONG([  0, 255, 255])
  color_purple = LONG([191,   0, 191])
  color_red    = LONG([255,   0,   0])
  color_green  = LONG([  0, 255,   0])
  color_blue   = LONG([ 63,  63, 255])
  color_black  = LONG([  0,   0,   0])

  TvLCT, color_red[0],color_red[1],color_red[2], MaxColor - 2
  TvLCT, color_blue[0],color_blue[1],color_blue[2], MaxColor - 3
  TvLCT, color_green[0],color_green[1],color_green[2], MaxColor - 4
  TvLCT, color_yellow[0],color_yellow[1],color_yellow[2], MaxColor - 5
  TvLCT, color_purple[0],color_purple[1],color_purple[2], MaxColor - 6
  TvLCT, color_cyan[0], color_cyan[1], color_cyan[2], MaxColor - 7

  if (!D.Name ne 'PS') then begin
    TvLCT, color_white[0], color_white[1], color_white[2], MaxColor - 1
    TvLCT, color_black[0],color_black[1],color_black[2], MaxColor - 8
  end else begin
    TvLCT, color_white[0], color_white[1], color_white[2], MaxColor - 8
    TvLCT, color_black[0],color_black[1],color_black[2], MaxColor - 1
  end
  
  if (Keyword_Set(clear)) then erase, MaxColor - 8
  
end