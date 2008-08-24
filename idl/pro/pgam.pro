pro pgam, aa, nx,dt,b,r,c,rc
a=alog(abs(aa))
ar=float(aa)
ai=imaginary(aa)
ph=atan(ar,ai)
ss=size(a)
s0=ss(0)
if(s0 eq 2)then begin
s1=ss(1)
s2=ss(2)
t=findgen(1,nx)*dt
tc=t
au=fltarr(nx)
auph=au
w=fltarr(nx)+1.
b=fltarr(s1,s2/nx)
r=b
c=b
rc=c
;window,1
;!P.MULTI = [0, 2, 0, 0, 0]
for i=0,s1-1 do begin
ij=-1
for j=0,s2-1,nx do begin
ij=ij+1
npi=0
for iha=0,nx-1 do begin
 au(iha)=a(i,j+iha)
; aup=ph(i,j+iha) 
; if(iha ge 1)then begin
; if( (auph(iha-1)-aup) gt 5.)then npi=npi+1
; if( (auph(iha-1)-aup) lt -5.)then npi=npi-1 
; endif
; auph(iha)=aup+npi*2*!pi
endfor
;if( (ij eq 6) and (i eq 42))then begin
;plot,t(0,*),au
;plot,tc(0,*),auph
;endif
res=regress(t,au,w,yfit,a0,sigma,rr,rmul,chisq,/relative_weight)
;w=fltarr(nx)+1.
;res1=regress(tc,auph,w,yfit1,a0,sigma1,rr1,rmul1,chisq1,/relative_weight)
b(i,ij)=res(0)
;c(i,ij)=res1(0)
r(i,ij)=correlate(t(0,*),au)
;rc(i,ij)=correlate(tc(0,*),auph)
c(i,ij)=(ph(i,j+1)-ph(i,j))/dt
endfor
endfor
endif
window,0
!p.multi=0
end
