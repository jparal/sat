; read his10 a his10nr
; get out history of bz in 'his.eps'
;.r 
dx=.125
dt=.05
a=' '
bb=' '
kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
ch=3.
!p.charsize=ch
!p.charthick=ch
!p.title='!8 '
if (a eq 'y') then begin
set_plot,'ps'
device,filename='his.ps',/land
endif else begin
set_plot,'x'
endelse
restore,'his10'
ss=size(bz)
s1=ss(1)
s2=ss(2)
ix=findgen(s1)*dx
iy=findgen(s2)*dt+dt
!p.region=[-0.2 ,-0.05,.55,1.05]
imco,bz,ix,iy,/nodata,xtitle='!N!8x!7x!b!8pi!n/c'
xyouts,-6,10.5,'!N!8 t!7X!b!8i!n',charsize=3, charthick=3
xyouts,1.,8.5,'!6a!8',charsize=5, charthick=3,color=255
restore,'his10nr'
ix=findgen(s1)*dx
iy=findgen(s2)*dt+dt
 !p.region=[.3,-0.05,1.05 ,1.05]
imco,bz,ix,iy,/nodata,xtitle='!N!8x!7x!b!8pi!n/c',$
 /noerase
xyouts,-6,10.5,'!N!8 t!7X!b!8i!n ',charsize=3, charthick=3
iy=iy(where(25-iy*1.25 lt 21.))
oplot,25-iy*1.25,iy,thick=4
arrow,12.,1. ,25-iy(0)*1.25,iy(0),/data,/solid,thick=4
xyouts,1,.5,'Escaping boundary',charsize=2., charthick=2,$
color=255
xyouts,1.,8.5,'!6b!8',charsize=5, charthick=3,color=255
if (a eq 'y') then begin
device,/close
endif else begin
read,'xloadct ?',bb
if (bb eq 'y') then xloadct
endelse
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
!p.region=[0.,0.,1. ,1.]
end
