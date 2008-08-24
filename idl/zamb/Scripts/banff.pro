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



; grafico ptot em funcao do tempo para run 2d 

;  osiris_analysis_2d, /addcontour, /zlog, contourlevels = 2.5*[1,10,100, 1000, 10000], $
;                     Title = 'Momentum Distribution', SubTitle = '2D Simulation', $
;                     FONT = 1, xtitle = 'Time [ 1 / !Mw!Dp!N ]', ytitle = 'p [ m!De!N c ]',$
;                     ztitle = 'a.u.', zmin = 0.1, $
;                     PSFILE = 'p_of_time_2D.ps', RES = [10.,10.], CHARSIZE = 0.5


; grafico ptot em funcao do tempo para run 3d 

; osiris_analysis_2d, /addcontour, /zlog, contourlevels = 0.7*[1,10,100, 1000, 10000], $
;                    Title = 'Momentum Distribution', SubTitle = '3D Simulation', $
;                    FONT = 1, xtitle = 'Time [ 1 / !Mw!Dp!N ]', ytitle = 'p [ m!De!N c ]',$
;                    ztitle = 'a.u.', zmin = 0.1,$
;                    PSFILE = 'p_of_time_3D.ps', RES = [10.,10.], CHARSIZE = 0.5

; grafico k-space em funcao do tempo para run 3D

; osiris_analysis_2d, /addcontour, contourlevels =[0.1, 0.2, 2.0, 7.0], CT = 25, yrange = [0.05,2.],$
;                     Title = 'k-Space Evolution', SubTitle = '3D Simulation', $
;                     FONT = 1, xtitle = 'Time [ 1 / !Mw!Dp!N ]', ytitle = 'k [ !Mw!Dp!N / c ]',$
;                     ztitle = 'a.u.', /zlog, zmax = 25.0, zmin  = 0.04, factor = [1,2], smooth = 3,$
;                     PSFILE = 'k_of_time_3D.ps', RES = [10.,10.], CHARSIZE = 0.5

; grafico k-space em funcao do tempo para run 2D

; osiris_analysis_2d, /addcontour, contourlevels =[0.3, 2.0, 7.0, 13.0], CT = 25,yrange = [0.05,2.],$
;                     Title = 'k-Space Evolution', SubTitle = '2D Simulation', $
;                     FONT = 1, xtitle = 'Time [ 1 / !Mw!Dp!N ]', ytitle = 'k [ !Mw!Dp!N / c ]',$
;                     ztitle = 'a.u.', /zlog, zmax = 25.0, zmin  = 0.08, $
;                     PSFILE = 'k_of_time_2D.ps', RES = [10.,10.], CHARSIZE = 0.5


; mass density 3D
;
; files:
;
; x3x2x1-1420
; x3x2x1-2600
; x3x2x1-3400
;

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
                     /dx, /abs, border = 1, antialias = 8,  RES = [600,600],$
                      TITLE = '!4Electron Mass Density!N', $ FILEOUT = 'mass_den_1420.tif',$
                      /POVERTRANS, PROJCT = 1                    


;   osiris_movie_3d, factor = 2, smooth = 5, FONTSIZE = 2.0, $
;                       isolevels = [0.5, 0.75, 1.25, 1.5, 1.0], /absisolevels,$
 ;                      low =       [ 0,  0  ,   1,  1, 0 ], $
 ;                      Color  = [[255b,255b,000b,255b], $
;                                 [255b,000b,000b,255b], $
;                                 [000b,255b,255b,255b], $
;                                 [000b,000b,255b,255b], $
;                                 [000b,255b,000b,080b]], $
;                       Bottom = [[128b,128b,000b,255b], $
 ;                                [128b,000b,000b,255b], $
;                                 [000b,128b,128b,255b], $
;                                 [000b,000b,128b,255b], $
;                                 [255b,255b,255b,255b]], $, $
;                       /dx, /abs, border = 1, antialias = 4,  RES = [384,384],$
;                       TITLE = '!4Electron Mass Density!N', $
 ;                      /POVERTRANS, PROJCT = 1, /show, SUBTITLE = ''                    



; Simulation Box
;
; Use any file from the simulation

;osiris_analysis, /noiso, /noproj, antialias = 8, Title = '!4Simulation Box!N', ZOOM = 0.95, $
;                 Subtitle = '', /dx, /invcolors, RES = [1024,1024], FILEOUT = 'sim_box.tif', $
;                 XTitle = 'x1 [c/!Mw!Dp!N]',YTitle = 'x2 [c/!Mw!Dp!N]',ZTitle = 'x3 [c/!Mw!Dp!N]' 


; Magnetic Field 3D


; print, 'Generating plot for magnetic field 3D' 
; osiris_analysis_3d_vfield, factor = 2, smooth = 5, RADIUS = -0.0003, $ 
;                              /noiso, /novectorfield,/fieldlines, vectordist = 0, $
;                              TITLE = '!4Magnetic Field Lines!N', $
;                              /POverTrans, /noproj, /dx, /track, NUMVECTS = 125 ,$
;                             antialias = 8 , RES = [600,600], LREF = 0.97 ;,FILEOUT = 'mag_fld_3400.tif'
 
; EM Energy 3D 

; osiris_analysis_3d, factor = 2, smooth = 5, $
;                     isolevels = 0.25*[0.75,0.5, 0.25], /absisolevels, $
;                      low =       [ 1,  1  , 1], $
;                      Color  = [[255b,000b,000b,255b], $
;                                [255b,255b,000b,128b], $
;                                [000b,255b,000b,064b] $
;                               ], $
;                      Bottom = [[128b,000b,000b,255b], $
;                               [128b,128b,000b,255b], $
;                              [000b,128b,000b,255b] $
;                            ], $
;                     /dx,  antialias = 8, RES = [1024,1024],$
;                     TITLE = '!4EM Energy!N', FILEOUT = 'em_ene_3400.tif',$
;                     /POVERTRANS, PROJCT = 1                    
                           

; Mass Density 2D
;
; x2x1-1400
; x2x1-2600
; x2x1-3400

;osiris_analysis_2d,  Title = 'Mass Density', /dx, /abs, zmin = 0., zmax = 5, $
;                     FONT = 1, xtitle = 'x1 [ c / !Mw!Dp!N ]', ytitle = 'x2 [ c / !Mw!Dp!N ]',$
;                     ztitle = 'a.u.', $
;                     PSFILE = 'x2x1-3400.ps', RES = [10.,10.], CHARSIZE = 0.5

; EM Energy 2D  
;
; The TOTEM files are corrupted so we use TOTB and TOTE and add them
 
;osiris_analysis_2d,  Title = 'EM Energy', /dx, ADDDATA = 1, zmin = 0., zmax = 3.7, $
;                     FONT = 1, xtitle = 'x1 [ c / !Mw!Dp!N ]', ytitle = 'x2 [ c / !Mw!Dp!N ]',$
;                     ztitle = 'a.u.', $
;                     PSFILE = 'EMen-3400.ps', RES = [10.,10.], CHARSIZE = 0.5

; Magnetic Field 2D

;osiris_analysis_2D_vfield, Title = '!4B!N-Field', /dx, $
;                           FONT = 1, xtitle = 'x1 [ c / !Mw!Dp!N ]', ytitle = 'x2 [ c / !Mw!Dp!N ]',$ 
;                           ztitle = 'a.u.', xrange = [40,80.1], yrange = [40,80.1], NUMVECTS = [25,25], $
;                           LREF = 1.12, zmin = 0, zmax = 1.12, $
;                           PSFILE = 'bvfield-3400.ps', RES = [10.,10.], CHARSIZE = 0.5
                           
                           
                           
;combine_movie_tiff, 3, DIST=[2,2]

end