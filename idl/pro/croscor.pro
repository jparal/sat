; find local maxima of cross-correlation b(i1,*),b(i2,*)
; bstr='title of file', a index, ii difference of ind. (plots!)
pro croscor, b,bstr, i1,i2,c,ii,a

b1=transpose(b)
cor1,b1(*,i1),b1(*,i2),c,ii
slmax,c,a,aa
s=string(ii(a))
s1=string(aa)
si=size(a)
ss='lmax: '
for i=0,si(1)-1 do if(aa(i) gt 0.)then ss=ss+'['+s(i)+','+s1(i)+']'
ss=strcompress(ss)
plot,ii,c,xtitle=ss,
title='Cross-correlation '+bstr+strcompress(string(i1)+string(i2))
oplot, ii(a), c(a), psym=5
return
end



