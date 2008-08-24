;comparison of distribution functions
; with or without Escaping boundary 
;.r 
!p.multi=[0,2,2,0,0]
a=' '
aa=' '
bb=' '
kkk:
read,' output to files (y) ',a
read,' charsize ', ch
!p.charsize=ch
if (a eq 'y') then begin
read,' encapsulated (y) ',aa
if (aa eq 'y') then begin
set_plot,'ps'
device,filename='dist.eps',/encapsulated
endif else begin
set_plot,'ps'
loadct,3
device,filename='dist.ps',/land,/color
endelse
endif else begin
set_plot,'x'
endelse
restore,'dis10'
 vxmin =  -7.103993   &  vxmax  =  6.317378
 vymin =  -6.209659   &  vymax  =  7.216958
ss=size(f1)
ix=findgen(ss(1))/ss(1)*(vxmax-vxmin)+vxmin
iy=findgen(ss(2))/ss(2)*(vymax-vymin)+vymin
imco,alog(f6+1),ix,iy,/nodata,title='!18 f(v!ix!N,v!iy!N)',$
xtitle='!18 v!ix!N',ytitle='!18 v!iy!N'
imco,alog(f7+1),ix,iy,/nodata,title='!18 f(v!ix!N,v!iy!N)',$
xtitle='!18 v!ix!N',ytitle='!18 v!iy!N'
restore,'dist5nr'
imco,alog(f7+1),ix,iy,/nodata,title='!18 f(v!ix!N,v!iy!N)',$
xtitle='!18 v!ix!N',ytitle='!18 v!iy!N'
imco,alog(f8+1),ix,iy,/nodata,title='!18 f(v!ix!N,v!iy!N)',$
xtitle='!18 v!ix!N',ytitle='!18 v!iy!N'

if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
