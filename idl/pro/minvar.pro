pro minvar, bx,by,bz, n1,n2,c0,bm,d,z,b1,b2,b3
c=fltarr(3,3)
c0=fltarr(3,3)
e=fltarr(3)
d=e
z=fltarr(3,3)
n=n2-n1+1
bxm=total(bx(n1:n2))/n
bym=total(by(n1:n2))/n
bzm=total(bz(n1:n2))/n
bm=[bxm,bym,bzm]
c(0,0)= total(bx(n1:n2)^2)/n -bxm*bxm
c(1,1)= total(by(n1:n2)^2)/n -bym*bym
c(0,1)= total(bx(n1:n2)*by(n1:n2))/n -bym*bxm 
c(0,2)= total(bx(n1:n2)*bz(n1:n2))/n -bzm*bxm +.1
c(2,2)= total(bz(n1:n2)^2)/n -bzm*bzm
c(1,2)= total(by(n1:n2)*bz(n1:n2))/n -bym*bzm
c(1,0)=c(0,1)
c(2,0)=c(0,2)
c(2,1)=c(1,2)
c0=c
c=10*c
print,'c= ',c
tred2,c,d,e
print,'d = ',d,'e= ',e
tqli,d,e,z
print,'d= ',d,'e= ',e,'z= ',z
z(0,*)= z(0,*)/sqrt((total(z(0,*)^2)))
z(1,*)= z(1,*)/sqrt((total(z(1,*)^2)))
z(2,*)= z(2,*)/sqrt((total(z(2,*)^2)))
 b1=bx*z(0,0)+by*z(0,1)+bz*z(0,2)
 b2=bx*z(1,0)+by*z(1,1)+bz*z(1,2)
 b3=bx*z(2,0)+by*z(2,1)+bz*z(2,2)
return
end
