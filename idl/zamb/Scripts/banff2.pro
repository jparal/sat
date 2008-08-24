;--------------------------------------------------
; Single field component
;--------------------------------------------------

  osiris_analysis_3D,  /track, isolevel = 0.7*[0.1, -0.5, -0.4, -0.2, -0.1], /absisolevels,$
                      color = [[255,0,0,255], $
                                [0,0,125,200], $
                                [0,255,255,60], $
                                [0,255,0,60],$
                                [255,255,0,60]], $
                      bottom = [[255,0,0,255], $
                                [0,0,125,200], $
                                [0,255,255,60], $
                                [0,255,0,60],$
                                [255,255,0,60]]*0.5, $          
                      low = [1,0,0,0,0],$
                      ratio = [13.,4.,4.], $;projCT = 25, /povertrans, $
                      xrange = [0.,13.], yrange = [3.,7.], zrange = [3.,7.]


;--------------------------------------------------
; Add square of field components (all 3 field components)
;--------------------------------------------------

; osiris_analysis_3D,  /track,/squared, adddata = 2, $
;                      isolevel = 0.49*[0.25, 0.16, 0.04, 0.01],$
;                      color = [ $
;                                [0,0,125,200], $
;                                [0,255,255,100], $
;                                [0,255,0,100],$
;                                [255,255,0,100]], $
;                     /invcolors,$ 
;                     ratio = [13.,4.,4.] , /povertrans, $
;                     xrange = [0.,13.], yrange = [3.,7.], zrange = [3.,7.]


; osiris_analysis_3D_vfield, /IGNORE_DIFF, xrange = [0.,13.], yrange = [3.,7.], zrange = [3.,7.],  $
;                            isolevel = 0.7*[0.5, 0.4, 0.2, 0.1], /absisolevels,/fieldlines, $
;                            color = [ $ 
;                                  [0,0,125,200], $
 ;                                 [0,255,255,100], $
 ;                                 [0,255,0,100],$
 ;                                 [255,255,0,100]], $
 ;;                           ratio = [13.,4.,4.], $
 ;                           /novectorfield, /track, VECTORDIST = 0, NUMVECTS = [10,4,4], $
 ;                           Title = 'Force Fields, Symmetric Case',  /arrow, radius = -0.0003

;osiris_analysis_3D_vfield, xrange = [0.,13.], yrange = [3.,7.], zrange = [3.,7.], /IGNORE_DIFF, $
;                           /noiso, isolevel = 0.7*[0.5, 0.4, 0.2, 0.1], /absisolevels,lref = .4, $
;                           color = [ $ 
;                                 [0,0,125,200], $
;                                 [0,255,255,100], $
;                                 [0,255,0,100],$
;                                 [255,255,0,100]], $
;                           slices = [[1,5.],[2,5.],[0,10.]], MIN = 0, MAX = 0.5,zoom = 1.6,$
;                           ratio = [13.,4.,4.], $
;                           /novectorfield, /track, VECTORDIST = 0, NUMVECTS = 125, $
;                           Title = 'Focusing Fields, Non-Symmetric Case', Antialias = 8, FILEOUT = 'plot2.tif'
                           
                           


;osiris_analysis_3D, /dx, /track, isolevel = 0.5*[0.1], /absisolevels

    
end