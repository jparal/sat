;--------------------------------------------------------------------;
; PLOTS A CONTOUR PLOT WITH VECTORS ON TOP OF IT                     ;
;                                                                    ;
; Original "image_vect" routine was skipping "N" grid points         ;
; in the data. We need rather to skip "dx" in terms of the spatial   ;
; size or define "dx" by means (axis_max - axis_min) / N = number    ;
; of vector points in the direction of the given axis.               ;
;                                                                    ;
; Hence this function uses "dsvec" instead of "nskip".               ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 08/2006, v.0.4.141: Derived from original IDL "pro" routine      ;
;   "image_vect".                                                    ;
;--------------------------------------------------------------------;
PRO PLT_VEC, a, vx, vy,$
  DSVEC=dsvec, ix, iy, LENGTH=length, MAXLEN=maxlen, $
  COLOR=color, VECSIZE=vecsize, _EXTRA=extra

if not(stw_keyword_set(dsvec))  then dsvec=1.0
if not(stw_keyword_set(length)) then length=1.0
if not(stw_keyword_set(color))  then color=500

ss=size(a)
sx=size(ix)
sy=size(iy)
svx=size(vx)
svy=size(vy)

;----------------------------------------------------------------;
; Get "myix" and "myiy" mesh coordinates. Given spatial size "L" ;
; in the given direction. We want to place here vectors with     ;
; "dsvec" spatial spacing. I.e. there shall be:                  ;
;                                                                ;
;                          L                                     ;
;   Number of vectors = ------- + 1                              ;
;                        dsvec                                   ;
;----------------------------------------------------------------;
if (sx(0) ne 1) then begin
  xvmin = 0.5
  xvmax = sx(1)-0.5
  yvmin = 0.5
  yvmax = sy(1)-0.5

  dx = ix(1)-ix(0)
  dy = iy(1)-iy(0)

endif else begin

  dx = ix(1)-ix(0)
  dy = iy(1)-iy(0)

  nsx = sx(1)
  nsy = sy(1)

  xvmin = ix(0) + dx*0.5            ; X-position of the first vector
  xvmax = ix(nsx-1) - dx*0.5
  yvmin = iy(0) + dy*0.5            ; Y-position of the first vector
  yvmax = iy(nsy-1) - dy*0.5
endelse

lvx = xvmax-xvmin
nvx = fix((xvmax-xvmin)/dsvec) + 1
lvy = yvmax-yvmin
nvy = fix((yvmax-yvmin)/dsvec) + 1

;---------------------------------------------------------;
; Allocate arrays to hold the vector origin/end points    ;
;                                                         ;
; While origins are defined in the form of uniform mesh   ;
; axises endpoints represent a field of "nvx" x "nvy"     ;
; values                                                  ;
;---------------------------------------------------------;
vxn = fltarr(nvx,nvy,/nozero)
vyn = vxn

x = fltarr (nvx,/nozero)
y = fltarr (nvy,/nozero)

for j = 0,nvy-1 do begin
  for i = 0,nvx-1 do begin

    offx = (0.5 + float(i)) * dsvec
    offy = (0.5 + float(j)) * dsvec

    ddx = offx/dx
    ddy = offy/dy

    ;------------------------------------------------;
    ; Assume, that the data are on equidistant mesh  ;
    ; (which is not in general always like that      ;
    ; - this routine however does not handle these   ;
    ; generic cases yet                              ;
    ;------------------------------------------------;
    il = fix (ddx)
    iu = il+1
    jl = fix (ddy)
    ju = jl+1

    if (il ge svx(1)) then il = svx(1)-1
    if (iu ge svx(1)) then iu = svx(1)-1
    if (jl ge svx(2)) then jl = svx(2)-1
    if (ju ge svx(2)) then ju = svx(2)-1

    xf = ddx - float(il)
    yf = ddy - float(jl)
    xa = 1.0 - xf
    ya = 1.0 - yf

    x(i) = offx+ix(0)
    y(j) = offy+iy(0)

    w1 = xa*ya;
    w2 = xf*ya;
    w3 = xf*yf;
    w4 = xa*yf;

    vecx = w1*vx(il,jl) + w2*vx(iu,jl) + w3*vx(iu,ju) + w4*vx(il,ju)
    vecy = w1*vy(il,jl) + w2*vy(iu,jl) + w3*vy(iu,ju) + w4*vy(il,ju)

    ;vecx=1.5
    ;vecy=1.5

    vxn(i,j) = vecx
    vyn(i,j) = vecy

  endfor
endfor

STW_OVECTOR, vxn, vyn, x, y, MAXLEN=maxlen, $
  LENGTH=length, COLOR=color, HSIZE=vecsize, _EXTRA=extra

end
