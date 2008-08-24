pro pl_fig3d_pos_get, $
  posxy=posxy, posxz=posxz, posyz=posyz, poscb=poscb, $
  lx_xy=lx_xy, ly_xy=ly_xy, $
  lx_xz=lx_xz, lz_xz=lz_xz, $
  ly_yz=ly_yz, lz_yz=lz_yz, $
  vertically=vertically,debug=debug

;--------------------------------------------------------------------;
; CALCULATE POS ARRAYS FOR PLOTTING OF UP TO 3 CUTS FROM A 3D        ;
; SIMULATIONS WITH AN AUTOMATIC ASPECT ADJUSTMENT.                   ;
;                                                                    ;
; + xydata, xzdata, yzdata - if one of these is not set, then user   ;
;   does not require corresponding plot.                             ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 02/2007, v.0.5.29: Development of "pl_fig3d" has been suspended  ;
;   in v.0.4.144. Now we continue with a new approach. Horizontal    ;
;   plotting almost works. Now: when plotting to a postscript file   ;
;   the result has a proper aspect, however it has no proper layout  ;
;   spacing.                                                         ;
;--------------------------------------------------------------------;

;--------------------------------------------------------------------;
; 1) CHECK INPUT PARAMETERS                                          ;
;                                                                    ;
;    Check here, whether the input parameters are compatible.        ;
;    (TODO)                                                          ;
;--------------------------------------------------------------------;
posxy=fltarr(4)
posxz=fltarr(4)
posyz=fltarr(4)
poscb=fltarr(4)

if (lx_xy ne 0 and ly_xy ne 0) then use_xy=1 else use_xy=0
if (lx_xz ne 0 and lz_xz ne 0) then use_xz=1 else use_xz=0
if (ly_yz ne 0 and lz_yz ne 0) then use_yz=1 else use_yz=0
use_cb=1

;--------------------------------------------------------------------;
; 1) INITIALIZE DEFAULTS                                             ;
;                                                                    ;
;    Introduce parameters and set their add hoc default parameters   ;
;    so they have defined values.                                    ;
;                                                                    ;
;    (w_??plot,h_??plot) - contain data-arrea sizes in physical      ;
;                          units.                                    ;
;    (w_??plot_add,h_??plot_add) - contain layout-sizes (sizes of    ;
;                          margins. ticks, plot separations etc.)    ;
;                          in relative units.                        ;
;--------------------------------------------------------------------;
w_xyplot = lx_xy
w_xzplot = lx_xz
w_yzplot = ly_yz
h_xyplot = ly_xy
h_xzplot = lz_xz
h_yzplot = lz_yz

w_xyplot_add = 0.0       ; Sum of all margins betwin the plots
w_xzplot_add = 0.0
w_yzplot_add = 0.0
h_xyplot_add = 0.0       ; Sum of all margins betwin the plots
h_xzplot_add = 0.0
h_yzplot_add = 0.0

;--------------------------------------------------------------------;
; 1a) SET UP DEV <-> REL COORDINATES MAPPING HERE                    ;
;                                                                    ;
;     Device is mapped via 1.0x1.0 area in relative units. This      ;
;     1x1 rectangle is deformed by device to the area:               ;
;     - w_dev, h_dev                                                 ;
;     We define transforming coefficients:                           ;
;     - cw_reltodev, ch_reltodev                                     ;
;     - cw_devtorel, ch_devtorel                                     ;
;     for the transformation of lengths between these systems. This  ;
;     allows us to neutralize device's own aspect latter             ;
;--------------------------------------------------------------------;
h_dev = float(!d.y_vsize)
w_dev = float(!d.x_vsize)

if keyword_set(debug) then begin
  print, 'pl_fig3d_pos_get: -----------------------------------------'
  print, strcompress('pl_fig3d_pos_get: DEVICE PARAMETERS: A=H/W: '+ $
         string(h_dev/w_dev)+' ='+string(h_dev)+' /'+string(w_dev))
  print, 'pl_fig3d_pos_get: (IDLS DEFAULT 0.8 = 512.0 / 640.0)'
endif

cw_reltodev=w_dev
ch_reltodev=h_dev
cw_devtorel=1.0/w_dev
ch_devtorel=1.0/h_dev

if keyword_set(debug) then begin
  print, strcompress('pl_fig3d_pos_get: cw_reltodev/ch_reltodev=: '+ $
         string(cw_reltodev)+' /'+string(ch_reltodev))
  print, strcompress('pl_fig3d_pos_get: cw_devtorel/ch_devtorel=: '+ $
         string(cw_devtorel)+' /'+string(ch_devtorel))
endif

;--------------------------------------------------------------------;
; FURTHER LAYOUT CONSTANTS:                                          ;
;                                                                    ;
; - w_ytick_dev, h_xtick_dev                                         ;
; - w_ytick_rel, h_xtick_rel                                         ;
; - w_sep_dev, h_sep_dev                                             ;
; - w_sep_rel, h_xtick_rel                                           ;
; - w_cb_dev                                                         ;
; - w_cb_rel                                                         ;
;--------------------------------------------------------------------;
w_ytick_idlwindow_dev = 40.0
h_xtick_idlwindow_dev = 36.0
w_ytick_dev = w_ytick_idlwindow_dev / 640.0 * w_dev
h_xtick_dev = h_xtick_idlwindow_dev / 512.0 * h_dev
w_ytick_rel = cw_devtorel * w_ytick_dev
h_xtick_rel = ch_devtorel * h_xtick_dev

w_sep_idlwindow_dev = 5.0
h_sep_idlwindow_dev = 5.0
w_sep_dev = w_sep_idlwindow_dev / 640.0 * w_dev
h_sep_dev = h_sep_idlwindow_dev / 512.0 * h_dev
w_sep_rel = cw_devtorel * w_sep_dev
h_sep_rel = ch_devtorel * h_sep_dev

w_cb_idl_dev = 15.0
w_cb_dev = w_cb_idl_dev / 640.0 * w_dev
w_cb_rel = cw_devtorel * w_cb_dev

;--------------------------------------------------------------------;
; 2) CALCULATE SIZE(S) OF PLOTS (DATA AND LAYOUT)                    ;
;    (We assume horizontal arrangement for the moment!)              ;
;                                                                    ;
; + Data size(s) are in physical units:                              ;
;   - h_xyplot, w_xyplot                                             ;
;   - h_xzplot, w_xzplot                                             ;
;   - h_yzplot, w_yzplot                                             ;
; + Layout size(s) are in relative units:                            ;
;   - h_xyplot_add, w_xyplot_add                                     ;
;   - h_xzplot_add, w_xzplot_add                                     ;
;   - h_yzplot_add, w_yzplot_add                                     ;
;--------------------------------------------------------------------;
if keyword_set(debug) then begin
  print, 'pl_fig3d_pos_get: ========================================='
  print, 'pl_fig3d_pos_get: NOW ASSUMING HORIZONTAL PLOT:'
endif

if (use_xy) then begin

  w_xyplot_add = w_xyplot_add + w_ytick_rel
  w_xyplot_add = w_xyplot_add + w_sep_rel

  if (not(use_yz) and not(use_yz) and use_cb) then begin
    w_xyplot_add = w_xyplot_add + w_sep_rel + w_ytick_rel + w_cb_rel
  endif

endif

if (use_xz) then begin

  if (not(use_xz)) then begin
    w_xzplot_add = w_xzplot_add + w_ytick_rel
    w_xzplot_add = w_xzplot_add + w_sep_rel
  endif else begin
    w_xzplot_add = w_xzplot_add + w_ytick_rel
    w_xzplot_add = w_xzplot_add + w_sep_rel
    w_xzplot_add = w_xzplot_add + w_sep_rel
  endelse

  if (not(use_yz) and use_cb) then begin
    w_xzplot_add = w_xzplot_add + w_sep_rel + w_ytick_rel + w_cb_rel
  endif

endif

if (use_yz) then begin

  if (not(use_xz)) then begin
    w_yzplot_add = w_yzplot_add + w_ytick_rel
    w_yzplot_add = w_yzplot_add + w_sep_rel
  endif else begin
    ; we do not need to replot Z-axis
    w_yzplot_add = w_yzplot_add + w_sep_rel
  endelse

  if (use_cb) then begin
    w_yzplot_add = w_yzplot_add + w_sep_rel + w_ytick_rel + w_cb_rel
  endif

endif

h_plot_add = h_xtick_rel + h_sep_rel    ; Common value for all

;-------------------------------------;
; SUMMARY OUTPUT OF THE SECTION 2):   ;
;-------------------------------------;
if keyword_set(debug) then begin
  print, 'pl_fig3d_pos_get: -----------------------------------------'
  print, 'pl_fig3d_pos_get: DATA-ARREA SIZE(S) IN PHYSICAL UNITS'
  print, 'pl_fig3d_pos_get: (WE WANT TO KEEP THE ASPECT RATIO IN'
  print, 'pl_fig3d_pos_get:  PHYSICAL UNITS):'
  print, strcompress('pl_fig3d_pos_get: plot(X,Y) A=H/W: '+ $
         string(h_xyplot/w_xyplot)+ $
         ' ='+string(h_xyplot)+' /'+ string(w_xyplot))
  print, strcompress('pl_fig3d_pos_get: plot(X,Y) A=H/W: '+ $
         string(h_xzplot/w_xzplot)+ $
         ' ='+string(h_xzplot)+' /'+ string(w_xzplot))
  print, strcompress('pl_fig3d_pos_get: plot(X,Y) A=H/W: '+ $
         string(h_yzplot/w_yzplot)+ $
         ' ='+string(h_yzplot)+' /'+ string(w_yzplot))
  print, 'pl_fig3d_pos_get: -----------------------------------------'
  print, 'pl_fig3d_pos_get: LAYOUT (ADD) SIZE(S) IN RELATIVE UNITS'
  print, 'pl_fig3d_pos_get: (I.E. WHEN H/W = 1/1:)'
  print, 'pl_fig3d_pos_get: plot(X,Y) layout H/W:', $
         h_plot_add, w_xyplot_add
  print, 'pl_fig3d_pos_get: plot(X,Z) layout H/W:', $
         h_plot_add, w_xzplot_add
  print, 'pl_fig3d_pos_get: plot(Y,Z) layout H/W:', $
         h_plot_add, w_yzplot_add
endif

;--------------------------------------;
; DEFINE ADDITIONAL PARAMETERS:        ;
;                                      ;
; - w_total_rel, h_total_rel           ;
; - w_remain_rel, h_remain_rel         ;
;--------------------------------------;
w_total_rel = 1.0
h_total_rel = 1.0
w_remain_rel = w_total_rel - w_xyplot_add - w_xzplot_add - w_yzplot_add
h_remain_rel = 1.0 - h_plot_add

if keyword_set(debug) then begin
  print, strcompress('pl_fig3d_pos_get: Area available A=H/W: '+ $
         string(h_remain_rel/w_remain_rel)+' ='+ $
         string(h_remain_rel)+' /'+ $
         string(w_remain_rel))
  print, 'pl_fig3d_pos_get: (in relative units)'
  print, 'pl_fig3d_pos_get: -----------------------------------------'
  print, strcompress('pl_fig3d_pos_get: DEVICE PARAMETERS: A=H/W: '+ $
         string(h_dev/w_dev)+' ='+string(h_dev)+' /'+string(w_dev))
  print, 'pl_fig3d_pos_get: A < 1: MEANS DISPLAY WITH W > H'
  print, 'pl_fig3d_pos_get: A > 1: MEANS DISPLAY WITH W < H'
endif

;--------------------------------------;
; DEFINE ADDITIONAL PARAMETERS:        ;
;                                      ;
; - w_remain_dev, h_remain_dev         ;
;--------------------------------------;
h_remain_dev = h_dev * h_remain_rel
w_remain_dev = w_dev * w_remain_rel

if keyword_set(debug) then begin
  print, strcompress('pl_fig3d_pos_get: Area available A=H/W: '+ $
         string(h_remain_dev/w_remain_dev)+' ='+ $
         string(h_remain_dev)+ ' /' +$
         string(w_remain_dev))
  print, 'pl_fig3d_pos_get: (in device units)'
  print, 'pl_fig3d_pos_get: ========================================='
endif

;--------------------------------------------------------------------;
; - *_add - distances are in "relative units" of a display assumed   ;
;   to be 1x1 big.                                                   ;
;--------------------------------------------------------------------;
if keyword_set(debug) then begin
  print, 'pl_fig3d_pos_get: GET RESOLUTIONS (DATA PER PIXEL):'
endif

w_data = w_xyplot + w_xzplot + w_yzplot
h_data = h_xyplot
if (h_xzplot gt h_data) then h_data = h_xzplot
if (h_yzplot gt h_data) then h_data = h_yzplot
a_data = h_data / w_data

if keyword_set(debug) then begin
  print, strcompress('pl_fig3d_pos_get: a_data = h_data/w_data: '+ $
         string(a_data)+' ='+string(h_data)+' /'+string(w_data))
endif

w_res = w_data / w_remain_dev
h_res = h_data / h_remain_dev

if keyword_set(debug) then begin
  print, strcompress('pl_fig3d_pos_get: h_res = '+string(h_res))
  print, strcompress('pl_fig3d_pos_get: w_res = '+string(w_res))
  print, 'pl_fig3d_pos_get: (LESS DATA PER PIXEL MEANS THAT THE'
  print, 'pl_fig3d_pos_get: DIRECTION HAS A BETTER RESOLUTION)'
  print, 'pl_fig3d_pos_get: ========================================='
endif

;--------------------------------------------------------------------;
; OBTAIN POS ARRAYS                                                  ;
;--------------------------------------------------------------------;
if (h_res lt w_res) then begin

  if keyword_set(debug) then begin
    print, 'pl_fig3d_pos_get: (1) h_res < w_res'
    print, 'pl_fig3d_pos_get: (VERTICAL RESOLUTION IS BETTER)'
    print, 'pl_fig3d_pos_get: ---------------------------------------'
  endif

  ;----------------------------------------------------------------;
  ; Calculate data-arrea sizes in relative units. As w_res > h_res ;
  ; normalize everything with respect to the  H-data scale in      ;
  ; physical units.                                                ;
  ;----------------------------------------------------------------;
  w_xyplot_rel = w_xyplot / w_data * w_remain_rel
  w_xzplot_rel = w_xzplot / w_data * w_remain_rel
  w_yzplot_rel = w_yzplot / w_data * w_remain_rel

  h_xyplot_rel = h_xyplot / w_data * w_remain_rel
  h_xzplot_rel = h_xzplot / w_data * w_remain_rel
  h_yzplot_rel = h_yzplot / w_data * w_remain_rel

  ;---------------------------------------------------;
  ; Neutralize the influence of DEVICES own aspect    ;
  ;---------------------------------------------------;
  w_xyplot_dev = w_xyplot_rel
  w_xzplot_dev = w_xzplot_rel
  w_yzplot_dev = w_yzplot_rel

  h_xyplot_dev = h_xyplot_rel * (cw_reltodev / ch_reltodev)
  h_xzplot_dev = h_xzplot_rel * (cw_reltodev / ch_reltodev)
  h_yzplot_dev = h_yzplot_rel * (cw_reltodev / ch_reltodev)

endif else begin

  if keyword_set(debug) then begin
    print, 'pl_fig3d_pos_get: (2) h_res > w_res'
    print, 'pl_fig3d_pos_get: (HORIZONTAL RESOLUTION IS BETTER)'
    print, 'pl_fig3d_pos_get: ---------------------------------------'
  endif

  ;----------------------------------------------------------------;
  ; Calculate data-arrea sizes in relative units. As h_res > w_res ;
  ; normalize everything with respect to the  H-data scale in      ;
  ; physical units.                                                ;
  ;----------------------------------------------------------------;
  w_xyplot_rel = w_xyplot / h_data * h_remain_rel
  w_xzplot_rel = w_xzplot / h_data * h_remain_rel
  w_yzplot_rel = w_yzplot / h_data * h_remain_rel

  h_xyplot_rel = h_xyplot / h_data * h_remain_rel
  h_xzplot_rel = h_xzplot / h_data * h_remain_rel
  h_yzplot_rel = h_yzplot / h_data * h_remain_rel

  ;---------------------------------------------------;
  ; Neutralize the influence of DEVICES own aspect    ;
  ;---------------------------------------------------;
  w_xyplot_dev = w_xyplot_rel * (ch_reltodev / cw_reltodev)
  w_xzplot_dev = w_xzplot_rel * (ch_reltodev / cw_reltodev)
  w_yzplot_dev = w_yzplot_rel * (ch_reltodev / cw_reltodev)

  h_xyplot_dev = h_xyplot_rel
  h_xzplot_dev = h_xzplot_rel
  h_yzplot_dev = h_yzplot_rel

  if keyword_set(debug) then begin
    print, 'pl_fig3d_pos_get: DATA-ARREA SIZES IN THE RELATIVE UNITS'
    print, strcompress('pl_fig3d_pos_get: plot(X,Y) H/W: ' +$
           string(h_xyplot_rel)+' /'+string(w_xyplot_rel) )
    print, strcompress('pl_fig3d_pos_get: plot(X,Z) H/W: ' +$
           string(h_xzplot_rel)+' /'+string(w_xzplot_rel) )
    print, strcompress('pl_fig3d_pos_get: plot(Y,Z) H/W: ' +$
           string(h_yzplot_rel)+' /'+string(w_yzplot_rel) )
    print, 'pl_fig3d_pos_get: ---------------------------------------'
  endif

endelse

h_cb = h_xyplot_dev
if (h_cb lt h_xzplot_dev) then h_cb=h_xzplot_dev
if (h_cb lt h_yzplot_dev) then h_cb=h_yzplot_dev

if (use_xy) then begin
  posxy(0) = w_ytick_rel + w_sep_rel
  posxy(1) = h_xtick_rel + h_sep_rel
  posxy(2) = posxy(0) + w_xyplot_dev
  posxy(3) = posxy(1) + h_xyplot_dev
endif

if (use_xz) then begin
  posxz(0) = w_ytick_rel + w_sep_rel
  if (use_xy) then begin
    posxz(0) = posxy(2) + w_ytick_rel + w_sep_rel + w_sep_rel
  endif
  posxz(1) = h_xtick_rel + h_sep_rel
  posxz(2) = posxz(0) + w_xzplot_dev
  posxz(3) = posxz(1) + h_xzplot_dev
endif

if (use_xz) then begin
  posyz(0) = w_ytick_rel + w_sep_rel
  if (use_xy) then begin
    posyz(0) = posxy(2) + w_ytick_rel + w_sep_rel + w_sep_rel
  endif
  if (use_xz) then begin
    posyz(0) = posxz(2) + w_sep_rel
  endif
  posyz(1) = h_xtick_rel + h_sep_rel
  posyz(2) = posyz(0) + w_yzplot_dev
  posyz(3) = posyz(1) + h_yzplot_dev
endif

if (use_cb) then begin
  if (use_yz) then begin 
    poscb(0) = posyz(2) + w_ytick_rel + w_sep_rel
  endif
  if (not(use_yz) and (use_xz)) then begin
    poscb(0) = posxz(2) + w_ytick_rel + w_sep_rel
  endif
  if ((not(use_yz) and not(use_xz)) and (use_xy)) then begin
    poscb(0) = posxy(2) + w_ytick_rel + w_sep_rel
  endif
  poscb(1) = h_xtick_rel + h_sep_rel
  poscb(2) = poscb(0) + w_cb_rel
  poscb(3) = poscb(1) + h_cb
endif

return
end
