;
   pro is, filename,nx,dnx,ny,dny,nz,dnz, dn, bx,by, bz,ux,uy,uz 
   iunit=6
   b=sqrt(bx^2+by^2+bz^2)
   ix=0
   for k=0, nx-1,dnx do ix=ix+1
   iy=0
   for k=0, ny-1,dny do iy=iy+1
   iz=0
   for k=0, nz-1,dnz do iz=iz+1

   openw, iunit, filename
  printf,iunit,'define mesh hyb_mesh'
  printf,iunit,' mesh_topology hyb_topy'
  printf,iunit,' mesh_grid hyb_grid'
  printf,iunit,'  '
  printf,iunit,'define reg_grid hyb_grid'
  printf,iunit,'  grid_samp ',ix,iy,iz
  printf,iunit,'  origin -3 -3 -3 '
  printf,iunit,'  step 0.2 0.2 0.2 '
  printf,iunit,'  '
  printf,iunit,'define reg_topology hyb_topy'
  printf,iunit,'   elem_samp ',ix-1,iy-1,iz-1
  printf,iunit,'  '
  printf,iunit,'define volume den '
  printf,iunit,'    volume_mesh hyb_mesh '
  printf,iunit,'    volume_vdata dn '
  printf,iunit,' '
  printf,iunit,'define volume  B_x'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata bx'
  printf,iunit,' '
  printf,iunit,'define volume  B_y'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata by'
  printf,iunit,' '
  printf,iunit,'define volume  B_z'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata bz'
  printf,iunit,' '
  printf,iunit,'define volume  v_x'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  vx'
  printf,iunit,'   '
  printf,iunit,'define volume  v_y'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  vy'
  printf,iunit,'   '
  printf,iunit,'define volume  v_z'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  vz'
  printf,iunit,'   '
  printf,iunit,' define volume  b_2'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  b2'
  printf,iunit,'   '
  printf,iunit,'define vdata 8 dn  bx by bz vx vy vz b2 ',ix*iy*iz  
;
   for k=0, nz-1,dnz do begin
     for j=0, ny-1,dny do begin
       for i= 0, nx-1,dnx do begin 
 printf,Format='(8F)', iunit,dn(i,j,k),bx(i,j,k), by(i,j,k), bz(i,j,k),$
 ux(i,j,k), uy(i,j,k), uz(i,j,k),b(i,j,k)
       endfor
     endfor
   endfor
   close, iunit
   return
   end                       
