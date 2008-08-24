!p.subtitle=''
;
!p.title=' Density '
image_cont0, reform(dn )
;
!p.title=' (vx,vy) '
image_vec,  reform(ux ), reform(uy ),n=n,$
length=l,color=c
;
!p.title=' vx '
image_cont0,reform(ux )
;
!p.title=' B-magnitude '
image_cont0,reform(b )
;
!p.title=' (Bx,By) '
image_vec, reform(bx ), reform(by ),n=n,$
length=l,color=c
;
!p.title=' Bz '
!p.subtitle=' t  ='+ t
image_cont0, reform(bz )
;
