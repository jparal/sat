; dispersion funcion of whistlers
; get out 'disp1.ps' 
;.r
a=' '
bb=' '
iunit=9
openr,iunit,'frq1.dat'
readf,iunit,nn,theta
k=fltarr(nn)
fr1=fltarr(nn)
fr2=fltarr(nn)
fr3=fltarr(nn)
fr4=fltarr(nn)
for i=0,nn-1 do begin
readf,iunit, k1,f1,f2,f3,f4
k(i)=k1
fr1(i)=f1
fr2(i)=f2
fr3(i)=f3
fr4(i)=f4
endfor
close,iunit

kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
!p.charsize=2
!p.charthick=2
!p.thick=2
if (a eq 'y') then begin
set_plot,'ps'
device,filename='disp1.ps'
endif else begin
set_plot,'x'
endelse

!p.title='!8 '
plot,k,fr1,/xst,yrange=[0.,60.],$
xtitle='!8 k c/!4x!8!Bpi!n ', $
title='!8 Dispersion relation',$
ytitle='!4x!8/!4X!8!Bi!N',linestyle=2
oplot,k,fr2
oplot,k,fr3
oplot,k,fr4,linestyle=3
;
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end

