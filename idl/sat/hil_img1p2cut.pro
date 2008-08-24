PRO HIL_IMG1P2CUT, data, vx, vy, vz, $
                   DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
                   PS=ps, $
;; AXIS
                   XNOTICKS=xnoticks, YNOTICKS=ynoticks, $
                   XRANGE=xrange, YRANGE=yrange, ZTITLE=ztitle, UNITS=units, $
;; SCALING
                   DX=dx, DY=dy, DZ=dz, RX=rx, RY=ry, RZ=rz, $
                   ZMIN=zmin, ZMAX=zmax, SCALE=scale, $
;; OPLOT
                   PLANET=planet, $
;; COLORTABLE
                   CTABLE=ctable, CTLOW=ctlow, CTHIGH=cthigh, CTGAMMA=ctgamma, $
;; TRAJECTORY
                   TRAJVERT  = trajvert,  TRAJPOINTS = trajpoints, $
                   TRAJCOLOR = trajcolor, TRAJTHICK  = trajthick, $
                   TRAJSTYLE = trajstyle, TRAJLEN    = trajlen, $
;                   TRAJMARK  = trajmark,  TRAJSYM    = trajsym, $
;; VECTORS
                   VECCOLOR=veccolor, DVEC=dvec, MAXLENVEC=maxlenvec, $
                   LENVEC=lenvec, VECSIZE=vecsize, $
                   _EXTRA=_extra
;+
; NAME:
;	HIL_IMG1P2CUT
;
; PURPOSE: HIgh Level IMaGe 1 Plus 2 CUT is a function for plotting cut
;       throught 3 major planes defined by center of the cut (parameters
;       R[X|Y|Z])
;
; CATEGORY:
;	High-Level
;
; INPUTS:
;	data:  3 dimensional array (for example magnitude of B field)
;
; OPTIONAL INPUTS:
;	vx,vy,vz:  3 dimensional arrays (for example x,y,z component of vector)
;
; KEYWORD PARAMETERS:
;
;       TRAJMARK - (integer) whem TRAJVERT keyword is given TRAJMARK is
;                  optional parameter which draw a mark (circle, cross, ...)
;                  defined by TRAJSYM every TRAJMARK data of TRAJVERT
;
;	TRAJSYM - defines what symbol to draw when TRAJMARK is specified (see
;                 PSYM keyword for allowed values)
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
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
;	vv = sqrt( vecx(*,*,*)^2 + vecy(*,*,*)^2 + vecz(*,*,*)^2 )
;
;       HIL_IMG1P2CUT, vv, vecx, vecy, vecz, $
;       	DX=0.4, DY=1., DZ=1., CTABLE=22, XRANGE=[-1,3], RX=0.4, $
;		RY=0.5, CTGAMMA=.3, CTHIGH=250, SCALE=12.5, ZMAX=6., PLANET=1, $
;		UNIT='R_{\rm M}', ZTITLE=ztitle, DVEC=.24, LENVEC=.2, $
;		MAXLENVEC=.35, VECSIZE=-.1
;
;
; MODIFICATION HISTORY:
;
;       Fri Jan 11 13:58:43 2008, Jan Paral <jparal@gmail.com>
;
;		Added DESC, DSCCOLOR and DSCCHARSIZE keywords for plotting
;		descriptions. Make possible trajvert to by array of pointers
;		since sometimes we need trajectories to be with different
;		length
;-
  nparam = N_PARAMS()

  UTL_CHECK_SIZE, data, ss=[3]

  IF N_ELEMENTS(dx)  EQ 0 THEN dx=1.0
  IF N_ELEMENTS(dy)  EQ 0 THEN dy=1.0
  IF N_ELEMENTS(dz)  EQ 0 THEN dz=1.0
  IF N_ELEMENTS(rx)  EQ 0 THEN rx=0.5
  IF N_ELEMENTS(ry)  EQ 0 THEN ry=0.5
  IF N_ELEMENTS(rz)  EQ 0 THEN rz=0.5
  IF N_ELEMENTS(units)  EQ 0 THEN units=''

  ss=size(data)

  bxy = reform(data[*,*,ss(3)*rz])
  bxz = reform(data[*,ss(2)*ry,*])
  byz = reform(data[ss(1)*rx,*,*])
  byz = dat_congrid(byz,ss(1),ss(2),resin=[dy,dz],resout=[dx,dy])

  IF (nparam EQ 4) THEN BEGIN
     UTL_CHECK_SIZE, data, vx, vy, vz
     vv = SQRT(vx^2 + vy^2 + vz^2)

     xvxy = reform(vx[*,*,ss(2)*rz])
     yvxy = reform(vy[*,*,ss(2)*rz])
     avxy = reform(vv[*,*,ss(2)*rz])

     xvxz = reform(vx[*,ss(2)*ry,*])
     yvxz = reform(vz[*,ss(2)*ry,*])
     avxz = reform(vv[*,ss(2)*ry,*])

     xvyz = reform(vy[ss(1)*rx,*,*])
     yvyz = reform(vz[ss(1)*rx,*,*])
     avyz = reform(vv[ss(1)*rx,*,*])
     xvyz = dat_congrid(xvyz,ss(1),ss(2),resin=[dy,dz],resout=[dx,dy])
     yvyz = dat_congrid(yvyz,ss(1),ss(2),resin=[dy,dz],resout=[dx,dy])
     avyz = dat_congrid(avyz,ss(1),ss(2),resin=[dy,dz],resout=[dx,dy])
  ENDIF

  IF NOT(KEYWORD_SET(xnoticks)) THEN BEGIN
     xtitle1='{TEX}$X [' + units + ']${TEX}'
     xtitle2='{TEX}$X [' + units + ']${TEX}'
     xtitle3='{TEX}$Y [' + units + ']${TEX}'
  ENDIF
  IF NOT(KEYWORD_SET(ynoticks)) THEN BEGIN
     ytitle1='{TEX}$Y [' + units + ']${TEX}'
     ytitle2='{TEX}$Z [' + units + ']${TEX}'
  ENDIF

  IF KEYWORD_SET(trajvert) THEN BEGIN
     UTL_CHECK_SIZE, trajvert, SMIN=[2,3], SMAX=[3,3]
     sstrj = SIZE(trajvert)
     IF (sstrj(0) EQ 3) THEN BEGIN
        trajvert1 = FLTARR(2,sstrj(2),sstrj(3))
        trajvert2 = FLTARR(2,sstrj(2),sstrj(3))
        trajvert3 = FLTARR(2,sstrj(2),sstrj(3))
        trajvert1 = trajvert[0:1,*,*]
        trajvert2[0,*,*] = trajvert[0,*,*]
        trajvert2[1,*,*] = trajvert[2,*,*]
        trajvert3 = trajvert[1:2,*,*]
     ENDIF ELSE BEGIN
        trajvert1 = FLTARR(2,sstrj(2))
        trajvert2 = trajvert1
        trajvert3 = trajvert1
        trajvert1 = trajvert[0:1,*]
        trajvert2[0,*] = trajvert[0,*]
        trajvert2[1,*] = trajvert[2,*]
        trajvert3 = trajvert[1:2,*]
     ENDELSE
  ENDIF

  PLT_IMG1P2, bxy, bxz, byz, MARGIN=.01, ZMIN=zmin, ZMAX=zmax, $
              CTABLE=ctable,CTLOW=ctlow, CTHIGH=cthigh, CTGAMMA=ctgamma, $
              DX=dx, DY=dy, RX=rx, RY=ry, R3X=rz, SCALE=scale, PLANET=planet, $
              XNOTICKS=xnoticks, YNOTICKS=ynoticks, $
              XRANGE=xrange, YRANGE=yrange, $
              XTITLE1=xtitle1, XTITLE2=xtitle2, XTITLE3=xtitle3, $
              YTITLE1=ytitle1, YTITLE2=ytitle2, ZTITLE=ztitle, $
              XVEC1=xvxy, YVEC1=yvxy, AVEC1=avxy, $
              XVEC2=xvxz, YVEC2=yvxz, AVEC2=avxz, $
              XVEC3=xvyz, YVEC3=yvyz, AVEC3=avyz, $
              VECCOLOR=veccolor, DVEC=dvec, MAXLENVEC=maxlenvec, $
              LENVEC=lenvec, VECSIZE=vecsize, $
              TRAJVERT1 = trajvert1, TRAJPOINTS1 = trajpoints1, $
              TRAJVERT2 = trajvert2, TRAJPOINTS2 = trajpoints2, $
              TRAJVERT3 = trajvert3, TRAJPOINTS3 = trajpoints3, $
              TRAJCOLOR = trajcolor, TRAJTHICK   = trajthick, $
              TRAJSTYLE = trajstyle, TRAJLEN = trajlen, $
              DESC=desc, DSCCOLOR=dsccolor, DSCCHARSIZE=dsccharsize, $
              PS=PS, _EXTRA=_extra

END
