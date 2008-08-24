; dispersion function of whistlers and 1D test 
; get out 'testpg_p.ps' 
;.r
a=' '
bb=' '
iunit=9
openr,iunit,'wh_p.dat'
readf,iunit,n_val
k=fltarr(n_val)
om=k
gam=k
au = complex(0,0)
for i=0,n_val-1 do begin
readf,iunit, kau,aa,omau,gamau,au,zz
k(i)=kau
om(i)=omau
gam(i)=gamau
endfor
close, iunit
openr,iunit, 'disp.dat'
readf, iunit, n_val_h
k_h=fltarr(n_val_h)
om_h=k_h
gam_h=k_h
for i=0,n_val_h-1 do begin 
readf,iunit, kau,omau,gamau
k_h(i)=kau
om_h(i)=omau
gam_h(i)=gamau
endfor
close, iunit
k=k/ .4082483
res =1e-3
k_h=k_h * 50./51.2
gg=-k^2*res
print, k, om
kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
!p.charsize=2
!p.charthick=2
if (a eq 'y') then begin
set_plot,'ps'
device,filename='testprg_p.ps'
endif else begin
set_plot,'x'
endelse

!p.title='!8 '
x0=    0.335938
y0=  0.664063
g=replicate(' ',30)
!p.region=[0.,x0,1.,1.]
plot,k,om,xtickname=g,thick=2,xrange=[2.,8.], yrange=[0.,60.],$
title='!8 Dispersion rel. k.B=0!9%!8'
xyouts,4.,45,'!N !7 x/X!b!8i!n ',charsize=3,charthick=4
;
oplot,k_h,om_h,psym=2,thick=2
;
!p.region=[0.,0.,1.,y0]
plot,k,gg,/noerase,xrange=[2.,8.], yrange=[-0.06,0.],$
xtitle='!N!8 kc/!7x!b!8pi!n',thick=2
xyouts,4.,-0.045,'!N !7 c/X!b!8i!n',charsize=3,charthick=4
oplot,k_h,gam_h,psym=2,thick=2
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

