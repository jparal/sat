;
read,'beta = ',beta
read,'theta = ',theta
theta=theta/180.*!pi
read,'mach num = ',ma
v1=sqrt(beta*.5)/ma
bx=cos(theta)/ma
bz=sin(theta)/ma
kk=5*v1^2+1
bx2=bx^2
bz2=bz^2
a=[-bx2*(bz2+bx2*kk),-(.5*bz2-2*bx2*(kk+2*bx2+bz2)),-(kk+2.5*bz2+8*bx2),4]
zroots,a,roots
print, roots
read,'which ?',n
ux=float(roots(n-1))
uz=bz*bx*(1-ux)/(ux-bx2)
b2z=bz*(1-bx2)/(ux-bx2)
b=sqrt(bx2+b2z^2)
theta2=asin(b2z/b)/!pi*180.
bzr=b2z/bz
bob=1+0.2/v1^2*(1+2*bz2-ux^2-uz^2-2*b2z*bz)
print,'u2x= ', ux*ma
print,'u2z= ', uz*ma
print,'n2/n1= ', 1/ux
print,'theta2= ', theta2
print,'bz2/bz1= ', bzr
print,'T2/T1= ', bob
end
