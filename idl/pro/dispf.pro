; dispersion funcion of whistlers
; get out 'dispf.eps' 
;.r
a=' '
bb=' '
restore,'wh'
vv=0.4082475
k1=-kpe/vv
omr1=omr
omi1=omi
k2=-kpe/vv
kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
!p.charsize=2
!p.charthick=2
if (a eq 'y') then begin
set_plot,'ps'
device,filename='dispf.ps'
endif else begin
set_plot,'x'
endelse

!p.title='!8 '
x0=    0.335938
y0=  0.664063
g=replicate(' ',30)
!p.region=[0.,x0,1.,1.]
plot,k2,omr,xtickname=g,thick=2,/xst
xyouts,4.,45,'!N !7 x/X!b!8i!n ',charsize=3,charthick=4
;
oplot,[6.7],[26.9],psym=2,thick=2
;
!p.region=[0.,0.,1.,y0]
plot,k2,omi,/noerase,$
xtitle='!N!8 kc/!7x!b!8pi!n',thick=2,/xst,yticks=3
xyouts,4.,-1.5,'!N !7 c/X!b!8i!n',charsize=3,charthick=4
;
!p.region=[0.,0.,1.,1.]
;
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
;.r

