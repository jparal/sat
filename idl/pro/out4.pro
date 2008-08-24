!p.subtitle=''
 
;
!p.title=' Density '

 plskeW,reform(dn(i,*,*)),s,0,20 
;
!p.title=' vx '
PlSkew,reform(ux(i,*,*)),s,0,20
!p.title=' vy '
 plskeW,reform(uy(i,*,*)),s,0,20
!p.title=' vz '
plskeW,reform(uz(i,*,*)),s,0,20
;
a=' '
read,a

;
!p.title=' B-magnitude '
plskeW ,reform(b(i,*,*)),s,0,20
;
!p.title=' Bx '
plskeW  , reform(bx(i,*,*)),s,0,20
;
!p.title=' By '
plskeW , reform(by(i,*,*)),s,0,20
;
!p.title=' Bz '
!p.subtitle=' x= '+string(i)
plskeW  , reform(bz(i,*,*)),s,0,20
;
