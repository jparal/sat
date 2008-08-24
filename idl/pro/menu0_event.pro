;
  pro menu0_event, event
  common d3fields, cbx,cby,cbz,$
                    cex,cey,cez,$
                    cux,cuy,cuz,$
                    cdn,cpe
  common ran, u,tp
  common rot, rbx, rby, rbz, rux, ruy, ruz
  common poynt, csx, csy, csz
  common f, ff,fff, a,b,c
  common coor, t,x,y,z 
  common list, list0,list1,list2,list3 
  common util, fft, shift,sign
  common fil, filnam
  common exe, filexe
  common textid, textfil, textexe
  common psss, pslog
  common volume_data, aslic
  type = tag_names(event,/structure)
    if (type eq 'WIDGET_TEXT') then begin
     j=event.id
     if(j eq textfil)then begin
      widget_control, get_value=filnam1 , event.id
      filnam=filnam1(0)
     endif
     if(j eq textexe)then begin
      widget_control, get_value=filnam1 , event.id
      filexe=filnam1(0)
     endif
    endif 
    if (type eq 'WIDGET_LIST') then begin
     j= event.id
     i= event.index
     if (j eq list0) then x=i
     if (j eq list1) then y=i
     if (j eq list2) then z=i
;     if (j eq list3) then t=i
    endif
;111111111111111111111111111111111111111111111111111111111111111111111111111
 if (type eq 'WIDGET_BUTTON') then begin
    widget_control, get_value=i , event.id  
;      if (i eq 'energy') then begin
;       ff = ene 
;       !p.title=' Graf Energy '
;      endif
      if (i eq 'Bx') then begin
       ff = cbx 
       !p.title=' Graf !17 B!Ix!3 '
      endif
      if (i eq 'By') then begin
       ff = cby 
       !p.title=' Graf !17 B!Iy!3 '
      endif 
      if (i eq 'Bz') then  begin
       ff = cbz 
       !p.title=' Graf !17 B!Iz!3 '
      endif    
      if (i eq 'BxBy') then begin
       ff = cbx 
       fff=cby
       !p.title=' Graf !17 B!Ix!N B!Iy!3 '
      endif
      if (i eq 'BxBz') then begin
       ff = cbx 
       fff=cbz
       !p.title=' Graf !17 B!Ix!N B!Iz!3'
      endif 
      if (i eq 'ByBz') then  begin
       ff = cby
       fff=cbz
       !p.title=' Graf !17 B!Iy!N B!Iz!3 '
      endif    
      if (i eq 'RotBxRotBy') then begin
       ff = rbx 
       fff=rby
       !p.title=' Graf !17 RotB!Ix!N RotB!Iy!3 '
      endif
      if (i eq 'RotBxRotBz') then begin
       ff = rbx 
       fff=rbz
       !p.title=' Graf !17 RotB!Ix!N RotB!Iz!3'
      endif 
      if (i eq 'RotByRotBz') then  begin
       ff = rby
       fff=rbz
       !p.title=' Graf !17 RotB!Iy!N RotB!Iz!3 '
      endif 
      if (i eq 'RotBx') then begin
       ff = rbx 
       !p.title=' Graf !17 rotB!Ix!3 '
      endif
      if (i eq 'RotBy') then begin
       ff = rby 
       !p.title=' Graf !17 rotB!Iy!3 '
      endif 
      if (i eq 'RotBz') then  begin
       ff = rbz 
       !p.title=' Graf !17 rotB!Iz!3 '
      endif  
      if (i eq 'Ex') then  begin
       ff = cex
       !p.title=' Graf !17 E!Ix!3 '
      endif  
      if (i eq 'Ey') then  begin
       ff = cey 
       !p.title=' Graf !17 E!Iy!3 '
      endif 
      if (i eq 'Ez') then  begin
       ff = cez 
       !p.title=' Graf !17 E!Iz!3 '
      endif     
      if (i eq 'ExEy') then begin
       ff = cex 
       fff=cey
       !p.title=' Graf !17 E!Ix!N E!Iy!3 '
      endif
      if (i eq 'ExEz') then begin
       ff = cex 
       fff=cez
       !p.title=' Graf !17 E!Ix!N E!Iz!3'
      endif 
      if (i eq 'EyEz') then  begin
       ff = cey
       fff=cez
       !p.title=' Graf !17 E!Iy!N E!Iz!3 '
      endif 
      if (i eq 'Sx') then  begin
       ff =csx
       !p.title=' Graf !17 S!Ix!3 '
      endif  
      if (i eq 'Sy') then  begin
       ff = csy 
       !p.title=' Graf !17 S!Iy!3 '
      endif 
      if (i eq 'Sz') then  begin
       ff = csz 
       !p.title=' Graf !17 S!Iz!3 '
      endif     
      if (i eq 'SxSy') then begin
       ff = csx 
       fff=csy
       !p.title=' Graf !17 S!Ix!N S!Iy!3 '
      endif
      if (i eq 'SxSz') then begin
       ff = csx 
       fff=csz
       !p.title=' Graf !17 S!Ix!N S!Iz!3'
      endif 
      if (i eq 'SySz') then  begin
       ff = csy
       fff=csz
       !p.title=' Graf !17 S!Iy!N S!Iz!3 '
      endif 
      if (i eq 'ux') then  begin
       ff = cux 
       !p.title=' Graf !17 u!Ix!3 '
      endif  
      if (i eq 'uy') then  begin
       ff = cuy 
       !p.title=' Graf !17 u!Iy!3 '
      endif  
      if (i eq 'uz') then  begin
       ff = cuz 
       !p.title=' Graf !17 u!Iz!3 '
      endif     
      if (i eq 'uxuy') then begin
       ff = cux 
       fff=cuy
       !p.title=' Graf !17 u!Ix!N u!Iy!3 '
      endif
      if (i eq 'uxuz') then begin
       ff = cux 
       fff=cuz
       !p.title=' Graf !17 u!Ix!N u!Iz!3'
      endif 
      if (i eq 'uyuz') then  begin
       ff = cuy
       fff=cuz
       !p.title=' Graf !17 u!Iy!N u!Iz!3 '
      endif    
      if (i eq 'RotuxRotuy') then begin
       ff = rux 
       fff=ruy
       !p.title=' Graf !17 Rotu!Ix!N Rotu!Iy!3 '
      endif
      if (i eq 'RotuxRotuz') then begin
       ff = rux 
       fff=ruz
       !p.title=' Graf !17 Rotu!Ix!N Rotu!Iz!3'
      endif 
      if (i eq 'RotuyRotuz') then  begin
       ff = ruy
       fff=ruz
       !p.title=' Graf !17 Rotu!Iy!N Rotu!Iz!3 '
      endif 
      if (i eq 'Rotux') then  begin
       ff = rux 
       !p.title=' Graf !17 rotu!Ix!3 '
      endif  
      if (i eq 'Rotuy') then  begin
       ff = ruy 
       !p.title=' Graf !17 rotu!Iy!3 '
      endif  
      if (i eq 'Rotuz') then  begin
       ff = ruz 
       !p.title=' Graf !17 rotu!Iz!3 '
      endif 
      if (i eq 'dn') then  begin
       ff = cdn 
       !p.title=' Graf !4 q!3 '
      endif 
      if (i eq 'pe') then  begin
       ff = cpe 
       !p.title=' Graf !17 p!Ie!3 '
      endif  
      if (i eq 'mass') then begin
        rh1, u,cdn, cux, cuy, cuz,cpe, cbx, cby, cbz ,ff 
        !p.title='R-H mass'
        !p.subtitle=' u = '+string(u)
      endif  
      if (i eq 'momx') then begin
        rh2, u,cdn, cux, cuy, cuz,(1.+tp)*cpe, cbx, cby, cbz ,ff 
        !p.title='R-H momentum x'
        !p.subtitle=' u = '+string(u)+' tp = '+string(tp)
      endif  
      if (i eq 'momy') then begin
        rh3, u,cdn, cux, cuy, cuz,cpe, cbx, cby, cbz ,ff 
        !p.title='R-H momentum y'
        !p.subtitle=' u = '+string(u)
      endif  
      if (i eq 'momz') then begin
        rh4, u,cdn, cux, cuy, cuz,cpe, cbx, cby, cbz ,ff 
        !p.title='R-H momentum z'
        !p.subtitle=' u = '+string(u)
      endif  
      if (i eq 'ener') then begin
        rh5, u,cdn, cux, cuy, cuz,(1.+tp)*cpe, cbx, cby, cbz ,ff 
        !p.title='R-H energy'
        !p.subtitle=' u = '+string(u)+' tp = '+string(tp)
      endif  
      if (i eq 'bn') then begin
        rh6, u,cdn, cux, cuy, cuz,cpe, cbx, cby, cbz ,ff 
        !p.title='R-H B normal'
        !p.subtitle=' u = '+string(u)
      endif  
      if (i eq 'et1') then begin
        rh7, u,cdn, cux, cuy, cuz,cpe, cbx, cby, cbz ,ff 
        !p.title='R-H E tang1'
        !p.subtitle=' u = '+string(u)
      endif  
      if (i eq 'et2') then begin
        rh8, u,cdn, cux, cuy, cuz,cpe, cbx, cby, cbz ,ff 
        !p.title='R-H E tang2'
        !p.subtitle=' u = '+string(u)
      endif        
      if (i eq '1') then !p.multi=0
      if (i eq '2x1') then !p.multi=[0,2,0,0,0]
      if (i eq '1x2') then !p.multi=[0,0,2,0,0]
      if (i eq '2x2') then !p.multi=[0,2,2,0,0]
      if (i eq '3x1') then !p.multi=[0,3,0,0,0]
      if (i eq '1x3') then !p.multi=[0,0,3,0,0]
      if (i eq 'Quit') then widget_control, event.top,/destroy
      if (i eq 'Slicer') then begin
        aslic=ff
        slicer
        aslic=0
      endif
      if (i eq 'Surface') then a=1
      if (i eq 'Contour') then a=0
      if (i eq 'Show3') then a=2
      if (i eq 'Plot' ) then a=3
      if (i eq 'Oplot') then a=4
      if (i eq 'Shade_surf') then a=5
      if (i eq 'Image_cont') then a=6
      if (i eq 'Image_cont1') then a=8
      if (i eq 'Image') then a=7
      if (i eq 'Vector') then a=9
      if (i eq 'FFT') then fft=1
      if (i eq 'No FFT') then fft=0
      if (i eq '+') then sign=1.
      if (i eq '-') then sign=-1.
      if (i eq 't') then  begin
       c=0
       !x.title=' !8 t [ 1/!4 x!8!Ip!n ] !3'
       !y.title='  '
      endif
      if (i eq 'x') then  begin
       c=1
       !x.title=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
       !y.title='  '
      endif
      if (i eq 'y') then  begin
       c=2
       !x.title=' !8 y [ v!Ia!n/!4 x!8!Ip!n ] !3'
       !y.title='  '
      endif
      if (i eq 'z' ) then  begin
       c=3
       !x.title=' !8 z [ v!Ia!n/!4 x!8!Ip!n ] !3'
       !y.title='  '
      endif
      if (i eq 'tx') then  begin
       b=0
       !x.title=' !8 t [ 1/!4 x!8!Ip!n ] !3'
       !y.title=' !8 x [ v!Ia!n/!4 x!8!Ip!n ]!3 '
      endif
      if (i eq 'xy') then begin
       b=1
       !x.title=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
       !y.title=' !8 y [ v!Ia!n/!4 x!8!Ip!n ]!3 '
      endif
      if (i eq 'yz') then  begin
       b=2
       !x.title=' !8 y [ v!Ia!n/!4 x!8!Ip!n ] !3'
       !y.title=' !8 z [ v!Ia!n/!4 x!8!Ip!n ]!3 '
      endif 
      if (i eq 'ty') then  begin
       b=3
       !x.title=' !8 t [ 1/!4 x!8!Ip!n ] !3'
       !y.title=' !8 y [ v!Ia!n/!4 x!8!Ip!n ]!3 '
      endif
      if (i eq 'tz') then begin
       b=4
       !x.title=' !8 t [ 1/!4 x!8!Ip!n ] !3'
       !y.title=' !8 z [ v!Ia!n/!4 x!8!Ip!n ]!3 '
      endif
      if (i eq 'xz') then  begin
       b=5
       !x.title=' !8 x [ v!Ia!n/!4 x!8!Ip!n ] !3'
       !y.title=' !8 z [ v!Ia!n/!4 x!8!Ip!n ]!3 '
      endif
      if (i eq ' WCALC ') then wcalc
      if (i eq ' XPALETTE ') then xpalette
      if (i eq ' EXECUTE ')then exxxx=execute(filexe)  
;22222222222222222222222222222222222222222222222222222222222222
      if ((i eq ' DRAW ') or (i eq ' PRINT ')) then begin
       if (i eq ' PRINT ') then begin
        if(pslog eq 0) then begin
         pslog=1
         set_plot,'ps'
         device,/color, filename=filnam
        endif
       endif else begin
        pslog=0
        set_plot,'x'
       endelse
;333333333333333333333333333333333333333333333333333333333333
       if (fft eq 0) then begin    
;444444444444444444444444444444444444444444444444444444444444
        if (a eq 3) then begin
;         if (c eq 0) then plot,sign*ff(*,x,y,z)
         if (c eq 1) then plot,sign*ff(*,y,z)
         if (c eq 2) then plot,sign* ff(x,*,z)
         if (c eq 3) then plot,sign* ff(x,y,*)
        endif else begin 
;555555555555555555555555555555555555555555555555555555555555
         if (a eq 4) then begin
;          if (c eq 0) then oplot,sign* ff(*,x,y,z)
          if (c eq 1) then oplot,sign*  ff(*,y,z)
          if (c eq 2) then oplot,sign* ff(x,*,z)
          if (c eq 3) then oplot,sign* ff(x,y,*)
         endif else begin
          if (b eq 0) then begin
;           if (a eq 0) then contour, sign*ff(*,*,y,z)
;           if (a eq 1) then surface,sign* ff(*,*,y,z)
;           if (a eq 2) then show3,sign* ff(*,*,y,z)
;           if (a eq 5) then shade_surf,sign* ff(*,*,y,z)
;           if (a eq 6) then image_cont,sign* ff(*,*,y,z)
;           if (a eq 8) then image_cont1,sign* ff(*,*,y,z)
;           if (a eq 7) then image, sign* ff(*,*,y,z)
;           if (a eq 9) then velovect, ff(*,*,y,z),fff(*,*,y,z)
          endif
          if (b eq 1) then begin
           if (a eq 0) then contour,sign*reform(ff(*,*,z))
           if (a eq 1) then surface,sign*reform(ff(*,*,z))
           if (a eq 2) then show3,sign* reform(ff(*,*,z))
           if (a eq 5) then shade_surf,sign*reform(ff(*,*,z))
           if (a eq 6) then image_cont,sign*reform(ff(*,*,z))
           if (a eq 8) then image_cont1,sign*reform(ff(*,*,z))
           if (a eq 7) then image,sign*reform(ff(*,*,z))
           if (a eq 9) then velovect,reform(ff(*,*,z)),reform(fff(*,*,z))
          endif
          if (b eq 2) then begin
           if (a eq 0) then contour,sign*reform(ff(x,*,*))
           if (a eq 1) then surface,sign*reform( ff(x,*,*))
           if (a eq 2) then show3,sign*reform(ff(x,*,*))
           if (a eq 5) then shade_surf,sign*reform(ff(x,*,*))
           if (a eq 6) then image_cont,sign*reform(ff(x,*,*))
           if (a eq 8) then image_cont1,sign*reform(ff(x,*,*))
           if (a eq 7) then image,sign*reform(ff(x,*,*))
           if (a eq 9) then velovect,reform(ff(x,*,*)),reform(fff(x,*,*))
          endif
          if (b eq 5) then begin
           if (a eq 0) then contour,sign*reform(ff(*,y,*))
           if (a eq 1) then surface,sign*reform( ff(*,y,*))
           if (a eq 2) then show3,sign*reform(ff(*,y,*))
           if (a eq 5) then shade_surf,sign*reform(ff(*,y,*))
           if (a eq 6) then image_cont,sign*reform(ff(*,y,*))
           if (a eq 8) then image_con1t,sign*reform(ff(*,y,*))
           if (a eq 7) then image,sign*reform(ff(*,y,*))
           if (a eq 9) then velovect,reform(ff(*,y,*)),reform(fff(*,y,*))
          endif
          if (b eq 4) then begin
;           if (a eq 0) then contour,sign*reform(ff(*,x,y,*))
;           if (a eq 1) then surface,sign*reform( ff(*,x,y,*))
;           if (a eq 2) then show3,sign*reform(ff(*,x,y,*))
;           if (a eq 5) then shade_surf,sign*reform(ff(*,x,y,*))
;           if (a eq 6) then image_cont,sign*reform(ff(*,x,y,*))
;           if (a eq 8) then image_cont1,sign*reform(ff(*,x,y,*))
;           if (a eq 7) then image,sign*reform(ff(*,x,y,*))
;           if (a eq 9) then velovect,reform(ff(*,x,y,*)),reform(fff(*,x,y,*))
          endif
          if (b eq 3) then begin
;           if (a eq 0) then contour,sign*reform(ff(*,x,*,z))
;           if (a eq 1) then surface,sign*reform( ff(*,x,*,z))
;           if (a eq 2) then show3,sign*reform(ff(*,x,*,z))
;           if (a eq 5) then shade_surf,sign*reform(ff(*,x,*,z))
;           if (a eq 6) then image_cont,sign*reform(ff(*,x,*,z))
;           if (a eq 8) then image_cont1,sign*reform(ff(*,x,*,z))
;           if (a eq 7) then image,sign*reform(ff(*,x,*,z))
;           if (a eq 7) then velovect,reform(ff(*,x,*,z)),reform(fff(*,x,*,z))
          endif
         endelse
;55555555555555555555555555555555555555555555555555555555555555555555
        endelse
;44444444444444444444444444444444444444444444444444444444444444444444
       endif else begin
;44444444444444444444444444444444444444444444444444444444444444444444
        if (a eq 3) then begin
 ;        if (c eq 0) then plot,alog(abs(fft(sign*ff(*,x,y,z),1)))
         if (c eq 1) then plot,alog(abs(fft(sign*ff(*,y,z),1)))
         if (c eq 2) then plot,alog(abs(fft(sign* ff(x,*,z),1)))
         if (c eq 3) then plot,alog(abs(fft(sign* ff(x,y,*),1)))
        endif else begin 
;5555555555555555555555555555555555555555555555555555555555555555555
         if (a eq 4) then begin
;          if (c eq 0) then oplot,alog(abs(fft(sign* ff(*,x,y,z),1)))
          if (c eq 1) then oplot,alog(abs(fft(sign*  ff(*,y,z),1)))
          if (c eq 2) then oplot,alog(abs(fft(sign* ff(x,*,z),1)))
          if (c eq 3) then oplot,alog(abs(fft(sign* ff(x,y,*),1)))
         endif else begin
          if (b eq 0) then begin
;           if (a eq 0) then contour, alog(abs(fft(sign*ff(*,*,y,z),1)))
;           if (a eq 1) then surface,sign*alog(abs(fft( ff(*,*,y,z),1)))
;           if (a eq 2) then show3,sign*alog(abs(fft( ff(*,*,y,z),1)))
;           if (a eq 5) then shade_surf,alog(abs(fft(sign* ff(*,*,y,z),1)))
;           if (a eq 6) then image_cont,sign*alog(abs(fft( ff(*,*,y,z),1)))
;;           if (a eq 8) then image_cont1,sign*alog(abs(fft( ff(*,*,y,z),1)))
;           if (a eq 7) then image, sign*alog(abs(fft( ff(*,*,y,z),1)))
          endif
          if (b eq 1) then begin
           if (a eq 0) then contour,sign*alog(abs(fft(reform(ff(*,*,z)),1)))
           if (a eq 1) then surface,sign*alog(abs(fft(reform(ff(*,*,z)),1)))
           if (a eq 2) then show3,sign*alog(abs(fft( reform(ff(*,*,z)),1)))
           if (a eq 5) then shade_surf,alog(abs(fft(sign*reform(ff(*,*,z)),1)))
           if (a eq 6) then image_cont,alog(abs(fft(sign*reform(ff(*,*,z)),1)))
           if (a eq 8) then image_cont1,alog(abs(fft(sign*reform(ff(*,*,z)),1)))
           if (a eq 7) then image,sign*alog(abs(fft(reform(ff(*,*,z)),1)))
          endif
          if (b eq 2) then begin
           if (a eq 0) then contour,sign*alog(abs(fft(reform(ff(x,*,*)),1)))
           if (a eq 1) then surface,sign*alog(abs(fft(reform( ff(x,*,*)),1)))
           if (a eq 2) then show3,sign*alog(abs(fft(reform(ff(x,*,*)),1)))
           if (a eq 5) then shade_surf,sign*alog(abs(fft(reform(ff(x,*,*)),1)))
           if (a eq 6) then image_cont,sign*alog(abs(fft(reform(ff(x,*,*)),1)))
           if (a eq 8) then image_cont1,sign*alog(abs(fft(reform(ff(x,*,*)),1)))
           if (a eq 7) then image,sign*alog(abs(fft(reform(ff(x,*,*)),1)))
          endif
          if (b eq 5) then begin
           if (a eq 0) then contour,sign*alog(abs(fft(reform(ff(*,y,*)),1)))
           if (a eq 1) then surface,sign*alog(abs(fft(reform( ff(*,y,*)),1)))
           if (a eq 2) then show3,sign*alog(abs(fft(reform(ff(*,y,*)),1)))
           if (a eq 5) then shade_surf,sign*alog(abs(fft(reform(ff(*,y,*)),1)))
           if (a eq 6) then image_cont,sign*alog(abs(fft(reform(ff(*,y,*)),1)))
           if (a eq 8) then image_con1t,sign*alog(abs(fft(reform(ff(*,y,*)),1)))
           if (a eq 7) then image,sign*alog(abs(fft(reform(ff(*,y,*)),1)))
          endif
          if (b eq 4) then begin
;           if (a eq 0) then contour,sign*alog(abs(fft(reform(ff(*,x,y,*)),1)))
;           if (a eq 1) then surface,sign*alog(abs(fft(reform( ff(*,x,y,*)),1)))
;           if (a eq 2) then show3,sign*alog(abs(fft(reform(ff(*,x,y,*)),1)))
;           if (a eq 5) then shade_surf,sign*alog(abs(fft(reform(ff(*,x,y,*)),1)))
;           if (a eq 6) then image_cont,sign*alog(abs(fft(reform(ff(*,x,y,*)),1)))
;           if (a eq 8) then image_cont1,sign*alog(abs(fft(reform(ff(*,x,y,*)),1)))
;           if (a eq 7) then image,sign*alog(abs(fft(reform(ff(*,x,y,*)),1)))
          endif
          if (b eq 3) then begin
;           if (a eq 0) then contour,sign*alog(abs(fft(reform(ff(*,x,*,z)),1)))
;           if (a eq 1) then surface,sign*alog(abs(fft(reform( ff(*,x,*,z)),1)))
;           if (a eq 2) then show3,sign*alog(abs(fft(reform(ff(*,x,*,z)),1)))
;           if (a eq 5) then shade_surf,sign*alog(abs(fft(reform(ff(*,x,*,z)),1)))
;           if (a eq 6) then image_cont,sign*alog(abs(fft(reform(ff(*,x,*,z)),1)))
;           if (a eq 8) then image_cont1,sign*alog(abs(fft(reform(ff(*,x,*,z)),1)))
;           if (a eq 7) then image,sign*alog(abs(fft(reform(ff(*,x,*,z)),1)))
          endif
         endelse
;55555555555555555555555555555555555555555555555555555555555555555555
        endelse
;44444444444444444444444444444444444444444444444444444444444444444444
       endelse
;33333333333333333333333333333333333333333333333333333333333333333333
      endif   
;22222222222222222222222222222222222222222222222222222222222222222222
     endif
;11111111111111111111111111111111111111111111111111111111111111111111
end
