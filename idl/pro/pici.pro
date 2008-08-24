;
  read,'x =',x
  ss=size(bx)
  !p.charsize=2.7

  if(abs(x) eq 1)then begin
  sx=ss(1)
  sy=ss(3)
  ix=findgen(sx)*dx
  iy=findgen(sy)*dz
  endif

  if(abs(x) eq 2)then begin
  sx=ss(1)
  sy=ss(2)
  ix=findgen(sx)*dx
  iy=findgen(sy)*dy
  endif

  if(x ge 0)then begin
  d2,ux,cux,x=x
  d2,uy,cuy,x=x
  d2,uz,cuz,x=x
  d2,pxxx,cpxxx,x=x
  d2,pxyz,cpxyz,x=x
  d2,dn,cdn,x=x
;
  d2,bx,cbx,x=x
  d2,by,cby,x=x
  d2,bz,cbz,x=x

   bx=cbx
   by=cby
   bz=cbz
   jx=0
   jy=0
   jz=0
   ex=0
   ey=0
   ez=0
   ux=cux
   uy=cuy
   uz=cuz
   px=0
   py=0
   pz=0
   pxy=0
   pyz=0
   pxz=0
   pxxx=cpxxx
   pxyz=cpxyz
   dn=cdn
   pe=0
   endif else begin

   if(x eq -1)then begin
   bx=reform(bx(*,0,*))
   by=reform(by(*,0,*))
   bz=reform(bz(*,0,*))
   jx=0
   jy=0
   jz=0
   ex=0
   ey=0
   ez=0
   ux=reform(ux(*,0,*))
   uy=reform(uy(*,0,*))
   uz=reform(uz(*,0,*))
   px=0
   py=0
   pz=0
   pxy=0
   pyz=0
   pxz=0
   pxxx=reform(pxxx(*,0,*))
   pxyz=reform(pxyz(*,0,*))
   dn=reform(dn(*,0,*))
   pe=0
   endif else begin
   bx=reform(bx(*,*,0))
   by=reform(by(*,*,0))
   bz=reform(bz(*,*,0))
   jx=0
   jy=0
   jz=0
   ex=0
   ey=0
   ez=0
   ux=reform(ux(*,*,0))
   uy=reform(uy(*,*,0))
   uz=reform(uz(*,*,0))
   px=0
   py=0
   pz=0
   pxy=0
   pyz=0
   pxz=0
   pxxx=reform(pxxx(*,*,0))
   pxyz=reform(pxyz(*,*,0))
   dn=reform(dn(*,*,0))
   pe=0
   endelse
   
   endelse
  
a=' '
b=' '
kkk:
 read,' output to files (y) ',a
if (a eq 'y') then begin
set_plot,'ps'
device,/land,filename='dn.ps',/color
endif else begin
set_plot,'x'
endelse
to_color
!p.multi=0
image_cont,dn
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='b.ps',/color
endif
image_cont,sqrt(bx^2+by^2+bz^2)
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='bz.ps',/color
endif
image_cont,bz
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='by.ps',/color
endif
;
image_cont,by
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='bx.ps',/color
endif
;
image_cont,bx
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='qx.ps',/color
endif
image_cont,0.5*(pxxx+pxyz)

read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='ux.ps',/color
endif
image_cont,ux
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='uy.ps',/color
endif
image_cont,uy
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='uz.ps',/color
endif
image_cont,uz
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
