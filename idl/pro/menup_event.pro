;
  pro menup_event, event
  common d3fields, cbx,cby,cbz,$
                    cex,cey,cez,$
                    cux,cuy,cuz,$
                    cdn,cpe
  common d3particles, cx,cy,cz,cvx,cvy,cvz
  common histo, quoi, ih, h
  common f, ff, a,b,c
  common coor, t,x,y,z 
  common list, list0,list1,list2,list3 
  common head, tit, xlab,ylab,zlab
  common util, fft, shift,sign
  common fil, filnam
  type = tag_names(event,/structure)
 if (type eq 'WIDGET_TEXT') then begin
    widget_control, get_value=filnam , event.id
  filnam=filnam(0)
  endif 
    if (type eq 'WIDGET_LIST') then begin
    j= event.id
    i= event.index
    if (j eq list0) then x=i
    if (j eq list1) then y=i
    if (j eq list2) then z=i
    if (j eq list3) then t=i
   endif
  if (type eq 'WIDGET_BUTTON') then begin
   widget_control, get_value=i , event.id  
   if (i eq 'Bx') then begin
       ff = cbx 
       tit=' Graf !17 B!Ix!3 '
      endif
   if (i eq 'By') then begin
       ff = cby 
       tit=' Graf !17 B!Iy!3 '
      endif 
   if (i eq 'Bz') then  begin
       ff = cbz 
       tit=' Graf !17 B!Iz!3 '
      endif  
   if (i eq 'Ex') then  begin
       ff = cex
       tit=' Graf !17 E!Ix!3 '
      endif  
   if (i eq 'Ey') then  begin
       ff = cey 
       tit=' Graf !17 E!Iy!3 '
      endif 
   if (i eq 'Ez') then  begin
       ff = cez 
       tit=' Graf !17 E!Iz!3 '
      endif 
   if (i eq 'ux') then  begin
       ff = cux 
       tit=' Graf !17 u!Ix!3 '
      endif  
   if (i eq 'uy') then  begin
       ff = cuy 
       tit=' Graf !17 u!Iy!3 '
      endif  
   if (i eq 'uz') then  begin
       ff = cuz 
       tit=' Graf !17 u!Iz!3 '
      endif 
   if (i eq 'dn') then  begin
       ff = cdn 
       tit=' Graf !4 q!3 '
      endif 
   if (i eq 'pe') then  begin
       ff = cpe 
       tit=' Graf !17 p!Ie!3 '
      endif
   if (i eq ':x') then begin 
       tit=' Histogram !8 x !3'
       hist, cx(t,*),ih,h 
       xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':y') then begin
       tit=' Histogram !8 y !3'
       hist, cy(t,*),ih,h
       xlab=' !8 y [ v!Ia!n/!4 x!8!Ip!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':z') then begin
       tit=' Histogram !8 z !3'
       hist, cz(t,*),ih,h
       xlab=' !8 z [ v!Ia!n/!4 x!8!Ip!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':vx') then begin
       tit=' Histogram !8 v!Ix!n !3'
       hist, cvx(t,*),ih,h
       xlab=' !8 v!Ix!n [ v!Ia!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':vy') then begin
       tit=' Histogram !8 v!Iy!n !3'
       hist, cvy(t,*),ih,h
       xlab=' !8 v!Iy!n [ v!Ia!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':vz') then begin
       tit=' Histogram !8 v!Iz!n !3'
       hist, cvz(t,*),ih,h
       xlab=' !8 v!Iz!n [ v!Ia!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq 'Quit') then widget_control, event.top,/destroy
   if (i eq 'Surface') then a=1
   if (i eq 'Contour') then a=0
   if (i eq 'Show3') then a=2
   if (i eq 'Plot' ) then a=3
   if (i eq 'Oplot') then a=4
   if (i eq 'Shade_surf') then a=5
   if (i eq 'Image_cont') then a=6
   if (i eq 'Histogram') then a=7
   if (i eq 'FFT') then fft=1
   if (i eq 'no FFT') then fft=0
   if (i eq '+') then sign=1.
   if (i eq '-') then sign=-1.
   if (i eq 't') then  begin
     c=0
     xlab=' !8 t [ 1/!4 x!8!Ip!n ] !3'
     ylab='  '
    endif
   if (i eq 'x') then  begin
     c=1
     xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
     ylab='  '
    endif
   if (i eq 'y') then  begin
     c=2
     xlab=' !8 y [ v!Ia!n/!4 x!8!Ip!n ] !3'
     ylab='  '
    endif
   if (i eq 'z' ) then  begin
     c=3
     xlab=' !8 z [ v!Ia!n/!4 x!8!Ip!n ] !3'
     ylab='  '
    endif
   if (i eq 'tx') then  begin
     b=0
     xlab=' !8 t [ 1/!4 x!8!Ip!n ] !3'
     ylab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ]!3 '
    endif
   if (i eq 'xy') then begin
     b=1
     xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
     ylab=' !8 y [ v!Ia!n/!4 x!8!Ip!n ]!3 '
    endif
   if (i eq 'yz') then  begin
     b=2
     xlab=' !8 y [ v!Ia!n/!4 x!8!Ip!n ] !3'
     ylab=' !8 z [ v!Ia!n/!4 x!8!Ip!n ]!3 '
    endif
   if ((i eq ' DRAW ') or (i eq ' PRINT ')) then begin
   if (i eq ' PRINT ') then begin
   set_plot,'ps'
   device, filename=filnam
   endif
   if (i eq ' DRAW ') then set_plot,'x'
   if (a eq 7) then begin
     plot,ih,h,title=tit,xtitle=xlab,ytitle=ylab
   endif
   if (a eq 3) then begin
     if (c eq 0) then plot,sign*ff(*,x,y,z),title=tit,xtitle=xlab,ytitle=ylab
     if (c eq 1) then plot,sign*ff(t,*,y,z),title=tit,xtitle=xlab,ytitle=ylab
     if (c eq 2) then plot,sign* ff(t,x,*,z),title=tit,xtitle=xlab,ytitle=ylab
     if (c eq 3) then plot,sign* ff(t,x,y,*),title=tit,xtitle=xlab,ytitle=ylab
   endif else begin 
   if (a eq 4) then begin
     if (c eq 0) then oplot,sign* ff(*,x,y,z)
     if (c eq 1) then oplot,sign*  ff(t,*,y,z)
     if (c eq 2) then oplot,sign* ff(t,x,*,z)
     if (c eq 3) then oplot,sign* ff(t,x,y,*)
   endif else begin
   if (b eq 0) then begin
     if (a eq 0) then contour, sign*ff(*,*,y,z),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 1) then surface,sign* ff(*,*,y,z),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 2) then show3,sign* ff(*,*,y,z)
     if (a eq 5) then shade_surf,sign* ff(*,*,y,z),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 6) then image_cont,sign* ff(*,*,y,z)
    endif
   if (b eq 1) then begin
     if (a eq 0) then contour,sign*  ff(t,*,*,z),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 1) then surface,sign* ff(t,*,*,z),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 2) then show3,sign* ff(t,*,*,z)
     if (a eq 5) then shade_surf,sign* ff(t,*,*,z),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 6) then image_cont,sign* ff(t,*,*,z)
    endif
   if (b eq 2) then begin
     if (a eq 0) then contour,sign* ff(t,x,*,*),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 1) then surface,sign* ff(t,x,*,*),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 2) then show3,sign*ff(t,x,*,*)
     if (a eq 5) then shade_surf,sign* ff(t,x,*,*),title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 6) then image_cont,sign* ff(t,x,*,*)
    endif
   endelse
   endelse
   endif
  endif   
end
