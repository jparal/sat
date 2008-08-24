;
      pro image1, a
;
     px=!x.window * !d.x_size
     py=!y.window * !d.y_size
     sx=(px(1)-px(0)+1)
     sy=(py(1)-py(0)+1)
     print,sx,sy
     sz= size(a)    
;
;    erase
;
     s=fltarr(sx, sy)
     tv, poly_2d(bytscl(a),[[0,0],[sz(1)/sx,0]],[[0,sz(2)/sy],[0,0]],2  $
         ,sx, sy), px(0), py(0)     
   end

