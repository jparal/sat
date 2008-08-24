; dispersion funcion of whistlers
; get out 'dispf.eps' 
;.r
a=' '
bb=' '
iunit=9
openr,iunit,'an.dat'
readf,iunit,nn
an=fltarr(nn)
gamax=an
readf,iunit,an,gamax
close,iunit

kkk:
read,' output to files (y) ',a
;read,' charsize ', ch
!p.charsize=2
!p.charthick=2
if (a eq 'y') then begin
set_plot,'ps'
device,filename='an.ps'
endif else begin
set_plot,'x'
endelse

!p.title='!8 '
plot,an,gamax, xrange=[3.,20.],yrange=[0.,1.],/yst,$
xtitle='T!Bperp!N/T!Bpar!N', $
title='AIC maximal growth rate',$
ytitle='!N!7c!8!Bmax!N!7/X!b!8i!n'
;
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
;.r

