
pro focus_anim

osiris_analysis_3D_vfield, xrange = [0.,13.], yrange = [3.,7.], zrange = [3.,7.], /IGNORE_DIFF, $
                           /noiso, isolevel = 0.7*[0.5, 0.4, 0.2, 0.1], /absisolevels,lref = .4, $
                           color = [ $ 
                                 [0,0,125,200], $
                                 [0,255,255,100], $
                                 [0,255,0,100],$
                                 [255,255,0,100]], $
                           ;slices = [[1,5.],[2,5.],[0,10.]], $ 
                           MIN = 0, MAX = 0.5,zoom = 1.6,$
                           ratio = [13.,4.,4.], $
                           /novectorfield, /track, VECTORDIST = 0, NUMVECTS = 125, /noproj, /fieldlines, $
                           Title = 'Focusing Fields, Non-Symmetric Case', RES = [350,350]
                           
                           




    
end