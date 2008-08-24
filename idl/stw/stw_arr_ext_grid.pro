pro stw_arr_ext_grid, arrin, arrout, help=help

;---------------------------------------------------------------------
; HISTORY:
;
; - 09/2006, v.0.5.15: Written.
;---------------------------------------------------------------------
if stw_keyword_set(help) then begin
  print, ' Usage:'
  print
  print, ' IDL> stw_arr_ext_grid, arrin, arrout'
  print
  return
endif

ss=size(arrin)
ssout=size(arrout,/type)

if (ss(0) eq 1) then begin
endif
if (ss(0) eq 2) then begin
endif

if (ss(0) eq 3) then begin

  nx=ss(1)
  ny=ss(2)
  nz=ss(3)
  nx1=nx+1
  ny1=ny+1
  nz1=nz+1
  nxm1=nx-1
  nym1=ny-1
  nzm1=nz-1

  arrout=fltarr(nx1,ny1,nz1)

;---------------------------------------------------------------------
; DO NOT USE LOOPS! THEY ARE INCREDIBLY SLOW!
;
; for iz=1,nzm1 do begin
; for iy=1,nym1 do begin
; for ix=1,nxm1 do begin
;   arrout(ix,iy,iz) = 0.125 * (arrin (ix-1,iy-1,iz-1) $
;                             + arrin (ix,iy-1,iz-1)   $
;                             + arrin (ix-1,iy,  iz-1) $
;                             + arrin (ix,iy  ,iz-1)   $
;                             + arrin(ix-1,iy-1,iz)    $
;                             + arrin(ix,iy-1,iz)      $
;                             + arrin(ix-1,iy,  iz)    $
;                             + arrin(ix,iy,  iz))
; endfor
; endfor
; endfor
;---------------------------------------------------------------------
  arrout(1:nxm1,1:nym1,1:nzm1) = 0.125 * $
                   (arrin (0:nxm1-1, 0:nym1-1, 0:nzm1-1) + $
                    arrin (1:nxm1,   0:nym1-1, 0:nzm1-1) + $
                    arrin (0:nxm1-1, 1:nym1,   0:nzm1-1) + $
                    arrin (1:nxm1,   1:nym1,   0:nzm1-1) + $
                    arrin (0:nxm1-1, 0:nym1-1, 1:nzm1) + $
                    arrin (1:nxm1,   0:nym1-1, 1:nzm1) + $
                    arrin (0:nxm1-1, 1:nym1,   1:nzm1) + $
                    arrin (1:nxm1,   1:nym1,   1:nzm1))

  ;-------------------------------------------------------------;
  ; Keep the first derivative at the boundary. This makes sure  ;
  ; that move to interlaced grid will keep original valuse at   ;
  ; boundary points.                                            ;
  ;-------------------------------------------------------------;
  arrout(0,1:nym1,1:nzm1)  = arrin(0,1:nym1,1:nzm1) $
    + 0.5 * (arrin(0,1:nym1,1:nzm1)   -arrin(1,1:nym1,1:nzm1))
  arrout(nx,1:nym1,1:nzm1) = arrin(nxm1,1:nym1,1:nzm1) $
    + 0.5 * (arrin(nxm1,1:nym1,1:nzm1)-arrin(nxm1-1,1:nym1,1:nzm1))

  arrout(1:nxm1,0,1:nzm1) = arrin(1:nxm1,0,1:nzm1) $
    + 0.5 * (arrin(1:nxm1,0,1:nzm1)   -arrin(1:nxm1,1,1:nzm1))
  arrout(1:nxm1,ny,1:nzm1) = arrin(1:nxm1,nym1,1:nzm1) $
    + 0.5 * (arrin(1:nxm1,nym1,1:nzm1) -arrin(1:nxm1,nym1-1,1:nzm1))

  arrout(1:nxm1,1:nym1,0) = arrin(1:nxm1,1:nym1,0) $
    + 0.5 * (arrin(1:nxm1,1:nym1,0) - arrin(1:nxm1,1:nym1,1))
  arrout(1:nxm1,1:nym1,nz) = arrin(1:nxm1,1:nym1,nzm1) $
    + 0.5 * (arrin(1:nxm1,1:nym1,nzm1) - arrin(1:nxm1,1:nym1,nzm1-1))

  arrout(0, 0, 0) = ( arrout(1, 0, 0) $
                    + arrout(0, 1, 0) $
                    + arrout(0, 0, 1) ) / 3.0
  arrout(nx,0, 0) = ( arrout(nxm1, 0, 0) $
                    + arrout(nx,   1, 0) $
                    + arrout(nx,   0, 1) ) / 3.0
  arrout(0, ny,0) = ( arrout(1, ny, 0) $
                    + arrout(0, nym1, 0) $
                    + arrout(0, ny, 1) ) / 3.0
  arrout(nx,ny,0) = ( arrout(nxm1, ny, 0) $
                    + arrout(nx, nym1, 0) $
                    + arrout(nx, ny, 1) ) / 3.0
  arrout(0, 0, nz) = ( arrout(1, 0, nz) $
                     + arrout(0, 1, nz) $
                     + arrout(0, 0, nzm1) ) / 3.0
  arrout(nx,0, nz) = ( arrout(nxm1, 0, nz) $
                     + arrout(nx,   1, nz) $
                     + arrout(nx,   0, nzm1) ) / 3.0
  arrout(0, ny,nz) = ( arrout(1, ny, nz) $
                     + arrout(0, nym1, nz) $
                     + arrout(0, ny, nzm1) ) / 3.0
  arrout(nx,ny,nz) = ( arrout(nxm1, ny, nz) $
                     + arrout(nx, nym1, nz) $
                     + arrout(nx, ny, nzm1) ) / 3.0
endif

return
end

;--------------------------------------------------------------------;
