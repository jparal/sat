restore,'den_prof2d'
restore,'res2d'
ix1=ix1/400./1.22
ix2=ix2/400./1.22
ix3=ix3/400./1.22
ix4=ix4/400./1.22
!p.charsize=1.5
!p.charthick=2
dxp=.05
dyp=.075
dyop=3.
ymn=-2.
ymx=6.
vr=28/7.
yyy=0.5
dd=-7.
dxx=0.5
!p.region=[0.-dxp,2./3.-dyp,2./2. ,3./3.+dyp]
;plot,ix(120:170),dn1(120:170),/xst, $
plot,ix,dn,/xst,yrange=[0.,4.], $
Title= ' Density profile '
xyouts,20.3,-1.,'x!4x!3!ipi!n/c',charsize=2.,charthick=2.
oplot,[17.+dd,17.+dd],[0.,4.]
oplot,[17.+dd+dxx,17.+dd+dxx],[0.,4.]
oplot,[17.+dd+2*dxx,17.+dd+2*dxx],[0.,4.]
oplot,[17.+dd+3*dxx,17.+dd+3*dxx],[0.,4.]
oplot,[17.+dd+4*dxx,17.+dd+4*dxx],[0.,4.] 
xyouts,17.1+dd,3,'a',charsize=3.,charthick=3.
xyouts,17.1+dd+dxx,3,'b',charsize=3.,charthick=3.
xyouts,17.1+dd+2*dxx,3,'c',charsize=3.,charthick=3.
xyouts,17.1+dd+3*dxx,3,'d',charsize=3.,charthick=3.
!p.region=[0.-dxp,1./3.-dyp,1./2.+dxp,2./3.+dyp]
plot ,h1, ix1,yrange=[0.,1.],xrange=[ymn,ymx],/noerase
xyouts,ymn+yyy,0.8,'a',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8000]
!p.region=[1./2.-2*dxp,1./3.-dyp,2./2. ,2./3.+dyp]
plot, h2,ix2,/noerase,yrange=[0.,1.],xrange=[ymn,ymx]
xyouts,ymn+yyy,0.8,'b',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8000] 
!p.region=[0.-dxp,0.-dyp,1./2.+dxp ,1./3.+dyp]
plot,  h3,ix3,/noerase,yrange=[0.,1.],xrange=[ymn,ymx]
xyouts,ymn+yyy,0.8,'c',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8000]
!p.region=[1./2.-2*dxp,0.-dyp,2./2. ,1./3.+dyp]
plot,  h4,ix4,/noerase,yrange=[0.,1.],xrange=[ymn,ymx]
xyouts,ymn+yyy,0.8,'d',charsize=3.,charthick=3.
oplot,[vr,vr],[0.,8000]
end 
