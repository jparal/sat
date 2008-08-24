pro pl_fig3d, $
  dataxy=dataxy, dataxz=dataxz, datayz=datayz, $
  dx=dx, dy=dy, dz=dz, $
  x0xy=x0xy, y0xy=y0xy, x0xz=x0xz, z0xz=z0xz, y0yz=y0yz, z0yz=z0yz, $
  radius=radius, $
  minx=minx, maxx=maxx, miny=miny, maxy=maxy, $
  minz=minz, maxz=maxz, mina=mina, maxa=maxa, $
  ps=ps, draw_planet=draw_planet, $
  colortable=colortable, blackcolor=blackcolor, $
  allow_negative=allow_negative, $
  draw_labels=draw_labels, vertically=vertically, $
  debug=debug, $
  dsvec=dsvec, maxlen=maxlen, len=len, hsize=hsize, $
  poster_vec=poster_vec,entity=entity

;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING PLANETARY DATA FROM 3D SIMULATIONS    ;
;                                                                    ;
; This routine produces up to three plots, so appart from "pl_fig2d" ;
; user can determine whether these plots shall be organized          ;
; vertically rather than horizontally (default), and whether the     ;
; plots shall be labeled by a), b) c).                               ;
;                                                                    ;
; !!! IF IDL HAS NOT OPENED ANY WINDOW, CALLER MUST USE "wset, 0"    ;
; !!! PRIOR THIS PROCEDURE SO THE PLOT POSITIONING IS DERIVED        ;
; !!! PROPERLY.                                                      ;
;                                                                    ;
; Developed for analysis of 3D Mercury/Enceladus simulations.        ;
;                                                                    ;
; EXAMPLE 1:                                                         ;
;                                                                    ;
;   IDL> rd,'Dn*i0.gz',dn                                            ;
;   IDL> pl_fig3d, dn, /plotxy, /plotxz, /plotyz                     ;
;                                                                    ;
; EXAMPLE 2:                                                         ;
;                                                                    ;
;   IDL> rd,'Dn*i0.gz',dn                                            ;
;   IDL> pl_fig3d,dn,/plotxy,/plotxz,/plotyz,dx=0.15,dy=0.15, $      ;
;        dz=0.15,xc=0.3,colortable=13,/draw_planet,radius=1.25, $    ;
;        maxa=1.3                                                    ;
;                                                                    ;
; TODO:                                                              ;
;                                                                    ;
; - Make colorbar plot optional                                      ;
; - In some cases Z-axis between (x,z) and (y,z) cut can be not      ;
;   compatible. This plotter should allow, that in certain cases     ;
;   one does not share z-axis between these plots.                   ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 02/2007, v.0.5.29: In the old version there was a separate       ;
;   script to plot vector data. Now we want to merge features        ;
;   for plotting of vectorized data into this (single) script.       ;
; - 02/2007, v.0.5.29: Started again. Former version can be found    ;
;   as "pl_fig3d_OLD.pro" subroutine. Horizontal plotting almost     ;
;   works for misc combos of chosen plot planes.                     ;
; - 11/2006, v.0.4.144: Development (temporarily ?) stoped.          ;
;--------------------------------------------------------------------;

;====================================================================;
; 1) CHECK INPUT PARAMETERS                                          ;
;====================================================================;
; a) By default we "do not use any plot" and all data are assumed    ;
;    to be scalar arrays.                                            ;
;--------------------------------------------------------------------;
use_xy=0
use_xz=0
use_yz=0
vdata_xy=0  ; 0 if corresponding data is scalar, 1 if it is a vector
vdata_xz=0
vdata_yz=0

if stw_keyword_set(poster_vec) then pvec=1 else pvec=0
if not(stw_keyword_set(entity)) then entity='' else entity=string(entity)

;-----------------------------------------------------;
; b) Check dimensionality and availability of data.   ;
;    Determine, whether they are used and whether     ;
;    they are scalar or vector arrays.                ;
;-----------------------------------------------------;
if stw_keyword_set(dataxy) then begin
  use_xy=1
  size_xy=size(dataxy,/TYPE)
  if (size_xy eq 0) then return
  size_xy=size(dataxy)
  if (size_xy(0) ne 2) then begin
    if ((size_xy(0) eq 3) and (size_xy(3) eq 3)) then vdata_xy=1 $
                                                 else return
  endif
endif
if stw_keyword_set(dataxz) then begin
  use_xz=1
  size_xz=size(dataxz,/TYPE)
  if (size_xz eq 0) then return
  size_xz=size(dataxz)
  if (size_xz(0) ne 2) then begin
    if ((size_xz(0) eq 3) and (size_xz(3) eq 3)) then vdata_xz=1 $
                                                 else return
  endif
endif
if stw_keyword_set(datayz) then begin
  use_yz=1
  size_yz=size(datayz,/TYPE)
  if (size_yz eq 0) then return
  size_yz=size(datayz)
  if (size_yz(0) ne 2) then begin
    if ((size_yz(0) eq 3) and (size_yz(3) eq 3)) then vdata_yz=1 $
                                                 else return
  endif
endif

;----------------------------------------------------------------;
; Now we know, which data are available and for each data set    ;
; we know, whether it is a scalar or vector array.               ;
;                                                                ;
; We use IDL's "keyword_set" for purpose. If debug=0 only IDL's  ;
; "keyword_set" recognizes this case as debug would not be set!  ;
; We want to be able switch off debugging by setting debug to 0. ;
;----------------------------------------------------------------;
if keyword_set(debug) then begin
  print, strcompress('pl_fig3d: use = ('+string(use_xy)+', '+ $
         string(use_xz)+', '+string(use_yz)+')')
  print, 'pl_fig3d: pass 1'
endif

;====================================================================;
; 2) FIX PARAMETERS NEEDED FOR PLOTTING                              ;
;====================================================================;
if not(stw_keyword_set(radius)) then radius=1.0

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0

;--------------------------------------------------------------------;
; DEFINE SIZE(S) OF PLOTS IN PHYSICAL UNITS OF DATA                  ;
; a) Define vertical and horizontal axises for each plot             ;
;--------------------------------------------------------------------;
if (use_xy) then begin
  lx_xy = (size_xy(1)-1)*dx
  ly_xy = (size_xy(2)-1)*dy
  if not(stw_keyword_set(x0xy)) then x0xy=0.5*lx_xy
  if not(stw_keyword_set(y0xy)) then y0xy=0.5*ly_xy
  ix_xy = (findgen(size_xy(1))*dx - x0xy) / radius
  iy_xy = (findgen(size_xy(2))*dy - y0xy) / radius
endif
if (use_xz) then begin
  lx_xz = (size_xz(1)-1)*dx
  lz_xz = (size_xz(2)-1)*dz
  if not(stw_keyword_set(x0xz)) then x0xz=0.5*lx_xz
  if not(stw_keyword_set(z0xz)) then z0xz=0.5*lz_xz
  ix_xz = (findgen(size_xz(1))*dx - x0xz) / radius
  iz_xz = (findgen(size_xz(2))*dz - z0xz) / radius
endif
if (use_yz) then begin
  ly_yz = (size_yz(1)-1)*dy
  lz_yz = (size_yz(2)-1)*dz
  if not(stw_keyword_set(y0yz)) then y0yz=0.5*ly_yz
  if not(stw_keyword_set(z0yz)) then z0yz=0.5*lz_yz
  iy_yz = (findgen(size_yz(1))*dy - y0yz) / radius
  iz_yz = (findgen(size_yz(2))*dz - z0yz) / radius
endif

;--------------------------------------------------------------------;
; b) Define min/max combos for                                       ;
;    vertical/horizontal axis of each plot                           ;
;--------------------------------------------------------------------;
minx_xy=0 & maxx_xy=0   &   miny_xy=0 & maxy_xy=0
minx_xz=0 & maxx_xz=0   &   minz_xz=0 & maxz_xz=0
miny_yz=0 & maxy_yz=0   &   minz_yz=0 & maxz_yz=0

if (use_xy) then begin
  if stw_keyword_set(minx) then minx_xy=minx else minx_xy=ix_xy(0)
  if stw_keyword_set(maxx) then maxx_xy=maxx else maxx_xy=ix_xy(size_xy(1)-1)
  if stw_keyword_set(miny) then miny_xy=miny else miny_xy=iy_xy(0)
  if stw_keyword_set(maxy) then maxy_xy=maxy else maxy_xy=iy_xy(size_xy(2)-1)
endif
if (use_xz) then begin
  if stw_keyword_set(minx) then minx_xz=minx else minx_xz=ix_xz(0)
  if stw_keyword_set(maxx) then maxx_xz=maxx else maxx_xz=ix_xz(size_xz(1)-1)
  if stw_keyword_set(minz) then minz_xz=minz else minz_xz=iz_xz(0)
  if stw_keyword_set(maxz) then maxz_xz=maxz else maxz_xz=iz_xz(size_xz(2)-1)
endif
if (use_yz) then begin
  if stw_keyword_set(miny) then miny_yz=miny else miny_yz=iy_yz(0)
  if stw_keyword_set(maxy) then maxy_yz=maxy else maxy_yz=iy_yz(size_yz(1)-1)
  if stw_keyword_set(minz) then minz_yz=minz else minz_yz=iz_yz(0)
  if stw_keyword_set(maxz) then maxz_yz=maxz else maxz_yz=iz_yz(size_yz(2)-1)
endif

;--------------------------------------------------------------------;
; c) Define min/max combos for the color scaled axis which           ;
;    shall be common for all plots in this version of                ;
;    "pl_fig3d".                                                     ;
;--------------------------------------------------------------------;
if (use_xy and vdata_xy) then begin
  amp_xy=sqrt(dataxy(*,*,0)^2+dataxy(*,*,1)^2+dataxy(*,*,2)^2)
endif
if (use_xz and vdata_xz) then begin
  amp_xz=sqrt(dataxz(*,*,0)^2+dataxz(*,*,1)^2+dataxz(*,*,2)^2)
endif
if (use_yz and vdata_yz) then begin
  amp_yz=sqrt(datayz(*,*,0)^2+datayz(*,*,1)^2+datayz(*,*,2)^2)
endif

if not(stw_keyword_set(mina)) then begin
  mina=0.0
  if (use_xy) then begin
    if (vdata_xy) then min_xy=min(amp_xy) else min_xy=min(dataxy)
  endif
  if (use_xz) then begin
    if (vdata_xz) then min_xz=min(amp_xz) else min_xz=min(dataxz)
  endif
  if (use_yz) then begin
    if (vdata_yz) then min_yz=min(amp_yz) else min_yz=min(datayz)
  endif
  if (use_xy) then mina=min_xy
  if (use_xz) then mina=min_xz
  if (use_yz) then mina=min_yz
  if (use_xy) then if (min_xy lt mina) then mina=min_xy
  if (use_xz) then if (min_xz lt mina) then mina=min_xz
  if (use_yz) then if (min_yz lt mina) then mina=min_yz
endif
if not(stw_keyword_set(maxa)) then begin
  maxa=1.0
  if (use_xy) then begin
    if (vdata_xy) then max_xy=max(amp_xy) else max_xy=max(dataxy)
  endif
  if (use_xz) then begin
    if (vdata_xz) then max_xz=max(amp_xz) else max_xz=max(dataxz)
  endif
  if (use_yz) then begin
    if (vdata_yz) then max_yz=max(amp_yz) else max_yz=max(datayz)
  endif
  if (use_xy) then maxa=max_xy
  if (use_xz) then maxa=max_xz
  if (use_yz) then maxa=max_yz
  if (use_xy) then if (max_xy gt maxa) then maxa=max_xy
  if (use_xz) then if (max_xz gt maxa) then maxa=max_xz
  if (use_yz) then if (max_yz gt maxa) then maxa=max_yz
endif

;----------------------------------------------------;
; Once limits are set we shall also limit the data.  ;
; PS output screews up otherwise.                    ;
;----------------------------------------------------;
if (use_xy) then begin
  if (vdata_xy) then begin
    if (pvec) then begin
      stw_minval_set, dataxy, mina, replval=0.0
    endif else begin
      stw_minval_set, dataxy, mina, srcdata=amp_xy, replval=0.0
    endelse
    stw_minval_set, amp_xy, mina 
  endif else begin
    stw_minval_set, dataxy, mina
  endelse
endif
if (use_xz) then begin
  if (vdata_xz) then begin
    if (pvec) then begin
      stw_minval_set, dataxz, mina, replval=0.0
    endif else begin
      stw_minval_set, dataxz, mina, srcdata=amp_xz, replval=0.0
    endelse
    stw_minval_set, amp_xz, mina 
  endif else begin
    stw_minval_set, dataxz, mina
  endelse
endif
if (use_yz) then begin
  if (vdata_yz) then begin
    if (pvec) then begin
      stw_minval_set, datayz, mina, replval=0.0
    endif else begin
      stw_minval_set, datayz, mina, srcdata=amp_yz, replval=0.0
    endelse
    stw_minval_set, amp_yz, mina 
  endif else begin
    stw_minval_set, datayz, mina
  endelse
endif

if keyword_set(debug) then begin
  print, 'pl_fig3d: pass 2 ', mina, maxa
endif

;--------------------------------------------------------------------;
; 3) PRODUCE DATA FOR THE OVERPLOT OF PLANET                         ;
;--------------------------------------------------------------------;
imi=findgen(1001)/1000*!pi*2
imx=1.0*sin(imi)
imy=1.0*cos(imi)

if keyword_set(debug) then begin
  print, 'pl_fig3d: pass 3'
endif

;--------------------------------------------------------------------;
; 4) PREPARE PLOT                                                    ;
;                                                                    ;
;    "tops" must (!) be called prior we calculate all positioning    ;
;    of plots. "tops" activates PS device and its vertical and       ;
;    horizontal sizes are used when "pos" arrays are calculated.     ;
;    This assures, that plot will look the same way in PS file as    ;
;    it looks on the screen (I mean it will have the same aspect     ;
;    ratio).                                                         ;
;--------------------------------------------------------------------;
if stw_keyword_set(ps) then begin
  tops,/col,file=ps,/land
endif

!x.margin=[2.,2.]

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

if keyword_set(debug) then begin
  print, 'pl_fig3d: pass 4'
endif

;--------------------------------------------------------------------;
; 3-DIMENSIONAL DATA - produce up to three plots                     ;
;                                                                    ;
; So we need more preparation for the plotting than in the           ;
; "pl_fig2d".                                                        ;
;--------------------------------------------------------------------;
ilabel=0
label=['aa','bb','cc']

nofplots=0
if (use_xz) then nofplots=nofplots+1
if (use_xy) then nofplots=nofplots+1
if (use_yz) then nofplots=nofplots+1

if (nofplots le 0) then return

if stw_keyword_set(vertically) then begin
  !p.multi=[0,1,nofplots]
endif else begin
  !p.multi=[0,nofplots,1]
endelse

none=replicate(' ',30)

iplot=0
remplots=nofplots

pl_fig3d_pos_get, $
  lx_xy=(maxx_xy-minx_xy), ly_xy=(maxy_xy-miny_xy), $
  lx_xz=(maxx_xz-minx_xz), lz_xz=(maxz_xz-minz_xz), $
  ly_yz=(maxy_yz-miny_yz), lz_yz=(maxz_yz-minz_yz), $
  posxy=posxy, posxz=posxz, posyz=posyz, poscb=poscb, $
  vertically=vertically,debug=debug

if stw_keyword_set(vertically) then begin

  print, 'NOT IMPLEMENTED'

endif else begin

  ;------------------------------------------------;
  ; HORIZINTALLY: PLOT (X,Y) PLANE AS FIRST ONE    ;
  ;------------------------------------------------;
  if (use_xy) then begin

    xout = minx_xy + (maxx_xy-minx_xy)/50.0
    yout = maxy_xy - (maxy_xy-miny_xy)/5.0

    if (vdata_xy eq 0) then begin
      contour, dataxy, ix_xy, iy_xy,$
      nlev=nle, /fill, lev=lev, $
      xrange=[minx_xy,maxx_xy],yrange=[miny_xy,maxy_xy], $
      zrange=[mina,maxa],$
      xtitle='xx',ytitle='yy', xtickformat='pl_xticks',$
      /xst,/yst,/zst,$
      position=posxy
    endif
    if (vdata_xy eq 1) then begin
      if (pvec) then poster=dataxy(*,*,2) else poster=amp_xy
      stw_contour_vect, poster, dataxy(*,*,0), dataxy(*,*,1), $
      ix_xy, iy_xy,$
      nlev=nle, /fill, lev=lev, $
      xrange=[minx_xy,maxx_xy],yrange=[miny_xy,maxy_xy], $
      zrange=[mina,maxa],$
      xtitle='xx',ytitle='yy', xtickformat='pl_xticks',$
      /xst,/yst,/zst,$
      position=posxy, $
      dsvec=dsvec, maxlen=maxlen, len=len, hsize=hsize, $
      color=blackcolor
    endif

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor

    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    remplots=remplots-1
    iplot=iplot+1

  endif ; PLOT (X,Y) ENDS HERE

  ;---------------------;
  ; PLOT (X,Z) PLANE    ;
  ;---------------------;
  if (use_xz) then begin

    xout = minx_xz + (maxx_xz-minx_xz)/50.0
    yout = maxz_xz - (maxz_xz-minz_xz)/5.0

    if (vdata_xz eq 0) then begin
      contour, dataxz, ix_xz, iz_xz,$
      nlev=nle, /fill, lev=lev, $
      xrange=[minx_xz,maxx_xz],yrange=[minz_xz,maxz_xz], $
      zrange=[mina,maxa],$
      xtitle='xx',ytitle='zz', xtickformat='pl_xticks',$
      /xst,/yst,/zst,$
      position=posxz
    endif
    if (vdata_xz eq 1) then begin
      if (pvec) then poster=dataxz(*,*,1) else poster=amp_xz
      stw_contour_vect, poster, dataxz(*,*,0), dataxz(*,*,2), $
      ix_xz, iz_xz,$
      nlev=nle, /fill, lev=lev, $
      xrange=[minx_xz,maxx_xz],yrange=[minz_xz,maxz_xz], $
      zrange=[mina,maxa],$
      xtitle='xx',ytitle='zz', xtickformat='pl_xticks',$
      /xst,/yst,/zst,$
      position=posxz, $
      dsvec=dsvec, maxlen=maxlen, len=len, hsize=hsize, $
      color=blackcolor
    endif

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor

    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

    remplots=remplots-1
    iplot=iplot+1

  endif ; PLOT (X,Z) ENDS HERE

  ;---------------------;
  ; PLOT (Y,Z) PLANE    ;
  ;---------------------;
  if (use_yz) then begin

    xout = miny_yz + (maxy_yz-miny_yz)/50.0
    yout = maxz_yz - (maxz_yz-minz_yz)/5.0

    if (vdata_yz eq 0) then begin
      contour, datayz, iy_yz, iz_yz,$
      nlev=nle, /fill, lev=lev, $
      xrange=[miny_yz,maxy_yz],yrange=[minz_yz,maxz_yz], $
      zrange=[mina,maxa],$
      xtitle='yy',ytickname=none, $
      /xst,/yst,/zst,$
      position=posyz
    endif
    if (vdata_yz eq 1) then begin
      if (pvec) then poster=datayz(*,*,0) else poster=amp_yz
      stw_contour_vect, poster, datayz(*,*,1), datayz(*,*,2), $
      iy_yz, iz_yz,$
      nlev=nle, /fill, lev=lev, $
      xrange=[miny_yz,maxy_yz],yrange=[minz_yz,maxz_yz], $
      zrange=[mina,maxa],$
      xtitle='yy', ytickname=none, $
      /xst,/yst,/zst,$
      position=posyz, $
      dsvec=dsvec, maxlen=maxlen, len=len, hsize=hsize, $
      color=blackcolor
    endif

    if keyword_set(draw_planet) then polyfill,imx,imy,/data,$
      color=blackcolor

    if keyword_set(draw_labels) then begin
      xyouts,xout,yout,label(ilabel),charsize=5
      ilabel=ilabel+1
    endif

  endif ; PLOT (Y,Z) ENDS HERE

  ;----------------------------------------------------;
  ; PLOT COLOR BAR                                     ;
  ;                                                    ;
  ; For certain entities, like the temperature,        ;
  ; do not plot negative portion of the scale.         ;
  ; Hence yra=[0.0,maxa] rather than yra=[mina,maxa].  ;
  ; We use negative mina oftenly to shift the color    ;
  ; scale by the given offset.                         ;
  ;----------------------------------------------------;
  if (stw_keyword_set(allow_negative) or mina > 0. or (pvec)) then begin
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[mina,maxa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=poscb, xtickname=none,/noerase, ytitle=entity
  endif else begin
    contour,aa, [0,1,2],lev, lev=lev,xra=[0,1],yra=[0.0,maxa], $
    /xst,/yst,/zst, nlev=nle,/fill,$
    position=poscb, xtickname=none,/noerase, ytitle=entity
  endelse

endelse

if keyword_set(ps) then begin
  device, /close
  tox
endif

;--------------------------------------------------------------------;
return
end
