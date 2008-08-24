;
  pro rahu, beta, theta,num=num,mmin=mmin,mmax=mmax
theta=theta/180.*!pi
if not(keyword_set(num)) then num=100
if not(keyword_set(mmin)) then mmin=1
if not(keyword_set(mmax)) then mmax=10
den=fltarr(num+1)
bb=den
the=den
bm=den
betas=den
numi=1./num
ii=den
for i=0, num do begin
ma=mmin+numi*i*(mmax-mmin)
ii(i)=ma
v1=sqrt(beta*.5)/ma
bx=cos(theta)/ma
bz=sin(theta)/ma
kk=5*v1^2+1
bx2=bx^2
bz2=bz^2
a=[-bx2*(bz2+bx2*kk),-(.5*bz2-2*bx2*(kk+2*bx2+bz2)),-(kk+2.5*bz2+8*bx2),4]
zroots,a,roots
;print, roots
;read,'which ?',n
n=3
ux=float(roots(n-1))
uz=bz*bx*(1-ux)/(ux-bx2)
b2z=bz*(1-bx2)/(ux-bx2)
b=sqrt(bx2+b2z^2)
theta2=asin(b2z/b)/!pi*180.
b=b/sqrt(bx2+bz2)
bob=v1^2+0.2*(1+2*bz2-ux^2-uz^2-2*b2z*bz)
;print,'u2x= ', ux*ma
;print,'u2z= ', uz*ma
;print,'n2/n1= ', 1/ux
;print,'theta2= ', theta2
;print,'abs(b)= ', b
;print,'T2/T1= ', bob
den(i)=1/ux
bb(i)=b2z/bz
the(i)=theta2
bm(i)=b
betas(i)=bob
endfor
!p.multi=[0,2,2,0,0]
plot,ii, den ,title=' density & b2z/b1z '
oplot,ii,bb,linestyle=3
plot,ii,the,title=' theta2'
plot,ii,betas,title='v2^2'
plot,ii,bm,title=' Magnitude B'
return
end
