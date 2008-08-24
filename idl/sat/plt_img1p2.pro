PRO PLT_IMG1P2, d1, d2, d3, $
                MARGIN=margin, COLOR=color, PS=ps, $
                DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
;; AXIS:
                XREVERSE = xreverse, YREVERSE = yreverse, $
                XTITLE1 = xtitle1, XTITLE2 = xtitle2, XTITLE3 = xtitle3, $
                YTITLE1 = ytitle1, YTITLE2 = ytitle2, $
                ZTITLE  = ztitle, $
                XNOTICKS    = xnoticks, YNOTICKS    = ynoticks, $
;; SCALING
                DX=dx, DY=dy, RX=rx, RY=ry, R3X=r3x, SCALE=scale, $
                XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange,$
                XMIN=xmin,     YMIN=ymin,     ZMIN=zmin, $
                XMAX=xmax,     YMAX=ymax,     ZMAX=zmax, $
;; COLORTABLE
                CTABLE=ctable, CTLOW=ctlow, CTHIGH=cthigh, CTGAMMA=ctgamma, $
;; PLANET:
                PLANET=planet, PLCOLOR=plcolor, $
;; TRAJECTORY:
                TRAJVERT1 = trajvert1, TRAJPOINTS1 = trajpoints1, $
                TRAJVERT2 = trajvert2, TRAJPOINTS2 = trajpoints2, $
                TRAJVERT3 = trajvert3, TRAJPOINTS3 = trajpoints3, $
                TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
                TRAJSTYLE = trajstyle, TRAJLEN = trajlen, $
;; VECTORS:
                XVEC1=xvec1, YVEC1=yvec1, AVEC1=avec1, $
                XVEC2=xvec2, YVEC2=yvec2, AVEC2=avec2, $
                XVEC3=xvec3, YVEC3=yvec3, AVEC3=avec3, $
                VECCOLOR=veccolor, DVEC=dvec, MAXLENVEC=maxlenvec, $
                LENVEC=lenvec, VECSIZE=vecsize, $
                _EXTRA=_extra

; 
;                     TITLE
; y  ----------   y  ----------  m  ----------   c z
; a |tag1      |  a |tag2      | a |tag3      |  b t
; x |    11    |  x |    22    | r |    33    |  a i
; i |    11    |  i |    22    | g |    33    |  r t
; s |          |  s |          | i |          |  1 l
; 1  ----------   2  ----------  n  ----------     e
;     (xaxis1)       (xaxis2)       (xaxis3)
;  (0)        (1)  (2)        (3) (4)        (5) <= xpos()
;
; - v0.3.0 2007-08-06 Jan Paral
;    Added DESC, DSCCOLOR and DSCCHARSIZE keywords for plotting descriptions

  IF N_PARAMS() NE 3 THEN MESSAGE, 'PLT_IMG1P2 require 3 arguments at least'

  noerase = 0
  IF KEYWORD_SET(ps) THEN BEGIN
     SET_PLOT,'ps'
     DEVICE,_EXTRA=extra
     DEVICE,/LAND,BITS_PER_PIXEL=16,/COLOR,FILE=ps
  ENDIF ELSE BEGIN
     TVLCT, r, g, b, /GET
     POLYFILL, [1,1,0,0,1], [1,0,0,1,1], /NORMAL, COLOR=FSC_COLOR('White')
     TVLCT, r, g, b
     noerase = 1
  ENDELSE

  IF NOT(KEYWORD_SET(ztitle))  THEN ztitle=''
  IF NOT(KEYWORD_SET(xtitle1)) THEN xtitle1=''
  IF NOT(KEYWORD_SET(xtitle2)) THEN xtitle2=''
  IF NOT(KEYWORD_SET(xtitle3)) THEN xtitle3=''
  IF NOT(KEYWORD_SET(ytitle1)) THEN ytitle1=''
  IF NOT(KEYWORD_SET(ytitle2)) THEN ytitle2=''

  cbarmargin = SAT_IDLRC(/CBARMARGIN, /PUBENV)

;;   UTL_CHECK_SIZE, d1, d2, d3, ss=[2]

  ss = size(d1)

  IF N_ELEMENTS(dx)  EQ 0 THEN dx=1.
  IF N_ELEMENTS(dy)  EQ 0 THEN dy=1.
  IF N_ELEMENTS(rx)  EQ 0 THEN rx=0.
  IF N_ELEMENTS(ry)  EQ 0 THEN ry=0.
  IF N_ELEMENTS(r3x) EQ 0 THEN r3x=rx
  IF N_ELEMENTS(r3y) EQ 0 THEN r3y=ry
  IF NOT(KEYWORD_SET(scale)) THEN scale=1.

  IF NOT(KEYWORD_SET(xmin)) THEN xmin=  -rx  * (ss(1)*dx/scale)
  IF NOT(KEYWORD_SET(xmax)) THEN xmax=(1-rx) * (ss(1)*dx/scale)
  IF KEYWORD_SET(xrange) THEN BEGIN
     xmin = xrange(0)
     xmax = xrange(1)
  ENDIF

  IF NOT(KEYWORD_SET(ymin)) THEN ymin=  -ry  * (ss(2)*dy/scale)
  IF NOT(KEYWORD_SET(ymax)) THEN ymax=(1-ry) * (ss(2)*dy/scale)
  IF KEYWORD_SET(yrange) THEN BEGIN
    ymin = yrange(0)
    ymax = yrange(1)
  ENDIF

  IF NOT(KEYWORD_SET(xmin3)) THEN xmin3=  -r3x  * (ss(1)*dx/scale)
  IF NOT(KEYWORD_SET(xmax3)) THEN xmax3=(1-r3x) * (ss(1)*dx/scale)
  IF KEYWORD_SET(xrange) THEN BEGIN
     xmin3 = xrange(0)
     xmax3 = xrange(1)
  ENDIF

  IF NOT(KEYWORD_SET(ymin3)) THEN ymin3=  -r3y  * (ss(2)*dy/scale)
  IF NOT(KEYWORD_SET(ymax3)) THEN ymax3=(1-r3y) * (ss(2)*dy/scale)
  IF KEYWORD_SET(yrange) THEN BEGIN
    ymin3 = yrange(0)
    ymax3 = yrange(1)
  ENDIF

  IF NOT(KEYWORD_SET(zmin)) THEN zmin=min(d1)
  IF NOT(KEYWORD_SET(zmax)) THEN zmax=max(d1)
  IF KEYWORD_SET(zrange) THEN BEGIN
     zmin = zrange(0)
     zmax = zrange(1)
  ENDIF

  lx = xmax - xmin
  ly = ymax - ymin
  aspectRatio = ly / lx
  wAspectRatio = FLOAT(!D.Y_VSIZE) / !D.X_VSIZE

  IF (aspectRatio LE wAspectRatio) THEN BEGIN
     xlo = 0.0
     ylo = 0.5 - 0.5 * (aspectRatio / wAspectRatio)
     xhi = 1.0
     yhi = 0.5 + 0.5 * (aspectRatio / wAspectRatio)
  ENDIF ELSE BEGIN
     xlo = 0.5 - 0.5 * (wAspectRatio / aspectRatio)
     ylo = 0.0
     xhi = 0.5 + 0.5 * (wAspectRatio / aspectRatio)
     yhi = 1.0
  ENDELSE
  xrel = xhi - xlo
  yrel = yhi - ylo

  IF N_ELEMENTS(margin) EQ 0 THEN margin=0.

  ;; Only two boundary margins since 1 is for colorbar
  ;; 2 times cbarmargin/2 for y-axis
  length = (1. - (7./3.)*cbarmargin - 1.*margin) / 3.
;  lengthy = (1 - 2*cbarmargin - 0*margin) / 1.

  llx = length * xrel
  lly = length * yrel

  xpos = fltarr (6)
  xpos(0) = (2./3.)*cbarmargin
  xpos(1) = xpos(0) + llx
  xpos(2) = xpos(1) + (2./3.)*cbarmargin
  xpos(3) = xpos(2) + llx
  xpos(4) = xpos(3) + margin
  xpos(5) = xpos(4) + llx

  ypos = fltarr (2)
  ypos(0) = cbarmargin
  ypos(1) = ypos(0) + lly

  pos1 = [xpos(0), ypos(0), xpos(1), ypos(1)]
  pos2 = [xpos(2), ypos(0), xpos(3), ypos(1)]
  pos3 = [xpos(4), ypos(0), xpos(5), ypos(1)]

  IF NOT(KEYWORD_SET(color))   THEN color=0
  IF NOT(KEYWORD_SET(ctlow))   THEN ctlow=0
  IF NOT(KEYWORD_SET(cthigh))  THEN cthigh=255
  IF NOT(KEYWORD_SET(ctgamma)) THEN ctgamma=1.
  IF (N_ELEMENTS(ctable) EQ 1)  THEN BEGIN
     LOADCT, ctable, /SILENT
     STRETCH, ctlow, cthigh, ctgamma
  ENDIF

  xticks = 1
  yticks = 1
  IF KEYWORD_SET(xnoticks) THEN xticks = 0
  IF KEYWORD_SET(ynoticks) THEN yticks = 0

  IF N_ELEMENTS(desc) NE 3 THEN BEGIN
     dsc = REPLICATE('',9)
     FOR i=0, N_ELEMENTS(desc)-1 DO BEGIN
        dsc[i] = desc[i]
     ENDFOR
  ENDIF ELSE dsc = desc

  PLT_IMG, d1, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTITLE=xtitle1, XTICKS=xticks, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTITLE=ytitle1, YTICKS=yticks, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert1,  TRAJPOINTS = trajpoints1, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, $
           XVEC=xvec1, YVEC=yvec1, AVEC=avec1, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, VECSIZE=vecsize, $
           DESC=dsc[0], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos1, OPLOT=noerase, TRAJLEN = trajlen, $
           _EXTRA=_extra
  PLT_IMG, d2, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTITLE=xtitle2, XTICKS=xticks, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTITLE=ytitle2, YTICKS=yticks, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert2,  TRAJPOINTS = trajpoints2, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec2, YVEC=yvec2, AVEC=avec2, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, VECSIZE=vecsize, $
           DESC=dsc[1], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos2, TRAJLEN = trajlen, $
           _EXTRA=_extra
  PLT_IMG, d3, DX=dx, DY=dy, SCALE=scale, RX=r3x, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, XTICKS=xticks, $
           XMIN=ymin3, XMAX=ymax3, XTITLE=xtitle3, $
           YMIN=ymin3, YMAX=ymax3, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert3,  TRAJPOINTS = trajpoints3, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           XVEC=xvec3, YVEC=yvec3, AVEC=avec3, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, VECSIZE=vecsize, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           DESC=dsc[2], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos3, TRAJLEN = trajlen, $
           _EXTRA=_extra

  cbpos1 = [xpos(5) + .08, ypos(0), xpos(5) + .10, ypos(1)]

  PLT_COLORBAR, /VERTICAL, TITLE=ztitle, RANGE=[zmin, zmax], $
                ANNOTATECOLOR=color, POSITION=cbpos1

  IF KEYWORD_SET(ps) THEN BEGIN
     DEVICE,/CLOSE
     SET_PLOT,'x'
  ENDIF
  
END
