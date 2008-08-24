;
;
  ss=size(bx)
  sx=ss(1)
  ix=findgen(sx)*dx
  ipx=(findgen(sx-1)+.5)*dx
  inte,ex
  inte,ey
  inte,ez
  rot, bx,by,bz,jx,jy,jz
  sx=ey*bz-by*ez
  sy=ez*bx-bz*ex
  sz=ex*by-bx*ey
;
a=' '
b=' '
kkk:
 read,' output to files (y) ',a
read,'u, y, z, t'
if (a eq 'y') then begin
set_plot,'ps'
device,/land,filename='res.ps'
endif else begin
set_plot,'x'
endelse
!p.multi=[0,2,4,0,0]
!p.title='!18 y=2.5, z=2.5, t=10 '
plot,ix,dn(*,y,z),title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 '
plot,ix,sqrt(bx(*,y,z)^2+by(*,y,z)^2+bz(*,y,z)^2),$
title='!N!5 Graph !18 B ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!e2!N/B!S!i0!R!e2' 
plot,ix,bx(*,y,z),title='!N!5 Graph !18 B!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!ix!N/B!i0' 
plot,ix,ex(*,y,z),title='!N!5 Graph !18 E!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!ix!N/(v!ia!NB!i0!n) '
plot,ix,by(*,y,z),title='!N!5 Graph !18B!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!iy!N/B!i0 '
plot,ix,ey(*,y,z),title='!N!5 Graph !18 E!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!iy!N/(v!ia!NB!i0!n) '
plot,ix,bz(*,y,z),title='!N!5 Graph !18B!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!iz!N/B!i0 '
plot,ix,ez(*,y,z),title='!N!5 Graph !18 E!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!iz!N/(v!ia!NB!i0!n) '
;
read,'next ?',b
;
plot,ix,dn(*,y,z),title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 '
plot,ipx,sqrt(jx(*,y,z)^2+jy(*,y,z)^2+jz(*,y,z)^2),$
title='!N!5 Graph !18 J ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!e2!N/?!S!i0!R!e2' 
plot,ix,sx(*,y,z),title='!N!5 Graph !18 S!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!ix!N/B!i0' 
plot,ipx,jx(*,y,z),title='!N!5 Graph !18 J!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!ix!N/(v!ia!NB!i0!n) '
plot,ix,Sy(*,y,z),title='!N!5 Graph !18S!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!iy!N/B!i0 '
plot,ipx,jy(*,y,z),title='!N!5 Graph !18 J!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!iy!N/(v!ia!NS!i0!n) '
plot,ix,Sz(*,y,z),title='!N!5 Graph !18S!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!iz!N/B!i0 '
plot,ipx,jz(*,y,z),title='!N!5 Graph !18 J!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!iz!N/(v!ia!NS!i0!n) '
;
read,'next ?',b
;
plot,ix,px(*,y,z),title='!N!5 Graph !18 p!ixx!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixx '
plot,ix,pxy(*,y,z),$
title='!N!5 Graph !18 p!ixy!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixy!N' 
plot,ix,py(*,y,z),title='!N!5 Graph !18 p!iyy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!iyy!N' 
plot,ix,pxz(*,y,z),title='!N!5 Graph !18 p!ixz!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixz!N '
plot,ix,pz(*,y,z),title='!N!5 Graph !18p!izz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!izz!N '
plot,ix,pyz(*,y,z),title='!N!5 Graph !18 p!iyz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!iyz!N '
plot,ix,pxxx(*,y,z),title='!N!5 Graph !18p!ixxx ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixxx!N '
plot,ix,pxyz(*,y,z),title='!N!5 Graph !18 p!ixyy!N+p!ixzz!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixyy!N+p!ixzz!N  '
;
read,'next ?',b
;
plot,ix,ux(*,y,z),title='!N!5 Graph !18 u!ix!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!ix/v!ia '
rh2, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff 
plot,ix,ff(*,y,z),$
title='!N!5 Graph Rel.R.-H. - mom !18 x  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18'
plot,ix,uy(*,y,z),title='!N!5 Graph !18 u!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!iy!N/v!ia'
rh3, u, dn , ux, uy ,uz,pe,px,py,pz,pxy, bx, by, bz, ff
plot,ix,ff(*,y,z),$
title='!N!5 Graph Rel.R.-H. - mom !18 y  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18'
plot,ix,uz(*,y,z),title='!N!5 Graph !18u!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!iz!N/v!ia '
rh4, u, dn , ux, uy ,uz,pe,px,py,pz,pxz, bx, by, bz, ff
plot,ix,ff(*,y,z),$
title='!N!5 Graph Rel.R.-H. - mom !18 z  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18  '
 rh0, u, dn , ux, uy ,uz,pe,px,py,pz,pxy,pxz,pxxx,$
    pxyz, sx, ff
plot,ix,ff(*,y,z),$
title='!N!5 Graph Rel.R.-H. - Energie  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18   '

rh1, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff
plot,ix,ff(*,y,z),$
title='!N!5 Graph Rel.R.-H. - mass !18 ', $
 xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 ' 
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
