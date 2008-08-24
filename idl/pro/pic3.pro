;
;
  !p.background=255
  !p.color=0
  !p.charsize=1.7
  ss=size(bx)
  sx=ss(1)
  read,'y,z =',y,z
  ix=findgen(sx)*dx
  ipx=findgen(sx-1)*dx+.5*dx
  cix=findgen(sx)*dx
  cipx=findgen(sx-1)*dx+.5*dx
  inte,ex
  inte,ey
  inte,ez
  rot,dx,dy,dz, bx,by,bz,jx,jy,jz
  sx=ey*bz-by*ez
  sy=ez*bx-bz*ex
  sz=ex*by-bx*ey
  d1,bx,cbx
  d1,by,cby
  d1,bz,cbz
  d1,sx,csx
  d1,sy,csy
  d1,sz,csz
  d1,ex,cex
  d1,ey,cey
  d1,ez,cez
  d1,ux,cux
  d1,uy,cuy
  d1,uz,cuz
  d1,px,cpx
  d1,py,cpy
  d1,pz,cpz
  d1,pxy,cpxy
  d1,pyz,cpyz
  d1,pxz,cpxz
  d1,pxxx,cpxxx
  d1,pxyz,cpxyz
  d1,jx,cjx
  d1,jy,cjy
  d1,jz,cjz
  d1,dn,cdn
  d1,pe,cpe
;
  bx=bx(*,y,z)
  by=by(*,y,z)
  bz=bz(*,y,z)
  jx=jx(*,y,z)
  jy=jy(*,y,z)
  jz=jz(*,y,z)
  ux=ux(*,y,z)
  uy=uy(*,y,z)
  uz=uz(*,y,z)
  ex=ex(*,y,z)
  ey=ey(*,y,z)
  ez=ez(*,y,z)
  sx=sx(*,y,z)
  sy=sy(*,y,z)
  sz=sz(*,y,z)
  px=px(*,y,z)
  py=py(*,y,z)
  pz=pz(*,y,z)
  pxy=pxy(*,y,z)
  pyz=pyz(*,y,z)
  pxz=pxz(*,y,z)
  pxyz=pxyz(*,y,z)
  pxxx=pxxx(*,y,z)
  pe=pe(*,y,z)

a=' '
b=' '
kkk:
 read,' output to files (y) ',a
 read, ' u= ',u 
if (a eq 'y') then begin
set_plot,'ps'
device,/land,filename='res.ps',/color
endif else begin
read,' x-windows',b
if(b eq 'y' )then begin
set_plot,'x'
endif else begin
set_plot,'tek'
endelse
endelse
to_color
!p.multi=[0,2,4,0,0]
!p.title='!18 y=2.5, z=2.5, t=10 '
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cdn,color=2
plot,ix,sqrt(bx^2+by^2+bz^2),$
title='!N!5 Graph !18 B ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
color=0
oplot,cix,sqrt(cbx^2+cby^2+cbz^2),$
color=2 
plot,ix,bx,title='!N!5 Graph !18 B!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
color=0 
oplot,cix,cbx ,color=2
plot,ix,ex,title='!N!5 Graph !18 E!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cex,color=2
plot,ix,by,title='!N!5 Graph !18B!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cby,color=2
plot,ix,ey,title='!N!5 Graph !18 E!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cey,color=2
plot,ix,bz,title='!N!5 Graph !18B!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cbz,color=2
plot,ix,ez,title='!N!5 Graph !18 E!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cez,color=2
;
read,'next ?',b
;
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cdn,color=2
plot,ipx,sqrt(jx^2+jy^2+jz^2),$
title='!N!5 Graph !18 J ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cipx,sqrt(cjx^2+cjy^2+cjz^2),color=2 
plot,ix,sx,title='!N!5 Graph !18 S!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,csx,color=2 
plot,ipx,jx,title='!N!5 Graph !18 J!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cipx,cjx,color=2
plot,ix,Sy,title='!N!5 Graph !18S!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,csy,color=2
plot,ipx,jy,title='!N!5 Graph !18 J!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cipx,cjy,color=2
plot,ix,Sz,title='!N!5 Graph !18S!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,csz,color=2
plot,ipx,jz,title='!N!5 Graph !18 J!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cipx,cjz,color=2
;
read,'next ?',b
;
plot,ix,px,title='!N!5 Graph !18 p!ixx!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cpx,color=2
plot,ix,pxy,$
title='!N!5 Graph !18 p!ixy!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cpxy,color=2 
plot,ix,py,title='!N!5 Graph !18 p!iyy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cpy,color=2
plot,ix,pxz,title='!N!5 Graph !18 p!ixz!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cpxz,color=2
plot,ix,pz,title='!N!5 Graph !18p!izz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cpz,color=2
plot,ix,pyz,title='!N!5 Graph !18 p!iyz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cpyz,color=2
plot,ix,.5*(pxyz+pxxx),title='!N!5 Graph !18q!ix ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,.5*(cpxyz+cpxxx),color=2
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cdn,color=2
;
read,'next ?',b
;
plot,ix,ux,title='!N!5 Graph !18 u!ix!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cux,color=2
rh2, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff 
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mom !18 x  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
rh2, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz, cbx, cby, cbz, ff
oplot,cix,ff,color=2
plot,ix,uy,title='!N!5 Graph !18 u!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cuy,color=2
rh3, u, dn , ux, uy ,uz,pe,px,py,pz,pxy, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mom !18 y  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
rh3, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz,cpxy, cbx, cby, cbz, ff
oplot,cix,ff,color=2
plot,ix,uz,title='!N!5 Graph !18u!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,cix,cuz,color=2
rh4, u, dn , ux, uy ,uz,pe,px,py,pz,pxz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mom !18 z  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
rh4, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz,cpxz, cbx, cby, cbz, ff
oplot,cix,ff,color=2
 rh0, u, dn , ux, uy ,uz,pe,px,py,pz,pxy,pxz,pxxx,$
    pxyz, sx, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - Energie  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
 rh0, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz,cpxy,cpxz,cpxxx,$
    cpxyz, csx, ff
oplot,cix,ff,color=2

rh1, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph Rel.R.-H. - mass !18 ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
rh1, u, cdn , cux, cuy ,cuz,cpe,cpx,cpy,cpz, cbx, cby, cbz, ff
oplot,cix,ff,color=2 
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
