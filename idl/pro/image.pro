;
      pro image, a
;
   
   tv, bytscl(a), !x.window(0), !y.window(0), $
xsize=!x.window(1)-!x.window(0), $
ysize=!y.window(1)-!y.window(0), $
/norm
contour,a,nlevels=0, xstyle=1,ystyle=1,/noerase
 return
  end

