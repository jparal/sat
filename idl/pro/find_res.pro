;finds a maximum of n.df/dv for unit vectors n in x < 0
;halp space; gives a maximum of der dmax and the velocity v_res
pro find_res, vx,vy,vz,dmax,v_res,iphi,ipsi,n_phi=n_phi,n_psi=n_psi
if not(keyword_set(n_phi))then n_phi=10
if not(keyword_set(n_psi))then n_psi=10
dmax=fltarr(n_phi+1,n_psi+1)
iphi=fltarr(n_phi+1)
ipsi=fltarr(n_psi+1)
v_res=dmax
dphi=!pi/n_phi
dpsi=!pi/n_psi
for i=0,n_phi do begin
phi=i*dphi
iphi(i)=phi
for j=0,n_psi do begin
psi=j*dpsi
iphi(j)=psi
print, phi,psi
nx=-sin(psi)*sin(phi)
ny=sin(psi)*cos(phi)
nz=cos(psi)
hist_along,vx,vy,vz,nx,ny,nz,ix,h
smax,h,a
ss=size(h)
der=-100.
coo=0
dxih=.5/(ix(1)-ix(0))
for k=a+2,ss(1)-2 do begin
der1=dxih*(h(k+1)+h(k)-h(k-1)-h(k-2))
if (der1 gt der)then begin
  der=der1
  coo=k
endif
endfor
dmax(i,j)=der
v_res=ix(coo)
endfor
endfor
return
end
