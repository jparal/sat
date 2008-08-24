;
  pro menu2d2_event, event
  common d2fields, cbx,cby,cbz,$
                    cex,cey,cez,$
                    cux,cuy,cuz,$
                    cdn,cpe
  common momsep, dn1,ux1,uy1,uz1, $
                 dn2,ux2,uy2,uz2
  common ran, u,tp
  common rot, rbx, rby, rbz, rux, ruy, ruz
  common poynt, csx, csy, csz
  common f, ff,fff, a,b,c
  common coor, x,y 
  common list, list0,list1,list2,list3 
  common util, fft, shift,sign
  common fil, filnam
  common exe, filexe
  common textid, textfil, textexe
  common psss, pslog
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
    endif
;111111111111111111111111111111111111111111111111111111111111111111111111111
 if (type eq 'WIDGET_BUTTON') then begin
    widget_control, get_value=i , event.id  
      if (i eq 'B') then begin
       ff = sqrt(cbx^2+cby^2+cbz^2) 
       !p.title=' !17 B!3 '
      endif
      if (i eq 'E') then begin
       ff = sqrt(cex^2+cey^2+cez^2) 
       !p.title=' !17 E!3 '
      endif
      if (i eq 'S') then begin
       ff = sqrt(csx^2+csy^2+csz^2) 
       !p.title=' !17 S!3 '
      endif
      if (i eq 'u') then begin
       ff = sqrt(cux^2+cuy^2+cuz^2) 
       !p.title=' !17 u!3 '
      endif
      if (i eq 'u1') then begin
       ff = sqrt(ux1^2+uy1^2+uz1^2) 
       !p.title=' !17 u!i1!3 '
      endif
      if (i eq 'u2') then begin
       ff = sqrt(ux2^2+uy2^2+uz2^2) 
       !p.title=' !17 u!i2!3 '
      endif
      if (i eq 'Bx') then begin
       ff = cbx 
       !p.title='  !17 B!Ix!3 '
      endif 
     if (i eq 'By') then begin
       ff = cby 
       !p.title='  !17 B!Iy!3 '
      endif 
      if (i eq 'Bz') then  begin
       ff = cbz 
       !p.title='  !17 B!Iz!3 '
      endif    
      if (i eq 'BxBy') then begin
       ff = cbx 
       fff=cby
       !p.title='  !17 B!Ix!N B!Iy!3 '
      endif
      if (i eq 'BxBz') then begin
       ff = cbx 
       fff=cbz
       !p.title='  !17 B!Ix!N B!Iz!3'
      endif 
      if (i eq 'ByBz') then  begin
       ff = cby
       fff=cbz
       !p.title='  !17 B!Iy!N B!Iz!3 '
      endif    
      if (i eq 'RotBxRotBy') then begin
       ff = rbx 
       fff=rby
       !p.title='  !17 RotB!Ix!N RotB!Iy!3 '
      endif
      if (i eq 'RotBxRotBz') then begin
       ff = rbx 
       fff=rbz
       !p.title='  !17 RotB!Ix!N RotB!Iz!3'
      endif 
      if (i eq 'RotByRotBz') then  begin
       ff = rby
       fff=rbz
       !p.title='  !17 RotB!Iy!N RotB!Iz!3 '
      endif 
      if (i eq 'RotBx') then begin
       ff = rbx 
       !p.title='  !17 rotB!Ix!3 '
      endif
      if (i eq 'RotBy') then begin
       ff = rby 
       !p.title='  !17 rotB!Iy!3 '
      endif 
      if (i eq 'RotBz') then  begin
       ff = rbz 
       !p.title='  !17 rotB!Iz!3 '
      endif  
      if (i eq 'Ex') then  begin
       ff = cex
       !p.title='  !17 E!Ix!3 '
      endif  
      if (i eq 'Ey') then  begin
       ff = cey 
       !p.title='  !17 E!Iy!3 '
      endif 
      if (i eq 'Ez') then  begin
       ff = cez 
       !p.title='  !17 E!Iz!3 '
      endif     
      if (i eq 'ExEy') then begin
       ff = cex 
       fff=cey
       !p.title='  !17 E!Ix!N E!Iy!3 '
      endif
      if (i eq 'ExEz') then begin
       ff = cex 
       fff=cez
       !p.title='  !17 E!Ix!N E!Iz!3'
      endif 
      if (i eq 'EyEz') then  begin
       ff = cey
       fff=cez
       !p.title='  !17 E!Iy!N E!Iz!3 '
      endif 
      if (i eq 'Sx') then  begin
       ff =csx
       !p.title='  !17 S!Ix!3 '
      endif  
      if (i eq 'Sy') then  begin
       ff = csy 
       !p.title='  !17 S!Iy!3 '
      endif 
      if (i eq 'Sz') then  begin
       ff = csz 
       !p.title='  !17 S!Iz!3 '
      endif     
      if (i eq 'SxSy') then begin
       ff = csx 
       fff=csy
       !p.title='  !17 S!Ix!N S!Iy!3 '
      endif
      if (i eq 'SxSz') then begin
       ff = csx 
       fff=csz
       !p.title='  !17 S!Ix!N S!Iz!3'
      endif 
      if (i eq 'SySz') then  begin
       ff = csy
       fff=csz
       !p.title='  !17 S!Iy!N S!Iz!3 '
      endif 
      if (i eq 'ux') then  begin
       ff = cux 
       !p.title='  !17 u!Ix!3 '
      endif  
      if (i eq 'uy') then  begin
       ff = cuy 
       !p.title='  !17 u!Iy!3 '
      endif  
      if (i eq 'uz') then  begin
       ff = cuz 
       !p.title='  !17 u!Iz!3 '
      endif     
      if (i eq 'uxuy') then begin
       ff = cux 
       fff=cuy
       !p.title='  !17 u!Ix!N u!Iy!3 '
      endif
      if (i eq 'uxuz') then begin
       ff = cux 
       fff=cuz
       !p.title='  !17 u!Ix!N u!Iz!3'
      endif 
      if (i eq 'uyuz') then  begin
       ff = cuy
       fff=cuz
       !p.title='  !17 u!Iy!N u!Iz!3 '
      endif    
      if (i eq 'ux1') then  begin
       ff = ux1 
       !p.title='  !17 u!Ix1!3 '
      endif  
      if (i eq 'uy1') then  begin
       ff = uy1 
       !p.title='  !17 u!Iy1!3 '
      endif  
      if (i eq 'uz1') then  begin
       ff = uz1 
       !p.title='  !17 u!Iz1!3 '
      endif     
      if (i eq 'uxuy1') then begin
       ff = ux1 
       fff=uy1
       !p.title='  !17 u!Ix1!N u!Iy1!3 '
      endif
      if (i eq 'uxuz1') then begin
       ff = ux1 
       fff=uz1
       !p.title='  !17 u!Ix1!N u!Iz1!3'
      endif 
      if (i eq 'uyuz1') then  begin
       ff = uy1
       fff=uz1
       !p.title='  !17 u!Iy1!N u!Iz1!3 '
      endif    
      if (i eq 'ux2') then  begin
       ff = ux2 
       !p.title='  !17 u!Ix2!3 '
      endif  
      if (i eq 'uy2') then  begin
       ff = uy2 
       !p.title='  !17 u!Iy2!3 '
      endif  
      if (i eq 'uz2') then  begin
       ff = uz2 
       !p.title='  !17 u!Iz2!3 '
      endif     
      if (i eq 'uxuy2') then begin
       ff = ux2 
       fff=uy2
       !p.title='  !17 u!Ix2!N u!Iy2!3 '
      endif
      if (i eq 'uxuz2') then begin
       ff = ux2 
       fff=uz2
       !p.title='  !17 u!Ix2!N u!Iz2!3'
      endif 
      if (i eq 'uyuz2') then  begin
       ff = uy2
       fff=uz2
       !p.title='  !17 u!Iy!N u!Iz!3 '
      endif    
      if (i eq 'RotuxRotuy') then begin
       ff = rux 
       fff=ruy
       !p.title='  !17 Rotu!Ix!N Rotu!Iy!3 '
      endif
      if (i eq 'RotuxRotuz') then begin
       ff = rux 
       fff=ruz
       !p.title='  !17 Rotu!Ix!N Rotu!Iz!3'
      endif 
      if (i eq 'RotuyRotuz') then  begin
       ff = ruy
       fff=ruz
       !p.title='  !17 Rotu!Iy!N Rotu!Iz!3 '
      endif 
      if (i eq 'Rotux') then  begin
       ff = rux 
       !p.title='  !17 rotu!Ix!3 '
      endif  
      if (i eq 'Rotuy') then  begin
       ff = ruy 
       !p.title='  !17 rotu!Iy!3 '
      endif  
      if (i eq 'Rotuz') then  begin
       ff = ruz 
       !p.title='  !17 rotu!Iz!3 '
      endif 
      if (i eq 'dn') then  begin
       ff = cdn 
       !p.title='  !4 q!3 '
      endif 
      if (i eq 'dn1') then  begin
       ff = dn1 
       !p.title='  !4 q!i1!3 '
      endif 
      if (i eq 'dn2') then  begin
       ff = dn2 
       !p.title='  !4 q!i2!3 '
      endif 
      if (i eq 'pe') then  begin
       ff = cpe 
       !p.title='  !17 p!Ie!3 '
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
      if (i eq 'Image_cont1') then a=8
      if (i eq 'Image') then a=7
      if (i eq 'Vector') then a=9
      if (i eq 'FFT') then fft=1
      if (i eq 'No FFT') then fft=0
      if (i eq '+') then sign=1.
      if (i eq '-') then sign=-1.
      if (i eq 'x') then  begin
       c=1
       !x.title=' !8 x [ c/!4 x!8!Ipi!n ] !3'
       !y.title='  '
      endif
      if (i eq 'y') then  begin
       c=2
       !x.title=' !8 y [ c/!4 x!8!Ipi!n ] !3'
       !y.title='  '
      endif
      if (i eq 'xy') then begin
       b=1
       !x.title=' !8 x [ c/!4 x!8!Ipi!n ] !3'
       !y.title=' !8 y [ c/!4 x!8!Ipi!n ]!3 '
      endif
      if (i eq ' WCALC ') then wcalc
      if (i eq ' XPALETTE ') then xpalette
      if (i eq ' EXECUTE ')then exxxx=execute(filexe)
      if (i eq ' NEW FILE ')then menu2drd2  
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
         if (c eq 1) then plot,sign*ff(*,y)
         if (c eq 2) then plot,sign* ff(x,*)
        endif else begin 
;555555555555555555555555555555555555555555555555555555555555
         if (a eq 4) then begin
          if (c eq 1) then oplot,sign*  ff(*,y)
          if (c eq 2) then oplot,sign* ff(x,*)
         endif else begin
          if (b eq 1) then begin
           if (a eq 0) then contour,sign*reform(ff(*,*))
           if (a eq 1) then surface,sign*reform(ff(*,*))
           if (a eq 2) then show3,sign* reform(ff(*,*))
           if (a eq 5) then shade_surf,sign*reform(ff(*,*))
           if (a eq 6) then image_cont,sign*reform(ff(*,*))
           if (a eq 8) then image_cont1,sign*reform(ff(*,*))
           if (a eq 7) then image1,sign*reform(ff(*,*))
           if (a eq 9) then image_vec,reform(ff(*,*)),reform(fff(*,*))
          endif
         endelse
;55555555555555555555555555555555555555555555555555555555555555555555
        endelse
;44444444444444444444444444444444444444444444444444444444444444444444
       endif else begin
;44444444444444444444444444444444444444444444444444444444444444444444
        sz=size(ff)/2
        if (a eq 3) then begin
         if (c eq 1) then plot,alog(abs(fft(sign*ff(*,y),1)))
         if (c eq 2) then plot,alog(abs(fft(sign* ff(x,*),1)))
        endif else begin 
;5555555555555555555555555555555555555555555555555555555555555555555
          sa=size(ff)
           s1=sa(1)/2
           s2=sa(2)/2 
         if (a eq 4) then begin
          if (c eq 1) then oplot,alog(abs(fft(sign*  ff(*,y),1)))
          if (c eq 2) then oplot,alog(abs(fft(sign* ff(x,*),1)))
         endif else begin
          if (b eq 1) then begin
            fff=sign*alog(abs(fft(ff,1)))
           if (a eq 0) then contour, shift(fff,s1,s2)
           if (a eq 1) then surface, shift(fff,s1,s2)
           if (a eq 2) then show3, shift(fff,s1,s2)
           if (a eq 5) then shade_surf,  shift(fff,s1,s2)
           if (a eq 6) then image_cont, shift(fff,s1,s2)
           if (a eq 8) then image_cont1, shift(fff,s1,s2)
           if (a eq 7) then image1,shift(fff,s1,s2)  
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
