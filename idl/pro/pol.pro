; polarisation of b 
; get out 'polb.ps'
;.r 
x0=25-13.3
y0=2.5
z0=2.5
n=30
del=.1
kx=4.2
ky=-3.7
kz=3.7
plcut, bx, x0,y0,z0,dx,dy,dz,n,del,kx,ky,kz,bx1
plcut, by, x0,y0,z0,dx,dy,dz,n,del,kx,ky,kz,by1
plcut, bz, x0,y0,z0,dx,dy,dz,n,del,kx,ky,kz,bz1
wc, kx,ky,kz,bx1,by1,bz1, bpa,bpe1,bpe2
ix=findgen(2*n+1)*del
a=' '
bb=' '
kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
!p.charsize=2
!p.charthick=2
if (a eq 'y') then begin
set_plot,'ps'
device,filename='polb.ps'
endif else begin
set_plot,'x'
endelse

plot,bpe1(10:45),bpe2(10:45),thick=2, $
title='!6Hodogram !8B!d!9x!n!8',$
xtitle='!8B!b!9x!81!N/B!bo!n',ytitle='!8B!b!9x!82!N/B!bo!n'
xyouts,0,1.3,'!9n!8k',charsize=3,charthick=3
;read,'number of arrows ', nar
nar=7
kar=30/nar
i1=findgen(nar)*kar + 12
i2=i1+1
arrow,bpe1(i2),bpe2(i2),bpe1(i1),bpe2(i1),/data,/solid,$
hsize=!D.X_SIZE / 32.
if (a eq 'y') then begin
device,/close
set_plot,'x'
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
