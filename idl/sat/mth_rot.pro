function mth_rot, arg, $
  dx=dx, dy=dy, dz=dz, help=help

;--------------------------------------------------------------------;
; CALCULATE ROT(INVEC) ON AN INTERLACED GRID.
;
; HISTORY:
;
; - 02/2007, v.0.5.30: Rewritten.
;--------------------------------------------------------------------;

;--------------------------------------------------------------------;
; 1) PRINT OUT THE USAGE STORY                                       ;
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
  print, ' Usage:'
  print
  print, ' IDL> b=fltarr(nx+1,ny+1,nz+1,3)
  print, ' IDL> stw_b, bx=bx,by=by,bz=bz,/reload,run,itt,dir=dir'
  print, ' IDL> stw_arr_ext_grid, bx, b(*,*,*,0)'
  print, ' IDL> stw_arr_ext_grid, by, b(*,*,*,1)'
  print, ' IDL> stw_arr_ext_grid, bz, b(*,*,*,2)'
  print, ' IDL> rot = stw_rot(b, dx=0.4)'
  print
  return, -1
endif

;--------------------------------------------------------------------;
; 2) CHECK INPUT PARAMETERS                                          ;
;--------------------------------------------------------------------;
if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0

if (dx le 0.0) then dx=1.0
if (dy le 0.0) then dy=1.0
if (dz le 0.0) then dz=1.0

s=size(arg)
if (s(0) ne 4) then return, -1 else dim = s(0)-1

;--------------------------------------------------------------------;
; 3) CALCULATE ROT(arg)                                              ;
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

  outarr=fltarr(nxm1,nym1,nzm1,3)

  ; aux1:  dbz/dy
  ; aux2:  dby/dz
  aux1 = dyiq * (arg(1:nxm1,1:nym1,1:nzm1,2) + $
                 arg(0:nxm2,1:nym1,1:nzm1,2) - $
                 arg(1:nxm1,0:nym2,1:nzm1,2) - $
                 arg(0:nxm2,0:nym2,1:nzm1,2) + $
                 arg(1:nxm1,1:nym1,0:nzm2,2) + $
                 arg(0:nxm2,1:nym1,0:nzm2,2) - $
                 arg(1:nxm1,0:nym2,0:nzm2,2) - $
                 arg(0:nxm2,0:nym2,0:nzm2,2))
  aux2 = dziq * (arg(1:nxm1,1:nym1,1:nzm1,1) + $
                 arg(0:nxm2,1:nym1,1:nzm1,1) + $
                 arg(1:nxm1,0:nym2,1:nzm1,1) + $
                 arg(0:nxm2,0:nym2,1:nzm1,1) - $
                 arg(1:nxm1,1:nym1,0:nzm2,1) - $
                 arg(0:nxm2,1:nym1,0:nzm2,1) - $
                 arg(1:nxm1,0:nym2,0:nzm2,1) - $
                 arg(0:nxm2,0:nym2,0:nzm2,1))

  outarr(*,*,*,0) = aux1 - aux2

  ; aux1:  dbx/dz
  ; aux2:  dbz/dx
  aux1 = dziq * (arg(1:nxm1,1:nym1,1:nzm1,0) + $
                 arg(0:nxm2,1:nym1,1:nzm1,0) + $
                 arg(1:nxm1,0:nym2,1:nzm1,0) + $
                 arg(0:nxm2,0:nym2,1:nzm1,0) - $
                 arg(1:nxm1,1:nym1,0:nzm2,0) - $
                 arg(0:nxm2,1:nym1,0:nzm2,0) - $
                 arg(1:nxm1,0:nym2,0:nzm2,0) - $
                 arg(0:nxm2,0:nym2,0:nzm2,0))
  aux2 = dxiq * (arg(1:nxm1,1:nym1,1:nzm1,2) - $
                 arg(0:nxm2,1:nym1,1:nzm1,2) + $
                 arg(1:nxm1,0:nym2,1:nzm1,2) - $
                 arg(0:nxm2,0:nym2,1:nzm1,2) + $
                 arg(1:nxm1,1:nym1,0:nzm2,2) - $
                 arg(0:nxm2,1:nym1,0:nzm2,2) + $
                 arg(1:nxm1,0:nym2,0:nzm2,2) - $
                 arg(0:nxm2,0:nym2,0:nzm2,2))

  outarr(*,*,*,1) = aux1 - aux2

  ; aux1:  dby/dx
  ; aux2:  dbx/dy
  aux1 = dxiq * (arg(1:nxm1,1:nym1,1:nzm1,1) - $
                 arg(0:nxm2,1:nym1,1:nzm1,1) + $
                 arg(1:nxm1,0:nym2,1:nzm1,1) - $
                 arg(0:nxm2,0:nym2,1:nzm1,1) + $
                 arg(1:nxm1,1:nym1,0:nzm2,1) - $
                 arg(0:nxm2,1:nym1,0:nzm2,1) + $
                 arg(1:nxm1,0:nym2,0:nzm2,1) - $
                 arg(0:nxm2,0:nym2,0:nzm2,1))
  aux2 = dyiq * (arg(1:nxm1,1:nym1,1:nzm1,0) + $
                 arg(0:nxm2,1:nym1,1:nzm1,0) - $
                 arg(1:nxm1,0:nym2,1:nzm1,0) - $
                 arg(0:nxm2,0:nym2,1:nzm1,0) + $
                 arg(1:nxm1,1:nym1,0:nzm2,0) + $
                 arg(0:nxm2,1:nym1,0:nzm2,0) - $
                 arg(1:nxm1,0:nym2,0:nzm2,0) - $
                 arg(0:nxm2,0:nym2,0:nzm2,0))

  outarr(*,*,*,2) = aux1 - aux2

endif

return, outarr
end

;--------------------------------------------------------------------;
