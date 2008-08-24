; get out shortcuts of bz 
; in file 'cont3.ps'
;.r
a=' '
bb=' '
kkk:
read,' output to files (y) ',a
;read,' charsize ',ch
restore, 's80m3p2'
d2,bz,bz2,/x
d2,bx,bx2,/x
ch=3.
!p.title='!8 '
!p.charsize=ch
!p.charthick=ch
if (a eq 'y') then begin
set_plot,'ps'
device,filename='cont5.ps',/land,/color
endif else begin
set_plot,'x'
endelse
s=size(bz)

ix=findgen(s(1))*dx
iz=findgen(s(3))*dz
;
!p.region=[-0.2 ,-0.05,.55,1.05]
imco,bz2,ix,iz,/nodata,$
title='B_z',xtitle='x'
xyouts, -5,12. ,'z',charsize=3,charthick=3
;
!p.region=[.3,-0.05,1.05 ,1.05]
imco,bx2,ix,iz,/nodata,$
title='B_x',xtitle='x',/noerase
xyouts,-5.,12.  ,'z',charsize=3,charthick=3
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
