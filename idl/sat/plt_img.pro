PRO PLT_IMG, data, $
             OPLOT=oplot, POSITION=position, NLEVEL=nlevel, $
             DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
;; AXIS:
             DX=dx, DY=dy, $
             RX=rx, RY=ry, COLOR=color, $
             XSCALE=xscale, YSCALE=yscale, SCALE=scale, $
             XREVERSE = xreverse, YREVERSE = yreverse, $
             XTITLE = xtitle, YTITLE = ytitle,  $
             XTICKS = xticks, YTICKS = yticks, $
;; SCALING
             XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange,$
             XMIN=xmin,     YMIN=ymin,     ZMIN=zmin, $
             XMAX=xmax,     YMAX=ymax,     ZMAX=zmax, $
             ZLOG=zlog, $
;; PLANET:
             PLANET=planet, PLCOLOR=plcolor, $
;; TRAJECTORY:
             TRAJVERT  = trajvert,  TRAJPOINTS = trajpoints, $
             TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
             TRAJSTYLE = trajstyle, TRAJLEN    = trajlen, $
             TRAJMARK  = trajmark,  TRAJSYM    = trajsym, $
;; VECTORS:
             XVEC=xvec, YVEC=yvec, AVEC=avec, VECCOLOR=veccolor, $
             DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, VECSIZE=vecsize, $
             _EXTRA=_extra
;+
; NAME:
;	PLT_IMG
;
;
; PURPOSE:
;	Low level plotting function called from PLT_* procedures
;
;
; CATEGORY:
;	Plottting
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; - v0.3.0 2008-01-17 Jan Paral
;    Bug in trajcolor when trajectory is only one
; - v0.3.0 2007-08-16 Jan Paral
;    Move the trajectory visualization after the planet
; - v0.3.0 2007-08-06 Jan Paral
;    Added DESC, DSCCOLOR and DSCCHARSIZE keywords for plotting descriptions
; - v0.3.0 2007-06-06 Jan Paral
;    Add XSCALE and YSCALE keywords
; - v0.3.0 2007-06-04 Jan Paral
;    TRAJVERT, TRAJCOLOR, TRAJSTYLE keywords now accept array of values
;    so we can overplot more then one trajectory with different style and color
; - v0.3.0 2007-03-14 Jan Paral
;    Initial version (forked from pl_fig2d)
;
;-

;--------------------------------------------------------------------;
; 1) CHECK INPUT PARAMETERS                                          ;
;                                                                    ;
; Make sure, that the data is a three dimensional array.             ;
;--------------------------------------------------------------------;
ss=SIZE(data,/TYPE)
IF (ss EQ 0) then MESSAGE, 'Wrong argument type'

ss=SIZE(data)
IF (ss(0) NE 2) THEN MESSAGE, 'Data are required to be 2D'

;--------------------------------------------------------------------;
; 2) FIX PARAMETERS NEEDED FOR PLOTTING                              ;
;--------------------------------------------------------------------;
IF NOT(KEYWORD_SET(scale)) THEN scale=1.0
IF NOT(KEYWORD_SET(xscale)) THEN xscale=scale
IF NOT(KEYWORD_SET(yscale)) THEN yscale=scale

IF NOT(KEYWORD_SET(dx)) THEN dx=1.0
IF NOT(KEYWORD_SET(dy)) THEN dy=1.0

IF NOT(KEYWORD_SET(rx)) THEN rx=0.0
IF NOT(KEYWORD_SET(ry)) THEN ry=0.0

;--------------------------------------------------------------------;
lx=(ss(1)-1)*dx
ly=(ss(2)-1)*dy

ix=(FINDGEN(ss(1))*dx-rx*lx)/xscale
iy=(FINDGEN(ss(2))*dy-ry*ly)/yscale

IF NOT(KEYWORD_SET(xmin)) THEN xmin=ix(0)
IF NOT(KEYWORD_SET(xmax)) THEN xmax=ix(ss(1)-1)
IF NOT(KEYWORD_SET(ymin)) THEN ymin=iy(0)
IF NOT(KEYWORD_SET(ymax)) THEN ymax=iy(ss(2)-1)
IF NOT(KEYWORD_SET(zmin)) THEN zmin=min(data)
IF NOT(KEYWORD_SET(zmax)) THEN zmax=max(data)

IF KEYWORD_SET(xrange) THEN BEGIN
   UTL_CHECK_SIZE, xrange, ss=[1,2]
   xmin = xrange(0)
   xmax = xrange(1)
ENDIF
IF KEYWORD_SET(yrange) THEN BEGIN
   UTL_CHECK_SIZE, yrange, ss=[1,2]
   ymin = yrange(0)
   ymax = yrange(1)
ENDIF
IF KEYWORD_SET(zrange) THEN BEGIN
   UTL_CHECK_SIZE, zrange, ss=[1,2]
   zmin = zrange(0)
   zmax = zrange(1)
ENDIF

dataloc=data

ndx=WHERE(data GT zmax, cnt)
sn=size(ndx)
;; IF (sn(0) NE 0) THEN BEGIN
;;   dataloc(ndx)=zmax
;; ENDIF
ndx=WHERE(data LT zmin, cnt)
sn=SIZE(ndx)
IF (sn(0) NE 0) THEN BEGIN
  dataloc(ndx)=zmin
ENDIF

IF NOT(KEYWORD_SET(zlog)) THEN BEGIN
   zlog=0
END ELSE BEGIN
   zlog=1
   dataloc=DAT_SCALEVEC(dataloc,1.,2500.)
   dataloc=BytScl(ALog10(dataloc), Top=253)
ENDELSE

IF NOT(KEYWORD_SET(plcolor)) THEN plcolor='Black'
IF NOT(KEYWORD_SET(color))   THEN color='Black'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               OVERPLOT OF PLANET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF NOT(KEYWORD_SET(planet)) THEN planet=0.
imi=FINDGEN(1001)/1000*!pi*2
imx=planet*SIN(imi)
imy=planet*COS(imi)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               PREPARE PLOT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF NOT(KEYWORD_SET(nlevel)) THEN nlevel=50
zmin = FLOAT(zmin)
zmax = FLOAT(zmax)
nlevel = FLOAT(nlevel)
lev = zmin + findgen(nlevel) * ((zmax-zmin)/(nlevel-1))

gg=REPLICATE(' ',30)

IF NOT(KEYWORD_SET(xticks)) THEN xtickname=gg
IF NOT(KEYWORD_SET(yticks)) THEN ytickname=gg
IF (N_ELEMENTS(xreverse) NE 0) THEN xtickformat='PLT_XTICKS'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Data only
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TVLCT, r, g, b, /GET
CONTOUR, dataloc, ix, iy,$
         NLEV=nlevel, /FILL, LEV=lev, $
         XRANGE=[xmin,xmax],YRANGE=[ymin,ymax],ZRANGE=[zmin,zmax],$
         /XST, /YST, /ZST, /DATA, XTICKNAME=gg, YTICKNAME=gg, $
         POSITION=position, NOERASE=oplot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF (KEYWORD_SET(xvec) AND KEYWORD_SET(xvec)) THEN BEGIN
   IF NOT(KEYWORD_SET(avec)) THEN avec=(xvec^2 + yvec^2)
   IF NOT(KEYWORD_SET(veccolor)) THEN veccolor='Black'
   UTL_CHECK_SIZE, xvec, yvec, avec, SS=SIZE(data)

   PLT_VEC, avec, xvec, yvec, ix, iy, DSVEC=dvec, COLOR=FSC_COLOR(veccolor), $
            XRANGE=[xmin,xmax],YRANGE=[ymin,ymax], MAXLEN= maxlenvec, $
            LENGTH= lenvec, VECSIZE=vecsize
ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               AXIS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CONTOUR, dataloc, ix, iy,$
         NLEV=nlevel, /FILL, LEV=lev, $
         XRANGE=[xmin,xmax], YRANGE=[ymin,ymax], ZRANGE=[zmin,zmax], $
         XTITLE=xtitle, XTICKNAME=xtickname, XTICKFORMAT=xtickformat, $
         YTITLE=ytitle, YTICKNAME=ytickname, $
         /XST, /YST, /ZST, /NODATA, /NOERASE, COLOR=FSC_COLOR(color), $
         POSITION=position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               PLANET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF KEYWORD_SET(planet) THEN BEGIN
   POLYFILL,imx,imy, /DATA, COLOR=FSC_COLOR(plcolor)
ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Trajectory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF KEYWORD_SET(trajvert) THEN BEGIN
   sstrj = SIZE(trajvert)
   UTL_CHECK_SIZE, trajvert, SMIN=[2], SMAX=[3]

   ;; Default symbol is Asterix
   IF (N_ELEMENTS(trajsym) EQ 0) THEN trajsym = 2

   IF (sstrj(0) EQ 2) THEN BEGIN
      IF (N_ELEMENTS(trajcolor) EQ 0) THEN trajcolor='Black'
      OPLOT, trajvert(0,*), trajvert(1,*), COLOR=FSC_COLOR(trajcolor), $
             THICK=trajthick, LINESTYLE=trajstyle

      ;; Draw trajectory marks avery TRAJMARK data value
      IF (N_ELEMENTS(trajmark) NE 0) THEN BEGIN
         IF (UINT(sstrj(2)/trajmark) - 1 GT 0) THEN BEGIN
            idx = trajmark * (INDGEN (UINT(sstrj(2)/trajmark) - 1) + 1)
            oplot, trajvert(0,idx), trajvert(1,idx), $
                   COLOR=FSC_COLOR(trajcolor), THICK=trajthick, PSYM=trajsym
         ENDIF
      ENDIF
   ENDIF ELSE BEGIN
      col = 'Black'
      IF (N_ELEMENTS(trajcolor) EQ 1) THEN col = trajcolor
      IF (N_ELEMENTS(trajcolor) NE sstrj(3)) THEN BEGIN
         trajcolor=STRARR(sstrj(3))
         trajcolor[*] = col
      ENDIF
      IF (N_ELEMENTS(trajstyle) NE sstrj(3)) THEN BEGIN
         trajstyle=INTARR(sstrj(3))
         trajstyle[*] = 0
      ENDIF
      IF (N_ELEMENTS(trajlen) NE sstrj(3)) THEN BEGIN
         trajlen=INTARR(sstrj(3))
         trajlen[*] = sstrj(2)
      ENDIF

      FOR i=0, sstrj(3)-1 DO BEGIN
         OPLOT, reform(trajvert[0,0:trajlen(i)-1,i]), $
                reform(trajvert[1,0:trajlen(i)-1,i]), $
                COLOR=FSC_COLOR(trajcolor[i]), $
                THICK=trajthick, LINESTYLE=trajstyle[i]
      ENDFOR
   ENDELSE
ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Trajectory Points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF KEYWORD_SET(trajpoints) THEN BEGIN
   IF (N_ELEMENTS(trajcolor) EQ 0) THEN trajcolor='Black'
   CONTOUR, trajpoints, ix, iy, $
            NLEV=nlevel, /FILL, LEV=1, COLOR=FSC_COLOR(trajcolor), $
            XRANGE=[xmin,xmax],YRANGE=[ymin,ymax],ZRANGE=[zmin,zmax],$
            /XST, /YST, /ZST, /DATA, XTICKNAME=gg, YTICKNAME=gg, $
            POSITION=position, /NOERASE, /OVERPLOT
ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               DESCRIPTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF KEYWORD_SET(desc) THEN BEGIN
   IF NOT(KEYWORD_SET(dsccolor))    THEN dsccolor='Black'
   IF NOT(KEYWORD_SET(dsccharsize)) THEN dsccharsize=1.
;;    IF KEYWORD_SET(position) THEN BEGIN
;;       xpos = 0.
;;       ypos = 0.
;;    ENDIF ELSE BEGIN
;;    ENDELSE

   chhigh = dsccharsize * (float(!D.Y_CH_SIZE) / float(!D.Y_VSIZE))
   xshit = 0.02 * (!X.WINDOW[1] - !X.WINDOW[0])
   yshit = 0.02 * (!Y.WINDOW[1] - !Y.WINDOW[0])

   xpos =  xshit + !X.WINDOW[0]
   ypos = -yshit + !Y.WINDOW[1] - chhigh

   XYOUTS, xpos, ypos, desc, /NORMAL, CHARSIZE=dsccharsize, $
           COLOR=FSC_COLOR(dsccolor)
ENDIF

;; Restore color table
TVLCT, r, g, b

RETURN
END
