;--------------------------------------------------------------------;
; CALCULATE ROT(INVEC) ON AN INTERLACED GRID. RETURNS SELLECTED      ;
; COMPONENTS AS (VECX, VECY, VECZ).                                  ;
;                                                                    ;
; TODO:                                                              ;
;                                                                    ;
; + Need to optimize: try to use k1, k2,..., k8 and reform           ;
;   (it does not work: see "stw_rotv2").                             ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 02/2006, v.0.5.29: Messaging revised.                            ;
; - 12/2006, v.0.5.25: Written.                                      ;
;--------------------------------------------------------------------;
pro stw_rotv, invecx, invecy, invecz, $
  dx=dx, dy=dy, dz=dz, $
  vecx=vecx, vecy=vecy, vecz=vecz, help=help

;--------------------------------------------------------------------;
; 1) PRINT OUT THE USAGE STORY                                       ;
;--------------------------------------------------------------------;
if stw_keyword_set(help) then begin
  print, ' Usage:'
  print
  print, ' IDL> stw_b, bx=bx,by=by,bz=bz,/reload,run,itt,dir=dir'
  print, ' IDL> stw_arr_ext_grid, bx, bx1'
  print, ' IDL> stw_arr_ext_grid, by, by1'
  print, ' IDL> stw_arr_ext_grid, bz, bz1'
  print, ' IDL> stw_rotv, bx1,by1,bz1, dx=0.4, vecx=rbx, vecy=rby, vecz=rbz'
  print
  return
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

svx=size(invecx)
svy=size(invecy)
svz=size(invecz)

if ((svx(0) ne 3) or $
    (svy(0) ne 3) or $
    (svz(0) ne 3)) then begin
  print, 'stw_rotv: ERROR: An input componet dimensionality != 3 (return)'
  return
endif

if ((svx(1) ne svy(1)) or $
    (svy(1) ne svz(1)) or $
    (svz(1) ne svx(1))) then begin
  print, 'stw_rotv: ERROR: Input componets have not compatible size in X-dimension'
  return
endif

if ((svx(2) ne svy(2)) or $
    (svy(2) ne svz(2)) or $
    (svz(2) ne svx(2))) then begin
  print, 'stw_rotv: ERROR: Input componets have not compatible size in Y-dimension'
  return
endif

if ((svx(3) ne svy(3)) or $
    (svy(3) ne svz(3)) or $
    (svz(3) ne svx(3))) then begin
  print, 'stw_rotv: ERROR: Input componets have not compatible size in Z-dimension'
  return
endif

;--------------------------------------------------------------------;
; 3) CALCULATE rot B                                                 ;
;                                                                    ;
; rot B array will be returned on interlaced grid with respect to    ;
; the grid of the input B. Hence, if you wish to know rot B on the   ;
; same grid, as the input data, use the "arr_ext_grid" (see HELP)    ;
; on all three B components before using this subroutine.            ;
;--------------------------------------------------------------------;
nx=svx(1)
ny=svx(2)
nz=svx(3)

nxm1=nx-1
nym1=ny-1
nzm1=nz-1

nxm2=nx-2
nym2=ny-2
nzm2=nz-2

vecx=fltarr(nxm1,nym1,nzm1)
vecy=fltarr(nxm1,nym1,nzm1)
vecz=fltarr(nxm1,nym1,nzm1)

dxiq = 0.25 / dx;
dyiq = 0.25 / dy;
dziq = 0.25 / dz;

for iz=0,nzm2 do begin

  izp1 = iz+1

  for iy=0,nym2 do begin

    iyp1 = iy+1

    for ix=0,nxm2 do begin

      ixp1 = ix+1

      dbxdy = dyiq * (invecx(ixp1,iyp1,izp1) + $
                      invecx(ix,iyp1,izp1) -   $
                      invecx(ix,iy,izp1) -     $
                      invecx(ixp1,iy,izp1) +   $
                      invecx(ixp1,iyp1,iz) +   $
                      invecx(ix,iyp1,iz) -     $
                      invecx(ix,iy,iz) -       $
                      invecx(ixp1,iy,iz))
      dbxdz = dziq * (invecx(ix,iy,izp1) +     $
                      invecx(ixp1,iy,izp1) +   $
                      invecx(ixp1,iyp1,izp1) + $
                      invecx(ix,iyp1,izp1) -   $
                      invecx(ix,iy,iz) -       $
                      invecx(ixp1,iy,iz) -     $
                      invecx(ixp1,iyp1,iz) -   $
                      invecx(ix,iyp1,iz))
      dbydx = dxiq * (invecy(ixp1,iy,izp1) +   $
                      invecy(ixp1,iyp1,izp1) - $
                      invecy(ix,iy,izp1) -     $
                      invecy(ix,iyp1,izp1) +   $
                      invecy(ixp1,iyp1,iz) -   $
                      invecy(ix,iyp1,iz) +     $
                      invecy(ixp1,iy,iz) -     $
                      invecy(ix,iy,iz))
      dbydz = dziq * (invecy(ix,iy,izp1) +     $
                      invecy(ixp1,iy,izp1) +   $
                      invecy(ixp1,iyp1,izp1) + $
                      invecy(ix,iyp1,izp1) -   $
                      invecy(ix,iy,iz) -       $
                      invecy(ixp1,iy,iz) -     $
                      invecy(ixp1,iyp1,iz) -   $
                      invecy(ix,iyp1,iz))
      dbzdx = dxiq * (invecz(ixp1,iy,izp1) +   $
                      invecz(ixp1,iyp1,izp1) - $
                      invecz(ix,iy,izp1) -     $
                      invecz(ix,iyp1,izp1) +   $
                      invecz(ixp1,iyp1,iz) -   $
                      invecz(ix,iyp1,iz) +     $
                      invecz(ixp1,iy,iz) -     $
                      invecz(ix,iy,iz))
      dbzdy = dyiq * (invecz(ixp1,iyp1,izp1) + $
                      invecz(ix,iyp1,izp1) -   $
                      invecz(ix,iy,izp1) -     $
                      invecz(ixp1,iy,izp1) +   $
                      invecz(ixp1,iyp1,iz) +   $
                      invecz(ix,iyp1,iz) -     $
                      invecz(ix,iy,iz) -       $
                      invecz(ixp1,iy,iz))

      vecx (ix,iy,iz) = dbzdy - dbydz
      vecy (ix,iy,iz) = dbxdz - dbzdx
      vecz (ix,iy,iz) = dbydx - dbxdy
    endfor
  endfor
endfor

return
end

;--------------------------------------------------------------------;
