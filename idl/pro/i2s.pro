; WAVE output to filename of dn  b(3) Jx Jy Jz bm qx
; with files(nx0:nx1:dnx,0:ny-1:dny,0:nz-1:dnz)
pro i2s, filename,nx0,nx1,dnx,ny,dny,nz,dnz,dx,dy,dz, dn, bx,by, bz,qx 
   iunit=6
   rot,dx,dy,dz,bx,by, bz, jx, jy, jz
   jx=reform(jx(*,1:*,1:*))
   jy=reform(jy(*,1:*,1:*))
   jz=reform(jz(*,1:*,1:*))
   dn=1/8.*(dn +shift(dn,1,0,0) +shift(dn,0,1,0) +shift(dn,0,0,1)   $
       +shift(dn,0,1,1) +shift(dn,1,0,1) +shift(dn,1,1,0) +shift(dn,1,1,1))
   bx=1/8.*(bx +shift(bx,1,0,0) +shift(bx,0,1,0) +shift(bx,0,0,1)   $
       +shift(bx,0,1,1) +shift(bx,1,0,1) +shift(bx,1,1,0) +shift(bx,1,1,1))
   by=1/8.*(by +shift(by,1,0,0) +shift(by,0,1,0) +shift(by,0,0,1)   $
       +shift(by,0,1,1) +shift(by,1,0,1) +shift(by,1,1,0) +shift(by,1,1,1))
   bz=1/8.*(bz +shift(bz,1,0,0) +shift(bz,0,1,0) +shift(bz,0,0,1)   $
       +shift(bz,0,1,1) +shift(bz,1,0,1) +shift(bz,1,1,0) +shift(bz,1,1,1))
   qx=1/8.*(qx +shift(qx,1,0,0) +shift(qx,0,1,0) +shift(qx,0,0,1)   $
       +shift(qx,0,1,1) +shift(qx,1,0,1) +shift(qx,1,1,0) +shift(qx,1,1,1))
   qx=qx(1:*,1:*,1:*)
   dn=dn(1:*,1:*,1:*)
   bx=bx(1:*,1:*,1:*)
   by=by(1:*,1:*,1:*)
   bz=bz(1:*,1:*,1:*)
b=sqrt(bx^2+by^2+bz^2)
   ix=0
   for k=nx0,nx1,dnx do ix=ix+1
   iy=0
   for k=0, ny-2,dny do iy=iy+1
   iz=0
   for k=0, nz-2,dnz do iz=iz+1

   openw, iunit, filename
  printf,iunit,'define mesh hyb_mesh'
  printf,iunit,' mesh_topology hyb_topy'
  printf,iunit,' mesh_grid hyb_grid'
  printf,iunit,'  '
  printf,iunit,'define reg_grid hyb_grid'
  printf,iunit,'  grid_samp ',ix,iy,iz
  printf,iunit,'  origin -3 -3 -3 '
  printf,iunit,'  step 0.08 0.2 0.2 '
  printf,iunit,'  '
  printf,iunit,'define reg_topology hyb_topy'
  printf,iunit,'   elem_samp ',ix-1,iy-1,iz-1
  printf,iunit,'  '
  printf,iunit,'define volume den '
  printf,iunit,'    volume_mesh hyb_mesh '
  printf,iunit,'    volume_vdata dn '
  printf,iunit,' '
  printf,iunit,'define volume  B_vec'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata b'
  printf,iunit,' '
  printf,iunit,'define volume  cour_x'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  Jx'
  printf,iunit,'define volume  cour_y'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  Jy'
  printf,iunit,' define volume  cour_z'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  Jz'
  printf,iunit,'   '
  printf,iunit,' define volume  bmag'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  bm'
  printf,iunit,'   '
  printf,iunit,' define volume  hflux'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  qx'
  printf,iunit,'   '
  printf,iunit,'define vdata 7 dn  b(3) Jx Jy Jz bm qx ',ix*iy*iz  

;
   for k=0, nz-2,dnz do begin
     for j=0, ny-2,dny do begin
       for i= nx0,nx1,dnx do begin 
 printf,Format='(9F)', iunit,dn(i,j,k),bx(i,j,k), by(i,j,k), bz(i,j,k),$
 jx(i,j,k), jy(i,j,k), jz(i,j,k), b(i,j,k),$
qx(i,j,k)
       endfor
     endfor
   endfor
   close, iunit
   return
   end                       
