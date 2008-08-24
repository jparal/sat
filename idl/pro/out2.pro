!p.subtitle=''
;
!p.title=' Density '
image_cont, reform(dn(i,*,*))
;
!p.title=' vx '
image_cont,reform(ux(i,*,*))
!p.title=' vy '
image_cont,reform(uy(i,*,*))
!p.title=' vz '
image_cont,reform(uz(i,*,*))
;
a=' '
read,a

;
!p.title=' B-magnitude '
image_cont,reform(b(i,*,*))
;
!p.title=' Bx '
image_cont, reform(bx(i,*,*))
;
!p.title=' By '
image_cont, reform(by(i,*,*))
;
!p.title=' Bz '
!p.subtitle=' x= '+string(i)
image_cont, reform(bz(i,*,*))
;
