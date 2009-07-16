;
; HISTORY:
;
; - 05/2007, v0.3.0
;     Adopted from STW
;--------------------------------------------------------------------;
FUNCTION DAT_FLYBY, data, traj, INTERP=interp, $
  POSX=posx, POSY=posy, POSZ=posz, SCALE=scale, $
  DX=dx, DY=dy, DZ=dz, RX=rx, RY=ry, RZ=rz

; INPUT:
; data are 2D or 3D data
; SCALE scale the axis (i.e. planet radius)
; Provide traj as [2|3,*] array or separate pos[x|y|z]
; 

;--------------------------------------------------------------------;
; CHECK INPUT PARAMETERS                                             ;
;--------------------------------------------------------------------;
ss=size(data,/type)
IF (ss EQ 0) THEN MESSAGE,'Wrong input data type'
ss=size(data)
IF ((ss(0) NE 2) AND (ss(0) NE 3)) THEN MESSAGE,'Wrong input data type'

IF N_PARAMS() EQ 2 THEN BEGIN
   poslx = reform(traj(0,*))
   posly = reform(traj(1,*))
   IF ss(0) EQ 3 THEN poslz = reform(traj(2,*))
ENDIF ELSE BEGIN
   poslx = reform(posx)
   posly = reform(posy)
   poslz = reform(posz)
ENDELSE

sx=size(poslx,/type)
sy=size(posly,/type)
IF ((sx EQ 0) OR (sy EQ 0)) THEN MESSAGE,'Wrong input data type'
sx=size(poslx)
sy=size(posly)
IF ((sx(0) NE 1) OR (sy(0) NE 1)) THEN MESSAGE,'Wrong input data size'
IF (sx(1) NE sy(1)) THEN MESSAGE,'Wrong input data size'

IF (ss(0) EQ 3) THEN BEGIN
  sz=size(poslz,/TYPE)
  IF (sz EQ 0) THEN MESSAGE,'Wrong input data type'
  sz=size(poslz)
  IF (sz(0) NE 1) THEN MESSAGE,'Wrong input data size'
  IF (sx(1) NE sz(1)) THEN MESSAGE,'Wrong input data size'
ENDIF

IF N_ELEMENTS(interp) NE 0 THEN BEGIN
   np = sx(1) * interp
   poslx = INTERPOL(poslx,np)
   sx=size(poslx)
   posly = INTERPOL(posly,np)
   sy=size(posly)
   IF ss(0) EQ 3 THEN BEGIN
      poslz = INTERPOL(poslz,np)
      sz=size(poslz)
   ENDIF
ENDIF

IF NOT(KEYWORD_SET(debug)) THEN debug=0
IF NOT(KEYWORD_SET(scale)) THEN scale=1.0

IF NOT(KEYWORD_SET(dx)) THEN dx=1.0
IF NOT(KEYWORD_SET(dy)) THEN dy=1.0
IF NOT(KEYWORD_SET(dz)) THEN dz=1.0

IF (dx LE 0.0) THEN MESSAGE,'Wrong input data size'
IF (dy LE 0.0) THEN MESSAGE,'Wrong input data size'
IF (dz LE 0.0) THEN MESSAGE,'Wrong input data size'

IF NOT(KEYWORD_SET(rx)) THEN rx=0.5
IF NOT(KEYWORD_SET(ry)) THEN ry=0.5
IF NOT(KEYWORD_SET(rz)) THEN rz=0.5

poslx = poslx*scale
posly = posly*scale
IF (ss(0) EQ 3) THEN poslz = poslz*scale

;--------------------------------------------------------------------;
; OK INPUT LOOKS GOOD                                                ;
;                                                                    ;
; We have all "posl?" arrays, they have the same dimension.           ;
;--------------------------------------------------------------------;
nx = ss(1)
ny = ss(2)

ncx=nx-1
ncy=ny-1

lx = float(ncx)*dx
ly = float(ncy)*dy

xmin = -rx*lx
xmax = lx-xmin
ymin = -ry*ly
ymax = ly-ymin

IF (ss(0) EQ 3) THEN BEGIN
   nz = ss(3)
   ncz=nz-1
   lz = float(ncz)*dz
   zmin = -rz*lz
   zmax = lz-zmin
ENDIF

fbdata = fltarr(sx(1))
np = sx(1)-1

IF (ss(0) EQ 2) THEN BEGIN

  FOR ip=0,np DO BEGIN

    x=poslx(ip)
    y=posly(ip)
    IF (x LE xmin OR x GE xmax) THEN CONTINUE
    IF (y LE ymin OR y GE ymax) THEN CONTINUE

    x=x-xmin
    y=y-ymin
    ix=fix(x/dx)
    ixp=ix+1
    IF (ixp GT ncx) THEN CONTINUE

    iy=fix(y/dy)
    iyp=iy+1
    IF (iyp GT ncy) THEN CONTINUE

    xf = (x/dx) - float(ix)
    xa = 1. - xf
    yf = (y/dy) - float(iy)
    ya = 1. - yf

    w1 = xa*ya
    w2 = xf*ya
    w3 = xf*yf
    w4 = xa*yf

    fbdata(ip) = w1*data(ix,iy)+w2*data(ixp,iy)+w3*data(ixp,iyp)+w4*data(ix,iyp)

  ENDFOR

ENDIF ELSE BEGIN

  FOR ip=0,np DO BEGIN

    x=poslx(ip)
    y=posly(ip)
    z=poslz(ip)

    IF (x LE xmin OR x GE xmax) THEN CONTINUE
    IF (y LE ymin OR y GE ymax) THEN CONTINUE
    IF (z LE zmin OR z GE zmax) THEN CONTINUE

    x=x-xmin
    y=y-ymin
    z=z-zmin

    ix=fix(x/dx)
    ixp=ix+1
    IF (ixp GT ncx) THEN CONTINUE

    iy=fix(y/dy)
    iyp=iy+1
    IF (iyp GT ncy) THEN CONTINUE

    iz=fix(z/dz)
    izp=iz+1
    IF (izp GT ncz) THEN CONTINUE

    xf = (x/dx) - float(ix)
    xa = 1. - xf
    yf = (y/dy) - float(iy)
    ya = 1. - yf
    zf = (z/dz) - float(iz)
    za = 1. - zf

    w1 = xa * ya * za
    w2 = xf * ya * za
    w3 = xf * yf * za
    w4 = xa * yf * za
    w5 = xa * ya * zf
    w6 = xf * ya * zf
    w7 = xf * yf * zf
    w8 = xa * yf * zf

    fbdata(ip) = w1 * data(ix ,iy ,iz ) + w2 * data(ixp,iy ,iz ) + $
                 w3 * data(ixp,iyp,iz ) + w4 * data(ix ,iyp,iz ) + $
                 w5 * data(ix ,iy ,izp) + w6 * data(ixp,iy ,izp) + $
                 w7 * data(ixp,iyp,izp) + w8 * data(ix ,iyp,izp)

  ENDFOR

ENDELSE

RETURN, fbdata
END
