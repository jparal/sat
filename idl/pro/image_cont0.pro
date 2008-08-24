;
 pro image_cont0, a
;
     px=!x.window * !d.x_size
     py=!y.window * !d.y_size
     sx=px(1)-px(0)+1
     sy=py(1)-py(0)+1
     sz= size(a)    
     s=fltarr(sx, sy)
 contour, a, xstyle=1, ystyle=1,/nodata
     tv, poly_2d(bytscl(a),[[0,0],[sz(1)/sx,0]],[[0,sz(2)/sy],[0,0]],2  $
         ,sx, sy), px(0), py(0)     
;        
     contour, a, /noerase, xstyle=1, ystyle=1,/nodata
   end

