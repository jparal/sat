PRO MTH_CART2SPHV, vx, vy, vz, outrho, outphi, outtht, $
  DX=dx, DY=dy, DZ=dz, X0=x0, Y0=y0, Z0=z0, FILLVAL=fillval, $
  DR=dr, DPHI=dphi, RMAX=rmax, $
  PHI0=phi0, HELP=help

;---------------------------------------------------------------------
; TODO: So far z direction of CYL system is parallel with Z of
;       original CART system.
;
;---------------------------------------------------------------------
if stw_keyword_set(help) then begin
print,'--------------------------------------------------------------'
print
print,'EXAMPLE(S):'
print
print,'IDL> dout=stw_cart2cyl(dn,dphi=2.5,dx=0.4,x0=560.0*0.35*0.4)'
print
print,'REQUIRES (v.0.5.29):'
print,'--------------------------------------------------------------'
return
endif

ss=size(vx,/type)
if (ss eq 0) then return
ss=size(vx)
if (ss(0) ne 3) then return

UTL_CHECK_SIZE, vx, vy, vz

nx=long(ss(1)) & ny=long(ss(2)) & nz=long(ss(3))
if (nx le 1) then return
if (ny le 1) then return
if (nz le 1) then return
nxy=long(nx*ny)

aux=reform(vx,nx*ny*nz)
auy=reform(vy,nx*ny*nz)
auz=reform(vz,nx*ny*nz)

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0

if not(stw_keyword_set(x0)) then x0=float(nx-1)*dx/2.0
if not(stw_keyword_set(y0)) then y0=float(ny-1)*dy/2.0
if not(stw_keyword_set(z0)) then z0=float(nz-1)*dz/2.0

print, x0, y0, z0

if not(stw_keyword_set(fillval)) then fillval=0.0

if not(stw_keyword_set(dr)) then dr=1.0
if not(stw_keyword_set(dphi)) then dphi=90.0
if not(stw_keyword_set(phi0)) then phi0=0.0

;--------------------------------------------------------;
; Determine "rmax" as the maximal distance between the   ;
; center of the CYLINDRICAL coordinate system and the    ;
; corner of the simulation box, which is in largest      ;
; distance from the center.                              ;
;--------------------------------------------------------;
lenght1 = sqrt((-x0)*(-x0) + (-y0)*(-y0) + (-z0)*(-z0))
lenght2 = sqrt((float(nx-1)*dx-x0)*(float(nx-1)*dx-x0) + $
               (-y0)*(-y0) + (-z0)*(-z0))
lenght3 = sqrt((-x0)*(-x0) + (float(ny-1)*dy-y0)*(float(ny-1)*dy-y0) + $
               (-z0)*(-z0))
lenght4 = sqrt((float(nx-1)*dx-x0)*(float(nx-1)*dx-x0) + $
               (float(ny-1)*dy-y0)*(float(ny-1)*dy-y0) + $
               (-z0)*(-z0))
lenght5 = sqrt((-x0)*(-x0) + (-y0)*(-y0) + $
               (float(nz-1)*dz-z0)*(float(nz-1)*dz-z0))
lenght6 = sqrt((float(nx-1)*dx-x0)*(float(nx-1)*dx-x0) + $
               (-y0)*(-y0) + (float(nz-1)*dz-z0)*(float(nz-1)*dz-z0))
lenght7 = sqrt((-x0)*(-x0) + (float(ny-1)*dy-y0)*(float(ny-1)*dy-y0) + $
               (float(nz-1)*dz-z0)*(float(nz-1)*dz-z0))
lenght8 = sqrt((float(nx-1)*dx-x0)*(float(nx-1)*dx-x0) + $
               (float(ny-1)*dy-y0)*(float(ny-1)*dy-y0) + $
               (float(nz-1)*dz-z0)*(float(nz-1)*dz-z0))

if not(stw_keyword_set(rmax)) then begin
  rmax=0.0
  if (rmax lt lenght1) then rmax=lenght1
  if (rmax lt lenght2) then rmax=lenght2
  if (rmax lt lenght3) then rmax=lenght3
  if (rmax lt lenght4) then rmax=lenght4
  if (rmax lt lenght5) then rmax=lenght5
  if (rmax lt lenght6) then rmax=lenght6
  if (rmax lt lenght7) then rmax=lenght7
  if (rmax lt lenght8) then rmax=lenght8
endif

print, rmax

nr = rmax/dr+1
nphi = 360.0/dphi

outrho=fltarr(nr,nz,nphi)
outphi=fltarr(nr,nz,nphi)
outtht=fltarr(nr,nz,nphi)

if (z0 lt 0.0) then z0 = 0.0
if (z0 ge float(nz)*dz) then z0 = float(nz)*dz

iz0=fix(z0/dz)
ir0=fix(float(nr)/2.0)

nnz=nz-iz0
nnr=nr-ir0

for iz=-iz0, nnz-1 do begin
for iphi=0, nphi-1 do begin
for ir=-ir0, nnr-1 do begin

  r   = float(ir)*dr
  phi = (float(iphi)*dphi-phi0) * !pi/180.0

  x = r*cos(phi) + x0
  y = r*sin(phi) + y0
  z = float(iz)*dz + z0

  i = long(fix(x/dx))
  j = long(fix(y/dy))
  k = long(fix(z/dz))

  inbox=1
  if (i lt 0 or i+1 ge nx) then inbox=0
  if (j lt 0 or j+1 ge ny) then inbox=0
  if (k lt 0 or k+1 ge nz) then inbox=0

  if (inbox) then begin

    xf = x/dx-float(i) & xa = 1.0 - xf
    yf = y/dy-float(j) & ya = 1.0 - yf
    zf = z/dz-float(k) & za = 1.0 - zf

    i1 = i + j * nx + k * nxy;
    i2 = i1 + 1L;
    i3 = i2 + nx;
    i4 = i3 - 1L;
    i5 = i1 + nxy;
    i6 = i5 + 1L;
    i7 = i6 + nx;
    i8 = i7 - 1L;

    w1 = xa*ya*za;
    w2 = xf*ya*za;
    w3 = xf*yf*za;
    w4 = xa*yf*za;
    w5 = xa*ya*zf;
    w6 = xf*ya*zf;
    w7 = xf*yf*zf;
    w8 = xa*yf*zf;

    locvx = w1*aux(i1) + w2*aux(i2) + w3*aux(i3) + w4*aux(i4) + $
            w5*aux(i5) + w6*aux(i6) + w7*aux(i7) + w8*aux(i8)
    locvy = w1*auy(i1) + w2*auy(i2) + w3*auy(i3) + w4*auy(i4) + $
            w5*auy(i5) + w6*auy(i6) + w7*auy(i7) + w8*auy(i8)
    locvz = w1*auz(i1) + w2*auz(i2) + w3*auz(i3) + w4*auz(i4) + $
            w5*auz(i5) + w6*auz(i6) + w7*auz(i7) + w8*auz(i8)

    ;; RHO component:
    axyz = sqrt((x-x0)^2 + (y-y0)^2 + (z-z0)^2)
    xrho0 = (x-x0)/axyz
    yrho0 = (y-y0)/axyz
    zrho0 = (z-z0)/axyz

    ;; PHI component:
    xphi0 = -sin(phi)
    yphi0 =  cos(phi)
    zphi0 = 0

    ;; THT component:
    xtht0 = yphi0*zrho0 - zphi0*yrho0
    ytht0 = zphi0*xrho0 - xphi0*zrho0
    ztht0 = xphi0*yrho0 - yphi0*xrho0
    atht0 = sqrt(xtht0^2 + ytht0^2 +ztht0^2)
    IF (atht0 GT 0.001) THEN BEGIN
       xtht0 = xtht0/atht0
       ytht0 = ytht0/atht0
       ztht0 = ztht0/atht0
    ENDIF

    arho = locvx*xrho0 + locvy*yrho0 + locvz*zrho0
    aphi = locvx*xphi0 + locvy*yphi0 + locvz*zphi0
    atht = locvx*xtht0 + locvy*ytht0 + locvz*ztht0

    outrho(ir+ir0,iz+iz0,iphi) = arho
    outphi(ir+ir0,iz+iz0,iphi) = aphi
    outtht(ir+ir0,iz+iz0,iphi) = atht

  endif else begin

     outrho(ir+ir0,iz+iz0,iphi) = fillval
     outphi(ir+ir0,iz+iz0,iphi) = fillval
     outtht(ir+ir0,iz+iz0,iphi) = fillval

  endelse

endfor
endfor
endfor

end
