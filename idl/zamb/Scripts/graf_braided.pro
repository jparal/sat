; Mutual Attraction of laser beams in plasmas: Braided Light
;
; C. Ren, R. G. Hemker, R. A. Fonseca, B. J. Duda, and W. B. Mori
;
; Scripts to generate the plots for the paper 

pro graf_braided

; osiris_gen_envelope, /mirror, kmin = 10, filter = 0.5 , /dx

val = 5.5
cent_rad = 0.012
line_thick = 3

;osiris_analysis_3D,  $
;                    lasercentroid = 0, LASERCENTMINVAL = val, $
;                    isolevel = [val], /ABSISOLEVELS, $
;                    color = [[000b,000b, 255b, 100b]], TRAJCOLOR = [000b,000b, 255b, 255b], $
;                    /DATA2, d2color = [[255b,000b, 000b, 100b]], TRAJ2COLOR = [255b,000b, 000b, 255b], $
;                    /povertrans, title = '', subtitle='' , /invcolors, /noproj, $
;                    TRAJRAD = cent_rad,TRAJ2RAD = cent_rad, TRAJTHICK = line_thick, TRAJ2THICK = line_thick , $
;                    antialias = 8 , RES = [1200,1200], FILEOUT = 'white.tif'

osiris_analysis_3D,  $
                    lasercentroid = 0, LASERCENTMINVAL = val, $
                    isolevel = [ val], /ABSISOLEVELS, $
                    color = [[000b,64b, 255b, 120b]], TRAJCOLOR = [000b,64b, 255b, 255b], $
                    /DATA2, d2color = [[255b,64b, 000b, 120b]], TRAJ2COLOR = [255b,64b, 000b, 255b], $
                    /povertrans, title = '', subtitle = '', SUPERSAMPLING=5, $
                    TRAJRAD = cent_rad,TRAJ2RAD = cent_rad, TRAJTHICK = line_thick, TRAJ2THICK = line_thick, $
                    antialias = 8 , RES = [1200,1200], FILEOUT = 'color.tif'
                    
                    

                     
end