;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING TEMPERATURE ANISOTROPY                ;
;                                                                    ;
; Developed for analysis of Mercury data simulations.                ;
; As template used script developed before within "06herm" paper     ;
; (figani.pro)                                                       ;
;                                                                    ;
; EXAMPLE:                                                           ;
;                                                                    ;
; 1) If you do not use "b" parameter (which is not required as       ;
;    input) the data will be always read:                            ;                                                                     ;
;                                                                    ;
;    IDL> pl_figani,'b25Kp','t30',radius=12.48,/draw_planet, $       ;
;         xc=0.35,dx=0.4                                             ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 28/08/2006, v.0.4.141: Up to date with recent plotters.          ;
; - 08/2006, v.0.4.140: Started. Derived from "pl_figbv.pro" of      ;
;   that date.                                                       ;
;--------------------------------------------------------------------;
pro pl_figani, run, itt, ani, $
  dir=dir, $
  dx=dx, dy=dy, dz=dz, $
  xc=xc, yc=yc, zc=zc, $
  radius=radius, $
  minx=minx, maxx=maxx, $
  miny=miny, maxy=maxy, $
  minz=minz, maxz=maxz, $
  mina=mina, maxa=maxa, specie=specie, $
  help=help, ps=ps, draw_planet=draw_planet, $
  reload=reload,colortable=colortable, blackcolor=blackcolor, $
  plotxy=plotxy, plotxz=plotxz, plotyz=plotyz,pamin=pamin,$
  draw_labels=draw_labels,inverse=inverse

;--------------------------------------------------------------------;
; 1) PRINT HELP, IF REQUESTED AND RETURN                             ;
;--------------------------------------------------------------------;
if keyword_set(help) then begin
  print, 'pl_figani: TO BE WRITTEN'
  return
endif

ss=size(ani)

;--------------------------------------------------------------------;
; 2) READ DATA IF "ANI" IS NOT DEFINED                               ;
;    + Fix input parameters which are needed to load data            ;
;--------------------------------------------------------------------;
if ((ss(1) eq 0) or stw_keyword_set(reload)) then begin

  if not(stw_keyword_set(reload)) then reload=1
  if not(stw_keyword_set(dir)) then dir='.'
  if not(stw_keyword_set(specie)) then specie=''

  if not(keyword_set(pamin)) then pamin=0.01
  if (pamin lt 0.01) then pamin=0.01

  rd,dir+'/'+'Ppar'+ specie + run + itt +'.gz',pa
  rd,dir+'/'+'Pper'+ specie + run + itt +'.gz',pe

  ;---------------------------------;
  ; Check if the data were read     ;
  ;---------------------------------;
  ss=size(pa)
  if (ss(1) eq 0) then return
  ss=size(pe)
  if (ss(1) eq 0) then return

  ndx=where(pa lt pamin, cnt)
  sn=size(ndx)
  if (sn (0) eq 0) then return

  if stw_keyword_set(inverse) then begin
    pa(ndx)=0.0
    pe(ndx)=1.0
    ani=pa/pe-1
  endif else begin
    pa(ndx)=1.0
    pe(ndx)=0.0
    ani=pe/pa-1
  endelse

  ss=size(ani)

endif

if (ss(0) lt 2) then return

if (stw_keyword_set(reload)) then begin

  ;-------------------------------------------------------;
  ; This shall be done only once when data was reloaded!  ;
  ;-------------------------------------------------------;
  pl_figdata, ani, $
    radius=radius, dx=dx, dy=dy, dz=dz, $
    xc=xc, yc=yc, zc=zc

endif

;--------------------------------------------------------------------;
; PLOT                                                               ;
;--------------------------------------------------------------------;

;--------------------------------------------------------------------;
; 2-DIMENSIONAL DATA - produce single plot                           ;
; Left unrevised from Enceladus!                                     ;
;--------------------------------------------------------------------;
if (ss(0) eq 2) then begin

  if keyword_set(ps) then tops,/col,file=ps,/land

  !p.multi=[0,1,1]

;  contour, ani(*,*,zcut), ix, iy,$
;  nlev=nle, /fill, lev=lev, $
;  xrange=[minx,maxx],yrange=[miny,maxy],zrange=[mina,maxa],$
;  xtitle='xx',ytitle='yy',$
;  /xst,/yst,/zst,$
;  position=[0.1, 0.1, 0.25, 0.95]

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

  pl_fig3d, ani, $
    plotxy=plotxy, plotxz=plotxz, plotyz=plotyz, $
    dx=dx, dy=dy, dz=dz, xc=xc, yc=yc, zc=zc, $
    radius=radius, $
    minx=minx, maxx=maxx, miny=miny, maxy=maxy, $
    minz=minz, maxz=maxz, mina=mina, maxa=maxa, $
    ps=ps, draw_planet=draw_planet, $
    colortable=colortable, blackcolor=blackcolor, $
    draw_labels=draw_labels

endif

;--------------------------------------------------------------------;
return
end
