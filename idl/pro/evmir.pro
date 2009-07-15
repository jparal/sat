rd1seq1,'A*_',1000,1000,10000,an
rd1seq1,'Em*_',1000,1000,10000,em
ss=size(an)

; time
tt=findgen(ss(1))+1
tt=tt*0.01 * 5.   ; timestep * frequency of conserv
rem=em/em(0)-1 
rem=rem*100
tops
!x.margin=[2.,3.]

!p.font=1
!p.charsize=2.5
!p.thick=4

coloran=50
colordb=250

device,/landscape,/color,file='ev_mir.ps'

loadct,40
plot,tt,an,xra=[0.,300.],yra=[-.5,6.5],/yst,/nodata, $
  xtitle='time  [1/Omega_p]',title='RUN EVOLUTION'

oplot,tt,an,thick=8,color=coloran
xyouts,150.,0.5, 'Anisotropy',charsize=4,color=coloran
oplot,tt,rem,thick=8,color=colordb
xyouts,150.,3.5, 'Wave energy',charsize=4,color=colordb

device,/close
end

  
