!p.subtitle=''
 
;
!p.title=' Density '

 plot,reform(dn(i,10,*))
;
!p.title=' vx '
plot ,reform(ux(i,10,*))
!p.title=' vy '
 plot,reform(uy(i,10,*))
!p.title=' vz '
plot ,reform(uz(i,10,*))
;
a=' '
read,a

;
!p.title=' B-magnitude '
plot  ,reform(b(i,10,*))
;
!p.title=' Bx '
plot  , reform(bx(i,10,*))
;
!p.title=' By '
plot  , reform(by(i,10,*))
;
!p.title=' Bz '
!p.subtitle=' x= '+string(i)
plot  , reform(bz(i,10,*))
;
