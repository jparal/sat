;osiris_analysis, /dx, $
;    isolevels = [ -5., -2.5, 5., 2.5], $
;    low = [0,0,1,1], $
;    color = [ [000b,000b,255b,255b], [000b,255b,255b,128b], [255b,000b,000b,255b], [255b,255b,000b,128b]], $
;    /noproj, /absisolevels, /track
    
    

osiris_analysis_3d, /povertrans, /track, /noiso, lasercentroid = 0, /data2, $
                    trajcolor = [0,0,255,255], traj2color = [255,0,0,255] , $
                    border = 2, $; yrange = [13,23], zrange = [13,23], $
                    antialias = 8, RES = [1024,1024],$
                    TITLE = '!4Laser Centroids!N', FILEOUT = 'laser_cent_1060.tif' 
end