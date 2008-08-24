;--------------------------------------------------------------------;
; PROCEDURE FOR PLOTTING VECTORIZED BULK SPEED/CURRENT FIELD         ;
; FROM TWO PLANETARY SIMULATIONS                                     ;
;                                                                    ;
; DURING THE FIRST CALL PLANET IS GENERATED AT POSITION OF CUTS      ;
; XC, YC, ZC (I.E. DATA IS ZEROED INSIDE PLANET)! YOU CAN CHANGE     ;
; POSITION OF CUTS IN SUBSEQUENT CALLS TO GET OTHER SLICES.          ;
;                                                                    ;
; Developed for analysis of Mercury data simulations.                ;
; As template used script developed before within "06herm" paper     ;
; (figdn.pro)                                                        ;
;                                                                    ;
; EXAMPLES:                                                          ;
;                                                                    ;
; 1) If you do not use parameters "b?1" and/or "b?2"                 ;
;    (which are not required as input because the procedure does     ;
;    not need them for full functionality) the data will be always   ;
;    readloaded:                                                     ;                                                                     ;
;                                                                    ;
;    IDL> pl_figuv2,'b25Kp','b25Ka','t26','t29', $                   ;
;         dir1='b25Kp128',dir2='b25Ka128',b1,b2, $                   ;
;         radius1=16.36,radius2=12.48,xc1=0.35,xc2=0.35, $           ;
;         /plotxz,maxa=4,mina=-1.,/draw_planet,colortable=0, $       ;
;         blackcolor=0,/plotxy,dx1=0.4,dx2=0.4,maxx=5.5,/plotyz      ;
;                                                                    ;
;    IDL> pl_figuv2,'b25Kp','b25Ka','t26','t29', $                   ;
;         dir1='b25Kp128',dir2='b25Ka128', $                         ;
;         radius1=16.36,radius2=12.48,xc1=0.35,xc2=0.35, $           ;
;         /plotxz,/draw_planet,colortable=0,/plotxy, $               ;
;         dx1=0.4,dx2=0.4,maxx=5.5,/plotyz, $                        ;
;         ux1,uy1,uz1,ux2,uy2,uz2, $                                 ;
;         dsvec=0.35,umax=50.,len=0.2,hsize=-0.15,maxlen=0.4, $      ;
;         /poster_vec,mina=-4.5,maxa=4.5,blackcolor=50               ;
;                                                                    ;
; TODO:                                                              ;
;                                                                    ;
; - v.0.4.141: Promote algorithm updates in pl_figbv.pro, namely     ;
;   when and when do not plot the "planet".                          ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 29/08/2006, v.0.4.141: Up to date with latest "pl_figbv2.pro"    ;
; - 28/08/2006, v.0.4.141: As of now this routine plots realy        ;
;   bulk speed by default. One has to specify "/current" keyword     ;
;   to plot proton current as it was the default case to date        ;
; - 08/2006, v.0.4.141: And now it continues as "pl_figuv2.pro"      ;
; - 08/2006, v.0.4.141: And now it continues as "pl_figbv2.pro"      ;
; - 08/2006, v.0.4.140: Then copyied and continues as "pl_figt2.pro" ;
;   We need to update "pl_figdn2.pro" according to the newly         ;
;   developed features here.                                         ;
; - 08/2006, v.0.4.140: Started. Derived from "pl_figani.pro" of     ;
;   that date, as pl_figdn2.pro                                      ;
;--------------------------------------------------------------------;
pro pl_figuv2, run1, run2, itt1, itt2, $
  ux1in, uy1in, uz1in, ux2in, uy2in, uz2in, $
  dir1=dir1, dir2=dir2, $
  dx1=dx1, dy1=dy1, dz1=dz1, dx2=dx2, dy2=dy2, dz2=dz2, $
  xc1=xc1, yc1=yc1, zc1=zc1, xc2=xc2, yc2=yc2, zc2=zc2, $
  radius1=radius1, radius2=radius2, $
  minx=minx, maxx=maxx, $
  miny=miny, maxy=maxy, $
  minz=minz, maxz=maxz, $
  mina=mina, maxa=maxa, specie=specie, $
  help=help, ps=ps, draw_planet=draw_planet, $
  dsvec=dsvec, maxlen=maxlen, len=len, hsize=hsize, $
  reload=reload,colortable=colortable, blackcolor=blackcolor, $
  plotxy=plotxy, plotxz=plotxz, plotyz=plotyz,umax=umax,$
  draw_labels=draw_labels, poster_vec=poster_vec,current=current,$
  dnmin=dnmin

;--------------------------------------------------------------------;
; 1) PRINT HELP, IF REQUESTED AND RETURN                             ;
;--------------------------------------------------------------------;
if keyword_set(help) then begin
  print, 'pl_figuv2: TO BE WRITTEN'
  return
endif

;--------------------------------------------------------------------;
; 2) READ DATA IF "DN1" AND/OR "DN2" IS NOT DEFINED                  ;
;                                                                    ;
;    + Fix input parameters which are needed to load data            ;
;--------------------------------------------------------------------;
ss1=size(ux1in)
ss2=size(ux2in)

if ((ss1(1) eq 0) or (ss2(1) eq 0) or keyword_set(reload)) then begin

  ;---------------------------------------------------------;
  ; This part should resemble "datadn.pro" functionality    ;
  ; of the "06herm" package. Note, that as of v.0.4.141     ;
  ; "U"-files contain proton currents (!) and must be       ;
  ; normalised by local density to resemble "bulk speed"    ;
  ;---------------------------------------------------------;
  if not(stw_keyword_set(dir1)) then dir1='.'
  if not(stw_keyword_set(dir2)) then dir2='.'
  if not(stw_keyword_set(specie)) then specie=''

  if not(stw_keyword_set(dnmin)) then dnmin=0.0
  if (dnmin lt 0.0) then dnmin=0.0

  ;------------------------------------------------------;
  ; U-arrays contain proton (in hybrid sense of m_e=0    ;
  ; also total) current, tot the proton bulk speed. The  ;
  ; proton bulk speed can be resembled by normalising    ;
  ; with respect to the local density. This is default   ;
  ; analysis. Use /current keywort to get map of         ;
  ; currents nearby the obstacle.                        ;
  ;------------------------------------------------------;
  if not(stw_keyword_set(current)) then begin
    rd,dir1+'/'+'Dn'+ specie + run1 + itt1 +'.gz',dn1
    rd,dir2+'/'+'Dn'+ specie + run2 + itt2 +'.gz',dn2

    ;---------------------------------;
    ; Check if the data were read     ;
    ;---------------------------------;
    ss=size(dn1)
    if (ss(1) eq 0) then return
    ss=size(dn2)
    if (ss(1) eq 0) then return

  endif

  rd,dir1+'/'+'Ux'+specie+run1+itt1+'.gz',ux1in
  rd,dir1+'/'+'Uy'+specie+run1+itt1+'.gz',uy1in
  rd,dir1+'/'+'Uz'+specie+run1+itt1+'.gz',uz1in

  rd,dir2+'/'+'Ux'+specie+run2+itt2+'.gz',ux2in
  rd,dir2+'/'+'Uy'+specie+run2+itt2+'.gz',uy2in
  rd,dir2+'/'+'Uz'+specie+run2+itt2+'.gz',uz2in

  ;---------------------------------;
  ; Check if the data were read     ;
  ;---------------------------------;
  ss=size(ux1in)
  if (ss(1) eq 0) then return
  ss=size(uy1in)
  if (ss(1) eq 0) then return
  ss=size(uz1in)
  if (ss(1) eq 0) then return
  ss=size(ux2in)
  if (ss(1) eq 0) then return
  ss=size(uy2in)
  if (ss(1) eq 0) then return
  ss=size(uz2in)
  if (ss(1) eq 0) then return

  if not(keyword_set(current)) then begin
    ndx=where(dn1 lt dnmin, cnt)
    sn=size(ndx)
    if (sn (0) eq 0) then return
    dn1(ndx)=1.0
    ux1in=ux1in/dn1
    uy1in=uy1in/dn1
    uz1in=uz1in/dn1

    ndx=where(dn2 lt dnmin, cnt)
    sn=size(ndx)
    if (sn (0) eq 0) then return
    dn2(ndx)=1.0
    ux2in=ux2in/dn2
    uy2in=uy2in/dn2
    uz2in=uz2in/dn2
  endif

  ss1=size(ux1in)
  ss2=size(ux2in)

endif

;--------------------------------------------------------------------;
; 3) FIX PARAMETERS NEEDED FOR THE PREPARATION OF DATA               ;
;--------------------------------------------------------------------;
if not(keyword_set(radius1)) then radius1=1.0
if not(keyword_set(radius2)) then radius2=1.0

if not(keyword_set(dx1)) then dx1=1.0
if not(keyword_set(dy1)) then dy1=1.0
if not(keyword_set(dz1)) then dz1=1.0
if not(keyword_set(dx2)) then dx2=1.0
if not(keyword_set(dy2)) then dy2=1.0
if not(keyword_set(dz2)) then dz2=1.0

if not(keyword_set(xc1)) then xc1=0.5
if not(keyword_set(yc1)) then yc1=0.5
if not(keyword_set(zc1)) then zc1=0.5
if not(keyword_set(xc2)) then xc2=0.5
if not(keyword_set(yc2)) then yc2=0.5
if not(keyword_set(zc2)) then zc2=0.5

if ((ss1(1) eq 0) or (ss2(1) eq 0) or keyword_set(reload)) then begin

  ;-------------------------------------------------------;
  ; This shall be done only once when data was reloaded!  ;
  ;-------------------------------------------------------;
  if (ss1(0) gt 2) then begin
    pl_gennul3, ss1(1), ss1(2), ss1(3), dx1, dy1, dz1, xc1, radius1, u01
  endif
  if (ss2(0) gt 2) then begin
    pl_gennul3, ss2(1), ss2(2), ss2(3), dx2, dy2, dz2, xc2, radius2, u02
  endif

  mnul, u01, ux1in, level=0.01, value=0.0
  mnul, u01, uy1in, level=0.01, value=0.0
  mnul, u01, uz1in, level=0.01, value=0.0
  mnul, u02, ux2in, level=0.01, value=0.0
  mnul, u02, uy2in, level=0.01, value=0.0
  mnul, u02, uz2in, level=0.01, value=0.0

endif

ux1=ux1in
uy1=uy1in
uz1=uz1in

ux2=ux2in
uy2=uy2in
uz2=uz2in

if not(keyword_set(umax)) then umax=100.0

ndx=where(ux1 gt umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then ux1(ndx)=umax
ndx=where(ux2 gt umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then ux2(ndx)=umax
ndx=where(ux1 lt -umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then ux1(ndx)=-umax
ndx=where(ux2 lt -umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then ux2(ndx)=-umax

ndx=where(uy1 gt umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uy1(ndx)=umax
ndx=where(uy2 gt umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uy2(ndx)=umax
ndx=where(uy1 lt -umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uy1(ndx)=-umax
ndx=where(uy2 lt -umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uy2(ndx)=-umax

ndx=where(uz1 gt umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uz1(ndx)=umax
ndx=where(uz2 gt umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uz2(ndx)=umax
ndx=where(uz1 lt -umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uz1(ndx)=-umax
ndx=where(uz2 lt -umax, cnt)
sn=size(ndx)
if (sn (0) ne 0) then uz2(ndx)=-umax

b1=sqrt(ux1*ux1+uy1*uy1+uz1*uz1)
b2=sqrt(ux2*ux2+uy2*uy2+uz2*uz2)

ss1=size(b1)
ss2=size(b2)

if (ss1(0) lt 2) then return
if (ss2(0) lt 2) then return

xcut1=(ss1(1)-1)*xc1
ycut1=(ss1(2)-1)*yc1
zcut1=(ss1(3)-1)*zc1
xcut2=(ss2(1)-1)*xc2
ycut2=(ss2(2)-1)*yc2
zcut2=(ss2(3)-1)*zc2

if not((xcut1 ge 0) and (xcut1 lt ss1(1))) then xcut1=ss1(1)/2
if not((ycut1 ge 0) and (ycut1 lt ss1(2))) then ycut1=ss1(2)/2
if not((zcut1 ge 0) and (zcut1 lt ss1(3))) then zcut1=ss1(3)/2
if not((xcut2 ge 0) and (xcut2 lt ss2(1))) then xcut2=ss2(1)/2
if not((ycut2 ge 0) and (ycut2 lt ss2(2))) then ycut2=ss2(2)/2
if not((zcut2 ge 0) and (zcut2 lt ss2(3))) then zcut2=ss2(3)/2

b1xy = reform (b1 (*, *, zcut1), ss1(1), ss1(2))
b1xz = reform (b1 (*, ycut1, *), ss1(1), ss1(3))
b1yz = reform (b1 (xcut1, *, *), ss1(2), ss1(3))

ux1xy= reform (ux1(*, *, zcut1), ss1(1), ss1(2))
uy1xy= reform (uy1(*, *, zcut1), ss1(1), ss1(2))
uz1xy= reform (uz1(*, *, zcut1), ss1(1), ss1(2))
ux1xz= reform (ux1(*, ycut1, *), ss1(1), ss1(3))
uy1xz= reform (uy1(*, ycut1, *), ss1(1), ss1(3))
uz1xz= reform (uz1(*, ycut1, *), ss1(1), ss1(3))
ux1yz= reform (ux1(xcut1, *, *), ss1(2), ss1(3))
uy1yz= reform (uy1(xcut1, *, *), ss1(2), ss1(3))
uz1yz= reform (uz1(xcut1, *, *), ss1(2), ss1(3))

b2xy = reform (b2 (*, *, zcut2), ss2(1), ss2(2))
b2xz = reform (b2 (*, ycut2, *), ss2(1), ss2(3))
b2yz = reform (b2 (xcut2, *, *), ss2(2), ss2(3))

ux2xy= reform (ux2(*, *, zcut2), ss2(1), ss2(2))
uy2xy= reform (uy2(*, *, zcut2), ss2(1), ss2(2))
uz2xy= reform (uz2(*, *, zcut2), ss2(1), ss2(2))
ux2xz= reform (ux2(*, ycut2, *), ss2(1), ss2(3))
uy2xz= reform (uy2(*, ycut2, *), ss2(1), ss2(3))
uz2xz= reform (uz2(*, ycut2, *), ss2(1), ss2(3))
ux2yz= reform (ux2(xcut2, *, *), ss2(2), ss2(3))
uy2yz= reform (uy2(xcut2, *, *), ss2(2), ss2(3))
uz2yz= reform (uz2(xcut2, *, *), ss2(2), ss2(3))

;--------------------------------------------------------------------;
; 4) FIX PARAMETERS NEEDED FOR PLOTTING                              ;
;--------------------------------------------------------------------;
lx1=(ss1(1)-1)*dx1
if (ss1(0) ge 2) then ly1=(ss1(2)-1)*dy1
if (ss1(0) eq 3) then lz1=(ss1(3)-1)*dz1

lx2=(ss2(1)-1)*dx2
if (ss2(0) ge 2) then ly2=(ss2(2)-1)*dy2
if (ss2(0) eq 3) then lz2=(ss2(3)-1)*dz2

ix1=(findgen(ss1(1))*dx1-xc1*lx1)/radius1
iy1=(findgen(ss1(2))*dy1-yc1*ly1)/radius1
if (ss1(0) eq 3) then iz1=(findgen(ss1(3))*dz1-zc1*lz1)/radius1

ix2=(findgen(ss2(1))*dx2-xc2*lx2)/radius2
iy2=(findgen(ss2(2))*dy2-yc2*ly2)/radius2
if (ss2(0) eq 3) then iz2=(findgen(ss2(3))*dz2-zc2*lz2)/radius2

if not(keyword_set(minx)) then minx=ix1(0)
if not(keyword_set(maxx)) then maxx=ix1(ss1(1)-1)
if not(keyword_set(miny)) then miny=iy1(0)
if not(keyword_set(maxy)) then maxy=iy1(ss1(2)-1)

if (ss1(0) eq 3) then begin
  if not(keyword_set(minz)) then minz=iz1(0)
  if not(keyword_set(maxz)) then maxz=iz1(ss1(3)-1)
endif

if not(keyword_set(mina)) then begin
  mina = min(b1)
  if (min(b2) gt mina) then mina = min(b2)
endif
if not(keyword_set(maxa)) then begin
  maxa = max(b1)
  if (max(b2) lt maxa) then maxa = max(b2)
endif

;--------------------------------------------------------------------;
; 5) PRODUCE PLANET                                                  ;
;--------------------------------------------------------------------;
imi=findgen(1001)/1000*!pi*2
imx=1.0*sin(imi)
imy=1.0*cos(imi)

;--------------------------------------------------------------------;
; 5) PLOT                                                            ;
;--------------------------------------------------------------------;
!x.margin=[4.,2.]

!p.font=0
!p.charsize=2
!p.background=0
!p.thick=2

if not(stw_keyword_set(colortable)) then colortable=0
if not(stw_keyword_set(blackcolor)) then blackcolor=0

loadct,colortable
nle=50
lev = mina + findgen(nle) * ((maxa-mina)/(nle-1))

aa=fltarr(3,nle)
aa(0,*)=lev
aa(1,*)=lev
aa(2,*)=lev

if not(keyword_set(dsvec)) then dsvec=0.5
if not(keyword_set(len)) then len=15.0/(radius1+radius2)*(dx1+dx2)
if not(keyword_set(maxlen)) then maxlen=len
if not(keyword_set(hsize)) then hsize=-0.4

;--------------------------------------------------------------------;
; 2-DIMENSIONAL DATA - produce single plot                           ;
; Left unrevised from Enceladus!                                     ;
;--------------------------------------------------------------------;
if ((ss1(0) eq 2) and (ss2(0) eq 2)) then begin

  if keyword_set(ps) then tops,/col,file=ps,/land

  !p.multi=[0,1,1]

;  contour, ani(*,*,zcut), ix, iy,$
;  nlev=nle, /fill, lev=lev, $
;  xrange=[minx,maxx],yrange=[miny,maxy],zrange=[mina,maxa],$
;  xtitle='xx',ytitle='yy',$
;  /xst,/yst,/zst,$
;  position=[0.1, 0.1, 0.25, 0.95]

  if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
    color=blackcolor

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
ilabel=0
label=['aa','bb','cc','dd','ee','ff']
xout=minx+(maxx-minx)/50.0
yout=maxy-(maxy-miny)/5.0

if ((ss1(0) eq 3) and (ss2(0) eq 3)) then begin

  nofplots=0
  if keyword_set(plotxz) then nofplots=nofplots+1
  if keyword_set(plotxy) then nofplots=nofplots+1
  if keyword_set(plotyz) then nofplots=nofplots+1

  if (nofplots eq 0) then return

  if keyword_set(ps) then tops,/col,file=ps,/land

  !p.multi=[0,nofplots,2]
  if keyword_set(plotyz) then begin
    off=0.2
    ysize=(0.95-off)/nofplots
  endif else begin
    off=0.1
    ysize=(0.95-off)/nofplots
  endelse

  gg=replicate(' ',30)

  iplot=0
  remplots=nofplots

  if keyword_set(plotxz) then begin

    ;---------------------------------------------------;
    ; Select poster.                                    ;
    ;                                                   ;
    ; Poster is used as CONTOUR on the background of    ;
    ; the plot. By default a poster is magnitude of the ;
    ; magnetic field and it can be only positive.       ;
    ;                                                   ;
    ; If /POSTER_VEC is set, then on backgrount we      ;
    ; display map of the component perpendicular to     ;
    ; the displayed plane.                              ;
    ;---------------------------------------------------;
    poster1=b1xz
    poster2=b2xz
    minaa=0.0
    maxaa=maxa

    if keyword_set(poster_vec) then begin
      poster1=uy1xz
      poster2=uy2xz
      minaa=mina
      maxaa=maxa
    endif

    if keyword_set(plotxy) then begin
      stw_contour_vect, poster1, ux1xz, uz1xz, ix1, iz1, $
      len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
      nlev=nle, /fill, lev=lev, $
      xrange=[minx,maxx],yrange=[minz,maxz],zrange=[mina,maxa],$
      xtickname=gg, ytitle='zz',$
      /xst,/yst,/zst,$
      position=[0.05, off+(nofplots-1)*ysize, 0.47, 0.95]
    endif else begin
      stw_contour_vect, poster1, ux1xz, uz1xz, ix1, iz1, $
      len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
      nlev=nle, /fill, lev=lev, $
      xrange=[minx,maxx],yrange=[minz,maxz],zrange=[mina,maxa],$
      xtitle='xx',ytitle='zz',xtickformat='pl_xticks',$
      /xst,/yst,/zst,$
      position=[0.05, off+(nofplots-1)*ysize, 0.47, 0.95]
    endelse

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor
    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    if keyword_set(plotxy) then begin
      stw_contour_vect, poster2, ux2xz, uz2xz, ix2, iz2, $
      len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
      nlev=nle, /fill, lev=lev, $
      xrange=[minx,maxx],yrange=[minz,maxz],zrange=[mina,maxa],$
      xtickname=gg,ytickname=gg,$
      /xst,/yst,/zst,$
      position=[0.48, off+(nofplots-1)*ysize, 0.9, 0.95]
    endif else begin
      stw_contour_vect, poster2, ux2xz, uz2xz, ix2, iz2, $
      len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
      nlev=nle, /fill, lev=lev, $
      xrange=[minx,maxx],yrange=[minz,maxz],zrange=[mina,maxa],$
      xtitle='xx',ytickname=gg,xtickformat='pl_xticks',$
      /xst,/yst,/zst,$
      position=[0.48, off+(nofplots-1)*ysize, 0.9, 0.95]
    endelse

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor
    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    ;----------------------------------------------------;
    ; For certain entities, like the temperature,        ;
    ; do not plot negative portion of the scale.         ;
    ; Hence yra=[0.0,maxa] rather than yra=[mina,maxa].  ;
    ; We use negative mina oftenly to shift the color    ;
    ; scale by the given offset.                         ;
    ;----------------------------------------------------;
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[minaa,maxaa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=[0.97, off+(nofplots-1)*ysize, 0.99, .95], $
    xtickname=gg,/noerase

    remplots=nofplots-1
    iplot=iplot+1

  endif

  if keyword_set(plotxy) then begin

    ;---------------------------------------------------;
    ; Select poster.                                    ;
    ;---------------------------------------------------;
    poster1=b1xy
    poster2=b2xy
    minaa=0.0
    maxaa=maxa

    if keyword_set(poster_vec) then begin
      poster1=uz1xz
      poster2=uz2xz
      minaa=mina
      maxaa=maxa
    endif

    stw_contour_vect, poster1, ux1xy, uy1xy, ix1, iy1, $
    len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
    nlev=nle, /fill, lev=lev, $
    xrange=[minx,maxx],yrange=[miny,maxy],zrange=[mina,maxa],$
    xtitle='xx',ytitle='yy',xtickformat='pl_xticks',$
    /xst,/yst,/zst,$
    position=[0.05, off+(remplots-1)*ysize, $
              0.47, 0.95-iplot*ysize-0.02]

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor
    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    stw_contour_vect, poster2, ux2xy, uy2xy, ix2, iy2, $
    len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
    nlev=nle, /fill, lev=lev, $
    xrange=[minx,maxx],yrange=[miny,maxy],zrange=[mina,maxa],$
    xtitle='xx',ytickname=gg,xtickformat='pl_xticks',$
    /xst,/yst,/zst,$
    position=[0.48, off+(remplots-1)*ysize, $
              0.9, 0.95-iplot*ysize-0.02]

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor
    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    ;----------------------------------------------------;
    ; For certain entities, like the temperature,        ;
    ; do not plot negative portion of the scale.         ;
    ; Hence yra=[0.0,maxa] rather than yra=[mina,maxa].  ;
    ; We use negative mina oftenly to shift the color    ;
    ; scale by the given offset.                         ;
    ;----------------------------------------------------;
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[minaa,maxaa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=[0.97, off+(remplots-1)*ysize, $
              0.99, .95-iplot*ysize-0.02], $
    xtickname=gg,/noerase

    iplot=iplot+1

  endif

  if keyword_set(plotyz) then begin

    off=0.0
    if (nofplots gt 1) then off=0.1

    ;---------------------------------------------------;
    ; Select poster.                                    ;
    ;---------------------------------------------------;
    poster1=b1yz
    poster2=b2yz
    minaa=0.0
    maxaa=maxa

    if keyword_set(poster_vec) then begin
      poster1=ux1yz
      poster2=ux2yz
      minaa=mina
      maxaa=maxa
    endif

    stw_contour_vect, poster1, uy1yz, uz1yz, iy1, iz1, $
    len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
    nlev=nle, /fill, lev=lev, $
    xrange=[miny,maxy],yrange=[minz,maxz],zrange=[mina,maxa],$
    xtitle='yy',ytitle='zz',$
    /xst,/yst,/zst,$
    position=[0.05, 0.1, $
              0.47, 0.95-iplot*ysize-0.02-off]

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor
    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    stw_contour_vect, poster2, uy2yz, uz2yz, iy2, iz2, $
    len=len, maxlen=maxlen, hsize=hsize, dsvec=dsvec, color=10, $
    nlev=nle, /fill, lev=lev, $
    xrange=[miny,maxy],yrange=[minz,maxz],zrange=[mina,maxa],$
    xtitle='yy',ytickname=gg,$
    /xst,/yst,/zst,$
    position=[0.48, 0.1, $
              0.9, 0.95-iplot*ysize-0.02-off]

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor
    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    ;----------------------------------------------------;
    ; For certain entities, like the temperature,        ;
    ; do not plot negative portion of the scale.         ;
    ; Hence yra=[0.0,maxa] rather than yra=[mina,maxa].  ;
    ; We use negative mina oftenly to shift the color    ;
    ; scale by the given offset.                         ;
    ;----------------------------------------------------;
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[minaa,maxaa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=[0.97, 0.1, $
              0.99, .95-iplot*ysize-0.02-off], $
    xtickname=gg,/noerase

  endif

  if keyword_set(ps) then begin
    device, /close
    tox
  endif

  !p.multi=[0,1,1]

endif

;--------------------------------------------------------------------;
return
end
