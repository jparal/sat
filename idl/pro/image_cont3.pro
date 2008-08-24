pro image_cont3, a
     px=!x.window * !d.x_size
     py=!y.window * !d.y_size
     sz= size(a)    
erase
tvscl,a,px(0),py(0)
contour,a,/noerase,xstyle=1,ystyle=1, $
   position=[px(0),py(0),px(0)+sz(1)-1,$
   py(0)+sz(2)-1],/device
return
end
