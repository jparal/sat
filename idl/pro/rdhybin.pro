pro rdhybin, filename=filename,dts=dts,dx=dx,dy=dy,dz=dz,runname=runname, $
bx0=bx0,by0=by0,bz0=bz0,rnds=rnds,xms=xms,qs=qs,nhsamp=nhsamp,tm=tm, $
dth=dth,dtf=dtf
tm=0l
if(not(keyword_set(filename)))then filename='hyb.in'
iunit=20
comments='                     '
runname='       '
ic='             '
if(not(fexist(filename)))then begin
print,filename,' not found'
return
endif

openr,iunit,filename
readf,iunit,comments
readf,iunit,comments
readf,iunit,runname
runname=strcompress(runname,/rem)
readf,iunit,comments
readf,iunit,irestart
readf,iunit,comments
readf,iunit,t0
readf,iunit,comments
readf,iunit,tm
readf,iunit,comments
readf,iunit,dtout
readf,iunit,comments
readf,iunit,noutpart
readf,iunit,comments
readf,iunit,dt
readf,iunit,comments
readf,iunit,nsub
readf,iunit,comments
readf,iunit,ntest
readf,iunit,comments
readf,iunit,nhsamp
readf,iunit,comments
readf,iunit,nstepmes
readf,iunit,comments
readf,iunit,comments
readf,iunit,ncx,ncy,ncz
nx=ncx+1
ny=ncy+1
nz=ncz+1
readf,iunit,comments
readf,iunit,dx,dy,cz
readf,iunit,comments
readf,iunit,betae
readf,iunit,comments
readf,iunit,ns
ng=intarr(ns)
readf,iunit,comments
readf,iunit,ng
betas=fltarr(ns)
rvth=betas
rnds=betas
qs=betas
xms=betas
vxs=betas
vys=betas
vzs=betas
readf,iunit,comments
readf,iunit,betas
readf,iunit,comments
readf,iunit,rvth
readf,iunit,comments
readf,iunit,rnds
readf,iunit,comments
readf,iunit,qs
readf,iunit,comments
readf,iunit,xms
readf,iunit,comments
readf,iunit,vxs
readf,iunit,comments
readf,iunit,vys
readf,iunit,comments
readf,iunit,vzs
readf,iunit,comments
readf,iunit,phi,psi
readf,iunit,comments
readf,iunit,comments
readf,iunit,ic
readf,iunit,comments
readf,iunit,nparam
if(nparam gt 0)then begin
  param=fltarr(nparam)
  for i=1,nparam do begin
    readf,iunit,comments
    readf,iunit,param(i-1)
  endfor
endif
close,iunit
; Thermal speed (parallel and perpendicular)
rmds = xms*rnds
qms  = qs/xms
; real thermal velocity - sqrt(2)
vth1 = sqrt (betas/rmds)/sqrt(2)
vth2 = sqrt(rvth)*vth1
; Macro-particle mass and charge 
sm = rmds/float(ng)
sn = rnds/float(ng)
sq = qms*sm
; Magnetic field 
b0 = 1.
pira=!pi/180.
rphi=pira*phi
rpsi=pira*psi
bx0 = b0*cos(rphi)*cos(rpsi)
by0 = b0*sin(rphi)*cos(rpsi)
bz0 = b0*sin(rpsi)
dth=fix(dt*200*nhsamp)
dtf=fix(dtout)
return
end

