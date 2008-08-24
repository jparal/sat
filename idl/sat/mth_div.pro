;--------------------------------------------------------------------;
; CALCULATE DIV(ARG) ON AN INTERLACED GRID.                          ;
;                                                                    ;
; HISTORY:                                                           ;
; - v.0.3.0 2007-05-24 Jan Paral                                     ;
;    Initial version (forked from stw_div.pro)                       ;
;--------------------------------------------------------------------;
function mth_div, arg, dx=dx, dy=dy, dz=dz, help=help

;--------------------------------------------------------------------;
; 1) PRINT OUT THE USAGE STORY                                       ;
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
  print, ' Usage:'
  print
  print, ' IDL> b=fltarr(nx+1,ny+1,nz+1,3)'
  print, ' IDL> stw_b, bx=bx,by=by,bz=bz,/reload,run,itt,dir=dir'
  print, ' IDL> stw_arr_ext_grid, bx, b(*,*,*,0)'
  print, ' IDL> stw_arr_ext_grid, by, b(*,*,*,1)'
  print, ' IDL> stw_arr_ext_grid, bz, b(*,*,*,2)'
  print, ' IDL> div = stw_div(b, dx=0.4)'
  print
  return, -1
endif

;--------------------------------------------------------------------;
; 2) CHECK INPUT PARAMETERS                                          ;
;--------------------------------------------------------------------;
IF (N_ELEMENTS(dx) EQ 0) THEN dx=1.0
IF (N_ELEMENTS(dy) EQ 0) THEN dy=1.0
IF (N_ELEMENTS(dz) EQ 0) THEN dz=1.0

if (dx le 0.0) then dx=1.0
if (dy le 0.0) then dy=1.0
if (dz le 0.0) then dz=1.0

s=size(arg)
if (s(0) lt 2) then return, -1
if (s(0) le 4) then dim = s(0)-1

;--------------------------------------------------------------------;
; 3) CALCULATE DIV(arg)                                              ;
;                                                                    ;
; DIV(arg) array will be returned on interlaced grid with respect to ;
; the grid of the input "arg". Hence, if you wish to know DIV(arg)   ;
; on the same grid, as the input data, use the "arr_ext_grid"        ;
; (see HELP) on all components of the input array "arg" before       ;
; using this subroutine.                                             ;
;--------------------------------------------------------------------;
if (dim eq 3) then begin

  nx=s(1)
  ny=s(2)
  nz=s(3)
  nxm1=nx-1
  nym1=ny-1
  nzm1=nz-1
  nxm2=nx-2
  nym2=ny-2
  nzm2=nz-2

  dxiq = 0.25 / dx;
  dyiq = 0.25 / dy;
  dziq = 0.25 / dz;

  outarr=fltarr(nxm1,nym1,nzm1)

  outarr(0:nxm2,0:nym2,0:nzm2) $
    = dxiq * (arg(1:nxm1,1:nym1,1:nzm1,0) - $
              arg(0:nxm2,1:nym1,1:nzm1,0) + $
              arg(1:nxm1,0:nym2,1:nzm1,0) - $
              arg(0:nxm2,0:nym2,1:nzm1,0) + $
              arg(1:nxm1,1:nym1,0:nzm2,0) - $
              arg(0:nxm2,1:nym1,0:nzm2,0) + $
              arg(1:nxm1,0:nym2,0:nzm2,0) - $
              arg(0:nxm2,0:nym2,0:nzm2,0))  $
    + dyiq * (arg(1:nxm1,1:nym1,1:nzm1,1) + $
              arg(0:nxm2,1:nym1,1:nzm1,1) - $
              arg(1:nxm1,0:nym2,1:nzm1,1) - $
              arg(0:nxm2,0:nym2,1:nzm1,1) + $
              arg(1:nxm1,1:nym1,0:nzm2,1) + $
              arg(0:nxm2,1:nym1,0:nzm2,1) - $
              arg(1:nxm1,0:nym2,0:nzm2,1) - $
              arg(0:nxm2,0:nym2,0:nzm2,1))  $
    + dziq * (arg(1:nxm1,1:nym1,1:nzm1,2) + $
              arg(0:nxm2,1:nym1,1:nzm1,2) + $
              arg(1:nxm1,0:nym2,1:nzm1,2) + $
              arg(0:nxm2,0:nym2,1:nzm1,2) - $
              arg(1:nxm1,1:nym1,0:nzm2,2) - $
              arg(0:nxm2,1:nym1,0:nzm2,2) - $
              arg(1:nxm1,0:nym2,0:nzm2,2) - $
              arg(0:nxm2,0:nym2,0:nzm2,2))

  return, outarr

endif

if (dim eq 2) then begin

  nx=s(1)
  ny=s(2)
  nxm1=nx-1
  nym1=ny-1
  nxm2=nx-2
  nym2=ny-2

  dxiq = 0.5 / dx;
  dyiq = 0.5 / dy;

  outarr=fltarr(nxm1,nym1)

  outarr(0:nxm2,0:nym2) $
    = dxiq * (arg(1:nxm1,1:nym1,0) - $
              arg(0:nxm2,1:nym1,0) + $
              arg(1:nxm1,0:nym2,0) - $
              arg(0:nxm2,0:nym2,0))  $
    + dyiq * (arg(1:nxm1,1:nym1,1) + $
              arg(0:nxm2,1:nym1,1) - $
              arg(1:nxm1,0:nym2,1) - $
              arg(0:nxm2,0:nym2,1))
endif

return, -1
end

;--------------------------------------------------------------------;
