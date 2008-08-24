;
 pro image_cont2, a
;
     px=!x.window * !d.x_size
     py=!y.window * !d.y_size
     sx=px(1)-px(0)+1
     sy=py(1)-py(0)+1
     sz= size(a)    
     contour, a, /nodata
;, xstyle=1, ystyle=1
     s=fltarr(sx, sy)
     tv,congrid(bytscl(a)  $
         ,sx, sy), px(0), py(0)     
;        
   return
   end

