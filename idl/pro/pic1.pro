;
;
  u=-1.33
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
  d1,bx,cbx
  d1,by,cby
  d1,bz,cbz

  bx=cbx
   by=cby
   bz=cbz
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
if (a eq 'y') then begin
set_plot,'ps'
device,filename='res.ps',/color,/land
endif else begin
set_plot,'x'
endelse
!p.multi=[0,1,3,0,0]
!p.title='!18 y=2.5, z=2.5, t=10 '
rh2, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff 
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mom !18 x  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18'
rh3, u, dn , ux, uy ,uz,pe,px,py,pz,pxy, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mom !18 y  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18'
rh4, u, dn , ux, uy ,uz,pe,px,py,pz,pxz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mom !18 z  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18  '
;
read,'next ',b
;
if (a eq 'y') then begin
device,/close
set_plot,'ps'
device,filename='res1.ps',/color,/land
endif
;
plot,ix,dn,title='!N!5 Graph density !4 q  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!4 q/q!18!i0 '
;
 rh0, u, dn , ux, uy ,uz,pe,px,py,pz,pxy,pxz,pxxx,$
    pxyz, sx, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - Energy  ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18   '

rh1, u, dn , ux, uy ,uz,pe,px,py,pz, bx, by, bz, ff
plot,ix,ff,$
title='!N!5 Graph RH-rel. - mass !18 ', $
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 ytitle='!N!18 '
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
