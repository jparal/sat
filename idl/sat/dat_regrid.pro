function dat_regrid, arr

; Function regrid data between intelaced <=> vertex and return the result
;
; HISTORY:
;
; - v.0.3.0 2007-05-24 Jan Paral
;    Initial version (forked from stw_arr_ext_grid.pro)

s=size(arr,/type)
if (s(0) eq 0) then MESSAGE, 'Wrong type argument'
s=size(arr)

;; 'arr' is just 3D data array
IF (s(0) EQ 3) THEN BEGIN

   nx=s(1)
   ny=s(2)
   nz=s(3)
   nx1=nx+1
   ny1=ny+1
   nz1=nz+1
   nxm1=nx-1
   nym1=ny-1
   nzm1=nz-1

   arrout=fltarr(nx1,ny1,nz1)

   arrout(1:nxm1,1:nym1,1:nzm1) = 0.125 * $
                   (arr (0:nxm1-1, 0:nym1-1, 0:nzm1-1) + $
                    arr (1:nxm1,   0:nym1-1, 0:nzm1-1) + $
                    arr (0:nxm1-1, 1:nym1,   0:nzm1-1) + $
                    arr (1:nxm1,   1:nym1,   0:nzm1-1) + $
                    arr (0:nxm1-1, 0:nym1-1, 1:nzm1) + $
                    arr (1:nxm1,   0:nym1-1, 1:nzm1) + $
                    arr (0:nxm1-1, 1:nym1,   1:nzm1) + $
                    arr (1:nxm1,   1:nym1,   1:nzm1))

  ;-------------------------------------------------------------;
  ; Keep the first derivative at the boundary. This makes sure  ;
  ; that move to interlaced grid will keep original valuse at   ;
  ; boundary points.                                            ;
  ;-------------------------------------------------------------;
  arrout(0,1:nym1,1:nzm1)  = arr(0,1:nym1,1:nzm1) $
    + 0.5 * (arr(0,1:nym1,1:nzm1)   -arr(1,1:nym1,1:nzm1))
  arrout(nx,1:nym1,1:nzm1) = arr(nxm1,1:nym1,1:nzm1) $
    + 0.5 * (arr(nxm1,1:nym1,1:nzm1)-arr(nxm1-1,1:nym1,1:nzm1))

  arrout(1:nxm1,0,1:nzm1) = arr(1:nxm1,0,1:nzm1) $
    + 0.5 * (arr(1:nxm1,0,1:nzm1)   -arr(1:nxm1,1,1:nzm1))
  arrout(1:nxm1,ny,1:nzm1) = arr(1:nxm1,nym1,1:nzm1) $
    + 0.5 * (arr(1:nxm1,nym1,1:nzm1) -arr(1:nxm1,nym1-1,1:nzm1))

  arrout(1:nxm1,1:nym1,0) = arr(1:nxm1,1:nym1,0) $
    + 0.5 * (arr(1:nxm1,1:nym1,0) - arr(1:nxm1,1:nym1,1))
  arrout(1:nxm1,1:nym1,nz) = arr(1:nxm1,1:nym1,nzm1) $
    + 0.5 * (arr(1:nxm1,1:nym1,nzm1) - arr(1:nxm1,1:nym1,nzm1-1))

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

  RETURN, arrout

ENDIF

IF (s(0) EQ 4) THEN BEGIN

  nx=s(1)
  ny=s(2)
  nz=s(3)
  nx1=nx+1
  ny1=ny+1
  nz1=nz+1
  nxm1=nx-1
  nym1=ny-1
  nzm1=nz-1

  arrout=fltarr(nx1,ny1,nz1,3)

  arrout(1:nxm1,1:nym1,1:nzm1,*) = 0.125 * $
                   (arr (0:nxm1-1, 0:nym1-1, 0:nzm1-1, *) + $
                    arr (1:nxm1,   0:nym1-1, 0:nzm1-1, *) + $
                    arr (0:nxm1-1, 1:nym1,   0:nzm1-1, *) + $
                    arr (1:nxm1,   1:nym1,   0:nzm1-1, *) + $
                    arr (0:nxm1-1, 0:nym1-1, 1:nzm1, *) + $
                    arr (1:nxm1,   0:nym1-1, 1:nzm1, *) + $
                    arr (0:nxm1-1, 1:nym1,   1:nzm1, *) + $
                    arr (1:nxm1,   1:nym1,   1:nzm1, *))

  ;-------------------------------------------------------------;
  ; Keep the first derivative at the boundary. This makes sure  ;
  ; that move to interlaced grid will keep original valuse at   ;
  ; boundary points.                                            ;
  ;-------------------------------------------------------------;
  arrout(0,1:nym1,1:nzm1,*) = arr(0,1:nym1,1:nzm1,*) $
    + 0.5 * (arr(0,1:nym1,1:nzm1,*)   -arr(1,1:nym1,1:nzm1,*))
  arrout(nx,1:nym1,1:nzm1,*) = arr(nxm1,1:nym1,1:nzm1,*) $
    + 0.5 * (arr(nxm1,1:nym1,1:nzm1,*)-arr(nxm1-1,1:nym1,1:nzm1,*))

  arrout(1:nxm1,0,1:nzm1,*) = arr(1:nxm1,0,1:nzm1,*) $
    + 0.5 * (arr(1:nxm1,0,1:nzm1,*)   -arr(1:nxm1,1,1:nzm1,*))
  arrout(1:nxm1,ny,1:nzm1,*) = arr(1:nxm1,nym1,1:nzm1,*) $
    + 0.5 * (arr(1:nxm1,nym1,1:nzm1,*) -arr(1:nxm1,nym1-1,1:nzm1,*))

  arrout(1:nxm1,1:nym1,0,*) = arr(1:nxm1,1:nym1,0,*) $
    + 0.5 * (arr(1:nxm1,1:nym1,0,*) - arr(1:nxm1,1:nym1,1,*))
  arrout(1:nxm1,1:nym1,nz,*) = arr(1:nxm1,1:nym1,nzm1,*) $
    + 0.5 * (arr(1:nxm1,1:nym1,nzm1,*) - arr(1:nxm1,1:nym1,nzm1-1,*))

  arrout(0, 0, 0,*) = (arrout(1, 0, 0,*) $
                     + arrout(0, 1, 0,*) $
                     + arrout(0, 0, 1,*)) / 3.0
  arrout(nx,0, 0,*) = (arrout(nxm1, 0, 0,*) $
                     + arrout(nx,   1, 0,*) $
                     + arrout(nx,   0, 1,*)) / 3.0
  arrout(0, ny,0,*) = (arrout(1, ny, 0,*) $
                     + arrout(0, nym1, 0,*) $
                     + arrout(0, ny, 1,*)) / 3.0
  arrout(nx,ny,0,*) = (arrout(nxm1, ny, 0,*) $
                     + arrout(nx, nym1, 0,*) $
                     + arrout(nx, ny, 1,*)) / 3.0
  arrout(0, 0, nz,*) = (arrout(1, 0, nz,*) $
                      + arrout(0, 1, nz,*) $
                      + arrout(0, 0, nzm1,*)) / 3.0
  arrout(nx,0, nz,*) = (arrout(nxm1, 0, nz,*) $
                      + arrout(nx,   1, nz,*) $
                      + arrout(nx,   0, nzm1,*)) / 3.0
  arrout(0, ny,nz,*) = (arrout(1, ny, nz,*) $
                      + arrout(0, nym1, nz,*) $
                      + arrout(0, ny, nzm1,*)) / 3.0
  arrout(nx,ny,nz,*) = (arrout(nxm1, ny, nz,*) $
                      + arrout(nx, nym1, nz,*) $
                      + arrout(nx, ny, nzm1,*)) / 3.0
  RETURN, arrout

ENDIF ELSE BEGIN
   MESSAGE, 'Function support 3D data array of vectors only!!'
ENDELSE

   RETURN, -1
END

;--------------------------------------------------------------------;

