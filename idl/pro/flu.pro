; plots a den, ddn and db
; ither to file 'flu.ps' ither to terminal 
;.r
  ss=size(bx)
  sx=ss(1)
  ix=findgen(sx)*dx
;
aa=' '
a=' '
bb=' '
b=sqrt(bz^2+by^2+bx^2)
dfof, dn,dn0,ddn
dfof, b,b0,db

kkk:
read,' output to files (y) ',a
;read,' charsize ',ch
!p.charthick=2.
!p.charsize=2.
if (a eq 'y') then begin
read,' encapsulated (y) ',aa
if (aa eq 'y') then begin
set_plot,'ps'
device,filename='flu.eps',/encapsulated
endif else begin
set_plot,'ps'
device,filename='flu.ps'
endelse
endif else begin
tox
endelse
x0=    0.335938
y0=  0.664063
g=replicate(' ',30)
!p.region=[0.,x0,1.,1.]
!p.title='!8 '
plot,ix,dn0,xtickname=g,thick=2
;read,x,y
xyouts,6.,3.,'!N !7 q/q!b!8o!n',charsize=2,charthick=3
;
!p.region=[0.,0.,1.,y0]
;
 
plot,ix,db/b0,/noerase,$ 
yticks=3,$
xtitle='!N!8 x!7x!b!8pi!n/c  ',thick=2
oplot,ix,ddn/dn0,linestyle=2,thick=2
;,psym=3
;read,x,y
xyouts,4.5,.8,'!N!7 d!8B/B',charsize=2,charthick=3
;read,x,y
xyouts,9.5,.07,'!N !7dq/q',charsize=2,charthick=3
;
!p.region=[0.,0.,1.,1.]
;

if (a eq 'y') then begin
device,/close
tox
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
