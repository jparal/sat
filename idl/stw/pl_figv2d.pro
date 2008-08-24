;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING PLANETARY DATA FROM 3D SIMULATIONS    ;
;                                                                    ;
; Developed for analysis of Mercury data simulations.                ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 09/2006, v.0.4.141: Trying to implement that this routine        ;
;   keeps the aspect ratio.                                          ;
; - 09/2006, v.0.4.141: Converting from "pl_fig2d.pro" into          ;
;   "pl_fig3d.pro".                                                  ;
; - 28/08/2006, v.0.4.141: Cloned/extracted from "pl_figani.pro".    ;
;--------------------------------------------------------------------;
pro pl_figv2d, data, datax, datay, $
  dx=dx, dy=dy, $
  xc=xc, yc=yc, $
  radius=radius, $
  minx=minx, maxx=maxx, miny=miny, maxy=maxy, $
  mina=mina, maxa=maxa, $
  ps=ps, draw_planet=draw_planet, $
  dsvec=dsvec, maxlen=maxlen, len=len, $
  colortable=colortable, blackcolor=blackcolor, $
  allow_negative=allow_negative

;--------------------------------------------------------------------;
; CHECK INPUT                                                        ;
;--------------------------------------------------------------------;
ss=size(data)
if (ss(0) ne 2) then return

ss=size(datax)
if (ss(0) ne 2) then return

ss=size(datay)
if (ss(0) ne 2) then return

;--------------------------------------------------------------------;
; FIX PARAMETERS NEEDED FOR PLOTTING                                 ;
;--------------------------------------------------------------------;
if not(stw_keyword_set(radius)) then radius=1.0

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0

if not(stw_keyword_set(xc)) then xc=0.5
if not(stw_keyword_set(yc)) then yc=0.5

lx=ss(1)*dx
ly=ss(2)*dy

ix=(findgen(ss(1))*dx-xc*lx)/radius
iy=(findgen(ss(2))*dy-yc*ly)/radius

if not(stw_keyword_set(minx)) then minx=ix(0)
if not(stw_keyword_set(maxx)) then maxx=ix(ss(1)-1)
if not(stw_keyword_set(miny)) then miny=iy(0)
if not(stw_keyword_set(maxy)) then maxy=iy(ss(2)-1)

if not(stw_keyword_set(mina)) then mina=min(data)
if not(stw_keyword_set(maxa)) then maxa=max(data)

;--------------------------------------------------------------------;
; PRODUCE PLANET                                                     ;
;--------------------------------------------------------------------;
imi=findgen(1001)/1000*!pi*2
imx=1.0*sin(imi)
imy=1.0*cos(imi)

;--------------------------------------------------------------------;
; PLOT                                                               ;
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
; 2-DIMENSIONAL DATA - single plots                                  ;
;--------------------------------------------------------------------;
if (ss(0) eq 2) then begin

  ;----------------------------------------------------------------;
  ; Keep aspect ratio:                                             ;
  ;                                                                ;
  ; plotr - is based on the available "position" area for the plot ;
  ;         - this is like "unity" aspect ration.                  ;
  ; datar - is based on the "min/max" values selected by the user  ;
  ;                                                                ;
  ; - If (as defined - Lx/Ly) the aspect ratio < 1, the plot is    ;
  ;   tall and we have to make it thinner                          ;
  ;   => sx = this what we have to cut out at left side to         ;
  ;      keep aspect.                                              ;
  ; - If the aspect ration is > 1, the plot is wide and we have    ;
  ;   to cut it at its bottom to keep the proper aspect ration     ;
  ;   on the plot.                                                 ;
  ;----------------------------------------------------------------;
  plotr=(0.85-0.05)/(0.95-0.1)
  datar=(maxx-minx)/(maxy-miny)

  aspect=datar*plotr*0.9  ; 0.9 is an ad hoc correction which works

  sx=0.0
  sy=0.0

  if (aspect lt 1.0) then sx=(0.85-0.05) - (0.85-0.05)*aspect
  if (aspect gt 1.0) then sy=(0.95-0.1) - (0.9-0.1)/aspect
  
  if stw_keyword_set(ps) then tops,/col,file=ps,/land

  !p.multi=[0,1,1]
  gg=replicate(' ',30)

  ;----------------------------------------------------;
  ; For certain entities, like the temperature,        ;
  ; do not plot negative portion of the scale.         ;
  ; Hence yra=[0.0,maxa] rather than yra=[mina,maxa].  ;
  ; We use negative mina oftenly to shift the color    ;
  ; scale by the given offset.                         ;
  ;----------------------------------------------------;
  if not(stw_keyword_set(allow_negative)) then begin
    if (mina lt 0.0) then mina = 0.0
  endif

  contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[mina,maxa], $
    /xst,/yst,/zst, nlev=nle,/fill,xtitle='',ytitle='',$
    position=[0.95, 0.1+sy, 0.99, .95], $
    xtickname=gg

  stw_contour_vect, data, datax, datay, ix, iy,$
                    nlev=nle, /fill, lev=lev, $
                    xrange=[minx,maxx],yrange=[miny,maxy],zrange=[mina,maxa],$
                    dsvec=dsvec, maxlen=maxlen, len=len, $
                    xtickformat='pl_xticks',$
                    /xst,/yst,/zst,color=blackcolor,$
                    position=[0.05+sx, 0.1+sy, 0.85, 0.95], /noerase

  if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
    color=blackcolor

  if keyword_set(ps) then begin
    device, /close
    tox
  endif

  !p.multi=[0,1,1]

endif

;--------------------------------------------------------------------;
return
end
