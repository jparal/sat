;
  read,'x =',x
  ss=size(bx)
  sx=ss(1)
  sy=ss(2)
  ix=findgen(sx)*dx
  iy=findgen(sy)*dy
  !p.charsize=2.7

   bx=reform(bx(*,*,0))
   by=reform(by(*,*,0))
   bz=reform(bz(*,*,0))
   dn=reform(dn(*,*,0))
  
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
!p.title='!18 y=2.5, z=2.5, t=10 '
shade_surf,dn,ix,iy,title='!N!5 Graph !4 q  ',$
xtitle='!N!18 X  ',$
 ytitle='!N!18 Z '
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='b.ps',/color
endif
shade_surf,sqrt(bx^2+by^2+bz^2),ix,iy,$
title='!N!5 Graph !18 B ', $
xtitle='!N!18 x   ',$
 ytitle='!N!18 z '
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='bz.ps',/color
endif
shade_surf,bz,ix,iy,title='!N!5 Graph !18B!iz ',$
xtitle='!N!18 x   ',$
 ytitle='!N!18 y  '
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='by.ps',/color
endif
;
shade_surf,by,ix,iy,title='!N!5 Graph !18B!iy ',$
xtitle='!N!18 x   ',$
 ytitle='!N!18 y  '
;
read,'next ?',b
;
if (a eq 'y') then begin
device,/land,filename='bx.ps',/color
endif
;
shade_surf,bx,ix,iy,title='!N!5 Graph !18B!ix ',$
xtitle='!N!18 x   ',$
 ytitle='!N!18 y  '
;
;
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
