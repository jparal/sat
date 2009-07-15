tops
device,/land,/color,file='sp_mir.ps'

rd1seq,'By*_',5000,50,10100,by
rd1seq,'Bz*_',5000,50,10100,bz

ss=size(by)
t=(ss(2))*.5

x=64.
foutr,by,x,t,fy,ix,iy
foutr,bz,fz
ff=sqrt(fy^2+fz^2)

loadct,3

!x.margin=[5.,3.]

!p.font=1
!p.charsize=2.5
!p.background=0
!p.thick=2

contour,/fill,-ff^.8,ix,iy,xra=[0.,1.5],yra=[-1.,1.],nlev=32, $
  title='DISPERSION RELATION',xtitle='wave vector',ytitle='omega'

rd1,'../lin/mir/Kve*mir',k1
rd1,'../lin/mir/Ga*mir',gam1
rd1,'../lin/mir/Om*mir',ome1

gam1=gam1*6.

oplot,k1,ome1,thick=8
oplot,k1,gam1,line=2,thick=8
oplot,k1,-ome1,thick=8

rd1,'../lin/nemo/Kve*nemo',k2
rd1,'../lin/nemo/Ga*nemo',gam2
rd1,'../lin/nemo/Om*nemo',ome2

gam2=gam2*6.

oplot,k2,ome2,thick=8,color=200
oplot,k2,gam2,line=2,thick=8,color=200
oplot,k2,-ome2,thick=8,color=200

device,/close

end
