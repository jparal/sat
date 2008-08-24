;
;
 !p.background=255
  !p.color=0
   !p.charsize=1.
;
  ss=size(bx)
  sx=ss(1)
  ix=findgen(sx)*dx
  ipx=(findgen(sx-1)+.5)*dx
  inte,ex
  inte,ey
  inte,ez
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
  d1,dn,cdn
  d1,pe,cpe
;
  rot,dx,dy,dz, bx,by,bz,jx,jy,jz
  d1,bx,cbx
  d1,by,cby
  d1,bz,cbz
  d1,jx,cjx
  d1,jy,cjy
  d1,jz,cjz

  bx=cbx
   by=cby
   bz=cbz
   jx=cjx
   jy=cjy
   jz=cjz
   ex=cex
   ey=cey
   ez=cez
   ux=cux
   uy=cuy
   uz=cuz
   px=cpx
   py=cpy
   pz=cpz
   pxy=cpxy
   pyz=cpyz
   pxz=cpxz
   pxxx=cpxxx
   pxyz=cpxyz
   dn=cdn
   pe=cpe
  
  sx=ey*bz-by*ez
  sy=ez*bx-bz*ex
  sz=ex*by-bx*ey
a=' '
b=' '
kkk:
 read,' output to files (y) ',a
 read,' u= ',u
if (a eq 'y') then begin
set_plot,'ps'
device,/land,filename='res.ps',/color
endif else begin
set_plot,'x'
endelse
to_color
!p.multi=[0,2,4,0,0]
!p.title='!18 y=2.5, z=2.5, t=10 '
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 ',color=0
plot,ix,sqrt(bx^2+by^2+bz^2),$
title='!N!5 Graph !18 B ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!e2!N/B!S!i0!R!e2',color=0
plot,ix,bx,title='!N!5 Graph !18 B!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!ix!N/B!i0' ,color=0 
plot,ix,ex,title='!N!5 Graph !18 E!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!ix!N/(v!ia!NB!i0!n) ',color=0
plot,ix,by,title='!N!5 Graph !18B!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!iy!N/B!i0 ',color=0
plot,ix,ey,title='!N!5 Graph !18 E!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!iy!N/(v!ia!NB!i0!n) ',color=0
plot,ix,bz,title='!N!5 Graph !18B!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 B!iz!N/B!i0 ',color=0
plot,ix,ez,title='!N!5 Graph !18 E!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 E!iz!N/(v!ia!NB!i0!n) ',color=0
;
read,'next ?',b
;
plot,ix,dn,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 ',color=0
plot,ipx,sqrt(jx^2+jy^2+jz^2),$
title='!N!5 Graph !18 J ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!e2!N/?!S!i0!R!e2',color=0
plot,ix,sx,title='!N!5 Graph !18 S!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!ix!N/B!i0',color=0
plot,ipx,jx,title='!N!5 Graph !18 J!ix ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!ix!N/(v!ia!NB!i0!n) ',color=0
plot,ix,Sy,title='!N!5 Graph !18S!iy ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!iy!N/B!i0 ',color=0
plot,ipx,jy,title='!N!5 Graph !18 J!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!iy!N/(v!ia!NS!i0!n) ',color=0
plot,ix,Sz,title='!N!5 Graph !18S!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 S!iz!N/B!i0 ',color=0
plot,ipx,jz,title='!N!5 Graph !18 J!iz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 J!iz!N/(v!ia!NS!i0!n) ',color=0
;
read,'next ?',b
;
plot,ix,px,title='!N!5 Graph !18 p!ixx!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixx ',color=0
plot,ix,pxy,$
title='!N!5 Graph !18 p!ixy!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixy!N',color=0
plot,ix,py,title='!N!5 Graph !18 p!iyy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!iyy!N' ,color=0
plot,ix,pxz,title='!N!5 Graph !18 p!ixz!N ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!ixz!N ',color=0
plot,ix,pz,title='!N!5 Graph !18p!izz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!izz!N ',color=0
plot,ix,pyz,title='!N!5 Graph !18 p!iyz ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 p!iyz!N ',color=0
plot,ix,0.5*(pxxx+pxyz),title='!N!5 Graph !18q!ix ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 q!ix!N ',color=0
plot,ix,dn,title='!N!5 Graph !4 q  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 ',color=0
;
read,'next ?',b
;
plot,ix,ux,title='!N!5 Graph !18 u!ix!N  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!ix/v!ia ',color=0
rh2, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff 
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mom !18 x  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18',color=0
plot,ix,uy,title='!N!5 Graph !18 u!iy ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!iy!N/v!ia!N',color=0
rh3, u, dn , ux, uy ,uz,pe,px,py,pz,pxy, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mom !18 y  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18',color=0
plot,ix,uz,title='!N!5 Graph !18u!iz ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 u!iz!N/v!ia ',color=0
rh4, u, dn , ux, uy ,uz,pe,px,py,pz,pxz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mom !18 z  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18  ',color=0
 rh0, u, dn , ux, uy ,uz,pe,px,py,pz,pxy,pxz,pxxx,$
    pxyz, sx, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - Energy  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18   ',color=0

rh1, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mass !18 ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 ',color=0
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
