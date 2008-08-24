;--------------------------------------------------------------------;
; CALCULATE DIV(ARG) ON AN INTERLACED GRID.                          ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 02/2007, v.0.5.30: Derived from "stw_rotv.pro".                  ;
;--------------------------------------------------------------------;
function stw_div_old, arg, dx=dx, dy=dy, dz=dz, help=help

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
  print, ' IDL> div = stw_div(b, dx=0.4)'
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

  for iz=0,nzm2 do begin

    izp1 = iz+1

    for iy=0,nym2 do begin

      iyp1 = iy+1

      for ix=0,nxm2 do begin

        ixp1 = ix+1

        dargdx = dxiq * (arg(ixp1,iyp1,izp1,0) - $
                         arg(ix,  iyp1,izp1,0) + $
                         arg(ixp1,iy,  izp1,0) - $
                         arg(ix,  iy,  izp1,0) + $
                         arg(ixp1,iyp1,iz,0) -   $
                         arg(ix,  iyp1,iz,0) +   $
                         arg(ixp1,iy,  iz,0) -   $
                         arg(ix,  iy,  iz,0))
        dargdy = dyiq * (arg(ixp1,iyp1,izp1,1) + $
                         arg(ix,  iyp1,izp1,1) - $
                         arg(ixp1,iy,  izp1,1) - $
                         arg(ix,  iy,  izp1,1) + $
                         arg(ixp1,iyp1,iz,1) +   $
                         arg(ix,  iyp1,iz,1) -   $
                         arg(ixp1,iy,  iz,1) -   $
                         arg(ix,  iy,  iz,1))
        dargdz = dziq * (arg(ixp1,iyp1,izp1,2) + $
                         arg(ix,  iyp1,izp1,2) + $
                         arg(ixp1,iy,  izp1,2) + $
                         arg(ix,  iy,  izp1,2) - $
                         arg(ixp1,iyp1,iz,2) -   $
                         arg(ix,  iyp1,iz,2) -   $
                         arg(ixp1,iy,  iz,2) -   $
                         arg(ix,  iy,  iz,2))

        outarr (ix,iy,iz) = dargdx + dargdy + dargdz

      endfor
    endfor

    print, strcompress('stw_div: '+string(float(iz)/float(nzm2)*100.0) $
           +' percent done')

  endfor

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

  for iy=0,nym2 do begin

    iyp1 = iy+1

    for ix=0,nxm2 do begin

      ixp1 = ix+1

      dargdx = dxiq * (arg(ixp1,iyp1,0) - $
                       arg(ix,  iyp1,0) + $
                       arg(ixp1,iy,  0) - $
                       arg(ix,  iy,  0))
      dargdy = dyiq * (arg(ixp1,iyp1,1) + $
                       arg(ix,  iyp1,1) - $
                       arg(ixp1,iy,  1) - $
                       arg(ix,  iy,  1))

      outarr (ix,iy) = dargdx + dargdy

    endfor
  endfor

endif

return, -1
end

;--------------------------------------------------------------------;
