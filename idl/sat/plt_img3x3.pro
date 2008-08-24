PRO PLT_IMG3X3, d1, d2, d3, d4, d5, d6, d7, d8, d9, $
                DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
                MARGIN=margin, COLOR=color, PS=ps, $
;; AXIS:
                XREVERSE = xreverse, YREVERSE = yreverse, $
                XTITLE  = xtitle,  YTITLE  = ytitle,  ZTITLE  = ztitle, $
                ZTITLE1 = ztitle1, ZTITLE2 = ztitle2, ZTITLE3 = ztitle3, $
                XNOTICKS    = xnoticks, YNOTICKS    = ynoticks, $
;; SCALING
                DX=dx, DY=dy, RX=rx, RY=ry, SCALE=scale, $
                XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange,$
                XMIN=xmin,     YMIN=ymin,     ZMIN=zmin, $
                XMAX=xmax,     YMAX=ymax,     ZMAX=zmax, $
;; COLORTABLE
                CTABLE=ctable, CTLOW=ctlow, CTHIGH=cthigh, CTGAMMA=ctgamma, $
;; PLANET:
                PLANET=planet, PLCOLOR=plcolor, $
;; TRAJECTORY:
                TRAJVERT1  = trajvert1,  TRAJPOINTS1 = trajpoints1, $
                TRAJVERT2  = trajvert2,  TRAJPOINTS2 = trajpoints2, $
                TRAJVERT3  = trajvert3,  TRAJPOINTS3 = trajpoints3, $
                TRAJVERT4  = trajvert4,  TRAJPOINTS4 = trajpoints4, $
                TRAJVERT5  = trajvert5,  TRAJPOINTS5 = trajpoints5, $
                TRAJVERT6  = trajvert6,  TRAJPOINTS6 = trajpoints6, $
                TRAJVERT7  = trajvert7,  TRAJPOINTS7 = trajpoints7, $
                TRAJVERT8  = trajvert8,  TRAJPOINTS8 = trajpoints8, $
                TRAJVERT9  = trajvert9,  TRAJPOINTS9 = trajpoints9, $
                TRAJSTYLE = trajstyle,   ALLTRAJPOINTS = alltrajpoints, $
                TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $

;; VECTORS:
                XVEC1=xvec1, YVEC1=yvec1, AVEC1=avec1, $
                XVEC2=xvec2, YVEC2=yvec2, AVEC2=avec2, $
                XVEC3=xvec3, YVEC3=yvec3, AVEC3=avec3, $
                XVEC4=xvec4, YVEC4=yvec4, AVEC4=avec4, $
                XVEC5=xvec5, YVEC5=yvec5, AVEC5=avec5, $
                XVEC6=xvec6, YVEC6=yvec6, AVEC6=avec6, $
                XVEC7=xvec7, YVEC7=yvec7, AVEC7=avec7, $
                XVEC8=xvec8, YVEC8=yvec8, AVEC8=avec8, $
                XVEC9=xvec9, YVEC9=yvec9, AVEC9=avec9, $
                VECCOLOR=veccolor, DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec

; 
;                     TITLE
; y  ----------  m  ----------  m  ----------   c z
; a |tag1      | a |tag2      | a |tag3      |  b t
; x |    11    | r |    22    | r |    33    |  a i
; i |    11    | g |    22    | g |    33    |  r t
; s |          | i |          | i |          |  1 l
; 1  ----------  n  ----------  n  ----------     e
;     margin          margin         magrin 
; y  ----------  m  ----------  m  ----------   c z
; a |tag4      | a |tag5      | a |tag6      |  b t
; x |    44    | r |    55    | r |    66    |  a i
; i |    44    | g |    55    | g |    66    |  r t
; s |          | i |          | i |          |  2 l
; 2  ----------  n  ----------  n  ----------     e
;     margin          margin         magrin 
; y  ----------  m  ----------  m  ----------   c z
; a |tag7      | a |tag8      | a |tag8      |  b t
; x |    77    | r |    88    | r |    99    |  a i
; i |    77    | g |    88    | g |    99    |  r t
; s |          | i |          | i |          |  3 l
; 3  ----------  n  ----------  n  ----------     e
;     (xaxis)        (xaxis)         (xaxis)
;  (0)        (1) (2)        (3) (4)        (5) <= xpos()
;
; HISTORY:                                                           ;
; - v0.3.0 2007-08-06 Jan Paral
;    Added DESC, DSCCOLOR and DSCCHARSIZE keywords for plotting descriptions
; - v0.3.0 2007-06-05 Jan Paral                                     ;
;    Add ALLTRAJPOINTS in case all pictures have the same trajectory and overide
;    all TRAJPOINS? keywords.

  IF N_PARAMS() NE 9 THEN MESSAGE, 'PLT_IMG3X3 require 9 arguments at least'

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

  IF KEYWORD_SET(alltrajpoints) THEN BEGIN
     trajpoints1 = alltrajpoints
     trajpoints2 = alltrajpoints
     trajpoints3 = alltrajpoints
     trajpoints4 = alltrajpoints
     trajpoints5 = alltrajpoints
     trajpoints6 = alltrajpoints
     trajpoints7 = alltrajpoints
     trajpoints8 = alltrajpoints
     trajpoints9 = alltrajpoints
  ENDIF

  IF NOT(KEYWORD_SET(ztitle))  THEN ztitle=''
  IF NOT(KEYWORD_SET(ztitle1)) THEN ztitle1=ztitle
  IF NOT(KEYWORD_SET(ztitle2)) THEN ztitle2=ztitle
  IF NOT(KEYWORD_SET(ztitle3)) THEN ztitle3=ztitle

  cbarmargin = SAT_IDLRC(/CBARMARGIN, /PUBENV)

  UTL_CHECK_SIZE, d1, d2, d3, d4, d5, d6, d7, d8, d9, ss=[2]

  IF N_ELEMENTS(desc) NE 9 THEN BEGIN
     dsc = REPLICATE('',9)
     FOR i=0, N_ELEMENTS(desc)-1 DO BEGIN
        dsc[i] = desc[i]
     ENDFOR
  ENDIF ELSE dsc = desc

  ss = size(d1)

  IF N_ELEMENTS(dx) EQ 0 THEN dx=1.
  IF N_ELEMENTS(dy) EQ 0 THEN dy=1.
  IF N_ELEMENTS(rx) EQ 0 THEN rx=0.
  IF N_ELEMENTS(ry) EQ 0 THEN ry=0.
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

  length = (1 - 2*cbarmargin - 2*margin) / 3

  llx = length * xrel
  lly = length * yrel

  xpos = fltarr (6)
  xpos(0) = cbarmargin
  xpos(1) = xpos(0) + llx
  xpos(2) = xpos(1) + margin
  xpos(3) = xpos(2) + llx
  xpos(4) = xpos(3) + margin
  xpos(5) = xpos(4) + llx

  ypos = fltarr (6)
  ypos(0) = cbarmargin
  ypos(1) = ypos(0) + lly
  ypos(2) = ypos(1) + margin
  ypos(3) = ypos(2) + lly
  ypos(4) = ypos(3) + margin
  ypos(5) = ypos(4) + lly

  pos1 = [xpos(0), ypos(4), xpos(1), ypos(5)]
  pos2 = [xpos(2), ypos(4), xpos(3), ypos(5)]
  pos3 = [xpos(4), ypos(4), xpos(5), ypos(5)]
  pos4 = [xpos(0), ypos(2), xpos(1), ypos(3)]
  pos5 = [xpos(2), ypos(2), xpos(3), ypos(3)]
  pos6 = [xpos(4), ypos(2), xpos(5), ypos(3)]
  pos7 = [xpos(0), ypos(0), xpos(1), ypos(1)]
  pos8 = [xpos(2), ypos(0), xpos(3), ypos(1)]
  pos9 = [xpos(4), ypos(0), xpos(5), ypos(1)]

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

  PLT_IMG, d1, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTICKS=0, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTITLE=ytitle, YTICKS=yticks, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert1,  TRAJPOINTS = trajpoints1, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, $
           XVEC=xvec1, YVEC=yvec1, AVEC=avec1, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[0], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos1, OPLOT=noerase
  PLT_IMG, d2, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTICKS=0, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert2,  TRAJPOINTS = trajpoints2, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec2, YVEC=yvec2, AVEC=avec2, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[1], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos2
  PLT_IMG, d3, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTICKS=0, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert3,  TRAJPOINTS = trajpoints3, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           XVEC=xvec3, YVEC=yvec3, AVEC=avec3, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           DESC=dsc[2], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos3
  PLT_IMG, d4, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTICKS=0, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTITLE=ytitle, YTICKS=yticks, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert4,  TRAJPOINTS = trajpoints4, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec4, YVEC=yvec4, AVEC=avec4, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[3], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos4
  PLT_IMG, d5, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTICKS=0, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert5,  TRAJPOINTS = trajpoints5, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec5, YVEC=yvec5, AVEC=avec5, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[4], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos5
  PLT_IMG, d6, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTICKS=0, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert6,  TRAJPOINTS = trajpoints6, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec6, YVEC=yvec6, AVEC=avec6, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[5], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos6
  PLT_IMG, d7, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTITLE=xtitle, XTICKS=xticks, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTITLE=ytitle, YTICKS=yticks, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert7,  TRAJPOINTS = trajpoints7, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec7, YVEC=yvec7, AVEC=avec7, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[6], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos7
  PLT_IMG, d8, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTITLE=xtitle, XTICKS=xticks, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert8,  TRAJPOINTS = trajpoints8, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec8, YVEC=yvec8, AVEC=avec8, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[7], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos8
  PLT_IMG, d9, DX=dx, DY=dy, SCALE=scale, RX=rx, RY=ry, $
           PLANET=planet, PLCOLOR=plcolor, COLOR=color, $
           XREVERSE = xreverse, YREVERSE = yreverse, $
           XMIN=xmin, XMAX=xmax, XRANGE=xrange, XTITLE=xtitle, XTICKS=xticks, $
           YMIN=ymin, YMAX=ymax, YRANGE=yrange, YTICKS=0, $
           ZMIN=zmin, ZMAX=zmax, ZRANGE=zrange, $
           TRAJVERT  = trajvert9,  TRAJPOINTS = trajpoints9, $
           TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
           TRAJSTYLE = trajstyle, /OPLOT, $
           XVEC=xvec9, YVEC=yvec9, AVEC=avec9, VECCOLOR=veccolor, $
           DVEC=dvec, MAXLENVEC=maxlenvec, LENVEC=lenvec, $
           DESC=dsc[8], DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
           POSITION=pos9

  cbpos1 = [xpos(5) + .08, ypos(0), xpos(5) + .10, ypos(1)]
  cbpos2 = [xpos(5) + .08, ypos(2), xpos(5) + .10, ypos(3)]
  cbpos3 = [xpos(5) + .08, ypos(4), xpos(5) + .10, ypos(5)]

  PLT_COLORBAR, /VERTICAL, TITLE=ztitle3, RANGE=[zmin, zmax], $
                ANNOTATECOLOR=color, POSITION=cbpos1
  PLT_COLORBAR, /VERTICAL, TITLE=ztitle2, RANGE=[zmin, zmax], $
                ANNOTATECOLOR=color, POSITION=cbpos2
  PLT_COLORBAR, /VERTICAL, TITLE=ztitle1, RANGE=[zmin, zmax], $
                ANNOTATECOLOR=color, POSITION=cbpos3

  IF KEYWORD_SET(ps) THEN BEGIN
     DEVICE,/CLOSE
     SET_PLOT,'x'
  ENDIF
  
END
