PRO PLT_IMG1, data, $
              PS=ps, COLOR=color, $
              DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
;; AXIS:
              XREVERSE = xreverse, YREVERSE = yreverse, $
              XTITLE = xtitle, YTITLE = ytitle, ZTITLE = ztitle, $
              XNOTICKS = xnoticks, YNOTICKS = ynoticks, $
;; SCALING
              DX=dx, DY=dy, RX=rx, RY=ry, $
              XSCALE=xscale, YSCALE=yscale, SCALE=scale, $
              XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange,$
              XMIN=xmin,     YMIN=ymin,     ZMIN=zmin, $
              XMAX=xmax,     YMAX=ymax,     ZMAX=zmax, $
;; COLORTABLE
              CTABLE=ctable, CTLOW=ctlow, CTHIGH=cthigh, CTGAMMA=ctgamma, $
;; PLANET:
              PLANET=planet, PLCOLOR=plcolor, $
;; TRAJECTORY:
              TRAJVERT  = trajvert,  TRAJPOINTS = trajpoints, $
              TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
              TRAJSTYLE = trajstyle, $
;; VECTORS:
              XVEC=xvec, YVEC=yvec, AVEC=avec, VECCOLOR=veccolor, $
              DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec

; - v0.3.0 2007-08-06 Jan Paral
;    Added DESC, DSCCOLOR and DSCCHARSIZE keywords for plotting descriptions
; - v0.3.0 2007-06-06 Jan Paral
;    Add XSCALE and YSCALE keywords

  data = reform (data)
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

  cbarmargin = SAT_IDLRC(/CBARMARGIN, /PUBENV)
  ss = size(data)
  
  IF N_ELEMENTS(dx) EQ 0 THEN dx=1.
  IF N_ELEMENTS(dy) EQ 0 THEN dy=1.
  IF N_ELEMENTS(rx) EQ 0 THEN rx=0.
  IF N_ELEMENTS(ry) EQ 0 THEN ry=0.
  IF NOT(KEYWORD_SET(scale)) THEN scale=1.
  IF NOT(KEYWORD_SET(xscale)) THEN xscale=scale
  IF NOT(KEYWORD_SET(yscale)) THEN yscale=scale

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

  IF NOT(KEYWORD_SET(zmin)) THEN zmin=min(data)
  IF NOT(KEYWORD_SET(zmax)) THEN zmax=max(data)
  IF KEYWORD_SET(zrange) THEN BEGIN
     zmin = zrange(0)
     zmax = zrange(1)
  ENDIF

  lx = xmax - xmin
  ly = ymax - ymin

  aspectRatio = ly / lx
  wAspectRatio = FLOAT(!D.Y_VSIZE) / !D.X_VSIZE

  IF (aspectRatio LE wAspectRatio) THEN BEGIN
     xlo = cbarmargin
     ylo = 0.5 - (0.5 - cbarmargin) * (aspectRatio / wAspectRatio)
     xhi = 1.0 - cbarmargin
     yhi = 0.5 + (0.5 - cbarmargin) * (aspectRatio / wAspectRatio)
  ENDIF ELSE BEGIN
     xlo = 0.5 - (0.5 - cbarmargin) * (wAspectRatio / aspectRatio)
     ylo = cbarmargin
     xhi = 0.5 + (0.5 - cbarmargin) * (wAspectRatio / aspectRatio)
     yhi = 1.0 - cbarmargin
  ENDELSE

  position = [xlo, ylo, xhi, yhi]

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

  PLT_IMG, data, DX=dx, DY=dy, RX=rx, RY=ry, $
           XSCALE=xscale, YSCALE=yscale, SCALE=scale, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse,$
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTITLE=xtitle, XTICKS=xticks, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTITLE=ytitle, YTICKS=yticks, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert,  TRAJPOINTS = trajpoints, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, $
           XVEC=xvec, YVEC=yvec, AVEC=avec, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=position, OPLOT=noerase

  position = [xhi + .08, ylo, xhi + .12, yhi]

  PLT_COLORBAR, /VERTICAL, TITLE=ztitle, RANGE=[zmin, zmax], $
                ANNOTATECOLOR=color, POSITION=position

  IF KEYWORD_SET(ps) THEN BEGIN
     DEVICE,/CLOSE
     SET_PLOT,'x'
  ENDIF
END
