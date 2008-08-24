!p.subtitle=''
;
!p.title='Density'
 plot, dn(*,10,10)
;
!p.title='Correlation density bx'
 plcor ,dn,bx
;
!p.title='Correlation density by'
 plcor ,dn,by
;
!p.title='Correlation density bz'
 plcor ,dn,bz
a=' '
read, a
;
 !p.title='B'
 plot, b(*,10,10)
;
!p.title='Correlation bx by'
 plcor, by,bx
;
!p.title='Correlation bx bz'
 plcor, bx,bz
;
!p.subtitle='t= '+t
!p.title='Correlation by bz'
 plcor, by,bz
;
