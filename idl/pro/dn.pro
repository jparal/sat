; get out shortcuts of dn 
; in file 'dn.eps'
;.r
a=' '
read,' new input (y) ',a
if (a eq 'y') then restore,'sh'
bb=' '
kkk:
read,' output to files (y) ',a
read,' charsize ', ch
!p.charsize=ch
if (a eq 'y') then begin
set_plot,'ps'
loadct,3
device, filename='dn.ps', /land, /color
endif else begin
set_plot,'x'
endelse
read,'x0,x1,x,y,z',x0,x1,x,y,z
shortcuts, dn,x0,x1,x,y,z,0,dx,dy,dz,$
title='!18 Density ',/nodata
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
