; 3D PIC simulations of the Weibel instability and the nonlinear
; structure of the self-generated magnetic field
;
; R.A.Fonseca, J.Tonge, R.G.Hemker, L.O.Silva,
; J.M.Dawson, W.B.Mori


; Embedded Font Formatting commands
;
; Positioning
;
; !M - Single symbol character
; !D - Down to subscript level, smaller char
; !U - Up to upperscript level, smaller char
; !N - return to normal formatting
;
; Formatting
;
; !3 - Helvetica
; !4 - Helvetica Bold
; !5 - Helvetica Italic
; !6 - Helvetica Bold Italic


; mass density 3D
;
; files:
;
; x3x2x1-2600
; x3x2x1-3400

pro mass_density_anim

  osiris_analysis_3d, factor = 2, smooth = 5, $
                      isolevels = [0.5, 0.75, 1.25, 1.5, 1.0], /absisolevels,$
                      low =       [ 0,  0  ,   1,  1, 0 ], $
                      Color  = [[255b,255b,000b,255b], $
                                [255b,000b,000b,255b], $
                                [000b,255b,255b,255b], $
                                [000b,000b,255b,255b], $
                                [000b,255b,000b,080b]], $
                      Bottom = [[128b,128b,000b,255b], $
                                [128b,000b,000b,255b], $
                                [000b,128b,128b,255b], $
                                [000b,000b,128b,255b], $
                                [255b,255b,255b,255b]], $, $
                     /dx, /abs, border = 1, RES = [300,300],$
                      TITLE = '!4Electron Mass Density!N' , /noproj
end
