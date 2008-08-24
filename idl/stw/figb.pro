;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING MAGNETIC FIELD DATA                   ;
;--------------------------------------------------------------------;
pro figb, run, itt, b, $
  dir=dir, dx=dx, dy=dy, dz=dz, ix=ix, iy=iy, iz=iz, $
  x0=x0, y0=y0, z0=z0

nle=30

ss=size(b)

if not(keyword_set(dir)) then dir='.'

if (ss(1) eq 0) then begin
  rd,dir+'/'+'Bx'+run+itt+'.gz',bx
  rd,dir+'/'+'By'+run+itt+'.gz',by
  rd,dir+'/'+'Bz'+run+itt+'.gz',bz
  b=sqrt(bx*bx+by*by+bz*bz)
  ss=size(b)
endif

if not(keyword_set(dx)) then dx=1.0
if not(keyword_set(dy)) then dy=1.0
if not(keyword_set(dz)) then dz=1.0

if not(keyword_set(x0)) then x0=0.5
if not(keyword_set(y0)) then y0=0.5
if not(keyword_set(z0)) then z0=0.5

lx=ss(1)*dx
if (ss(0) ge 2) then ly=ss(2)*dy
if (ss(0) eq 3) then lz=ss(3)*dz

if not(keyword_set(ix)) then begin
  ix=findgen(ss(1))*dx-x0*lx
endif

if not(keyword_set(iy)) then begin
  iy=findgen(ss(2))*dy-y0*ly
endif

if (not(keyword_set(iz)) and (ss(0) eq 3)) then begin
  iz=findgen(ss(3))*dz-z0*lz
endif

loadct,3

;--------------------------------------------------------------------;
; 2-DIMENSIONAL DATA - produce single plot                           ;
;--------------------------------------------------------------------;
if (ss(0) eq 2) then begin
  contour,b,ix,iy,/fill,nle=nle,$
  /xst,/yst,/zst
endif

;--------------------------------------------------------------------;
; 3-DIMENSIONAL DATA - produce three plots                           ;
;--------------------------------------------------------------------;
if (ss(0) eq 3) then begin
  print, 'not implemented'
endif

;--------------------------------------------------------------------;
return
end
