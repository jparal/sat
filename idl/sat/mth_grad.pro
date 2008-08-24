function mth_grad, sca, dx=dx, dy=dy, dz=dz

; ON INTERLACE GRID!!!

s=size(sca,/type)
if (s(0) eq 0) then return, -1
s=size(sca)
dim=s(0)

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0
if (dx lt 0.0001) then dx = 1.0
if (dy lt 0.0001) then dy = 1.0
if (dz lt 0.0001) then dz = 1.0

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
  dxiq = 0.25/dx
  dyiq = 0.25/dy
  dziq = 0.25/dz
  grad = fltarr(nxm1,nym1,nzm1,3)
  grad(0:nxm2,0:nym2,0:nzm2,0) = $
      dxiq * (sca(1:nxm1,1:nym1,1:nzm1) - $
              sca(0:nxm2,1:nym1,1:nzm1) + $
              sca(1:nxm1,0:nym2,1:nzm1) - $
              sca(0:nxm2,0:nym2,1:nzm1) + $
              sca(1:nxm1,1:nym1,0:nzm2) - $
              sca(0:nxm2,1:nym1,0:nzm2) + $
              sca(1:nxm1,0:nym2,0:nzm2) - $
              sca(0:nxm2,0:nym2,0:nzm2))
  grad(0:nxm2,0:nym2,0:nzm2,1) = $
      dyiq * (sca(1:nxm1,1:nym1,1:nzm1) + $
              sca(0:nxm2,1:nym1,1:nzm1) - $
              sca(1:nxm1,0:nym2,1:nzm1) - $
              sca(0:nxm2,0:nym2,1:nzm1) + $
              sca(1:nxm1,1:nym1,0:nzm2) + $
              sca(0:nxm2,1:nym1,0:nzm2) - $
              sca(1:nxm1,0:nym2,0:nzm2) - $
              sca(0:nxm2,0:nym2,0:nzm2))
  grad(0:nxm2,0:nym2,0:nzm2,2) = $
      dziq * (sca(1:nxm1,1:nym1,1:nzm1) + $
              sca(0:nxm2,1:nym1,1:nzm1) + $
              sca(1:nxm1,0:nym2,1:nzm1) + $
              sca(0:nxm2,0:nym2,1:nzm1) - $
              sca(1:nxm1,1:nym1,0:nzm2) - $
              sca(0:nxm2,1:nym1,0:nzm2) - $
              sca(1:nxm1,0:nym2,0:nzm2) - $
              sca(0:nxm2,0:nym2,0:nzm2))
  return, grad
endif

if (dim eq 2) then begin
endif

return, -1
end