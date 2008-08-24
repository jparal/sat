function stw_cart2cyl, din, $
  dx=dx, dy=dy, dz=dz, x0=x0, y0=y0, z0=z0, fillval=fillval, $
  dr=dr, dphi=dphi, rmax=rmax, $
  phi0=phi0,help=help

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
print,'IDL> dout=stw_cart2cyl(dn,dphi=2.5,dx=0.4,x0=560.0*0.30*0.4)'
print
print,'REQUIRES (v.0.5.29):'
print,'--------------------------------------------------------------'
return,-1
endif

ss=size(din,/type)
if (ss eq 0) then return, -1
ss=size(din)
if (ss(0) ne 3) then return, -1

nx=long(ss(1)) & ny=long(ss(2)) & nz=long(ss(3))
if (nx le 1) then return, -1
if (ny le 1) then return, -1
if (nz le 1) then return, -1
nxy=long(nx*ny)

aux=reform(din,nx*ny*nz)

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

dout=fltarr(nr,nphi,nz)

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

    dout(ir+ir0,iphi,iz+iz0) = w1*aux(i1) + w2*aux(i2) + w3*aux(i3) $
                     + w4*aux(i4) + w5*aux(i5) + w6*aux(i6) $
                     + w7*aux(i7) + w8*aux(i8)
  endif else begin

    dout(ir+ir0,iphi,iz+iz0) = fillval

  endelse

endfor
endfor
endfor

return, dout
end
