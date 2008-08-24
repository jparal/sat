;
;
  !p.background=255
  !p.color=0
  !p.charsize=1.7
  ss=size(a)
  sx=ss(1)
  read,'y,z =',y,z
  ix=findgen(sx)*dx
  aa=a
  d1,a,a1
  a0=a(*,y,z) 
a=' '
b=' '
kkk:
 read,' output to files (y) ',a
if (a eq 'y') then begin
set_plot,'ps'
device,/land,filename='res.ps',/color
endif else begin
read,' x-windows',b
if(b eq 'y' )then begin
set_plot,'x'
endif else begin
set_plot,'tek'
endelse
endelse
to_color
!p.title='!18 y=2.5, z=2.5, t=10 '
plot,ix,a0,title='!N!5 Graph !7 H!18!iB!in!N !3 local  ',$
xtitle='!N!18 x /(v!ia!N/!4X!i!18i!N)  ',$
 color=0
oplot,ix,a1,color=2
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',b
if (b ne 'y') then goto, kkk
;
end
