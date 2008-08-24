; get out shortcuts of bz 
; in file 'bz.eps'
;.r
a=' '
bb=' '
kkk:
read,' output to files (y) ',a
;read,' charsize ',ch
bzs=smoothp(bz,3)
;bzs=bz
ch=3.
!p.title='!8 '
!p.charsize=ch
!p.charthick=ch
if (a eq 'y') then begin
set_plot,'ps'
device,filename='bz_f.ps',/land,/color
endif else begin
set_plot,'x'
endelse
s=size(bz)
;read,'x0,x1,x,y,z',x0,x1,x,y,z
 x0=50
 x1=120
 x=90
;read,'x = ', x
 y=10
 z=20
ix=findgen(x1-x0+1)*dx+x0*dx
iy=findgen(s(2))*dy
iz=findgen(s(3))*dz
;
!p.region=[-0.2 ,-0.05,.55,1.05]
imco,reform(bzs(x0:x1,y,*)),ix,iz,/nodata,$
title='Pl. de coplan.',xtitle='x'
xyouts, 4.5 ,2.2 ,'z',charsize=3,charthick=3
;
!p.region=[.3,-0.05,1.05 ,1.05]
imco,reform(bzs(x,*,*)),iy,iz,/nodata,$
title='Pl. du choc',xtitle='y',/noerase
xyouts,-1,2.2  ,'z',charsize=3,charthick=3
if (a eq 'y') then begin
device,/close
endif else begin
read,' xloadct ? (y)',bb
if (bb eq 'y') then xloadct
endelse
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
