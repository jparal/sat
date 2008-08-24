;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING PLANETARY DATA FROM 2D SIMULATIONS    ;
;                                                                    ;
; Primarily developed for analysis of 2D Enceadus simulations.       ;
;                                                                    ;
; EXAMPLES:                                                          ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 09/2006, v.0.4.143: lx=(ss(*)-1)*dx rather than lx=ss(*)*dx.     ;
;   (fixed).                                                         ;
; - 09/2006, v.0.4.141: Converting from "pl_fig2d.pro" into          ;
;   "pl_fig3d.pro".                                                  ;
; - 28/08/2006, v.0.4.141: Cloned/extracted from "pl_figani.pro".    ;
;--------------------------------------------------------------------;
pro plt_2d, data, DX=dx, DY=dy, INFO=info, PS=ps, OPLOT=oplot, $
            RX=rx, RY=ry, AXISSCALE=axisscale, $
            XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange,$
            XMIN=xmin, XMAX=xmax, YMIN=ymin, YMAX=ymax, ZMIN=zmin, ZMAX=zmax, $
            CTABLE=ctable, CTLOW=ctlow, CTHIGH=cthigh, CTGAMMA=ctgamma, $
            COLOR=color, DRAW_PLANET=draw_planet, DRAW_SCALE=draw_scale,$
            ALLOW_NEGATIVE = allow_negative, REVERSE_XAXIS = reverse_xaxis, $
            XTITLE    = xtitle,    YTITLE     = ytitle,     LABEL = label, $
            XNOTICKS  = xnoticks,  YNOTICKS   = ynoticks, $
            TRAJVERT  = trajvert,  TRAJPOINTS = trajpoints, $
            TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
            TRAJSTYLE = trajstyle

  

;--------------------------------------------------------------------;
; 1) CHECK INPUT PARAMETERS                                          ;
;                                                                    ;
; Make sure, that the data is a three dimensional array.             ;
;--------------------------------------------------------------------;
ss=size(data,/TYPE)
if (ss eq 0) then return
ss=size(data)
if (ss(0) ne 2) then return

;--------------------------------------------------------------------;
; 2) FIX PARAMETERS NEEDED FOR PLOTTING                              ;
;--------------------------------------------------------------------;
if not(keyword_set(axisscale)) then axisscale=1.0

if not(keyword_set(dx)) then dx=1.0
if not(keyword_set(dy)) then dy=1.0

if not(keyword_set(rx)) then rx=0.5
if not(keyword_set(ry)) then ry=0.5

;--------------------------------------------------------------------;
lx=(ss(1)-1)*dx
ly=(ss(2)-1)*dy

ix=(findgen(ss(1))*dx-rx*lx)/axisscale
iy=(findgen(ss(2))*dy-ry*ly)/axisscale

if not(keyword_set(xmin)) then xmin=ix(0)
if not(keyword_set(xmax)) then xmax=ix(ss(1)-1)
if not(keyword_set(ymin)) then ymin=iy(0)
if not(keyword_set(ymax)) then ymax=iy(ss(2)-1)
if not(keyword_set(zmin)) then zmin=min(data)
if not(keyword_set(zmax)) then zmax=max(data)

if keyword_set(xrange) then begin
   UTL_CHECK_SIZE, xrange, ss=[1,2]
   xmin = xrange(0)
   xmax = xrange(1)
endif
if keyword_set(yrange) then begin
   UTL_CHECK_SIZE, yrange, ss=[1,2]
   ymin = yrange(0)
   ymax = yrange(1)
endif
if keyword_set(zrange) then begin
   UTL_CHECK_SIZE, yrange, ss=[1,2]
   zmin = zrange(0)
   zmax = zrange(1)
endif


dataloc=data

ndx=where(data gt zmax, cnt)
sn=size(ndx)
if (sn(0) ne 0) then begin
  dataloc(ndx)=zmax
endif
ndx=where(data lt zmin, cnt)
sn=size(ndx)
if (sn(0) ne 0) then begin
  dataloc(ndx)=zmin
endif

;--------------------------------------------------------------------;
; 3) PRODUCE DATA FOR THE OVERPLOT OF PLANET                         ;
;--------------------------------------------------------------------;
if not(keyword_set(draw_planet)) then draw_planet=0.
imi=findgen(1001)/1000*!pi*2
imx=draw_planet*sin(imi)
imy=draw_planet*cos(imi)

;--------------------------------------------------------------------;
; 4) PREPARE PLOT                                                    ;
;--------------------------------------------------------------------;
!x.margin=[4.,2.]

!p.font=0
!p.charsize=2
!p.background=0
!p.thick=2

if not(keyword_set(ctable)) then ctable=0
if not(keyword_set(color)) then color=0
if not(keyword_set(ctlow)) then ctlow=0
if not(keyword_set(cthigh)) then cthigh=255
if not(keyword_set(ctgamma)) then ctgamma=1.

nle=50
lev = zmin + findgen(nle) * ((zmax-zmin)/(nle-1))

aa=fltarr(3,nle)
aa(0,*)=lev
aa(1,*)=lev
aa(2,*)=lev

;--------------------------------------------------------------------;
; 2-DIMENSIONAL DATA - single plot                                   ;
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
  ;   tall and we have to insert it to a thinner are, than it      ;
  ;   would be done by default => we have to add offset sx.        ;
  ;   => sx = this what we have to cut out at left side to         ;
  ;      keep aspect.                                              ;
  ; - If the aspect ration is > 1, the plot is wide and we have    ;
  ;   to cut it at its bottom to keep the proper aspect ratio      ;
  ;   on the plot.                                                 ;
  ;----------------------------------------------------------------;
  plotr=(0.85-0.05)/(0.95-0.1)
  datar=(xmax-xmin)/(ymax-ymin)

  aspect=datar*plotr*0.9  ; 0.9 is an ad hoc correction which works

  sx=0.0
  sy=0.0

  if (aspect lt 1.0) then sx=(0.85-0.05) - (0.85-0.05)*aspect
  if (aspect gt 1.0) then sy=(0.95-0.1) - (0.9-0.1)/aspect

  if keyword_set(ps) then tops,/col,file=ps,/land

  !p.multi=[0,1,1]
  gg=replicate(' ',30)

  IF keyword_set(xnoticks) THEN xtickname=gg
  IF keyword_set(ynoticks) THEN ytickname=gg
  IF (N_ELEMENTS(reverse_xaxis) NE 0) THEN xtickformat='pl_xticks'

  IF (N_ELEMENTS(oplot) NE 0) THEN BEGIN
     xtickname=gg
     ytickname=gg
  ENDIF

  loadct, ctable, /SILENT
  stretch, ctlow, cthigh, ctgamma
  contour, dataloc, ix, iy,$
           nlev=nle, /fill, lev=lev, $
           xrange=[xmin,xmax],yrange=[ymin,ymax],zrange=[zmin,zmax],$
           /xst,/yst,/zst,/data, xtickname=gg, ytickname=gg, $
           position=[0.05+sx, 0.1+sy, 0.85, 0.95], noerase=oplot


  IF KEYWORD_SET(trajvert) THEN BEGIN
     loadct, 0, /SILENT
     OPLOT, trajvert(0,*), trajvert(1,*), COLOR=trajcolor, $
            THICK=trajthick, LINESTYLE=trajstyle
  ENDIF
  IF KEYWORD_SET(trajpoints) THEN BEGIN
     loadct, 0, /SILENT
     contour, trajpoints, ix, iy,$
              nlev=nle, /fill, lev=1, color=0, $
              xrange=[xmin,xmax],yrange=[ymin,ymax],zrange=[zmin,zmax],$
              /xst,/yst,/zst,/data, xtickname=gg, ytickname=gg, $
              position=[0.05+sx, 0.1+sy, 0.85, 0.95], /noerase, /overplot
  ENDIF

  loadct, 0, /SILENT
  contour, dataloc, ix, iy,$
           nlev=nle, /fill, lev=lev, $
           xrange=[xmin,xmax],yrange=[ymin,ymax],zrange=[zmin,zmax],$
           xtitle=xtitle, xtickname=xtickname, xtickformat=xtickformat, $
           ytitle=ytitle, ytickname=ytickname, $
           /xst,/yst,/zst,/nodata,/noerase, color=0, $
           position=[0.05+sx, 0.1+sy, 0.85, 0.95]

  IF KEYWORD_SET(draw_planet) THEN BEGIN
     LOADCT, 0, /SILENT
     POLYFILL,imx,imy, /DATA, COLOR=0
  ENDIF

  ;----------------------------------------------------;
  ; For certain entities, like the temperature,        ;
  ; do not plot negative portion of the scale.         ;
  ; Hence yra=[0.0,zmax] rather than yra=[zmin,zmax].  ;
  ; We use negative zmin oftenly to shift the color    ;
  ; scale by the given offset.                         ;
  ;----------------------------------------------------;
  if not(keyword_set(allow_negative)) then begin
    if (zmin lt 0.0) then zmin = 0.0
  endif

  if (keyword_set(draw_scale) and not(keyword_set(oplot)))then begin
     loadct, ctable, /SILENT
     stretch, ctlow, cthigh, ctgamma
     contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[zmin,zmax], $
             /xst,/yst,/zst, nlev=nle,/fill, /data, $
             position=[0.95, 0.1+sy, 0.99, .95], $
             xtickname=gg, ytickname=gg, /noerase
     loadct, 0, /SILENT
     contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[zmin,zmax], $
             /xst,/yst,/zst, nlev=nle,/fill,color=0,/nodata, $
             position=[0.95, 0.1+sy, 0.99, .95], $
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
