!p.subtitle=''
!p.multi=[0,3,2,0,0]
;
!p.title=' Density '
image_cont, reform(dn(i,*,*))
;
!p.title=' (vy,vz) '
uym=total(uy(i,*,*))/ny/nz
uzm=total(uz(i,*,*))/ny/nz
print, uym,uzm
image_vec,  reform(uy(i,*,*)-uym), reform(uz(i,*,*)-uzm),n=n,$
length=l,color=c
;
!p.title=' vx '
image_cont,reform(ux(i,*,*))
;
!p.title=' B-magnitude '
image_cont,reform(b(i,*,*))
;
!p.title=' (By,Bz) '
;bym=total(by(i,*,*))/ny/nz
;bzm=total(bz(i,*,*))/ny/nz
;print, bym,bzm
image_vec, reform(by(i,*,*)), reform(bz(i,*,*)),n=n,$
length=l,color=c
;
!p.title=' Bx '
!p.subtitle=' x= '+string(i)
image_cont, reform(bx(i,*,*))
;
