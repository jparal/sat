;--------------------------------------------------------------------;
; GIVEN 2D OR 3D DATA ARRAY. GIVEN SET OF POSITIONS OF A VIRTUAL
; SPACECRAFT. THIS FUNCTION PERFORMS MEASUREMENT OF THE GIVEN
; ENTITY ALONG THE TRAJECTORY OF THE VIRTUAL SPACECRAFT
;
; dx, dy, dz - given in c/omega_pi
; Hence positions (posx, posy, posz) must be given also in 
; c/omega_pi
;
; Example 1:
;
;   IDL> rd,'Dnp*i5000.gz',dn
;   IDL> den = pl_flyby (dn,posx=reform(e(6,*),1778)*1.25, $
;          posy=reform(e(7,*),1778)*1.25,dx=0.15,dy=0.15,xc=0.4)
;
; Example 2:
;
;   To get corresponding data sets bxf (Amalka) <-----> bxe (Cassini)
;                                  byf (Amalka) <-----> bye (Cassini)
;                                  bzf (Amalka) <-----> bze (Cassini)
;   use following sequence:
;
;   IDL> rd,'data/e11.asc',e
;   IDL> px=reform(e(6,*),(size(e))(2))       ... X_enis
;   IDL> py=reform(e(8,*),(size(e))(2))       ... Z_enis !!!!
;   IDL> stw_b,'plume2d','i5000',bampl=b,bx=bx, by=by, bz=bz
;   IDL> bxf=pl_flyby (bx,posx=px*1.25,posy=py*1.25,dx=0.15,dy=0.15,xc=0.4)
;   IDL> byf=pl_flyby (by,posx=px*1.25,posy=py*1.25,dx=0.15,dy=0.15,xc=0.4)
;   IDL> bzf=pl_flyby (bz,posx=px*1.25,posy=py*1.25,dx=0.15,dy=0.15,xc=0.4)
;   IDL> bxe=reform(e(2,*),(size(e))(2))      ... BX_ENIS
;   IDL> bye=reform(e(4,*),(size(e))(2))      ... BZ_ENIS !!!!
;   IDL> bze=reform(e(3,*),(size(e))(2))      ... BY_ENIS
;   IDL> be=sqrt(bxe*bxe+bye*bye+bze*bze)
;
; HISTORY:
;
; - 09/2006, v.0.4.141: Written
;--------------------------------------------------------------------;
FUNCTION pl_flyby, data, $
  posx=posx, posy=posy, posz=posz, $
  dx=dx, dy=dy, dz=dz, $
  xc=xc, yc=yc, zc=zc

;--------------------------------------------------------------------;
; CHECK INPUT PARAMETERS                                             ;
;--------------------------------------------------------------------;
ss=size(data,/type)
if (ss eq 0) then return, -1
ss=size(data)
if ((ss(0) ne 2) and (ss(0) ne 3)) then return, -1

sx=size(posx,/type)
sy=size(posy,/type)
if ((sx eq 0) or (sy eq 0)) then return, -1
sx=size(posx)
sy=size(posy)
if ((sx(0) ne 1) or (sy(0) ne 1)) then return, -1
if (sx(1) ne sy(1)) then return, -1

if (ss(0) eq 3) then begin
  sz=size(posz,/type)
  if (sz eq 0) then return, -1
  sz=size(posz)
  if (sz(0) ne 1) then return, -1
  if (sx(1) ne sz(1)) then return, -1
endif

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0

if (dx le 0.0) then return, -1
if (dy le 0.0) then return, -1
if (dz le 0.0) then return, -1

if not(stw_keyword_set(xc)) then xc=0.5
if not(stw_keyword_set(yc)) then yc=0.5
if not(stw_keyword_set(zc)) then zc=0.5

;--------------------------------------------------------------------;
; OK INPUT LOOKS GOOD                                                ;
;                                                                    ;
; We have all "pos?" arrays, they have the same dimension.           ;
;--------------------------------------------------------------------;
nx = ss(1)
ny = ss(2)

ncx=nx-1
ncy=ny-1

lx=float(ncx)*dx
ly=float(ncy)*dy

xmin=-xc*lx
xmax=lx-xmin
ymin=-yc*ly
ymax=ly-ymin

flyby=fltarr(sx(1))
np=sx(1)-1


if (ss(0) eq 2) then begin

  for ip=0,np do begin

    x=posx(ip)
    y=posy(ip)
    if (x le xmin or x ge xmax) then continue
    if (y le ymin or y ge ymax) then continue

    x=x-xmin
    y=y-ymin
    ix=fix(x/dx)
    ixp=ix+1
    if (ixp gt ncx) then continue

    iy=fix(y/dy)
    iyp=iy+1
    if (iyp gt ncy) then continue

    xf = x - float(ix)*dx
    xa = 1. - xf
    yf = y - float(iy)*dy
    ya = 1. - yf
    
    w1 = xa*ya
    w2 = xf*ya
    w3 = xf*yf
    w4 = xa*yf

    flyby(ip) = w1*data(ix,iy)+w2*data(ixp,iy)+w3*data(ixp,iyp)+w4*data(ix,iyp)

  endfor

endif

if (ss(0) eq 3) then begin
  nz = ss(3)
endif

return, flyby
end
