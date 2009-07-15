function z,ksi
;      double precision x,y,zr,zi,zpr,zpi
;      double complex ksi, z,b(8),c(8),i,zp
i=dcomplex(0.d0,1.d0)
b=[ dcomplex(-1.734012457471826d-2, -4.630639291680322d-2), $
    dcomplex(-1.734012457471826d-2, 4.630639291680322d-2), $
    dcomplex(-7.399169923225014d-1, 8.395179978099844d-1), $
    dcomplex(-7.399169923225014d-1, -8.395179978099844d-1), $
    dcomplex(5.840628642184073d0, 9.536009057643667d-1), $
    dcomplex(5.840628642184073d0, -9.536009057643667d-1), $
    dcomplex(-5.583371525286853d0, -1.120854319126599d1), $
    dcomplex(-5.583371525286853d0, 1.120854319126599d1)]
c=[ dcomplex( 2.237687789201900d0, -1.625940856173727d0), $
    dcomplex(-2.237687789201900d0, -1.625940856173727d0), $
    dcomplex( 1.465234126106004d0, -1.789620129162444d0), $
    dcomplex(-1.465234126106004d0, -1.789620129162444d0), $
    dcomplex( .8392539817232638d0, -1.891995045765206d0), $
    dcomplex(-.8392539817232638d0, -1.891995045765206d0), $
    dcomplex( .2739362226285564d0, -1.941786875844713d0), $
    dcomplex(-.2739362226285564d0, -1.941786875844713d0)]

zz=dcomplex(0.d0,0.d0)
for j=0,7  do begin
  zz=zz+b(j)/(ksi-c(j))
endfor
return,zz
end
