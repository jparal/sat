tops

rd1seq,'By*_',0,50,10100,by

ss=size(by)

ix=findgen(ss(1))*0.5
iy=findgen(ss(2))*0.5

loadct,26

!x.margin=[5.,3.]

!p.font=1
!p.charsize=2.5
!p.background=1
!p.thick=2

device,/land,/color,file='by_mir.ps'

contour,/fill,by,ix,iy,nlev=32,yra=[0,300],/xst,/yst, $
  title='EVOLUTION  By',xtitle='x',ytitle='time'

device,/close

end
