;comparison of distribution functions
; with or without whistlers 
;.r 
a=' '
aa=' '
bb=' '
kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
!p.title='!8'
!p.charsize=2.8
!p.charthick=3.2
if (a eq 'y') then begin
read,' encapsulated (y) ',aa
if (aa eq 'y') then begin
set_plot,'ps'
device,filename='dist2.eps',/encapsulated
endif else begin
set_plot,'ps'
device,filename='dist2.ps',/land
endelse
endif else begin
set_plot,'x'
endelse
restore,'dis10'
 vxmin =  -6.93993   &  vxmax  =  7.217378
 vymin =  -6.209659   &  vymax  =  7.216958
ss=size(f1)
ix=findgen(ss(1))/ss(1)*(vxmax-vxmin)+vxmin
iy=findgen(ss(2))/ss(2)*(vymax-vymin)+vymin
!p.region=[-0.2 ,-0.05,.55,1.05]
imco,alog(f6+1),ix,iy,/nodata,$
;title=' f(V!bx!n,V!by!n)',$
;xtickname=['-6',' ','-2','0','2',' ','6'],$
xtitle=' V!bx!n/V!bA!n', /aspect
xyouts,-10,8.1,'V!by!n/V!bA!n',charsize=3,charthick=3
xyouts,-6,5. ,'!6a!3',charsize=5,charthick=4,color=255
restore,'distnowh'
!p.region=[.3,-0.05,1.05 ,1.05]
imco,alog(f7+1),ix,iy,/nodata,$
;title=' f(V!bx!n,V!by!n)',$
;xtickname=['-6',' ','-2','0','2',' ','6'],$
xtitle=' V!bx!n/V!bA!n' ,/aspect,/noerase
xyouts,-10,8.1,'V!by!n/V!bA!n',charsize=3,charthick=3
xyouts,-6,5. ,'!6b!3',charsize=5,charthick=4,color=255
if (a eq 'y') then begin
device,/close
tox
endif else begin
read,'xloadct? ',bb
if (bb eq 'y') then xloadct
endelse
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
