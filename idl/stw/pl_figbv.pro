;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING (VECTORISED) MAGNETIC FIELD DATA      ;
; Developed for Enceladus simulations.                               ;
; As template used script developed before within "06herm" paper     ;
; (figmag.pro)                                                       ;
;                                                                    ;
; EXAMPLE:                                                           ;
;                                                                    ;
; 1) If you do not use "b" parameter (which is not required as       ;
;    input) the data will be always read:                            ;                                                                     ;
;                                                                    ;
;    IDL> pl_figbv,mina=0.95,maxa=1.1,radius=1.25,                   ;
;         /draw_planet,x0=0.4,dx=0.15,dy=0.15,'ucla5','i1500'        ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 08/2006, v.0.4.140: Started.                                     ;
;--------------------------------------------------------------------;
pro pl_figbv, run, itt, b, $
  dir=dir, dx=dx, dy=dy, dz=dz, ix=ix, iy=iy, iz=iz, $
  x0=x0, y0=y0, z0=z0, $
  minx=minx, maxx=maxx, miny=miny, maxy=maxy, minz=minz, maxz=maxz, $
  mina=mina, maxa=maxa, $
  nskip=nskip, len=len, hsize=hsize, radius=radius, $
  help=help, ps=ps, draw_planet=draw_planet

;--------------------------------------------------------------------;
; PRINT HELP, IF REQUESTED AND RETURN                                ;
;--------------------------------------------------------------------;
if keyword_set(help) then begin
  print, 'pl_figbv: TO BE WRITTEN'
  return
endif

ss=size(b)

if not(keyword_set(dir)) then dir='.'

if (ss(1) eq 0) then begin
  rd,dir+'/'+'Bx'+run+itt+'.gz',bx
  rd,dir+'/'+'By'+run+itt+'.gz',by
  rd,dir+'/'+'Bz'+run+itt+'.gz',bz
  b=sqrt(bx*bx+by*by+bz*bz)
  ss=size(b)
endif

if (ss(0) lt 2) then return

if not(keyword_set(dx)) then dx=1.0
if not(keyword_set(dy)) then dy=1.0
if not(keyword_set(dz)) then dz=1.0

if not(keyword_set(x0)) then x0=0.5
if not(keyword_set(y0)) then y0=0.5
if not(keyword_set(z0)) then z0=0.5

lx=ss(1)*dx
if (ss(0) ge 2) then ly=ss(2)*dy
if (ss(0) eq 3) then lz=ss(3)*dz

if not(keyword_set(radius)) then radius=1.0

if not(keyword_set(ix)) then ix=(findgen(ss(1))*dx-x0*lx)/radius
if not(keyword_set(minx)) then minx=ix(0)
if not(keyword_set(maxx)) then maxx=ix(ss(1)-1)
if not(keyword_set(iy)) then iy=(findgen(ss(2))*dy-y0*ly)/radius
if not(keyword_set(miny)) then miny=iy(0)
if not(keyword_set(maxy)) then maxy=iy(ss(2)-1)

if (ss(0) eq 3) then begin
  if not(keyword_set(iz)) then iz=(findgen(ss(3))*dz-z0*lz)/radius
  if not(keyword_set(minz)) then minz=iz(0)
  if not(keyword_set(maxz)) then maxz=iz(ss(3)-1)
endif

if not(keyword_set(mina)) then mina=min(b)
if not(keyword_set(maxa)) then maxa=max(b)

if not(keyword_set(nskip)) then nskip=20.0
if not(keyword_set(len)) then len=15.0/radius*dx
if not(keyword_set(hsize)) then hsize=-0.4

imi=findgen(1001)/1000*!pi*2
imx=1.0*sin(imi)
imy=1.0*cos(imi)

!x.margin=[4.,2.]

!p.font=0
!p.charsize=2
!p.background=0
!p.thick=2

loadct,3
col=20
nle=30
lev = mina + findgen(nle) * ((maxa-mina)/(nle-1))

;--------------------------------------------------------------------;
; 2-DIMENSIONAL DATA - produce single plot                           ;
;--------------------------------------------------------------------;
if (ss(0) eq 2) then begin

  if keyword_set(ps) then tops,/col,file=ps,/land

  !p.multi=[0,1,1]

  image_vect, b, bx, by, ix, iy,$
  len=len, hsize=hsize, nskip=nskip, color=10, $
  nlev=nle, /fill, lev=lev, $
  xrange=[minx,maxx],yrange=[miny,maxy],zrange=[mina,maxa],$
  xtitle='xx',ytitle='yy',$
  /xst,/yst,/zst,$
  position=[0.1, 0.1, 0.85, 0.95]

  if keyword_set(draw_planet) then polyfill,imx,imy,/data,color=0

  aa=fltarr(3,nle)
  aa(0,*)=lev
  aa(1,*)=lev
  aa(2,*)=lev

  gg=replicate(' ',30)

  contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[mina,maxa], $
  /xst,/yst,/zst, nlev=nle,/fill,$
  position=[0.95, 0.1, 0.99, .95],xtickname=gg,/noerase

  if keyword_set(ps) then begin
    device, /close
    tox
  endif

endif

;--------------------------------------------------------------------;
; 3-DIMENSIONAL DATA - produce three plots                           ;
;--------------------------------------------------------------------;
if (ss(0) eq 3) then begin
  !p.multi=[0,3,1]

  print, 'not implemented'
endif

;--------------------------------------------------------------------;
return
end
