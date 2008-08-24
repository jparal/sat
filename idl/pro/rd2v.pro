pro rd2v,file,n1,n2,a,b,c
iunit=9
openr,iunit,file
aux=fltarr(3,n1,n2)
readf,iunit,aux
close,iunit
a=reform(aux(0,*,*))
b=reform(aux(1,*,*))
c=reform(aux(2,*,*))
return
end
