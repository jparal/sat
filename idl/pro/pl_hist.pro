restore,'den_profi'
restore,'reso'
ix1=ix1/8000./dxx
ix2=ix2/8000./dxx
ix3=ix3/8000./dxx
ix4=ix4/8000./dxx
!p.charsize=1.5
!p.charthick=2
dxp=.045
dyp=.075
dxop=.06
dyop=3.
ymn=-2.
ymx=6.
vr=27./6.9
yyy=0.5
!p.region=[0.-dxp,2./3.-dyp,2./2. ,3./3.+dyp]
;plot,ix(60:120),dn1(60:120),/xst, $
plot,ix,dn,xrange=[9.5,12.5],/xst, $
Title= ' Density profile '
xyouts,20.3,-1.,'x!4x!3!ipi!n/c',charsize=2.,charthick=2.
oplot,x0*[1.,1.],[0.,4.]
oplot,(x0+dxx)*[1.,1.],[0.,4.]
oplot,(x0+2*dxx)*[1.,1.],[0.,4.]
oplot,(x0+3*dxx)*[1.,1.],[0.,4.]
oplot,(x0+4*dxx)*[1.,1.],[0.,4.] 
xyouts,(x0+dxop),dyop,'a',charsize=3.,charthick=3.
xyouts,(x0+dxop+dxx),dyop,'b',charsize=3.,charthick=3.
xyouts,(x0+dxop+2*dxx),dyop,'c',charsize=3.,charthick=3.
xyouts,(x0+dxop+3*dxx),dyop,'d',charsize=3.,charthick=3.
!p.region=[0.-dxp,1./3.-dyp,1./2.+dxp,2./3.+dyp]
plot ,h1, ix1,yrange=[0.,1.],xrange=[ymn,ymx],/noerase 
xyouts,ymn+yyy, .8,'a',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8 ]
!p.region=[1./2.-2*dxp,1./3.-dyp,2./2. ,2./3.+dyp]
plot, h2,ix2,/noerase,yrange=[0.,1.],xrange=[ymn,ymx]
xyouts,ymn+yyy, .8,'b',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8 ] 
!p.region=[0.-dxp,0.-dyp,1./2.+dxp ,1./3.+dyp]
plot,  h3,ix3,/noerase,yrange=[0.,1.],xrange=[ymn,ymx]
xyouts,ymn+yyy, .8,'c',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8 ]
!p.region=[1./2.-2*dxp,0.-dyp,2./2. ,1./3.+dyp]
plot,  h4,ix4,/noerase,yrange=[0.,1.], xrange=[ymn,ymx]
xyouts,ymn+yyy, .8,'d',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8]
end 
