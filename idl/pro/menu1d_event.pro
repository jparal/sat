;
  pro menu1d_event, event
  common d3fields, cbx,cby,cbz,$
                    cex,cey,cez,$
                    cux,cuy,cuz,$
                    cdn,cpe
  common psout, pslog
  common d3particles, cx,cvx,cvy,cvz,npc
  common f, ff, a,b,c
  common coor, t,x 
  common list, list0,list1,listp
  common head, tit, xlab,ylab,zlab
  common util, fft, shift,sign
  common fil, filnam
  common minmax, xmin,xmax,tmin,tmax,xmin1,xmax1,tmin1,tmax1
  common psym, p
  common nnn, nx, num
  common histo, quoi, ih, h
  type = tag_names(event,/structure)
 if (type eq 'WIDGET_TEXT') then begin
    widget_control, get_value=filnam , event.id
  filnam=filnam(0)
  endif 
    if (type eq 'WIDGET_LIST') then begin
    j= event.id
    i= event.index
    if (j eq list0) then x=i
    if (j eq list1) then t=i
    if (j eq listp) then p=i+1
   endif
  if (type eq 'WIDGET_BUTTON') then begin
   widget_control, get_value=i , event.id  
  if (i eq ':x') then begin
       c=2 
       tit=' Histogram !8 x !3 ( t= '+string(t)+')'
       hist, cx(t,0:npc(t)-1),ih,h
       xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':vx') then begin
       c=2
       tit=' Histogram !8 v!Ix!n !3 ( t= '+string(t)+')'
       hist, cvx(t,0:npc(t)-1),ih,h
       xlab=' !8 v!Ix!n [ v!Ia!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':vy') then begin
       c=2
       tit=' Histogram !8 v!Iy!n !3 ( t= '+string(t)+')'
       hist, cvy(t,0:npc(t)-1),ih,h
       xlab=' !8 v!Iy!n [ v!Ia!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq ':vz') then begin
       c=3
       tit=' Histogram !8 v!Iz!n !3 ( t= '+string(t)+')'
       hist, cvz(t,0:npc(t)-1),ih,h
       xlab=' !8 v!Iz!n [ v!Ia!n ] !3'
       ylab=' number of particles '
      endif
   if (i eq 'x vx') then begin
       c=3
       tit=' Phase diagram ( t= '+string(t)+')'
       ih=cx(t,0:npc(t)-1)
       h=cvx(t,0:npc(t)-1)
       ylab=' !8 v!Ix!n [ v!Ia!n ] !3'
       xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3' 
      endif
   if (i eq 'x vy') then begin
       c=3
       tit=' Phase diagram ( t= '+string(t)+')'
       ih=cx(t,0:npc(t)-1)
       h=cvy(t,0:npc(t)-1)
       ylab=' !8 v!Iy!n [ v!Ia!n ] !3'
       xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
      endif
   if (i eq 'x vz') then begin
       c=3
       tit=' Phase diagram ( t= '+string(t)+')'
       ih=cx(t,0:npc(t)-1)
       h=cvz(t,0:npc(t)-1)
       ylab=' !8 v!Iz!n [ v!Ia!n ] !3'
       xlab=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
      endif
   if (i eq 'vx vy') then begin
       c=3
       tit=' Phase diagram ( t= '+string(t)+')'
       ih=cvx(t,0:npc(t)-1)
       h=cvy(t,0:npc(t)-1)
       ylab=' !8 v!Iy!n [ v!Ia!n ] !3'
       xlab=' !8 v!Ix!n [ v!Ia!n ] !3'
      endif
   if (i eq 'vx vz') then begin
       c=3
       tit=' Phase diagram ( t= '+string(t)+')'
       ih=cvx(t,0:npc(t)-1)
       h=cvz(t,0:npc(t)-1)
       ylab=' !8 v!Iz!n [ v!Ia!n ] !3'
       xlab=' !8 v!Ix!n [ v!Ia!n ] !3'
      endif
   if (i eq 'vy vz') then begin
       c=3
       tit=' Phase diagram ( t= '+string(t)+')'
       ih=cvy(t,0:npc(t)-1)
       h=cvz(t,0:npc(t)-1)
       ylab=' !8 v!Iz!n [ v!Ia!n ] !3'
       xlab=' !8 v!Iy!n [ v!Ia!n ] !3'
      endif
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
   if (i eq 'rh1') then  begin
       rh1, cdn,cux,cuy,cuz,cbx,cby,cbz,ff
       tit=' Graf rh1 '
      endif
   if (i eq 'rh2') then  begin
       rh2, cdn,cux,cuy,cuz,cbx,cby,cbz,ff
       tit=' Graf rh2 '
      endif
   if (i eq 'rh3') then  begin
       rh3, cdn,cux,cuy,cuz,cbx,cby,cbz,ff
       tit=' Graf rh3 '
      endif
   if (i eq 'rh4') then  begin
       rh4, cdn,cux,cuy,cuz,cbx,cby,cbz,ff
       tit=' Graf rh4 '
      endif
   if (i eq 'rh5') then  begin
       rh5, cdn,cux,cuy,cuz,cbx,cby,cbz,ff
       tit=' Graf rh5 '
      endif
   if (i eq 'rh6') then  begin
       rh6, cdn,cux,cuy,cuz,cbx,cby,cbz,ff
       tit=' Graf rh6 '
      endif
   if (i eq '1') then !p.multi=0
   if (i eq '2x1') then !p.multi=[0,2,0,0,0]
   if (i eq '1x2') then !p.multi=[0,0,2,0,0]
   if (i eq '2x2') then !p.multi=[0,2,2,0,0]
   if (i eq '3x1') then !p.multi=[0,3,0,0,0]
   if (i eq '1x3') then !p.multi=[0,0,3,0,0]
   if (i eq 'Quit') then widget_control, event.top,/destroy
   if (i eq 'Surface') then a=1
   if (i eq 'Contour') then a=0
   if (i eq 'Show3') then a=2
   if (i eq 'Plot' ) then a=3
   if (i eq 'Oplot') then a=4
   if (i eq 'Shade_surf') then a=5
   if (i eq 'Image_cont') then a=6  
   if (i eq 'Image') then a=7
   if (i eq 'FFT') then fft=1
   if (i eq 'no FFT') then fft=0
   if (i eq '+') then sign=1.
   if (i eq '-') then sign=-1.
   if (i eq 'xmin') then xmin1=x
   if (i eq 'xmax') then xmax1=x
   if (i eq 'tmin') then tmin1=t
   if (i eq 'tmax') then tmax1=t
   if (i eq 'CLEAR')then begin
      xmin1=xmin
      xmax1=xmax
      tmin1=tmin
      tmax1=tmax
   endif
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
   if (i eq ' COLOR ') then color_edit
   if ((i eq ' DRAW ') or (i eq ' PRINT ')) then begin
   if (i eq ' PRINT ') then begin
     if (pslog eq 0) then begin 
        pslog=1
        set_plot,'ps'
        device,/color, filename=filnam
       endif
     endif else begin
     pslog=0 
     set_plot,'x'
     endelse
  if (fft eq 0) then begin 
   if (a eq 3) then begin
     if (c eq 0) then begin
       plot,sign*ff(tmin1:tmax1,x),title=tit,xtitle=xlab,ytitle=ylab
     endif
     if (c eq 1) then begin
       plot,sign*ff(t,xmin1:xmax1),title=tit,xtitle=xlab,ytitle=ylab
     endif
     if (c eq 2) then begin
       plot,ih,h,title=tit,xtitle=xlab,ytitle=ylab
     endif
     if (c eq 3) then begin
       plot,ih,h,title=tit,xtitle=xlab,ytitle=ylab,psym=p
     endif
   endif else begin 
;           a neq 3
   if (a eq 4) then begin
     if (c eq 0) then oplot,sign* ff(tmin1:tmax1,x)
     if (c eq 1) then oplot,sign*  ff(t,xmin1:xmax1)
     if (c eq 2) then oplot, ih,h
     if (c eq 3) then oplot, ih,h,psym=p
   endif else begin            
;             a neq 4            
     if (a eq 0) then contour, sign*ff(tmin1:tmax1,xmin1:xmax1), $ 
          title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 1) then surface,sign* ff(tmin1:tmax1,xmin1:xmax1), $
        title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 2) then show3,sign* ff(tmin1:tmax1,xmin1:xmax1)
     if (a eq 5) then shade_surf,sign* ff(tmin1:tmax1,xmin1:xmax1), $ 
       title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 6) then image_cont,sign* ff(tmin1:tmax1,xmin1:xmax1)
     if (a eq 7) then image, sign* ff(tmin1:tmax1,xmin1:xmax1)
   endelse
;       a neq 4
   endelse
;       a neq 3
   endif else begin
;       fft neq 0  
   if (a eq 3) then begin
     if (c eq 0) then begin
       plot,sign*fft(ff(tmin1:tmax1,x),1),title=tit,xtitle=xlab,ytitle=ylab
     endif
     if (c eq 1) then begin
       plot,sign*fft(ff(t,xmin1:xmax1),1),title=tit,xtitle=xlab,ytitle=ylab
     endif
     if (c eq 2) then begin
       plot,ih,h,title=tit,xtitle=xlab,ytitle=ylab
     endif
     if (c eq 3) then begin
       plot,ih,h,title=tit,xtitle=xlab,ytitle=ylab,psym=p
     endif
   endif else begin 
;           a neq 3
   if (a eq 4) then begin
     if (c eq 0) then oplot,sign* fft(ff(tmin1:tmax1,x),1)
     if (c eq 1) then oplot,sign* fft(ff(t,xmin1:xmax1),1)
     if (c eq 2) then oplot, ih,h
     if (c eq 3) then oplot, ih,h,psym=p
   endif else begin            
;             a neq 4            
     if (a eq 0) then contour, sign*fft(ff(tmin1:tmax1,xmin1:xmax1),1), $ 
          title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 1) then surface,sign*fft( ff(tmin1:tmax1,xmin1:xmax1),1), $
        title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 2) then show3,sign*fft( ff(tmin1:tmax1,xmin1:xmax1),1)
     if (a eq 5) then shade_surf,sign*fft( ff(tmin1:tmax1,xmin1:xmax1),1), $ 
       title=tit,xtitle=xlab,ytitle=ylab
     if (a eq 6) then image_cont,sign*fft( ff(tmin1:tmax1,xmin1:xmax1),1)
     if (a eq 7) then image, sign*fft( ff(tmin1:tmax1,xmin1:xmax1),1)
   endelse
;       a neq 4
   endelse
;       a neq 3
   endelse
;       fft neq 0
   endif
   endif    
end
