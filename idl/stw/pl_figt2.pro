;--------------------------------------------------------------------;
; PROCEDURE FOR PLOTTING TEMPERATURE FROM TWO PLANETARY SIMULATIONS  ;
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
; 1) If you do not use parameters "t1" and/or "t2"                   ;
;    (which are not required as input because the procedure does     ;
;    not need them for full functionality) the data will be always   ;
;    readloaded:                                                     ;                                                                     ;
;                                                                    ;
;    IDL> pl_figt2,'b25Kp','b25Ka','t26','t29', $                    ;
;         dir1='b25Kp128',dir2='b25Ka128',t1,t2, $                   ;
;         radius1=16.36,radius2=12.48,xc1=0.35,xc2=0.35, $           ;
;         /plotxz,maxa=4,mina=-1.,/draw_planet,colortable=0, $       ;
;         blackcolor=0,/plotxy,dx1=0.4,dx2=0.4,maxx=5.5,/plotyz      ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 29/08/2006, v.0.4.141: Up to date with latest "pl_figbv2.pro"    ;
; - 08/2006, v.0.4.140: Then copyied and continues as "pl_figt2.pro" ;
;   We need to update "pl_figdn2.pro" according to the newly         ;
;   developed features here.                                         ;
; - 08/2006, v.0.4.140: Started. Derived from "pl_figani.pro" of     ;
;   that date, as pl_figdn2.pro                                      ;
;--------------------------------------------------------------------;
pro pl_figt2, run1, run2, itt1, itt2, t1, t2, $
  dir1=dir1, dir2=dir2, $
  dx1=dx1, dy1=dy1, dz1=dz1, dx2=dx2, dy2=dy2, dz2=dz2, $
  xc1=xc1, yc1=yc1, zc1=zc1, xc2=xc2, yc2=yc2, zc2=zc2, $
  radius1=radius1, radius2=radius2, $
  minx=minx, maxx=maxx, $
  miny=miny, maxy=maxy, $
  minz=minz, maxz=maxz, $
  mina=mina, maxa=maxa, specie=specie, $
  help=help, ps=ps, draw_planet=draw_planet, $
  reload=reload,colortable=colortable, blackcolor=blackcolor, $
  plotxy=plotxy, plotxz=plotxz, plotyz=plotyz,dnmin=dnmin,$
  draw_labels=draw_labels

;--------------------------------------------------------------------;
; 1) PRINT HELP, IF REQUESTED AND RETURN                             ;
;--------------------------------------------------------------------;
if keyword_set(help) then begin
  print, 'pl_figt2: TO BE WRITTEN'
  return
endif

;--------------------------------------------------------------------;
; 2) READ DATA IF "DN1" AND/OR "DN2" IS NOT DEFINED                  ;
;                                                                    ;
;    + Fix input parameters which are needed to load data            ;
;--------------------------------------------------------------------;
ss1=size(t1)
ss2=size(t2)

if ((ss1(1) eq 0) or (ss2(1) eq 0) or stw_keyword_set(reload)) then begin

  ;---------------------------------------------------------;
  ; This part should resemble "datadn.pro" functionality    ;
  ; of the "06herm" package.                                ;
  ;---------------------------------------------------------;
  if not(keyword_set(dir1)) then dir1='.'
  if not(keyword_set(dir2)) then dir2='.'
  if not(keyword_set(specie)) then specie=''

  if not(keyword_set(dnmin)) then dnmin=0.01
  if (dnmin lt 0.01) then dnmin=0.01

  rd,dir1+'/'+'Dn'+ specie + run1 + itt1 +'.gz',dn1
  rd,dir2+'/'+'Dn'+ specie + run2 + itt2 +'.gz',dn2
  rd,dir1+'/'+'Pper'+ specie + run1 + itt1 +'.gz',pe1
  rd,dir2+'/'+'Pper'+ specie + run2 + itt2 +'.gz',pe2
  rd,dir1+'/'+'Ppar'+ specie + run1 + itt1 +'.gz',pa1
  rd,dir2+'/'+'Ppar'+ specie + run2 + itt2 +'.gz',pa2

  ;---------------------------------;
  ; Check if the data were read     ;
  ;---------------------------------;
  ss=size(dn1)
  if (ss(1) eq 0) then return
  ss=size(dn2)
  if (ss(1) eq 0) then return
  ss=size(pe1)
  if (ss(1) eq 0) then return
  ss=size(pe2)
  if (ss(1) eq 0) then return
  ss=size(pa1)
  if (ss(1) eq 0) then return
  ss=size(pa2)
  if (ss(1) eq 0) then return

  ndx=where(dn1 lt dnmin, cnt)
  sn=size(ndx)
  if (sn (0) eq 0) then return
  pa1(ndx)=0.0
  pe1(ndx)=0.0
  dn1(ndx)=1.0

  ndx=where(dn2 lt dnmin, cnt)
  sn=size(ndx)
  if (sn (0) eq 0) then return
  pa2(ndx)=0.0
  pe2(ndx)=0.0
  dn2(ndx)=1.0

  t1=(pa1+2.0*pe1)/3.0/dn1
  t2=(pa2+2.0*pe2)/3.0/dn2

  ss1=size(t1)
  ss2=size(t2)

endif

if (ss1(0) lt 2) then return
if (ss2(0) lt 2) then return

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
    pl_gennul3, ss1(1), ss1(2), ss1(3), dx1, dy1, dz1, xc1, radius1, t01
  endif
  if (ss2(0) gt 2) then begin
    pl_gennul3, ss2(1), ss2(2), ss2(3), dx2, dy2, dz2, xc2, radius2, t02
  endif

  mnul, t01, t1, level=0.01, value=0.0
  mnul, t02, t2, level=0.01, value=0.0

endif

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
  mina = min(t1)
  if (min(t2) gt mina) then mina = min(t2)
endif
if not(keyword_set(maxa)) then begin
  maxa = max(t1)
  if (max(t2) lt maxa) then maxa = max(t2)
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

  gg=replicate(' ',30)

  iplot=0
  remplots=nofplots

  if keyword_set(plotxz) then begin

    if keyword_set(plotxy) then begin
      contour, reform(t1(*,ycut1,*),ss1(1),ss1(3)), ix1, iz1,$
      nlev=nle, /fill, lev=lev, $
      xrange=[minx,maxx],yrange=[minz,maxz],zrange=[mina,maxa],$
      xtickname=gg, ytitle='zz',$
      /xst,/yst,/zst,$
      position=[0.05, off+(nofplots-1)*ysize, 0.47, 0.95]
    endif else begin
      contour, reform(t1(*,ycut1,*),ss1(1),ss1(3)), ix1, iz1,$
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
      contour, reform(t2(*,ycut2,*),ss2(1),ss2(3)), ix2, iz2,$
      nlev=nle, /fill, lev=lev, $
      xrange=[minx,maxx],yrange=[minz,maxz],zrange=[mina,maxa],$
      xtickname=gg,ytickname=gg,$
      /xst,/yst,/zst,$
      position=[0.48, off+(nofplots-1)*ysize, 0.9, 0.95]
    endif else begin
      contour, reform(t2(*,ycut2,*),ss2(1),ss2(3)), ix2, iz2,$
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
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[0.0,maxa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=[0.97, off+(nofplots-1)*ysize, 0.99, .95], $
    xtickname=gg,/noerase

    remplots=nofplots-1
    iplot=iplot+1

  endif

  if keyword_set(plotxy) then begin

    contour, reform(t1(*,*,zcut1),ss1(1),ss1(2)), ix1, iy1,$
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

    contour, reform(t2(*,*,zcut2),ss2(1),ss2(2)), ix2, iy2,$
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
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[0.0,maxa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=[0.97, off+(remplots-1)*ysize, $
              0.99, .95-iplot*ysize-0.02], $
    xtickname=gg,/noerase

    iplot=iplot+1

  endif

  if keyword_set(plotyz) then begin

    off=0.0
    if (nofplots gt 1) then off=0.1

    contour, reform(t1(xcut1,*,*),ss1(2),ss1(3)), iy1, iz1,$
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

    contour, reform(t2(xcut2,*,*),ss2(2),ss2(3)), iy2, iz2,$
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
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[0.0,maxa], $
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
