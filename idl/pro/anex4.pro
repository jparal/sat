;4th order analytic extrapolation of omega(k) to complex k=kr+i*ki
; and shock solution of given theta and vsh
pro anex4, ikpe,ikpa,omer,omei,theta,vsh,ki,om,kip,omp,ai0,ai1,ai2,ai3,ai4 
s=size(omei)
n1=s(1)
n2=s(2)
ai0=omei
ar0=omer
thetan=theta*!pi/180.
nx=sin(thetan)
ny=cos(thetan)
dkx=ikpe(1)-ikpe(0)
dky=ikpa(1)-ikpa(0)
ddx,dkx,omer,omrx
ddy,dky,omer,omry
;
ai1=nx*omrx+ny*omry-vsh
;
ddx,dkx,omei,omix
ddx,dkx,omix,omixx
ddy,dky,omei,omiy
ddy,dky,omiy,omiyy
ddy,dky,omix,omixy
ddx,dkx,omiy,omiyx
omixy=.5*(omixy+omiyx)
ai2=-.5*(nx^2*omixx+ny^2*omiyy+2*nx*ny*omixy)
;
ar1=-(nx*omix+ny*omiy)
;
ddx,dkx,omrx,omrxx
ddy,dky,omry,omryy
ddy,dky,omrx,omrxy
ddx,dkx,omry,omryx
omrxy=.5*(omrxy+omryx)
;
ar2=-.5*(nx^2*omrxx+ny^2*omryy+2*nx*ny*omrxy)
;
ddx,dkx,omrxx,omrxxx
ddy,dky,omrxx,omrxxy
ddy,dky,omrxy,omrxyy
ddx,dkx,omrxy,omrxyx
ddx,dkx,omryy,omryyx
ddy,dky,omryy,omryyy
omryyx=.5*(omryyx+omrxyy)
omrxxy=.5*(omrxxy+omrxyx)
;
ai3=-1./6.*(nx^3*omrxxx+3*nx^2*ny*omrxxy+3*nx*ny^2*omryyx+ny^3*omryyy)
;
ddx,dkx,omixx,omixxx
ddy,dky,omixx,omixxy
ddy,dky,omixy,omixyy
ddx,dkx,omixy,omixyx
ddx,dkx,omiyy,omiyyx
ddy,dky,omiyy,omiyyy
omiyyx=.5*(omiyyx+omixyy)
omixxy=.5*(omixxy+omixyx)
;
ar3=1./6.*(nx^3*omixxx+3*nx^2*ny*omixxy+3*nx*ny^2*omiyyx+ny^3*omiyyy)
;
ddx,dkx,omixxx,omixxxx
ddy,dky,omixxx,omixxxy
ddy,dky,omixxy,omixxyy
ddx,dkx,omixxy,omixxyx
ddx,dkx,omiyyx,omiyyxx
ddy,dky,omiyyx,omiyyxy
ddx,dkx,omiyyy,omiyyyx
ddy,dky,omiyyy,omiyyyy
omiyyyx=.5*(omiyyyx+omiyyxy)
omixxxy=.5*(omixxxy+omixxyx)
omixxyy=.5*(omixxyy+omiyyxx)
;
ai4=1./24.*(nx^4*omixxxx+4*nx^3*ny*omixxxy+6*nx^2*ny^2* $
                  omixxyy+4*nx*ny^3*omiyyyx+ny^4*omiyyyy)
;
ddx,dkx,omrxxx,omrxxxx
ddy,dky,omrxxx,omrxxxy
ddy,dky,omrxxy,omrxxyy
ddx,dkx,omrxxy,omrxxyx
ddx,dkx,omryyx,omryyxx
ddy,dky,omryyx,omryyxy
ddx,dkx,omryyy,omryyyx
ddy,dky,omryyy,omryyyy
omryyyx=.5*(omryyyx+omryyxy) 
omrxxxy=.5*(omrxxxy+omrxxyx)
omrxxyy=.5*(omrxxyy+omryyxx)
;
ar4=1./24.*(nx^4*omrxxxx+4*nx^3*ny*omrxxxy+6*nx^2*ny^2* $
                  omrxxyy+4*nx*ny^3*omryyyx+ny^4*omryyyy)
ki=omei
om=omei
kip=omei
omp=omei
for i=0,n1-1 do begin
for j=0,n2-1 do begin
if(abs(ai4(i,j)) gt 1.e-6) then begin
roots=NR_ZROOTS([ai0(i,j),ai1(i,j),ai2(i,j),ai3(i,j),ai4(i,j)])
 endif else begin
  print,'ai4(',i,j,')=',ai4(i,j)
  if(abs(ai3(i,j)) gt 1.e-5) then begin
   roots=NR_ZROOTS([ai0(i,j),ai1(i,j),ai2(i,j),ai3(i,j)])
  endif else begin
   if(abs(ai2(i,j)) gt 1.e-4) then begin 
    roots=NR_ZROOTS([ai0(i,j),ai1(i,j),ai2(i,j)])
   endif else begin
    if(abs(ai1(i,j)) gt 1.e-3) then begin
     roots=NR_ZROOTS([ai0(i,j),ai1(i,j)]) 
    endif else begin
     roots=[0.]
    endelse  
   endelse
  endelse   
 endelse
nn=size(roots)
kin=0.
for k=0,nn(1)-1 do begin
 if (abs(imaginary(roots(k))) lt 1.e-6)then kin=max([kin,float(roots(k))])
endfor
ki(i,j)=kin
om(i,j)=ar0(i,j)+(ar1(i,j)+(ar2(i,j)+(ar3(i,j)+ar4(i,j)*kin)*kin)*kin)*kin
kin=1.e8
for k=0,nn(1)-1 do begin
if(abs(imaginary(roots(k))) lt 1.e-6)then begin
 if(float(roots(k)) gt 0.) then begin
 kin=min([kin,float(roots(k))])
endif
endif
endfor
if (kin gt 1e6)then kin=0
kip(i,j)=kin
omp(i,j)=ar0(i,j)+(ar1(i,j)+(ar2(i,j)+(ar3(i,j)+ar4(i,j)*kin)*kin)*kin)*kin
endfor
endfor 
return
end
