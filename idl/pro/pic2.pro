;
;
 restore,'sh3'
  u=-1.36
  y=10
  z=10
  t=10.
  !p.background=255
  !p.color=0
  ss=size(bx)
  sx=ss(1)
  cix=findgen(sx)*dx
  cipx=(findgen(sx-1)+.5)*dx
  inte,ex
  inte,ey
  inte,ez
  rot,dx,dy,dz, bx,by,bz,jx,jy,jz
  sx=ey*bz-by*ez
  sy=ez*bx-bz*ex
  sz=ex*by-bx*ey
  cbx=bx(*,y,z)
  cby=by(*,y,z)
  cbz=bz(*,y,z)
  csx=sx(*,y,z)
  csy=sy(*,y,z)
  csz=sz(*,y,z)
  cex=ex(*,y,z)
  cey=ey(*,y,z)
  cez=ez(*,y,z)
  cux=ux(*,y,z)
  cuy=uy(*,y,z)
  cuz=uz(*,y,z)
  cpx=px(*,y,z)
  cpy=py(*,y,z)
  cpz=pz(*,y,z)
  cpxy=pxy(*,y,z)
  cpyz=pyz(*,y,z)
  cpxz=pxz(*,y,z)
  cpxxx=pxxx(*,y,z)
  cpxyz=pxyz(*,y,z)
  cjx=jx(*,y,z)
  cjy=jy(*,y,z)
  cjz=jz(*,y,z)
  cdn=dn(*,y,z)
  cpe=pe(*,y,z)
;
 restore,'sh4'
  ss=size(bx)
  sx=ss(1)
  ix=findgen(sx)*dx
  ipx=(findgen(sx-1)+.5)*dx
  inte,ex
  inte,ey
  inte,ez
  ex=ex(*,y,z)
  ey=ey(*,y,z)
  ez=ez(*,y,z)
  ux=ux(*,y,z)
  uy=uy(*,y,z)
  uz=uz(*,y,z)
  px=px(*,y,z)
  py=py(*,y,z)
  pz=pz(*,y,z)
  pxy=pxy(*,y,z)
  pyz=pyz(*,y,z)
  pxz=pxz(*,y,z)
  pxxx=pxxx(*,y,z)
  pxyz=pxyz(*,y,z)
  dn=dn(*,y,z)
  pe=pe(*,y,z)
;
  rot,dx,dy,dz, bx,by,bz,jx,jy,jz
  bx=bx(*,y,z)
  by=by(*,y,z)
  bz=bz(*,y,z)
  jx=jx(*,y,z)
  jy=jy(*,y,z)
  jz=jz(*,y,z)
  sx=ey*bz-by*ez
  sy=ez*bx-bz*ex
  sz=ex*by-bx*ey
a=' '
b=' '
kkk:
 read,' output to files (y) ',a
if (a eq 'y') then begin
set_plot,'ps'
device,/land,filename='res.ps',/color
endif else begin
set_plot,'tek'
endelse
to_color
!p.multi=[0,2,4,0,0]
!p.title='!18 y=2.5, z=2.5, t=10 '
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 ',color=0
oplot,cix,cdn,color=2
plot,ix,bx^2+by^2+bz^2,$
title='!N!5 Graph !18 B!e2 ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!e2!N/B!S!i0!R!e2',color=0
oplot,cix,cbx^2+cby^2+cbz^2,$
color=2 
plot,ix,bx,title='!N!5 Graph !18 B!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!ix!N/B!i0' ,color=0 
oplot,cix,cbx ,color=2
plot,ix,ex,title='!N!5 Graph !18 E!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!ix!N/(v!ia!NB!i0!n) ',color=0
oplot,cix,cex,color=2
plot,ix,by,title='!N!5 Graph !18B!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!iy!N/B!i0 ',color=0
oplot,cix,cby,color=2
plot,ix,ey,title='!N!5 Graph !18 E!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!iy!N/(v!ia!NB!i0!n) ',color=0
oplot,cix,cey,color=2
plot,ix,bz,title='!N!5 Graph !18B!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!iz!N/B!i0 ',color=0
oplot,cix,cbz,color=2
plot,ix,ez,title='!N!5 Graph !18 E!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!iz!N/(v!ia!NB!i0!n) ',color=0
oplot,cix,cez,color=2
;
read,'next ?',b
;
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 ',color=0
oplot,cix,cdn,color=2
plot,ipx,jx^2+jy^2+jz^2,$
title='!N!5 Graph !18 J!e2 ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!e2!N/?!S!i0!R!e2',color=0
oplot,cipx,cjx^2+cjy^2+cjz^2,color=2 
plot,ix,sx,title='!N!5 Graph !18 S!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!ix!N/B!i0',color=0
oplot,cix,csx,color=2 
plot,ipx,jx,title='!N!5 Graph !18 J!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!ix!N/(v!ia!NB!i0!n) ',color=0
oplot,cipx,cjx,color=2
plot,ix,Sy,title='!N!5 Graph !18S!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!iy!N/B!i0 ',color=0
oplot,cix,csy,color=2
plot,ipx,jy,title='!N!5 Graph !18 J!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!iy!N/(v!ia!NS!i0!n) ',color=0
oplot,cipx,cjy,color=2
plot,ix,Sz,title='!N!5 Graph !18S!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!iz!N/B!i0 ',color=0
oplot,cix,csz,color=2
plot,ipx,jz,title='!N!5 Graph !18 J!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!iz!N/(v!ia!NS!i0!n) ',color=0
oplot,cipx,cjz,color=2
;
read,'next ?',b
;
plot,ix,px,title='!N!5 Graph !18 p!ixx!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixx ',color=0
oplot,cix,cpx,color=2
plot,ix,pxy,$
title='!N!5 Graph !18 p!ixy!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixy!N',color=0
oplot,cix,cpxy,color=2 
plot,ix,py,title='!N!5 Graph !18 p!iyy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!iyy!N' ,color=0
oplot,cix,cpy,color=2
plot,ix,pxz,title='!N!5 Graph !18 p!ixz!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixz!N ',color=0
oplot,cix,cpxz,color=2
plot,ix,pz,title='!N!5 Graph !18p!izz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!izz!N ',color=0
oplot,cix,cpz,color=2
plot,ix,pyz,title='!N!5 Graph !18 p!iyz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!iyz!N ',color=0
oplot,cix,cpyz,color=2
plot,ix,pxxx,title='!N!5 Graph !18p!ixxx ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixxx!N ',color=0
oplot,cix,cpxxx,color=2
plot,ix,pxyz,title='!N!5 Graph !18 p!ixyy!N+p!ixzz!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixyy!N+p!ixzz!N  ',color=0
oplot,cix,cpxyz,color=2
;
read,'next ?',b
;
plot,ix,ux,title='!N!5 Graph !18 u!ix!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!ix/v!ia ',color=0
oplot,cix,cux,color=2
rh2, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff 
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mom !18 x  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18',color=0
rh2, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz, cbx, cby, cbz, ff
oplot,cix,ff,color=2
plot,ix,uy,title='!N!5 Graph !18 u!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!iy!N/v!ia!N',color=0
oplot,cix,cuy,color=2
rh3, u, dn , ux, uy ,uz,pe,px,py,pz,pxy, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mom !18 y  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18',color=0
rh3, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz,cpxy, cbx, cby, cbz, ff
oplot,cix,ff,color=2
plot,ix,uz,title='!N!5 Graph !18u!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!iz!N/v!ia ',color=0
oplot,cix,cuz,color=2
rh4, u, dn , ux, uy ,uz,pe,px,py,pz,pxz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mom !18 z  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18  ',color=0
rh4, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz,cpxz, cbx, cby, cbz, ff
oplot,cix,ff,color=2
 rh0, u, dn , ux, uy ,uz,pe,px,py,pz,pxy,pxz,pxxx,$
    pxyz, sx, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - Energie  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18   ',color=0
 rh0, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz,cpxy,cpxz,cpxxx,$
    cpxyz, csx, ff
oplot,cix,ff,color=2

rh1, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mass !18 ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 ',color=0
rh1, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz, cbx, cby, cbz, ff
oplot,cix,ff,color=2 
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
